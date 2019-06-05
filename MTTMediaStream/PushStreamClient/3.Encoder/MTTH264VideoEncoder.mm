//
//  MTTH264VideoEncoder.m
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/5.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTH264VideoEncoder.h"
#import "MTTVideoFrame.h"
#import <CoreMedia/CoreMedia.h>
#import <mach/mach_time.h>
#import "MTTNALUnit.h"
#import "MTTAVEncoder.h"



@interface MTTH264VideoEncoder(){
    FILE *fp;
    NSInteger frameCount;
    BOOL enabledWirteVideoFile;
}

@property (nonatomic, strong) MTTLiveVideoConfiguration *configuration;
@property (nonatomic, weak) id<MTTVideoEncodeDelegate>h264Delegate;
@property (nonatomic, assign) BOOL isBackground;
@property (nonatomic, assign) NSInteger currentVideoBitRate;
@property (nonatomic, strong) dispatch_queue_t sendQueue;
@property (nonatomic, strong) MTTAVEncoder *encoder;

@property (nonatomic, strong) NSData *naluStartCode;
@property (nonatomic, strong) NSMutableData *videoSPSAndPPS;
@property (nonatomic, strong) NSMutableData *spsData;
@property (nonatomic, strong) NSMutableData *ppsData;
@property (nonatomic, strong) NSMutableData *sei;
@property (nonatomic, assign) CMTimeScale timeSacle;
@property (nonatomic, strong) NSMutableArray *orphanedFrames;
@property (nonatomic, strong) NSMutableArray *orphanedSEIFrames;
@property (nonatomic, assign) CMTime lastPTS;


@end


@implementation MTTH264VideoEncoder

- (instancetype)initWithVideoStreamConfiguration:(MTTLiveVideoConfiguration *)configuration {
    if (self = [super init]) {
        _configuration = configuration;
        
    }
    return self;
}

- (void)initCompressionSession {
    _sendQueue = dispatch_queue_create("cn.waitwalker.h264.sendFrame", DISPATCH_QUEUE_SERIAL);
    [self initializeNALUnitStartCode];
    
    _lastPTS = kCMTimeInvalid;
    _timeSacle = 1000;
    frameCount = 0;
#if DEBUG
    enabledWirteVideoFile = false;
    [self initForFilePath];
#endif
    
    _encoder = [MTTAVEncoder encoderForHeight:(int)_configuration.videoSize.height andWidth:(int)_configuration.videoSize.width bitrate:(int)_configuration.videoBitRate];
    [_encoder encodeWithBlock:^int(NSArray *data, CMTimeValue ptsValue) {
        [self ];
        return 0;
    } onParams:^int(NSData *params) {
        [self ];
        return 0;
    }];
}

- (void)initializeNALUnitStartCode {
    NSUInteger naluLength = 4;
    uint8_t *nalu = (uint8_t *)malloc(naluLength * sizeof(uint8_t));
    nalu[0] = 0x00;
    nalu[1] = 0x00;
    nalu[2] = 0x00;
    nalu[3] = 0x00;
    _naluStartCode = [NSData dataWithBytesNoCopy:nalu length:naluLength freeWhenDone:true];
}

- (void)initForFilePath {
    NSString *path = [self getFilePathByFileName:@"iOSCameraDemo.H264"];
    NSLog(@"%@",path);
}

- (NSString *)getFilePathByFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *writablePath = [documentDirectory stringByAppendingPathComponent:fileName];
    return writablePath;
}

- (void)incomingVideoFrames:(NSArray *)frames ptsValue:(CMTimeValue)ptsValue {
    if (ptsValue == 0) {
        [self addOrphanedFramesFromArray:frames];
        return;
    }
    
    if (!_videoSPSAndPPS) {
        [self generateSPSAndPPS];
    }
    
    CMTime pts = CMTimeMake(ptsValue, _timeSacle);
    if (self.orphanedFrames.count > 0) {
        CMTime ptsDiff = CMTimeSubtract(pts, _lastPTS);
        NSUInteger orphanedFramesCount = self.orphanedFrames.count;
        for (NSData *frame in self.orphanedFrames) {
            CMTime fakePTSDiff = CMTimeMultiplyByFloat64(ptsDiff, 1.0 / (orphanedFramesCount + 1));
            CMTime fakePTS = CMTimeAdd(_lastPTS, fakePTSDiff);
        }
    }
}

- (void)addOrphanedFramesFromArray:(NSArray *)frames {
    for (NSData *data in frames) {
        unsigned char *pNal = (unsigned char *)[data bytes];
        int idc = pNal[0] & 0x60;
        int naltype = pNal[0] & 0x1f;
        if (idc == 0 && naltype == 6) {
            [self.orphanedSEIFrames addObject:data];
        } else {
            [self.orphanedSEIFrames addObject:data];
        }
    }
}

- (void)generateSPSAndPPS {
    NSData *config = _encoder.getConfigData;
    if (!config) {
        return;
    }
    MTTavcCHeader avcC((const BYTE *)[config bytes],(int)[config length]);
    MTTSeqParamSet seqParams;
    seqParams.Parse(avcC.sps());
    
    NSData *spsData = [NSData dataWithBytes:avcC.sps()->Start() length:avcC.sps()->Length()];
    NSData *ppsData = [NSData dataWithBytes:avcC.pps()->Start() length:avcC.pps()->Length()];
    
    _spsData = [NSMutableData dataWithCapacity:avcC.sps()->Length() + _naluStartCode.length];
    _ppsData = [NSMutableData dataWithCapacity:avcC.pps()->Length() + _naluStartCode.length];
    
    [_spsData appendData:_naluStartCode];
    [_spsData appendData:spsData];
    [_ppsData appendData:_naluStartCode];
    [_spsData appendData:ppsData];
    
    _videoSPSAndPPS = [NSMutableData dataWithCapacity:avcC.sps()->Length() + avcC.pps()->Length() + _naluStartCode.length * 2];
    [_videoSPSAndPPS appendData:_naluStartCode];
    [_videoSPSAndPPS appendData:spsData];
    [_videoSPSAndPPS appendData:_naluStartCode];
    [_videoSPSAndPPS appendData:ppsData];
}

- (void)writeVideoFrames:(NSArray *)frames pts:(CMTime)pts {
    NSMutableArray *totalFrames = [NSMutableArray array];
    if (self.orphanedSEIFrames.count > 0) {
        [totalFrames addObjectsFromArray:self.orphanedSEIFrames];
        [self.orphanedSEIFrames removeAllObjects];
    }
    [totalFrames addObjectsFromArray:frames];
    
    NSMutableData *aggregateFrameData = [NSMutableData data];
    
    for (NSData *data in totalFrames) {
        unsigned char *pNal = (unsigned char *)[data bytes];
        int idc = pNal[0] & 0x60;
        int naltype = pNal[0] & 0x1f;
        NSData *videoData = nil;
        
        if (idc == 0 && naltype == 6) {
            _sei = [NSMutableData dataWithData:data];
            continue;
        } else if (naltype == 5) {
            NSMutableData *IDRData = [NSMutableData dataWithData:_videoSPSAndPPS];
            if (_sei) {
                [IDRData appendData:_naluStartCode];
                [IDRData appendData:_sei];
                _sei = nil;
            }
            [IDRData appendData:_naluStartCode];
            [IDRData appendData:data];
            videoData = IDRData;
        } else {
            NSMutableData *regularData = [NSMutableData dataWithData:_naluStartCode];
            [regularData appendData:data];
            videoData = regularData;
        }
        [aggregateFrameData appendData:videoData];
        
        MTTVideoFrame *videoFrame = [MTTVideoFrame new];
        const char *dataBuffer = (const char *)aggregateFrameData.bytes;
        videoFrame.data = [NSMutableData dataWithBytes:dataBuffer + _naluStartCode.length length:aggregateFrameData.length - _naluStartCode.length];
        videoFrame.timeStamp = pts.value;
        videoFrame.isKeyFrame = (naltype == 5);
        videoFrame.sps = _spsData;
        videoFrame.pps = _ppsData;
        if (self.h264Delegate && [self.h264Delegate respondsToSelector:@selector(videoEncoder:videoFrame:)]) {
            [self.h264Delegate videoEncoder:self videoFrame:videoFrame];
        }
    }
    
    if (self->enabledWirteVideoFile) {
        fwrite(aggregateFrameData.bytes, 1, aggregateFrameData.length, self->fp);
    }
    
}

@end

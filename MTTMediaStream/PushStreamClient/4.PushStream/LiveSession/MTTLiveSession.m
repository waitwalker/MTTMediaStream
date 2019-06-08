//
//  MTTLiveSession.m
//  MTTMediaStream
//
//  Created by WangJunZi on 2019/6/6.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTLiveSession.h"
#import "MTTVideoCapture.h"
#import "MTTAudioCapture.h"
#import "MTTHardwareAudioEncoder.h"
#import "MTTHardwareVideoEncoder.h"
#import "MTTH264VideoEncoder.h"
#import "MTTStreamRTMPSocket.h"
#import "MTTGPUImageBeautyFilter.h"


@interface MTTLiveSession()<MTTAudioCaptureDelegate,MTTVideoCaptureDelegate,MTTAudioEncodeDelegate,MTTVideoEncodeDelegate,MTTStreamSocketDelegate>

// 视频配置
@property (nonatomic, strong) MTTLiveVideoConfiguration *videoConfiguration;
// 音频配置
@property (nonatomic, strong) MTTLiveAudioConfiguration *audioConfiguration;
// 视频采集对象
@property (nonatomic, strong) MTTVideoCapture *videoCaptureSource;
// 音频采集对象
@property (nonatomic, strong) MTTAudioCapture *audioCaptureSource;
// 音频编码器
@property (nonatomic, strong) id<MTTAudioEncodeInterface> audioEncoder;
// 视频编码器
@property (nonatomic, strong) id<MTTVideoEncodeInterface> videoEncoder;
// socket
@property (nonatomic, strong) id<MTTStreamSocketInterface> socket;

// debug
@property (nonatomic, strong) MTTLiveDebug *debugInfo;

// 流信息
@property (nonatomic, strong) MTTLiveStreamInfo *streamInfo;

// 是否正在上传
@property (nonatomic, assign) BOOL uploading;

// 直播状态
@property (nonatomic, assign, readwrite) MTTLiveState state;

// 采集类型
@property (nonatomic, assign, readwrite) MTTLiveCaptureTypeMask captureType;

// 同步锁
@property (nonatomic, strong) dispatch_semaphore_t lock;

// 相对时间戳
@property (nonatomic, assign) uint64_t relativeTimeStamps;

// 音视频是否对齐
@property (nonatomic, assign) BOOL AVAlignment;

// 是否采集到了音频
@property (nonatomic, assign) BOOL hasCaptureAudio;

// 是否采集到了视频关键帧
@property (nonatomic, assign) BOOL hasKeyFrameVideo;

@end

/**  时间戳 */
#define NOW (CACurrentMediaTime()*1000)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation MTTLiveSession

- (instancetype)initWithAudioConfiguration:(MTTLiveAudioConfiguration *)audioConfiguration videoConfiguration:(MTTLiveVideoConfiguration *)videoConfiguration {
    return [self initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration captureType:MTTLiveCaptureDefaultMask];
}

- (instancetype)initWithAudioConfiguration:(MTTLiveAudioConfiguration *)audioConfiguration videoConfiguration:(MTTLiveVideoConfiguration *)videoConfiguration captureType:(MTTLiveCaptureTypeMask)captureType {
    if ((captureType & MTTLiveCaptureMaskAudio || captureType & MTTLiveInputMaskVideo) && !audioConfiguration) {
        @throw [NSException exceptionWithName:@"MTTLiveSession init error" reason:@"audio configuration is nil" userInfo:nil];
    }

    if ((captureType & MTTLiveCaptureMaskVideo || captureType & MTTLiveInputMaskVideo) && !videoConfiguration) {
        @throw [NSException exceptionWithName:@"MTTLiveSession init error" reason:@"video configuration is nil" userInfo:nil];
    }

    if (self = [super init]) {
        _audioConfiguration = audioConfiguration;
        _videoConfiguration = videoConfiguration;
        _adaptiveBitRate = false;
        _captureType = captureType;
    }

    return self;
}

- (void)dealloc {
    _videoCaptureSource.running = false;
    _audioCaptureSource.running = false;
}

// MARK: - 开始直播
- (void)startLive:(MTTLiveStreamInfo *)streamInfo {
    if (!streamInfo) {
        return;
    }

    _streamInfo = streamInfo;
    _streamInfo.videoConfiguration = _videoConfiguration;
    _streamInfo.audioConfiguration = _audioConfiguration;
    [self.socket start];
}

// MARK: - 停止直播
- (void)stopLive {
    self.uploading = false;
    [self.socket stop];
    self.socket = nil;
}

// MARK: - 推送视频数据
- (void)pushVideo:(CVPixelBufferRef)pixelBuffer {
    if (self.captureType & MTTLiveInputMaskVideo) {
        if (self.uploading) {
            [self.videoEncoder encodeVideoData:pixelBuffer timeStamp:NOW];
        }
    }
}

// MARK: - 推送音频数据
- (void)pushAudio:(NSData *)audioData {
    if (self.captureType & MTTLiveCaptureMaskAudio) {
        if (self.uploading) {
            [self.audioEncoder encodeAudioData:audioData timeStamp:NOW];
        }
    }
}

// MARK: - 私有方法
- (void)pushSendBuffer:(MTTFrame *)frame {
    if (self.relativeTimeStamps == 0) {
        self.relativeTimeStamps = frame.timeStamp;
    }

    frame.timeStamp = [self uoloadTimeStamp:frame.timeStamp];
    [self.socket sendFrame:frame];
}

- (uint64_t)uoloadTimeStamp:(uint64_t)captureTimeStamp {
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    uint64_t currents = 0;
    currents = captureTimeStamp - self.relativeTimeStamps;
    dispatch_semaphore_signal(self.lock);
    return currents;
}

// MARK: - capture delegate
- (void)captureOutput:(MTTAudioCapture *)audioCapture audioData:(NSData *)audioData {
    if (self.uploading) {
        [self.audioEncoder encodeAudioData:audioData timeStamp:NOW];
    }
}

- (void)captureOutput:(MTTVideoCapture *)videoCapture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (self.uploading) {
        [self.videoEncoder encodeVideoData:pixelBuffer timeStamp:NOW];
    }
}

// MARK: - encoder delegate
- (void)audioEncoder:(id<MTTAudioEncodeInterface>)encoder audioFrame:(MTTAudioFrame *)frame {
    if (self.uploading) {
        self.hasCaptureAudio = true;
        if (self.AVAlignment) {
            [self pushSendBuffer:frame];
        }
    }
}

- (void)videoEncoder:(id<MTTVideoEncodeInterface>)encoder videoFrame:(MTTVideoFrame *)frame {
    if (self.uploading) {
        if (frame.isKeyFrame && self.hasCaptureAudio) {
            self.hasKeyFrameVideo = true;
        }

        if (self.AVAlignment) {
            [self pushSendBuffer:frame];
        }
    }
}

// MARK: - Stream Scoket delegate
- (void)socketStatus:(id<MTTStreamSocketInterface>)socket status:(MTTLiveState)status {
    if (status == MTTLiveStarted) {
        if (!self.uploading) {
            self.AVAlignment = false;
            self.hasCaptureAudio = false;
            self.hasKeyFrameVideo = false;
            self.relativeTimeStamps = 0;
            self.uploading = true;
        }
    } else if (status == MTTLiveStop || status == MTTLiveError) {
        self.uploading = false;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.state = status;
        if (self.delegate && [self.delegate respondsToSelector:@selector(liveSession:liveStateDidChange:)]) {
            [self.delegate liveSession:self liveStateDidChange:status];
        }
    });
}

- (void)socketDidError:(id<MTTStreamSocketInterface>)socket errorCode:(MTTLiveSocketErrorCode)errorCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(liveSession:errorCode:)]) {
            [self.delegate liveSession:self errorCode:errorCode];
        }
    });
}

- (void)socketDebug:(id<MTTStreamSocketInterface>)socket debugInfo:(MTTLiveDebug *)debugInfo {
    self.debugInfo = debugInfo;
    if (self.showDebugInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(liveSession:debugInfo:)]) {
                [self.delegate liveSession:self debugInfo:debugInfo];
            }
        });
    }
}

- (void)socketBufferStatus:(id<MTTStreamSocketInterface>)socket status:(MTTLiveBufferState)status {
    if ((self.captureType & MTTLiveCaptureMaskVideo || self.captureType & MTTLiveInputMaskVideo) && self.adaptiveBitRate) {
        NSUInteger videoBitRate = [self.videoEncoder videoBitRate];
        if (status == MTTLiveBufferDeclines) {
            if (videoBitRate < _videoConfiguration.videoBitRate) {
                videoBitRate = videoBitRate + 50 * 1000;
                [self.videoEncoder setVideoBitRate:videoBitRate];
                NSLog(@"Increase bitrate : %@",@(videoBitRate));
            }
        } else {
            if (videoBitRate > self.videoConfiguration.videoMinBitRate) {
                videoBitRate = videoBitRate - 100 * 1000;
                [self.videoEncoder setVideoBitRate:videoBitRate];
                NSLog(@"Decline bitrate :%@",@(videoBitRate));
            }
        }
    }
}

@end

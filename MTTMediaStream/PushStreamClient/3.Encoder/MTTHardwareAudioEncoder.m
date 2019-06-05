//
//  MTTHardwareAudioEncoder.m
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/5.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTHardwareAudioEncoder.h"

@interface MTTHardwareAudioEncoder(){
    AudioConverterRef m_converter;
    char *leftBuf;
    char *accBuf;
    NSInteger leftLength;
    FILE *fp;
    BOOL enabledWirteAudioFile;
}
@property (nonatomic, strong) MTTLiveAudioConfiguration *configuration;
@property (nonatomic, weak) id<MTTAudioEncodeDelegate>accDelegate;


@end

@implementation MTTHardwareAudioEncoder

- (instancetype)initWithAudioSteamConfiguration:(MTTLiveAudioConfiguration *)configuration {
    if (self = [super init]) {
        _configuration = configuration;
        if (!leftBuf) {
            leftBuf = malloc(_configuration.bufferLength);
        }
        if (!accBuf) {
            accBuf = malloc(_configuration.bufferLength);
        }
        
#if DEBUG
        enabledWirteAudioFile = false;
        [self initForFilePath];
#endif
        
        
    }
    return self;
}

- (void)dealloc {
    if (accBuf) {
        free(accBuf);
    }
    if (leftBuf) {
        free(leftBuf);
    }
}

- (void)setDelegate:(id<MTTAudioEncodeDelegate>)delegate {
    _accDelegate = delegate;
}

- (void)encodeAudioData:(NSData *)audioData timeStamp:(uint64_t)timeStamp {
    if (<#condition#>) {
        <#statements#>
    }
}

- (BOOL)createAudioConvert {
    if (m_converter != nil) {
        return true;
    }
    
    AudioStreamBasicDescription inputFormat = {0};
    inputFormat.mSampleRate = _configuration.audioSampleRate;
    inputFormat.mFormatID = kAudioFormatLinearPCM;
    inputFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    inputFormat.mChannelsPerFrame = (UInt32)_configuration.numberOfChannels;
    inputFormat.mFramesPerPacket = 1;
    inputFormat.mBitsPerChannel = 16;
    inputFormat.mBytesPerFrame = inputFormat.mBitsPerChannel / 8 * inputFormat.mChannelsPerFrame;
    inputFormat.mBytesPerPacket = inputFormat.mBytesPerFrame * inputFormat.mFramesPerPacket;
    
    // 输出音频格式
    AudioStreamBasicDescription outputFormat;
    memset(&outputFormat, 0, sizeof(outputFormat));
    outputFormat.mSampleRate = inputFormat.mSampleRate;//采样率保持一致
    outputFormat.mFormatID = kAudioFormatMPEG4AAC;//AAC 编码
    outputFormat.mChannelsPerFrame = (UInt32)_configuration.numberOfChannels;
    outputFormat.mFramesPerPacket = 1024;//AAC 一帧是1024字节
    const OSType subtype = kAudioFormatMPEG4AAC;
    AudioClassDescription requestCodecs[2] = {
        {
            kAudioEncoderComponentType,
            subtype,
            kAppleSoftwareAudioCodecManufacturer
        },
        {
            kAudioEncoderComponentType,
            subtype,
            kAppleHardwareAudioCodecManufacturer
        }
    };
    OSStatus result = AudioConverterNewSpecific(&inputFormat, &outputFormat, 2, requestCodecs, &m_converter);
    UInt32 outputBitrate = _configuration.audioBitRate;
    UInt32 propSize = sizeof(outputBitrate);
    if (result == noErr) {
        result = AudioConverterSetProperty(m_converter, kAudioConverterEncodeBitRate, propSize, &outputBitrate);
    }
    return true;
}

- (void)initForFilePath {
    NSString *path = [self getFilePathWithFileName:@"iOSAudioDemo.acc"];
    NSLog(@"%@",path);
    self->fp = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "wb");
}

- (NSString *)getFilePathWithFileName:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *writeabelPath = [documentDirectory stringByAppendingPathComponent:filename];
    return writeabelPath;
}

@end

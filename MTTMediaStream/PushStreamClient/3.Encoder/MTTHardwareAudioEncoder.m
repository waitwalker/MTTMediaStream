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

// MARK: - set delegate
- (void)setDelegate:(id<MTTAudioEncodeDelegate>)delegate {
    _accDelegate = delegate;
}

// MARK: - 开始音频编码
- (void)encodeAudioData:(NSData *)audioData timeStamp:(uint64_t)timeStamp {
    if (![self createAudioConvert]) {
        return;
    }
    
    if (leftLength + audioData.length >= self.configuration.bufferLength) {
        NSInteger totalSize = leftLength + audioData.length;
        NSInteger encodeCount = totalSize / self.configuration.bufferLength;
        char *totalBuf = malloc(totalSize);
        char *p = totalBuf;
        
        size_t nel = 0;
        memset(totalBuf, (int)totalSize, nel);
        memcpy(totalBuf, leftBuf, leftLength);
        memcpy(totalBuf + leftLength, audioData.bytes, audioData.length);
        
        for (NSInteger index = 0; index < encodeCount; index ++) {
            [self encodeBuffer:p timeStamp:timeStamp];
            p += self.configuration.bufferLength;
        }
        leftLength = totalSize % self.configuration.bufferLength;
        memset(leftBuf, 0, self.configuration.bufferLength);
        memcpy(leftBuf, totalBuf + (totalSize - leftLength), leftLength);
        free(totalBuf);
    } else {
        memcpy(leftBuf + leftLength, audioData.bytes, audioData.length);
        leftLength = leftLength + audioData.length;
    }
}

- (void)encodeBuffer:(char *)buf timeStamp:(uint64_t)timeStamp {
    AudioBuffer inBuffer;
    inBuffer.mNumberChannels = 1;
    inBuffer.mData = buf;
    inBuffer.mDataByteSize = (UInt32)self.configuration.bufferLength;
    
    AudioBufferList buffers;
    buffers.mNumberBuffers = 1;
    buffers.mBuffers[0] = inBuffer;
    
    AudioBufferList outBufferList;
    outBufferList.mNumberBuffers = 1;
    outBufferList.mBuffers[0].mNumberChannels = inBuffer.mNumberChannels;
    outBufferList.mBuffers[0].mDataByteSize = inBuffer.mDataByteSize;//设置缓冲区大小
    outBufferList.mBuffers[0].mData = accBuf;// 设置AAC缓冲区
    UInt32 outputDataPacketSize = 1;
    
    // 开始音频编码 编码后的回调在inputDataProc回调函数中
    if (AudioConverterFillComplexBuffer(m_converter, inputDataProc, &buffers, &outputDataPacketSize, &outBufferList, NULL) != noErr) {
        return;
    }
    
    MTTAudioFrame *audioFrame = [MTTAudioFrame new];
    audioFrame.timeStamp = timeStamp;
    audioFrame.data = [NSData dataWithBytes:accBuf length:outBufferList.mBuffers[0].mDataByteSize];
    
    char exeData[2];
    exeData[0] = _configuration.asc[0];
    exeData[1] = _configuration.asc[1];
    audioFrame.audioInfo = [NSData dataWithBytes:exeData length:2];
    
    if (self.accDelegate && [self.accDelegate respondsToSelector:@selector(audioEncoder:audioFrame:)]) {
        [self.accDelegate audioEncoder:self audioFrame:audioFrame];
    }
    
    if (self->enabledWirteAudioFile) {
        NSData *adts = [self adtsData:_configuration.numberOfChannels rawDataLength:audioFrame.data.length];
        fwrite(adts.bytes, 1, adts.length, self->fp);
        fwrite(audioFrame.data.bytes, 1, audioFrame.data.length, self->fp);
    }
}

OSStatus inputDataProc(AudioConverterRef inConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription * *outDataPacketDescription, void *inUserData){
    AudioBufferList bufferList = *(AudioBufferList *)inUserData;
    ioData->mBuffers[0].mNumberChannels = 1;
    ioData->mBuffers[0].mData = bufferList.mBuffers[0].mData;
    ioData->mBuffers[0].mDataByteSize = bufferList.mBuffers[0].mDataByteSize;
    return noErr;
}

// MARK: - 停止编码
- (void)stopEncoder {
    
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
    UInt32 outputBitrate = _configuration.audioBitrate;
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

- (NSData *)adtsData:(NSInteger)channel rawDataLength:(NSInteger)rawDataLength {
    int adtsLength = 7;
    char *packet = malloc(sizeof(char) * adtsLength);
    // Variables Recycled by addADTStoPacket
    int profile = 2;  //AAC LC
    //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
    NSInteger freqIdx = [self sampleRateIndex:self.configuration.audioSampleRate];  //44.1KHz
    int chanCfg = (int)channel;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
    NSUInteger fullLength = adtsLength + rawDataLength;
    // fill in ADTS data
    packet[0] = (char)0xFF;     // 11111111     = syncword
    packet[1] = (char)0xF9;     // 1111 1 00 1  = syncword MPEG-2 Layer CRC
    packet[2] = (char)(((profile-1)<<6) + (freqIdx<<2) +(chanCfg>>2));
    packet[3] = (char)(((chanCfg&3)<<6) + (fullLength>>11));
    packet[4] = (char)((fullLength&0x7FF) >> 3);
    packet[5] = (char)(((fullLength&7)<<5) + 0x1F);
    packet[6] = (char)0xFC;
    NSData *data = [NSData dataWithBytesNoCopy:packet length:adtsLength freeWhenDone:YES];
    return data;
}

- (NSInteger)sampleRateIndex:(NSInteger)frequencyInHz {
    NSInteger sampleRateIndex = 0;
    switch (frequencyInHz) {
        case 96000:
            sampleRateIndex = 0;
            break;
        case 88200:
            sampleRateIndex = 1;
            break;
        case 64000:
            sampleRateIndex = 2;
            break;
        case 48000:
            sampleRateIndex = 3;
            break;
        case 44100:
            sampleRateIndex = 4;
            break;
        case 32000:
            sampleRateIndex = 5;
            break;
        case 24000:
            sampleRateIndex = 6;
            break;
        case 22050:
            sampleRateIndex = 7;
            break;
        case 16000:
            sampleRateIndex = 8;
            break;
        case 12000:
            sampleRateIndex = 9;
            break;
        case 11025:
            sampleRateIndex = 10;
            break;
        case 8000:
            sampleRateIndex = 11;
            break;
        case 7350:
            sampleRateIndex = 12;
            break;
        default:
            sampleRateIndex = 15;
    }
    return sampleRateIndex;
}

@end

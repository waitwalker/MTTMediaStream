//
//  MTTLiveAudioConfiguration.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/5/28.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - 音频码率
typedef enum : NSUInteger {
    // 32Kps 音频码率
    MTTLiveAudioBitRate_32Kps = 32000,
    // 64Kps 音频码率
    MTTLiveAudioBitRate_64Kps = 64000,
    // 96Kps 音频码率
    MTTLiveAudioBitRate_96Kps = 96000,
    // 128Kps 音频码率
    MTTLiveAudioBitRate_128Kps = 128000,
    // 默认码率
    MTTLiveAudioBitRate_Default = MTTLiveAudioBitRate_96Kps
} MTTLiveAudioBitRate;

// MARK: - 音频采样率(默认44.1KHz)
typedef enum : NSUInteger {
    // 16KHz 采样率
    MTTLiveAudioSampleRate_16000Hz = 16000,
    // 44.1KHz 采样率
    MTTLiveAudioSampleRate_44100Hz = 44100,
    // 48KHz 采样率
    MTTLiveAudioSampleRate_48000Hz = 48000,
    // 默认采样率
    MTTLiveAudioSampleRate_Default = MTTLiveAudioSampleRate_44100Hz
} MTTLiveAudioSampleRate;

// MARK: - 音频质量
typedef enum : NSUInteger {
    // 低音频质量 audio sample rate:16KHz audio bitrate: numberOfChannels 1: 32Kbps 2:64Kbps
    MTTLiveAudioQuality_Low = 0,
    // 中音频l音频 audio sample rate:44.1KHz audio bitrate:96Kbps
    MTTLiveAudioQuality_Medium = 1,
    // 高音频质量 audio sample rate:44.1KHz audio bitrate:128Kbps
    MTTLiveAudioQuality_High = 2,
    // 超高音频质量 audio sample rate:48KHz audio bitrate:128Kbps
    MTTLiveAudioQuality_VeryHigh = 3,
    MTTLiveAudioQuality_Default = MTTLiveAudioQuality_High
} MTTLiveAudioQuality;

@interface MTTLiveAudioConfiguration : NSObject<NSCopying,NSCoding>


/**
 默认音频配置

 @return instance
 */
+ (instancetype)defaultConfiguration;


/**
 根据音频质量获取配置

 @param audioQuality 音频质量
 @return instance
 */
+ (instancetype)defaultConfigurationForQuality:(MTTLiveAudioQuality)audioQuality;

// 声道数目
@property (nonatomic, assign) NSUInteger numberOfChannels;

// 采样率
@property (nonatomic, assign) MTTLiveAudioSampleRate audioSampleRate;

// 码率
@property (nonatomic, assign) MTTLiveAudioBitRate audioBitRate;

// flv 编码音频头
@property (nonatomic, assign, readonly) char *asc;

// 缓冲区长度
@property (nonatomic, assign, readonly) NSUInteger bufferLength;

@end

NS_ASSUME_NONNULL_END

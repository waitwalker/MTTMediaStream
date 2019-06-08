//
//  LFLiveAudioConfiguration.h
//   
//
//  Created by waitwalker on 19/5/20.
//  Copyright © 2019年 waitwalker All rights reserved.
//

#import <Foundation/Foundation.h>

/// 音频码率 (默认96Kbps)
typedef NS_ENUM (NSUInteger, MTTLiveAudioBitRate) {
    /// 32Kbps 音频码率
    MTTLiveAudioBitRate_32Kbps = 32000,
    /// 64Kbps 音频码率
    MTTLiveAudioBitRate_64Kbps = 64000,
    /// 96Kbps 音频码率
    MTTLiveAudioBitRate_96Kbps = 96000,
    /// 128Kbps 音频码率
    MTTLiveAudioBitRate_128Kbps = 128000,
    /// 默认音频码率，默认为 96Kbps
    MTTLiveAudioBitRate_Default = MTTLiveAudioBitRate_96Kbps
};

/// 音频采样率 (默认44.1KHz)
typedef NS_ENUM (NSUInteger, MTTLiveAudioSampleRate){
    /// 16KHz 采样率
    MTTLiveAudioSampleRate_16000Hz = 16000,
    /// 44.1KHz 采样率
    MTTLiveAudioSampleRate_44100Hz = 44100,
    /// 48KHz 采样率
    MTTLiveAudioSampleRate_48000Hz = 48000,
    /// 默认音频采样率，默认为 44.1KHz
    MTTLiveAudioSampleRate_Default = MTTLiveAudioSampleRate_44100Hz
};

///  Audio Live quality（音频质量）
typedef NS_ENUM (NSUInteger, MTTLiveAudioQuality){
    /// 低音频质量 audio sample rate: 16KHz audio bitrate: numberOfChannels 1 : 32Kbps  2 : 64Kbps
    MTTLiveAudioQuality_Low = 0,
    /// 中音频质量 audio sample rate: 44.1KHz audio bitrate: 96Kbps
    MTTLiveAudioQuality_Medium = 1,
    /// 高音频质量 audio sample rate: 44.1MHz audio bitrate: 128Kbps
    MTTLiveAudioQuality_High = 2,
    /// 超高音频质量 audio sample rate: 48KHz, audio bitrate: 128Kbps
    MTTLiveAudioQuality_VeryHigh = 3,
    /// 默认音频质量 audio sample rate: 44.1KHz, audio bitrate: 96Kbps
    MTTLiveAudioQuality_Default = MTTLiveAudioQuality_High
};

@interface MTTLiveAudioConfiguration : NSObject<NSCoding, NSCopying>

/// 默认音频配置
+ (instancetype)defaultConfiguration;
/// 音频配置
+ (instancetype)defaultConfigurationForQuality:(MTTLiveAudioQuality)audioQuality;

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/// 声道数目(default 2)
@property (nonatomic, assign) NSUInteger numberOfChannels;
/// 采样率
@property (nonatomic, assign) MTTLiveAudioSampleRate audioSampleRate;
/// 码率
@property (nonatomic, assign) MTTLiveAudioBitRate audioBitrate;
/// flv编码音频头 44100 为0x12 0x10
@property (nonatomic, assign, readonly) char *asc;
/// 缓存区长度
@property (nonatomic, assign,readonly) NSUInteger bufferLength;

@end

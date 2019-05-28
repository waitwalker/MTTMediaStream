//
//  MTTLiveAudioConfiguration.m
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/5/28.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTLiveAudioConfiguration.h"

@implementation MTTLiveAudioConfiguration

+ (instancetype)defaultConfiguration {
    return [MTTLiveAudioConfiguration defaultConfigurationForQuality:MTTLiveAudioQuality_Default];
}

+ (instancetype)defaultConfigurationForQuality:(MTTLiveAudioQuality)audioQuality {
    MTTLiveAudioConfiguration *configuration = [[MTTLiveAudioConfiguration alloc]init];
    configuration.numberOfChannels = 2;
    switch (audioQuality) {
        case MTTLiveAudioQuality_Low:
            configuration.audioBitRate = configuration.numberOfChannels == 1 ? MTTLiveAudioBitRate_32Kps : MTTLiveAudioBitRate_64Kps;
            configuration.audioSampleRate = MTTLiveAudioSampleRate_16000Hz;
            break;
        case MTTLiveAudioQuality_Medium:
            configuration.audioBitRate = MTTLiveAudioBitRate_96Kps;
            configuration.audioSampleRate = MTTLiveAudioSampleRate_44100Hz;
            break;
        case MTTLiveAudioQuality_High:
            configuration.audioBitRate = MTTLiveAudioBitRate_128Kps;
            configuration.audioSampleRate = MTTLiveAudioSampleRate_44100Hz;
            break;
        case MTTLiveAudioQuality_VeryHigh:
            configuration.audioBitRate = MTTLiveAudioBitRate_128Kps;
            configuration.audioSampleRate = MTTLiveAudioSampleRate_48000Hz;
            break;
            
        default:
            configuration.audioBitRate = MTTLiveAudioBitRate_96Kps;
            configuration.audioSampleRate = MTTLiveAudioSampleRate_44100Hz;
            break;
    }
    return configuration;
}

- (instancetype)init {
    if (self = [super init]) {
        _asc = malloc(2);
    }
    return self;
}

- (void)dealloc {
    if (_asc) {
        free(_asc);
    }
}

// MARK: - setter getter 
- (void)setAudioSampleRate:(MTTLiveAudioSampleRate)audioSampleRate {
    _audioSampleRate = audioSampleRate;
    NSInteger sampleRateIndex = [self sampleRateIndex:audioSampleRate];
    self.asc[0] = 0x10 | ((sampleRateIndex >> 1)& 0x7);
    self.asc[1] = ((sampleRateIndex & 0x1)<<7) | ((self.numberOfChannels & 0xF)<< 3);
}

- (void)setNumberOfChannels:(NSUInteger)numberOfChannels {
    _numberOfChannels = numberOfChannels;
    NSInteger sampleRateIndex = [self sampleRateIndex:self.audioSampleRate];
    self.asc[0] = 0x10 | ((sampleRateIndex >> 1) & 0x7);
    self.asc[1] = ((sampleRateIndex & 0x1) << 7) | ((numberOfChannels & 0xF) << 3);
}

- (NSUInteger)bufferLength {
    return 1024 * 2 * self.numberOfChannels;
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
            sampleRateIndex = 12;
            break;
    }
    return sampleRateIndex;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone { 
    MTTLiveAudioConfiguration *configuration = [self.class defaultConfiguration];
    return configuration;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder { 
    [aCoder encodeObject:@(self.numberOfChannels) forKey:@"numberOfChannels"];
    [aCoder encodeObject:@(self.audioSampleRate) forKey:@"audioSampleRate"];
    [aCoder encodeObject:@(self.audioBitRate) forKey:@"audioBitRate"];
    [aCoder encodeObject:[NSString stringWithUTF8String:self.asc] forKey:@"asc"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder { 
    if (self = [super init]) {
        _numberOfChannels = [[aDecoder decodeObjectForKey:@"numberOfChannels"]unsignedIntegerValue];
        _audioSampleRate = [[aDecoder decodeObjectForKey:@"audioSampleRate"]unsignedIntegerValue];
        _audioBitRate = [[aDecoder decodeObjectForKey:@"audioBitRate"] unsignedIntegerValue];
        _asc = strdup([[aDecoder decodeObjectForKey:@"asc"]cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return true;
    }
    else if (![super isEqual:object]) {
        return false;
    } else {
        MTTLiveAudioConfiguration *obj = object;
        return obj.numberOfChannels == self.numberOfChannels &&
        obj.audioBitRate == self.audioBitRate && 
        strcmp(obj.asc, self.asc) == 0 && 
        obj.audioSampleRate == self.audioSampleRate;
    }
}

- (NSUInteger)hash {
    NSUInteger hash = 0;
    NSArray *values = @[@(_numberOfChannels),
                        @(_audioSampleRate),
                        [NSString stringWithUTF8String:self.asc],
                        @(_audioBitRate)
                        ];
    for (NSObject *value in values) {
        hash ^= value.hash;
    }
    return hash;
}

- (NSString *)description {
    NSMutableString *desc = @"".mutableCopy;
    [desc appendFormat:@"<MTTLiveAudioConfiguration: %p>",self];
    [desc appendFormat:@" numberOfChannels:%zi",self.numberOfChannels];
    [desc appendFormat:@" audioSampleRate:%zi",self.audioSampleRate];
    [desc appendFormat:@" audioBitRate:%zi",self.audioBitRate];
    [desc appendFormat:@" audioHeader:%@",[NSString stringWithUTF8String:self.asc]];
    return desc;
}

@end

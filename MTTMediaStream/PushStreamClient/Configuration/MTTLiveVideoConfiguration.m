//
//  MTTLiveVideoConfiguration.m
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/5/28.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTLiveVideoConfiguration.h"
#import <AVFoundation/AVFoundation.h>

@implementation MTTLiveVideoConfiguration

+ (instancetype)defaultConfiguration {
    return [MTTLiveVideoConfiguration defaultConfigurationForQuality:MTTLiveVideoQuality_Default];
}

+ (instancetype)defaultConfigurationForQuality:(MTTLiveVideoQuality)videoQuality {
    return [MTTLiveVideoConfiguration defaultConfigurationForQuality:videoQuality outputOrientation:UIInterfaceOrientationPortrait];
}

+ (instancetype)defaultConfigurationForQuality:(MTTLiveVideoQuality)videoQuality outputOrientation:(UIInterfaceOrientation)orientation {
    MTTLiveVideoConfiguration *configuration = [MTTLiveVideoConfiguration new];
    switch (videoQuality) {
        case MTTLiveVideoQuality_Low1:
            configuration.sessionPreset = MTTCaptureSessionPreset360x640;
            configuration.videoFrameRate = 15;
            configuration.videoMaxFrameRate = 15;
            configuration.videoMinFrameRate = 10;
            configuration.videoBitRate = 500 * 1000;
            configuration.videoMaxBitRate = 600 * 1000;
            configuration.videoMinBitRate = 400 * 1000;
            configuration.videoSize = CGSizeMake(360, 640);
            break;
        case MTTLiveVideoQuality_Low2:
            configuration.sessionPreset = MTTCaptureSessionPreset360x640;
            configuration.videoFrameRate = 24;
            configuration.videoMaxFrameRate = 24;
            configuration.videoMinFrameRate = 12;
            configuration.videoBitRate = 600 * 1000;
            configuration.videoMaxBitRate = 720 * 1000;
            configuration.videoMinBitRate = 500 * 1000;
            configuration.videoSize = CGSizeMake(360, 640);
            break;
        case MTTLiveVideoQuality_Low3:
            configuration.sessionPreset = MTTCaptureSessionPreset360x640;
            configuration.videoFrameRate = 30;
            configuration.videoMaxFrameRate = 30;
            configuration.videoMinFrameRate = 15;
            configuration.videoBitRate = 800 * 1000;
            configuration.videoMaxBitRate = 960 * 1000;
            configuration.videoMinBitRate = 600 * 1000;
            configuration.videoSize = CGSizeMake(360, 640);
            break;
            
        case MTTLiveVideoQuality_Medium1:
            configuration.sessionPreset = MTTCaptureSessionPreset540x960;
            configuration.videoFrameRate = 15;
            configuration.videoMaxFrameRate = 15;
            configuration.videoMinFrameRate = 10;
            configuration.videoBitRate = 800 * 1000;
            configuration.videoMaxBitRate = 960 * 1000;
            configuration.videoMinBitRate = 500 * 1000;
            configuration.videoSize = CGSizeMake(540, 960);
            break;
        case MTTLiveVideoQuality_Medium2:
            configuration.sessionPreset = MTTCaptureSessionPreset540x960;
            configuration.videoFrameRate = 24;
            configuration.videoMaxFrameRate = 24;
            configuration.videoMinFrameRate = 12;
            configuration.videoBitRate = 800 * 1000;
            configuration.videoMaxBitRate = 960 * 1000;
            configuration.videoMinBitRate = 500 * 1000;
            configuration.videoSize = CGSizeMake(540, 960);
            break;
        case MTTLiveVideoQuality_Medium3:
            configuration.sessionPreset = MTTCaptureSessionPreset540x960;
            configuration.videoFrameRate = 30;
            configuration.videoMaxFrameRate = 30;
            configuration.videoMinFrameRate = 15;
            configuration.videoBitRate = 1000 * 1000;
            configuration.videoMaxBitRate = 120 * 1000;
            configuration.videoMinBitRate = 500 * 1000;
            configuration.videoSize = CGSizeMake(540, 960);
            break;
        case MTTLiveVideoQuality_High1:
            configuration.sessionPreset = MTTCaptureSessionPreset720x1280;
            configuration.videoFrameRate = 15;
            configuration.videoMaxFrameRate = 15;
            configuration.videoMinFrameRate = 10;
            configuration.videoBitRate = 1000 * 1000;
            configuration.videoMaxBitRate = 1200 * 1000;
            configuration.videoMinBitRate = 500 * 1000;
            configuration.videoSize = CGSizeMake(720, 1280);
            break;
        case MTTLiveVideoQuality_High2:
            configuration.sessionPreset = MTTCaptureSessionPreset720x1280;
            configuration.videoFrameRate = 24;
            configuration.videoMaxFrameRate = 24;
            configuration.videoMinFrameRate = 12;
            configuration.videoBitRate = 1200 * 1000;
            configuration.videoMaxBitRate = 1440 * 1000;
            configuration.videoMinBitRate = 800 * 1000;
            configuration.videoSize = CGSizeMake(720, 1280);
            break;
        case MTTLiveVideoQuality_High3:
            configuration.sessionPreset = MTTCaptureSessionPreset720x1280;
            configuration.videoFrameRate = 30;
            configuration.videoMaxFrameRate = 30;
            configuration.videoMinFrameRate = 15;
            configuration.videoBitRate = 1200 * 1000;
            configuration.videoMaxBitRate = 1440* 1000;
            configuration.videoMinBitRate = 800 * 1000;
            configuration.videoSize = CGSizeMake(720, 1280);
            break;
            
        default:
            break;
    }
    configuration.sessionPreset = [configuration supportSessionPreset:configuration.sessionPreset];
    configuration.videoMaxKeyFrameInterval = configuration.videoFrameRate * 2;
    configuration.outputOrientation = orientation;
    CGSize size = configuration.videoSize;
    if (configuration.landscape) {
        configuration.videoSize = CGSizeMake(size.height, size.width);
    } else {
        configuration.videoSize = CGSizeMake(size.width, size.height);
    }
    return configuration;
}

- (MTTCaptureSessionPreset)supportSessionPreset:(MTTCaptureSessionPreset)sessionPreset {
    AVCaptureSession *session = [AVCaptureSession new];
    AVCaptureDevice *inputDevice;
    AVCaptureDeviceDiscoverySession *deviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    NSArray *devices = deviceDiscoverySession.devices;
    for (AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionFront) {
            inputDevice = device;
        }
    }
    
    NSError *error;
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:inputDevice error:&error];
    if (!error) {
        if ([session canAddInput:videoInput]) {
            [session addInput:videoInput];
        }
        
        if (![session canSetSessionPreset:self.avSessionPreset]) {
            if (sessionPreset == MTTCaptureSessionPreset720x1280) {
                sessionPreset = MTTCaptureSessionPreset540x960;
                if (![session canSetSessionPreset:self.avSessionPreset]) {
                    sessionPreset = MTTCaptureSessionPreset360x640;
                }
            } else if (sessionPreset == MTTCaptureSessionPreset540x960) {
                sessionPreset = MTTCaptureSessionPreset360x640;
            }
        } else {
            sessionPreset = MTTCaptureSessionPreset360x640;
        }
    }
    return sessionPreset;
}

// MARK: - setter getter
- (NSString *)avSessionPreset {
    NSString *avSessionPreset = nil;
    switch (self.sessionPreset) {
        case MTTCaptureSessionPreset360x640:
            avSessionPreset = AVCaptureSessionPreset640x480;
            break;
        case MTTCaptureSessionPreset540x960:
            avSessionPreset = AVCaptureSessionPresetiFrame960x540;
            break;
        case MTTCaptureSessionPreset720x1280:
            avSessionPreset = AVCaptureSessionPresetiFrame1280x720;
            break;
            
        default:
            avSessionPreset = AVCaptureSessionPreset640x480;
            break;
    }
    return avSessionPreset;
}

- (BOOL)landscape {
    return (self.outputOrientation == UIInterfaceOrientationLandscapeLeft || self.outputOrientation == UIInterfaceOrientationLandscapeRight) ? true : false;
}

- (CGSize)videoSize {
    if (_videoSizeRespectingAspectRatio) {
        return self.aspectRatioVideoSize;
    }
    return _videoSize;
}

- (void)setVideoMaxBitRate:(NSUInteger)videoMaxBitRate {
    if (videoMaxBitRate <= _videoBitRate) {
        return;
    }
    _videoMaxBitRate = videoMaxBitRate;
}

- (void)setVideoMinBitRate:(NSUInteger)videoMinBitRate {
    if (videoMinBitRate >= _videoBitRate) {
        return;
    }
    _videoMinBitRate = videoMinBitRate;
}

- (void)setVideoMaxFrameRate:(NSUInteger)videoMaxFrameRate {
    if (videoMaxFrameRate <= _videoFrameRate) {
        return;
    }
    _videoMaxFrameRate = videoMaxFrameRate;
}       

- (void)setVideoMinFrameRate:(NSUInteger)videoMinFrameRate {
    if (videoMinFrameRate >= _videoFrameRate) {
        return;
    }
    _videoMinFrameRate = videoMinFrameRate;
}

- (void)setSessionPreset:(MTTCaptureSessionPreset)sessionPreset {
    _sessionPreset = sessionPreset;
    _sessionPreset = [self supportSessionPreset:sessionPreset];
}

- (CGSize)captureOutVideoSize {
    CGSize videoSize = CGSizeZero;
    switch (_sessionPreset) {
        case MTTCaptureSessionPreset360x640:
            videoSize = CGSizeMake(360, 640);
            break;
        case MTTCaptureSessionPreset540x960:
            videoSize = CGSizeMake(540, 960);
            break;
        case MTTCaptureSessionPreset720x1280:
            videoSize = CGSizeMake(720, 1280);
            break;
        default:
            videoSize = CGSizeMake(360, 640);
            break;
    }
    if (self.landscape) {
        return CGSizeMake(videoSize.height, videoSize.width);
    }
    return videoSize;
}

- (CGSize)aspectRatioVideoSize {
    CGSize size = AVMakeRectWithAspectRatioInsideRect([self captureOutVideoSize], CGRectMake(0, 0, _videoSize.width, _videoSize.height)).size;
    NSInteger width = ceil(size.width);
    NSInteger height = ceil(size.height);
    if (width % 2 != 0) {
        width = width - 1;
    }
    if (height % 2 != 0) {
        height = height - 1;
    }
    return CGSizeMake(width, height);
}


- (nonnull id)copyWithZone:(nullable NSZone *)zone { 
    MTTLiveVideoConfiguration *copyConfiguration = [self.class defaultConfiguration];
    return copyConfiguration;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder { 
    [aCoder encodeObject:[NSValue valueWithCGSize:self.videoSize] forKey:@"videoSize"];
    [aCoder encodeObject:@(self.videoFrameRate) forKey:@"videoFrameRate"];
    [aCoder encodeObject:@(self.videoMaxFrameRate) forKey:@"videoMaxFrameRate"];
    [aCoder encodeObject:@(self.videoMinFrameRate) forKey:@"videoMinFrameRate"];
    [aCoder encodeObject:@(self.videoMaxKeyFrameInterval) forKey:@"videoNaxKeyFrameInterval"];
    [aCoder encodeObject:@(self.videoBitRate) forKey:@"videoBitRate"];
    [aCoder encodeObject:@(self.videoMaxBitRate) forKey:@"videoMaxBitRate"];
    [aCoder encodeObject:@(self.videoMinBitRate) forKey:@"videoMinBitRate"];
    [aCoder encodeObject:@(self.sessionPreset) forKey:@"sessionPreset"];
    [aCoder encodeObject:@(self.outputOrientation) forKey:@"outputOrientation"];
    [aCoder encodeObject:@(self.autorotate) forKey:@"autorotate"];
    [aCoder encodeObject:@(self.videoSizeRespectingAspectRatio) forKey:@"videoSizeRespectingAspectRatio"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder { 
    if (self = [super init]) {
        _videoSize = [[aDecoder decodeObjectForKey:@"videoSize"]CGSizeValue];
        _videoFrameRate = [[aDecoder decodeObjectForKey:@"videoFrameRate"] unsignedIntegerValue];
        _videoMaxBitRate = [[aDecoder decodeObjectForKey:@"videoMaxFrameRate"]unsignedIntegerValue];
        _videoMaxFrameRate = [[aDecoder decodeObjectForKey:@"videoMaxFrameRate"]unsignedIntegerValue];
        _videoMinFrameRate = [[aDecoder decodeObjectForKey:@"videoMinFrameRate"]unsignedIntegerValue];
        _videoBitRate = [[aDecoder decodeObjectForKey:@"videoBitRate"]unsignedIntegerValue];
        _videoMaxBitRate = [[aDecoder decodeObjectForKey:@"videoMaxBitRate"]unsignedIntegerValue];
        _videoMinBitRate = [[aDecoder decodeObjectForKey:@"videoMinBitRate"]unsignedIntegerValue];
        _sessionPreset = [[aDecoder decodeObjectForKey:@"sessionPreset"]unsignedIntegerValue];
        _outputOrientation = [[aDecoder decodeObjectForKey:@"outputOrientation"]unsignedIntegerValue];
        _autorotate = [[aDecoder decodeObjectForKey:@"autorate"]boolValue];
        _videoSizeRespectingAspectRatio = [[aDecoder decodeObjectForKey:@"videoSizeRespectingAspectRatio"]unsignedIntegerValue];
    }
    return self;
}

- (NSUInteger)hash {
    NSUInteger hash = 0;
    NSArray *values = @[[NSValue valueWithCGSize:self.videoSize],
                        @(self.videoFrameRate),
                        @(self.videoMaxFrameRate),
                        @(self.videoMinFrameRate),
                        @(self.videoMaxKeyFrameInterval),
                        @(self.videoBitRate),
                        @(self.videoMaxBitRate),
                        @(self.videoMinBitRate),
                        self.avSessionPreset,
                        @(self.sessionPreset),
                        @(self.outputOrientation),
                        @(self.autorotate),
                        @(self.videoSizeRespectingAspectRatio)
                        ];
    for (NSObject *value in values) {
        hash ^= value.hash;
    }
    return hash;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return true;
    } else if (![super isEqual:object]) {
        return false;
    } else {
        MTTLiveVideoConfiguration *obj = object;
        return CGSizeEqualToSize(obj.videoSize, self.videoSize) &&
        obj.videoFrameRate == self.videoFrameRate && 
        obj.videoMaxFrameRate == self.videoMaxFrameRate && 
        obj.videoMinFrameRate == self.videoMinFrameRate && 
        obj.videoMaxKeyFrameInterval == self.videoMaxKeyFrameInterval && 
        obj.videoBitRate == self.videoBitRate && 
        obj.videoMaxBitRate == self.videoMaxBitRate &&
        obj.videoMinBitRate == self.videoMinBitRate &&
        [obj.avSessionPreset isEqualToString:self.avSessionPreset] &&
        obj.sessionPreset == self.sessionPreset &&
        obj.outputOrientation == self.outputOrientation &&
        obj.autorotate == self.autorotate &&
        obj.videoSizeRespectingAspectRatio == self.videoSizeRespectingAspectRatio;
        
    }
}

- (NSString *)description {
    NSMutableString *desc = @"".mutableCopy;
    [desc appendFormat:@"<MTTLiveVideoConfiguration: %p>",self];
    [desc appendFormat:@" videoSize:%@",NSStringFromCGSize(self.videoSize)];
    [desc appendFormat:@" videoSizeRespectingAspectRation:%d",self.videoSizeRespectingAspectRatio];
    [desc appendFormat:@" videoFrameRate:%zi",self.videoFrameRate];
    [desc appendFormat:@" videoMaxFrameRate:%zi",self.videoMaxFrameRate];
    [desc appendFormat:@" videoMinFrameRate:%zi",self.videoMinFrameRate];
    [desc appendFormat:@" videoMaxKeyFrameInteravl:%zi",self.videoMaxKeyFrameInterval];
    [desc appendFormat:@" videoBitRate:%zi",self.videoBitRate];
    [desc appendFormat:@" videoMaxBitRate:%zi",self.videoMaxBitRate];
    [desc appendFormat:@" videoMinBitRate:%zi",self.videoMinBitRate];
    [desc appendFormat:@" avSessionPreset:%@",self.avSessionPreset];
    [desc appendFormat:@" sessionPreset:%zi",self.sessionPreset];
    [desc appendFormat:@" outputOrientation:%zi",self.outputOrientation];
    [desc appendFormat:@" autorotate:%d",self.autorotate];
    return desc;
}

@end

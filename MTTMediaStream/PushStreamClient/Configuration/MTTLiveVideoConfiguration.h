//
//  MTTLiveVideoConfiguration.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/5/28.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - 视频采集分辨率
typedef enum : NSUInteger {
    MTTCaptureSessionPreset360x640  = 0,
    MTTCaptureSessionPreset540x960  = 1,
    MTTCaptureSessionPreset720x1280 = 2,
} MTTCaptureSessionPreset;

// MARK: - 视频质量
typedef enum : NSUInteger {
    // 分辨率:360 x 640 帧数:15 码率:500Kps
    MTTLiveVideoQuality_Low1    = 0,
    // 分辨率:360 x 640 帧数:24 码率:800Kps
    MTTLiveVideoQuality_Low2    = 1,
    // 分辨率:360 x 640 帧数:30 码率:800Kps
    MTTLiveVideoQuality_Low3    = 2,
    // 分辨率:540 x 960 帧数:15 码率:800Kps
    MTTLiveVideoQuality_Medium1 = 3,
    // 分辨率:540 x 960 帧数:24 码率:800Kps
    MTTLiveVideoQuality_Medium2 = 4,
    // 分辨率:540 x 960 帧数:30 码率:800Kps
    MTTLiveVideoQuality_Medium3 = 5,
    // 分辨率:720 x 1280 帧数:15 码率:1000Kps
    MTTLiveVideoQuality_High1   = 6,
    // 分辨率:720 x 1280 帧数:24 码率:1200Kps
    MTTLiveVideoQuality_High2   = 7,
    // 分辨率:720 x 1280 帧数:30 码率:1200Kps
    MTTLiveVideoQuality_High3   = 8,
    MTTLiveVideoQuality_Default = MTTLiveVideoQuality_Low2,
} MTTLiveVideoQuality;



@interface MTTLiveVideoConfiguration : NSObject<NSCopying,NSCoding>


/**
 视频默认配置

 @return instance
 */
+ (instancetype)defaultConfiguration;

/**
 根据视频质量生成配置

 @param videoQuality 视频质量
 @return instance
 */
+ (instancetype)defaultConfigurationForQuality:(MTTLiveVideoQuality)videoQuality;


/**
 根据视频质量和设备方向生成配置

 @param videoQuality 视频质量
 @param orientation 方向
 @return instance
 */
+ (instancetype)defaultConfigurationForQuality:(MTTLiveVideoQuality)videoQuality outputOrientation:(UIInterfaceOrientation)orientation;

// 视频的分辨率，宽高务必设定为 2 的倍数，否则解码播放时可能出现绿边
@property (nonatomic, assign) CGSize videoSize;

// 输出图像是否等比例, 默认false
@property (nonatomic, assign) BOOL   videoSizeRespectRatio;

// 视频输出方向
@property (nonatomic, assign) UIInterfaceOrientation outputOrientation;

// 自动旋转
@property (nonatomic, assign) BOOL autorotate;

// 视频fps
@property (nonatomic, assign) NSUInteger videoFrameRate;

// 视频最大fps
@property (nonatomic, assign) NSUInteger videoMaxFrameRate;

// 视频最小fps
@property (nonatomic, assign) NSUInteger videoMinFrameRate;

// 最大关键帧间隔 
@property (nonatomic, assign) NSUInteger videoMaxKeyFrameInterval;

// 视频码率
@property (nonatomic, assign) NSUInteger videoBitRate;

// 采集分辨率
@property (nonatomic, assign) MTTCaptureSessionPreset sessionPreset;

// sde3分辨率
@property (nonatomic, assign, readonly) NSString *avSessionPreset;

// 是否横屏
@property (nonatomic, assign, readonly) BOOL landscape;

@end

NS_ASSUME_NONNULL_END

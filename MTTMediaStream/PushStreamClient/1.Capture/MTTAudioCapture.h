//
//  MTTAudioCapture.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/3.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTLiveAudioConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/// componentFailed notification post name
extern NSString * _Nullable const kAudioComponentFailedToCreateNotification;

// MARK: - audio capture delegate
@class MTTAudioCapture;
@protocol MTTAudioCaptureDelegate <NSObject>

/**
 音频采集回调

 @param audioCapture 采集对象
 @param audioData 采集到的数据
 */
- (void)captureOutput:(nullable MTTAudioCapture *)audioCapture audioData:(nullable NSData *)audioData;

@end

@interface MTTAudioCapture : NSObject
// delegate
@property (nonatomic, weak) id<MTTAudioCaptureDelegate>delegate;

// 静音
@property (nonatomic, assign) BOOL muted;

// 是否正在采集
@property (nonatomic, assign) BOOL running;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;


/**
 根据音频配置生成实例

 @param configuration 音频配置
 @return 实例
 */
- (instancetype)initWithAudioConfiguration:(nullable MTTLiveAudioConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END

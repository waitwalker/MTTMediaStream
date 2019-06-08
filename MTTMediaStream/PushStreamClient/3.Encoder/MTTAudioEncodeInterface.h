//
//  MTTAudioEncodeInterface.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/4.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTLiveAudioConfiguration.h"
#import <AVFoundation/AVFoundation.h>
#import "MTTAudioFrame.h"

NS_ASSUME_NONNULL_BEGIN


@protocol MTTAudioEncodeInterface;
@protocol MTTAudioEncodeDelegate <NSObject>

@required

/**
 音频编码回调

 @param encoder 编码器
 @param frame 音频编码后的帧
 */
- (void)audioEncoder:(nullable id<MTTAudioEncodeInterface>)encoder audioFrame:(MTTAudioFrame *)frame;

@end

@protocol MTTAudioEncodeInterface <NSObject>

@required
/**
开始音频编码

 @return v
 */
- (void)encodeAudioData:(nullable NSData*)audioData timeStamp:(uint64_t)timeStamp;

/**
 停止音频编码
 */
- (void)stopEncoder;

@optional


/**
 根据音频配置生成音频编码实例

 @param configuration 音频配置
 @return instance
 */
- (nullable instancetype)initWithAudioSteamConfiguration:(nullable MTTLiveAudioConfiguration *)configuration;


/**
 设置delegate

 @param delegate delegate
 */
- (void)setDelegate:(nullable id<MTTAudioEncodeDelegate>)delegate;


/**
 将编码后的数据写入本地

 @param channel channel
 @param rawDataLength 原始数据长度
 @return 编码后的数据
 */
- (nullable NSData*)adtsData:(NSInteger)channel rawDataLength:(NSInteger)rawDataLength;

@end

NS_ASSUME_NONNULL_END

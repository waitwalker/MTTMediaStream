//
//  MTTVideoEncodeInterface.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/4.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTVideoFrame.h"
#import "MTTLiveVideoConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MTTVideoEncodeInterface;
@protocol MTTVideoEncodeDelegate <NSObject>

@required

/**
 视频编码回调

 @param encoder 编码器
 @param frame 视频帧
 */
- (void)videoEncoder:(nullable id<MTTVideoEncodeInterface>)encoder videoFrame:(nullable MTTVideoFrame *)frame;

@end

@protocol MTTVideoEncodeInterface <NSObject>
@required

/**
 开始视频编码

 @param pixelBuffer 视频缓冲数据
 @param timeStamp 时间戳
 */
- (void)encodeVideoData:(nullable CVPixelBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp;

@optional

/**
 根据视频配置生成视频编码实例

 @param configuration 视频配置
 @return instance
 */
- (nullable instancetype)initWithVideoStreamConfiguration:(nullable MTTLiveVideoConfiguration *)configuration;

/**
 设置delegate

 @param delegate delegate
 */
- (void)setDelegate:(nullable id<MTTVideoEncodeDelegate>)delegate;

/**
 停止编码
 */
- (void)stopEncode;

// 视频比特率
@property (nonatomic, assign) NSInteger videoBitRate;

@end

NS_ASSUME_NONNULL_END

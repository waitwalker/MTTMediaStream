//
//  MTTVideoCapture.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/3.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MTTLiveVideoConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@class MTTVideoCapture;
@protocol MTTVideoCaptureDelegate <NSObject>


/**
 视频采集回调

 @param videoCapture 视频采集对象
 @param pixelBuffer 采集数据buffer
 */
- (void)captureOutput:(nullable MTTVideoCapture *)videoCapture pixelBuffer:(nullable CVPixelBufferRef)pixelBuffer;

@end

@interface MTTVideoCapture : NSObject

@property (nonatomic, weak) id<MTTVideoCaptureDelegate> delegate;

// 是否正在采集
@property (nonatomic, assign) BOOL running;

// 预览
@property (null_resettable, nonatomic, strong) UIView *preView;

// 摄像头方向
@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePosition;

// 是否美颜
@property (nonatomic, assign) BOOL beautyFace;

// 是否打开手电筒
@property (nonatomic, assign) BOOL torch;

// The mirror control mirror of front camera is on or off
@property (nonatomic, assign) BOOL mirror;

// 美颜强度
@property (nonatomic, assign) CGFloat beautyLevel;

// 亮度强度
@property (nonatomic, assign) CGFloat brightLevel;

// 缩放比例 1-3
@property (nonatomic, assign) NSInteger zoomScale;

// fps
@property (nonatomic, assign) NSInteger videoFrameRate;

// 水印
@property (nonatomic, strong, nullable) UIView *waterMarkView;

// 当前snapshot
@property (nonatomic, strong, nullable) UIImage *currentImage;

// 视频是否保存到本地
@property (nonatomic, assign) BOOL saveLocalVideo;

// 本地视频路径
@property (nonatomic, strong, nullable) NSURL *saveLocalVideoPath;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;


/**
 根据视频配置生成视频采集对象

 @param configuration 视频配置
 @return 采集对象
 */
- (instancetype)initWithVideoConfiguration:(nullable MTTLiveVideoConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END

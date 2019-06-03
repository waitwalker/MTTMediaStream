//
//  MTTVideoCapture.m
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/3.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTVideoCapture.h"
#import <GPUImage/GPUImage.h>
#import "MTTGPUImageBeautyFilter.h"
#import "MTTGPUImageEmptyFilter.h"

@interface MTTVideoCapture()

// 相当于视频采集会话
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

// 美颜滤镜
@property (nonatomic, strong) MTTGPUImageBeautyFilter *beautyFilter;

@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;

@property (nonatomic, strong) GPUImageCropFilter *cropfilter;

@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *output;

@property (nonatomic, strong) GPUImageView *gpuImageView;

@property (nonatomic, strong) MTTLiveVideoConfiguration *configuration;

@property (nonatomic, strong) GPUImageAlphaBlendFilter *blendFilter;

@property (nonatomic, strong) GPUImageUIElement *uiElementInput;

@property (nonatomic, strong) UIView *waterMarkContainerView;

@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;

@end

@implementation MTTVideoCapture
// 让编译器自动生成setter getter
@synthesize torch = _torch;
@synthesize beautyLevel = _beautyLevel;
@synthesize brightLevel = _brightLevel;
@synthesize zoomScale = _zoomScale;

- (instancetype)initWithVideoConfiguration:(MTTLiveVideoConfiguration *)configuration {
    if (self = [super init]) {
        _configuration = configuration;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(statusBarChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        self.beautyFace = true;
        self.beautyLevel = 0.5;
        self.brightLevel = 0.5;
        self.zoomScale = 1.0;
        self.mirror = true;
    }
    return self;
}

- (void)willEnterBackground:(NSNotification *)notification {
    
    // 是否一直亮屏
    [UIApplication sharedApplication].idleTimerDisabled = false;
    [self.videoCamera pauseCameraCapture];
    runSynchronouslyOnVideoProcessingQueue(^{
       glFinish(); 
    });
}

- (void)willEnterForeground:(NSNotification *)notification {
    [self.videoCamera resumeCameraCapture];
    [UIApplication sharedApplication].idleTimerDisabled = true;
}

- (void)statusBarChange:(NSNotification *)notification {
    NSLog(@"UIApplicationWillChangeStatusBarOrientationNotification. UserInfo:%@",notification.userInfo);
    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (self.configuration.autorotate) {
        if (self.configuration.landscape) {
            if (statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
                self.videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
            } else if (statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                self.videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
            }
        } else {
            if (statusBarOrientation == UIInterfaceOrientationPortrait) {
                self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortraitUpsideDown;
            } else if (statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown) {
                self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
            }
        }
    }
}



@end

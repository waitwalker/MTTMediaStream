//
//  MTTVideoCapture.m
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/3.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTVideoCapture.h"
#if __has_include(<GPUImage/GPUImage.h>)
#import <GPUImage/GPUImage.h>
#elif __has_include("GPUImage/GPUImage.h")
#import "GPUImage/GPUImage.h"
#else
#import "GPUImage.h"
#endif
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

- (void)dealloc {
    [UIApplication sharedApplication].idleTimerDisabled = false;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [_videoCamera stopCameraCapture];
    if (_gpuImageView) {
        [_gpuImageView removeFromSuperview];
        _gpuImageView = nil;
    }
}

// MARK: - setter getter
- (GPUImageVideoCamera *)videoCamera {
    if (_videoCamera == nil) {
        _videoCamera = [[GPUImageVideoCamera alloc]initWithSessionPreset:_configuration.avSessionPreset cameraPosition:AVCaptureDevicePositionFront];
        _videoCamera.outputImageOrientation = _configuration.outputOrientation;
        _videoCamera.horizontallyMirrorFrontFacingCamera = false;
        _videoCamera.horizontallyMirrorRearFacingCamera = false;
        _videoCamera.frameRate = (int32_t)_configuration.videoFrameRate;
    }
    return _videoCamera;
}

- (void)setRunning:(BOOL)running {
    if (_running == running) {
        return;
    }
    
    _running = running;
    if (!_running) {
        [UIApplication sharedApplication].idleTimerDisabled = false;
        [self.videoCamera stopCameraCapture];
        if (self.saveLocalVideo) {
            [self.movieWriter finishRecording];
        }
    } else {
        [UIApplication sharedApplication].idleTimerDisabled = true;
        [self reloadFilter];
        [self.videoCamera startCameraCapture];
        if (self.saveLocalVideo) {
            [self.movieWriter startRecording];
        }
    }    
}

- (void)setPreView:(UIView *)preView {
    if (self.gpuImageView.superview) {
        [preView insertSubview:self.gpuImageView atIndex:0];
        self.gpuImageView.frame = CGRectMake(0, 0, preView.frame.size.width, preView.frame.size.height);
    }
}

- (UIView *)preView {
    return self.gpuImageView.superview;
}

- (void)setCaptureDevicePosition:(AVCaptureDevicePosition)captureDevicePosition {
    if (captureDevicePosition == self.videoCamera.cameraPosition) {
        return;
    }
    
    [self.videoCamera rotateCamera];
    self.videoCamera.frameRate = (int32_t)_configuration.videoFrameRate;
    [self reloadMirror];
}

- (AVCaptureDevicePosition)captureDevicePosition {
    return [self.videoCamera cameraPosition];
}

// MARK: - private
- (void)reloadFilter {
    [self.filter removeAllTargets];
    [self.blendFilter removeAllTargets];
    [self.uiElementInput removeAllTargets];
    [self.videoCamera removeAllTargets];
    [self.output removeAllTargets];
    [self.cropfilter removeAllTargets];
    
    if (self.beautyFace) {
        self.output = [[MTTGPUImageEmptyFilter alloc]init];
        self.filter = [[MTTGPUImageBeautyFilter alloc]init];
        self.beautyFilter = (MTTGPUImageBeautyFilter *)self.filter;
    } else {
        self.output = [[MTTGPUImageEmptyFilter alloc]init];
        self.filter = [[MTTGPUImageEmptyFilter alloc]init];
        self.beautyFilter = nil;
    }
    
    // 调节镜像
    [self reloadMirror];
    
    // 设置输出
    if ([self.configuration.avSessionPreset isEqualToString:AVCaptureSessionPreset640x480]) {
        CGRect cropRect = self.configuration.landscape ? CGRectMake(0, 0.125, 1, 0.75) : CGRectMake(0.125, 0, 0.75, 1);
        self.cropfilter = [[GPUImageCropFilter alloc]initWithCropRegion:cropRect];
        [self.videoCamera addTarget:self.cropfilter];
        [self.videoCamera addTarget:self.filter];
    } else {
        [self.videoCamera addTarget:self.filter];
    }
    
    // 添加水印
    if (self.waterMarkView) {
        [self.filter addTarget:self.blendFilter];
        [self.uiElementInput addTarget:self.blendFilter];
        [self.blendFilter addTarget:self.gpuImageView];
        if (self.saveLocalVideo) {
            [self.blendFilter addTarget:self.movieWriter];
        }
        [self.filter addTarget:self.output];
        [self.uiElementInput update];
    } else {
        [self.filter addTarget:self.output];
        [self.output addTarget:self.gpuImageView];
        if (self.saveLocalVideo) {
            [self.output addTarget:self.movieWriter];
        }
    }
    
    [self.filter forceProcessingAtSize:self.configuration.videoSize];
    [self.output forceProcessingAtSize:self.configuration.videoSize];
    [self.blendFilter forceProcessingAtSize:self.configuration.videoSize];
    [self.uiElementInput forceProcessingAtSize:self.configuration.videoSize];
    
    // 输出数据
    __weak typeof (self) _self = self;
    [self.output setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        [_self processVideo:output];
    }];
}

- (void)reloadMirror {
    if (self.mirror && self.captureDevicePosition == AVCaptureDevicePositionFront) {
        self.videoCamera.horizontallyMirrorFrontFacingCamera = true;
    } else {
        self.videoCamera.horizontallyMirrorFrontFacingCamera = false;
    }
}

- (void)processVideo:(GPUImageOutput *)output {
    __weak typeof(self) _self = self;
    @autoreleasepool {
        GPUImageFramebuffer *imageFrameBuffer = output.framebufferForOutput;
        CVPixelBufferRef pixelBuffer = [imageFrameBuffer pixelBuffer];
        if (pixelBuffer && _self.delegate && [_self.delegate respondsToSelector:@selector(captureOutput:pixelBuffer:)]) {
            [_self.delegate captureOutput:_self pixelBuffer:pixelBuffer];
        }
    }
}

// MARK: - notification action call back
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

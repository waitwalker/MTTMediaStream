//
//  MTTGPUImageBeautyFilter.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/3.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<GPUImage/GPUImage.h>)
#import <GPUImage/GPUImage.h>
#elif __has_include("GPUImage/GPUImage.h")
#import "GPUImage/GPUImage.h"
#else
#import "GPUImage.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MTTGPUImageBeautyFilter : GPUImageFilter

@property (nonatomic, assign) CGFloat beautyLevel;
@property (nonatomic, assign) CGFloat brightLevel;
@property (nonatomic, assign) CGFloat toneLevel;

@end

NS_ASSUME_NONNULL_END

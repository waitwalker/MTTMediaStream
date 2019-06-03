//
//  MTTGPUImageBeautyFilter.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/3.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTTGPUImageBeautyFilter : GPUImageFilter

@property (nonatomic, assign) CGFloat beautyLevel;
@property (nonatomic, assign) CGFloat brightLevel;
@property (nonatomic, assign) CGFloat toneLevel;

@end

NS_ASSUME_NONNULL_END

//
//  MTTVideoFrame.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/4.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTFrame.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTTVideoFrame : MTTFrame

@property (nonatomic, assign) BOOL isKeyFrame;
@property (nonatomic, strong) NSData *sps;
@property (nonatomic, strong) NSData *pps;

@end

NS_ASSUME_NONNULL_END

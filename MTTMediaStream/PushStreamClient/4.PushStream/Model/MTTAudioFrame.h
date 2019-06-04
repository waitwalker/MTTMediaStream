//
//  MTTAudioFrame.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/4.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTFrame.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTTAudioFrame : MTTFrame

@property (nonatomic, strong) NSData *audioInfo;

@end

NS_ASSUME_NONNULL_END

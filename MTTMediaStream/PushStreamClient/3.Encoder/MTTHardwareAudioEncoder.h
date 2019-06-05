//
//  MTTHardwareAudioEncoder.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/5.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTAudioEncodeInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTTHardwareAudioEncoder : NSObject<MTTAudioEncodeInterface>

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END

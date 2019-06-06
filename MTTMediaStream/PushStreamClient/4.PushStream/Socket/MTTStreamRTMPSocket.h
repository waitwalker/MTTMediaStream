//
//  MTTStreamRTMPSocket.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/6.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTStreamSocketInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTTStreamRTMPSocket : NSObject<MTTStreamSocketInterface>

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END

//
//  LFHardwareVideoEncoder.h
//   
//
//  Created by waitwalker on 19/5/20.
//  Copyright © 2019年 waitwalker All rights reserved.
//

#import "MTTVideoEncodeInterface.h"

@interface MTTHardwareVideoEncoder : NSObject<MTTVideoEncodeInterface>

#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

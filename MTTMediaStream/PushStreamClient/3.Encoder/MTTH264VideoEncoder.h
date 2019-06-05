//
//  MTTH264VideoEncoder.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/5.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTVideoEncodeInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTTH264VideoEncoder : NSObject<MTTVideoEncodeInterface>


/**
 关闭
 */
- (void)shutdown;

@end

NS_ASSUME_NONNULL_END

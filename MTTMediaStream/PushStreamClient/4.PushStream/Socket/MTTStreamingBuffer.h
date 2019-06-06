//
//  MTTStreamingBuffer.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/6.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - 缓冲区状态
typedef NS_ENUM(NSUInteger, MTTLiveBufferState) {
    // 未知
    MTTLiveBufferUnknown = 0,
    // 缓冲区状态差应该降低码率
    MTTLiveBufferIncrease = 1,
    // 缓冲区状态好应该提升码率
    MTTLiveBufferDeclines = 2,
};

@interface MTTStreamingBuffer : NSObject

@end

NS_ASSUME_NONNULL_END

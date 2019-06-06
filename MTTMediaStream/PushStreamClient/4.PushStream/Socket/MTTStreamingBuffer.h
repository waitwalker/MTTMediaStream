//
//  MTTStreamingBuffer.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/6.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTAudioFrame.h"
#import "MTTVideoFrame.h"

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

@class MTTStreamingBuffer;
@protocol MTTStreamingBufferDelegate <NSObject>

@optional

/**
 缓冲区状态回调

 @param buffer 当前缓冲区
 @param state 缓冲区状态
 */
- (void)streamingBuffer:(nullable MTTStreamingBuffer *)buffer bufferState:(MTTLiveBufferState)state;

@end

@interface MTTStreamingBuffer : NSObject

@property(nullable, nonatomic, weak) id<MTTStreamingBufferDelegate>delegate;

// current buffer frames
@property (nonatomic, strong, readonly) NSMutableArray <MTTFrame *> *_Nonnull list;

// buffer count max size default 1000
@property (nonatomic, assign) NSUInteger maxCount;

// 上次丢帧总数
@property (nonatomic, assign) NSInteger lastDropFrames;


/**
 添加帧到buffer list

 @param frame 当前帧
 */
- (void)appendFrame:(nullable MTTFrame *)frame;

/**
 弹出第一帧

 @return 第一帧
 */
- (nullable MTTFrame *)popFirstFrame;

/**
 删除所有帧
 */
- (void)removeAllFrame;


@end

NS_ASSUME_NONNULL_END

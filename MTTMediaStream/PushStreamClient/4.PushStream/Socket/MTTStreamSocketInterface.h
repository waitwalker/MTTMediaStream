//
//  MTTStreamSocketInterface.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/6.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTLiveStreamInfo.h"
#import "MTTStreamingBuffer.h"
#import "MTTLiveDebug.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MTTStreamSocketInterface;
@protocol MTTStreamSocketDelegate <NSObject>


/**
 当前缓冲区回调

 @param socket socket
 @param status 缓冲区状态
 */
- (void)socketBufferStatus:(nullable id<MTTStreamSocketInterface>)socket status:(MTTLiveBufferState)status;

/**
 当前网络回调

 @param socket socket
 @param status 直播状态
 */
- (void)socketStatus:(nullable id <MTTStreamSocketInterface>)socket status:(MTTLiveState)status;


/**
 socket 错误回调

 @param socket socket
 @param errorCode 错误码
 */
- (void)socketDidError:(nullable id<MTTStreamSocketInterface>)socket errorCode:(MTTLiveSocketErrorCode)errorCode;


@optional

/**
 debug信息回调

 @param debugInfo debug
 */
- (void)socketDebug:(nullable id<MTTStreamSocketInterface>)socket debugInfo:(nullable MTTLiveDebug *)debugInfo;

@end

@protocol MTTStreamSocketInterface <NSObject>


/**
 开始socket
 */
- (void)start;


/**
 停止socket
 */
- (void)stop;


/**
 发送frame

 @param frame frame
 */
- (void)sendFrame:(nullable MTTFrame *)frame;


/**
 设置delegate

 @param delegate delegate
 */
- (void)setDelegate:(nullable id<MTTStreamSocketDelegate>)delegate;

@optional

/**
 根据stream info 生成socket实例

 @param stream stream
 @return instance
 */
- (instancetype)initWithStream:(nullable MTTLiveStreamInfo *)stream;


/**
 根据重连间隔和重连次数生成socket实例

 @param stream stream
 @param reconnectInterval 重连间隔
 @param reconnectCount 重连次数
 @return instance
 */
- (instancetype)initWithStream:(nullable MTTLiveStreamInfo *)stream reconnectInterval:(NSInteger)reconnectInterval reconnectCount:(NSInteger)reconnectCount;

@end

NS_ASSUME_NONNULL_END

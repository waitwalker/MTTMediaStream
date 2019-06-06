//
//  MTTLiveStreamInfo.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/6.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTLiveAudioConfiguration.h"
#import "MTTLiveVideoConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

// MARK: - 直播流状态
typedef NS_ENUM(NSUInteger, MTTLiveState) {
    // 准备
    MTTLiveReady = 0,
    
    // 连接中
    MTTLivePending = 1,
    
    // 已连接
    MTTLiveStarted= 2,
    
    // 已断开
    MTTLiveStop = 3,
    
    // 连接出错
    MTTLiveError = 4,
    
    // 正在刷新
    MTTLiveRefresh = 5
};

// MARK: - socket 错误状态码
typedef NS_ENUM(NSUInteger, MTTLiveSocketErrorCode) {
    // 预览失败
    MTTLiveSocketError_Preview = 201,
    // 获取流媒体信息失败
    MTTLiveScoketError_GetStreamInfo = 202,
    // 连接socket失败
    MTTLiveSocketError_ConnectSocket = 203,
    // 验证服务器失败
    MTTLiveSocketError_Verification = 204,
    // 重连服务器失败
    MTTLiveSocketError_ReconnectTimeout = 205,
};

@interface MTTLiveStreamInfo : NSObject

@property (nonatomic, copy) NSString *streamId;

@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) MTTLiveAudioConfiguration *audioConfiguration;
@property (nonatomic, strong) MTTLiveVideoConfiguration *videoConfiguration;


@end

NS_ASSUME_NONNULL_END

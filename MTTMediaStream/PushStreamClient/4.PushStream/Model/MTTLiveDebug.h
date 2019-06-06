//
//  MTTLiveDebug.h
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/6.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTTLiveDebug : NSObject

@property (nonatomic, copy) NSString *streamId; //流id
@property (nonatomic, copy) NSString *uploadUrl; //流地址
@property (nonatomic, assign) CGSize videoSize; //上传视频分辨率
@property (nonatomic, assign) BOOL isRTMP; //上传协议

@property (nonatomic, assign) CGFloat elaspedMilli; //距离上次统计的时间,单位ms
@property (nonatomic, assign) CGFloat timeStamp;// 时间戳
@property (nonatomic, assign) CGFloat dataFlow; //总流量
@property (nonatomic, assign) CGFloat bandWidth; //1s内总带宽
@property (nonatomic, assign) CGFloat currentBandWidth; //上次宽带

@property (nonatomic, assign) NSInteger dropFrame; //丢掉的帧数
@property (nonatomic, assign) NSInteger totalFrame; //总帧数

@property (nonatomic, assign) NSInteger capturedAudioCount; //1s内音频捕获个数
@property (nonatomic, assign) NSInteger capturedVideoCount; //1s内视频捕获个数
@property (nonatomic, assign) NSInteger currentCapturedAudioCount; //上次的音频捕获个数
@property (nonatomic, assign) NSInteger currentCapturedVideoCount; //上次的视频捕获总数

@property (nonatomic, assign) NSInteger unsendCount; //未发送个数(表示当前缓冲区等待发送的)

@end

NS_ASSUME_NONNULL_END

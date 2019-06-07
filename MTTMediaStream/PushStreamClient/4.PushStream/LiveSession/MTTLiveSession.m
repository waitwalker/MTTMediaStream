//
//  MTTLiveSession.m
//  MTTMediaStream
//
//  Created by WangJunZi on 2019/6/6.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTLiveSession.h"
#import "MTTVideoCapture.h"
#import "MTTAudioCapture.h"
#import "MTTHardwareAudioEncoder.h"
#import "MTTHardwareVideoEncoder.h"
#import "MTTH264VideoEncoder.h"
#import "MTTStreamRTMPSocket.h"
#import "MTTGPUImageBeautyFilter.h"


@interface MTTLiveSession()<MTTAudioCaptureDelegate,MTTVideoCaptureDelegate,MTTAudioEncodeDelegate,MTTVideoEncodeDelegate,MTTStreamSocketDelegate>

// 视频配置
@property (nonatomic, strong) MTTLiveVideoConfiguration *videoConfiguration;
// 音频配置
@property (nonatomic, strong) MTTLiveAudioConfiguration *audioConfiguration;
// 视频采集对象
@property (nonatomic, strong) MTTVideoCapture *videoCaptureSource;
// 音频采集对象
@property (nonatomic, strong) MTTAudioCapture *audioCaptureSource;
// 音频编码器
@property (nonatomic, strong) id<MTTAudioEncodeInterface> audioEncoder;
// 视频编码器
@property (nonatomic, strong) id<MTTVideoEncodeInterface> videoEncoder;
// socket
@property (nonatomic, strong) id<MTTStreamSocketInterface> socket;

@end


@implementation MTTLiveSession

@end

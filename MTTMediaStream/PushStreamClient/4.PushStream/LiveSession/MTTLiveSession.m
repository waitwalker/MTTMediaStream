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

// debug
@property (nonatomic, strong) MTTLiveDebug *debugInfo;

// 流信息
@property (nonatomic, strong) MTTLiveStreamInfo *streamInfo;

// 是否正在上传
@property (nonatomic, assign) BOOL uploading;

// 直播状态
@property (nonatomic, assign, readwrite) MTTLiveState state;

// 采集类型
@property (nonatomic, assign, readwrite) MTTLiveCaptureTypeMask captureType;

// 同步锁
@property (nonatomic, strong) dispatch_semaphore_t lock;

// 相对时间戳
@property (nonatomic, assign) uint64_t relativeTimeStamps;

// 音视频是否对齐
@property (nonatomic, assign) BOOL AVAlignment;

// 是否采集到了音频
@property (nonatomic, assign) BOOL hasCaptureAudio;

// 是否采集到了视频
@property (nonatomic, assign) BOOL hasCaptureVideo;

@end

/**  时间戳 */
#define NOW (CACurrentMediaTime()*1000)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation MTTLiveSession

- (instancetype)initWithAudioConfiguration:(MTTLiveAudioConfiguration *)audioConfiguration videoConfiguration:(MTTLiveVideoConfiguration *)videoConfiguration {
    return [self initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration captureType:MTTLiveCaptureDefaultMask];
}

- (instancetype)initWithAudioConfiguration:(MTTLiveAudioConfiguration *)audioConfiguration videoConfiguration:(MTTLiveVideoConfiguration *)videoConfiguration captureType:(MTTLiveCaptureTypeMask)captureType {
    if ((captureType & MTTLiveCaptureMaskAudio || captureType & MTTLiveInputMaskVideo) && !audioConfiguration) {
        @throw [NSException exceptionWithName:@"MTTLiveSession init error" reason:@"audio configuration is nil" userInfo:nil];
    }

    if ((captureType & MTTLiveCaptureMaskVideo || captureType & MTTLiveInputMaskVideo) && !videoConfiguration) {
        @throw [NSException exceptionWithName:@"MTTLiveSession init error" reason:@"video configuration is nil" userInfo:nil];
    }

    if (self = [super init]) {
        _audioConfiguration = audioConfiguration;
        _videoConfiguration = videoConfiguration;
        _adaptiveBitRate = false;
        _captureType = captureType;
    }

    return self;
}

- (void)dealloc {
    _videoCaptureSource.running = false;
    _audioCaptureSource.running = false;
}

// MARK: - 开始直播
- (void)startLive:(MTTLiveStreamInfo *)streamInfo {
    if (!streamInfo) {
        return;
    }

    _streamInfo = streamInfo;
    _streamInfo.videoConfiguration = _videoConfiguration;
    _streamInfo.audioConfiguration = _audioConfiguration;
    [self.socket start];
}

// MARK: - 停止直播
- (void)stopLive {
    self.uploading = false;
    [self.socket stop];
    self.socket = nil;
}

@end

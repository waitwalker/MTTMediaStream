//
//  MTTLiveSession.h
//  MTTMediaStream
//
//  Created by WangJunZi on 2019/6/6.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MTTLiveStreamInfo.h"
#import "MTTAudioFrame.h"
#import "MTTVideoFrame.h"
#import "MTTLiveAudioConfiguration.h"
#import "MTTLiveVideoConfiguration.h"
#import "MTTLiveDebug.h"

NS_ASSUME_NONNULL_BEGIN

// MARK: - 采集类型
typedef NS_ENUM(NSUInteger, MTTLiveCaptureType) {
    // 只采集音频
    MTTLiveCaptureAudio,
    // 只采集视频
    MTTLiveCaptureVideo,
    // 采集外部输入音频
    MTTLiveInputAudio,
    // 采集外部输入视频
    MTTLiveInputVideo
};

///< 用来控制采集类型（可以内部采集也可以外部传入等各种组合，支持单音频与单视频,外部输入适用于录屏，无人机等外设介入）
typedef NS_ENUM(NSInteger,MTTLiveCaptureTypeMask) {
    MTTLiveCaptureMaskAudio = (1 << MTTLiveCaptureAudio),                                 ///< only inner capture audio (no video)
    MTTLiveCaptureMaskVideo = (1 << MTTLiveCaptureVideo),                                 ///< only inner capture video (no audio)
    MTTLiveInputMaskAudio = (1 << MTTLiveInputAudio),                                     ///< only outer input audio (no video)
    MTTLiveInputMaskVideo = (1 << MTTLiveInputVideo),                                     ///< only outer input video (no audio)
    MTTLiveCaptureMaskAll = (MTTLiveCaptureMaskAudio | MTTLiveCaptureMaskVideo),           ///< inner capture audio and video
    MTTLiveInputMaskAll = (MTTLiveInputMaskAudio | MTTLiveInputMaskVideo),                 ///< outer input audio and video(method see pushVideo and pushAudio)
    MTTLiveCaptureMaskAudioInputVideo = (MTTLiveCaptureMaskAudio | MTTLiveInputMaskVideo), ///< inner capture audio and outer input video(method pushVideo and setRunning)
    MTTLiveCaptureMaskVideoInputAudio = (MTTLiveCaptureMaskVideo | MTTLiveInputMaskAudio), ///< inner capture video and outer input audio(method pushAudio and setRunning)
    MTTLiveCaptureDefaultMask = MTTLiveCaptureMaskAll                                     ///< default is inner capture audio and video
};

@class MTTLiveSession;
@protocol MTTLiveSessionDelegate <NSObject>

@optional

/**
 直播状态变化回调

 @param session session
 @param state 直播状态
 */
- (void)liveSession:(nullable MTTLiveSession *)session liveStateDidChange:(MTTLiveState)state;


/**
 直播debug info回调

 @param session session
 @param debugInfo debug info
 */
- (void)liveSession:(nullable MTTLiveSession *)session debugInfo:(MTTLiveDebug *)debugInfo;

/**
 直播socket错误回调

 @param session session
 @param errorCode socket error code
 */
- (void)liveSession:(nullable MTTLiveSession *)session errorCode:(MTTLiveSocketErrorCode)errorCode;

@end

@interface MTTLiveSession : NSObject

@property (nonatomic, weak) id<MTTLiveSessionDelegate>delegate;
@property (nonatomic, assign) BOOL running;
@property (nonatomic, strong, null_resettable) UIView *preView;
@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePosition;
@property (nonatomic, assign) BOOL beautyFace;
@property (nonatomic, assign) CGFloat beautyLevel;
@property (nonatomic, assign) CGFloat brightLevel;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, assign) BOOL torch;
@property (nonatomic, assign) BOOL mirror;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) BOOL adaptiveBitRate;
@property (nonatomic, strong, readonly) MTTLiveStreamInfo *streamInfo;
@property (nonatomic, assign, readonly) MTTLiveState state;
@property (nonatomic, assign, readonly) MTTLiveCaptureTypeMask captureType;
@property (nonatomic, assign) BOOL showDebugInfo;
@property (nonatomic, assign) NSUInteger reconnectInterval;
@property (nonatomic, assign) NSUInteger reconnectCount;
@property (nonatomic, strong) UIView *waterMarkView;
@property (nonatomic, strong, readonly) UIImage *currentImage;
@property (nonatomic, assign) BOOL saveLocalVideo;
@property (nonatomic, strong) NSURL *saveLocalVideoPath;



@end

NS_ASSUME_NONNULL_END

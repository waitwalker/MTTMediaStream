//
//  MTTStreamRTMPSocket.m
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/6/6.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTStreamRTMPSocket.h"
#if __has_include(<pili-librtmp/rtmp.h>)
#import <pili-librtmp/rtmp.h>
#else
#import "rtmp.h"
#endif

static const NSInteger kRetryTimesBroken = 5; //重连一分钟 3s一次
static const NSInteger kRetryTimesMargin = 3;

#define RTMP_RECEIVE_TIMEOUT 2
#define DATA_ITEMS_MAX_COUNT 100
#define RTMP_DATA_RESERVE_SIZE 400
#define RTMP_HEAD_SIZE (sizeof(RTMPPacket) + RTMP_MAX_HEADER_SIZE)

#define SAVC(x)    static const AVal av_ ## x = AVC(#x)

static const AVal av_setDataFrame = AVC("@setDataFrame");
static const AVal av_SDKVersion = AVC("  2.4.0");
SAVC(onMetaData);
SAVC(duration);
SAVC(width);
SAVC(height);
SAVC(videocodecid);
SAVC(videodatarate);
SAVC(framerate);
SAVC(audiocodecid);
SAVC(audiodatarate);
SAVC(audiosamplerate);
SAVC(audiosamplesize);
//SAVC(audiochannels);
SAVC(stereo);
SAVC(encoder);
//SAVC(av_stereo);
SAVC(fileSize);
SAVC(avc1);
SAVC(mp4a);

@interface MTTStreamRTMPSocket(){
    PILI_RTMP *_rtmp;
}

@property (nonatomic, weak)id <MTTStreamSocketDelegate>delegate;
@property (nonatomic, strong) MTTLiveStreamInfo *stream;
@property (nonatomic, strong) MTTStreamingBuffer *buffer;
@property (nonatomic, strong) MTTLiveDebug *debugInfo;

@property (nonatomic, assign) RTMPError error;
@property (nonatomic, assign) NSInteger retryTimesNetworkBroken;
@property (nonatomic, assign) NSInteger reconnectInterval;
@property (nonatomic, assign) NSInteger reconnectCount;

@property (atomic, assign) BOOL isSending;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, assign) BOOL isConnecting;
@property (nonatomic, assign) BOOL isReconnecting;

@property (nonatomic, assign) BOOL sendVideoHead;
@property (nonatomic, assign) BOOL sendAudioHead;

@end

@implementation MTTStreamRTMPSocket

- (instancetype)initWithStream:(MTTLiveStreamInfo *)stream {
    return [self initWithStream:stream reconnectInterval:0 reconnectCount:0];
}

- (instancetype)initWithStream:(MTTLiveStreamInfo *)stream reconnectInterval:(NSInteger)reconnectInterval reconnectCount:(NSInteger)reconnectCount {
    if (!stream) {
        @throw [NSException exceptionWithName:@"StreamRTMPSocket init error" reason:@"stream is nil" userInfo:nil];
    }
    
    if (self = [super init]) {
        _stream = stream;
        if (reconnectInterval > 0) {
            _reconnectInterval = reconnectInterval;
        } else {
            _reconnectInterval = kRetryTimesMargin;
        }
        
        if (reconnectCount > 0) {
            _reconnectCount = reconnectCount;
        } else {
            _reconnectCount = kRetryTimesBroken;
        }
        [self addObserver:self forKeyPath:@"isSending" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"isSending"];
}

@end

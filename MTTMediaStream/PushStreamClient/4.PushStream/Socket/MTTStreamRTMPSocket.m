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
@property (nonatomic, strong) dispatch_queue_t rtmpSendQueue;

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

// MARK: - 开始socket
- (void)start {
    dispatch_async(self.rtmpSendQueue, ^{
        [self _start];
    });
}

- (void)_start {
    if (!_stream) {
        return;
    }
    
    if (_isConnecting) {
        return;
    }
    
    if (_rtmp != NULL) {
        return;
    }
    
    self.debugInfo.streamId = self.stream.streamId;
    self.debugInfo.uploadUrl = self.stream.url;
    self.debugInfo.isRTMP = true;
    if (_isConnecting) {
        return;
    }
    
    _isConnecting = true;
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]) {
        [self.delegate socketStatus:self status:MTTLivePending];
    }
    
    if (_rtmp != NULL) {
        PILI_RTMP_Close(_rtmp, &_error);
        PILI_RTMP_Free(_rtmp);
    }
    
    [self RTMP264_Connect:(char *)[_stream.url cStringUsingEncoding:NSASCIIStringEncoding]];
}

- (NSInteger)RTMP264_Connect:(char *)push_url {
    // 分配与初始化
    _rtmp = PILI_RTMP_Alloc();
    PILI_RTMP_Init(_rtmp);
    
    // 设置URL
    if (PILI_RTMP_SetupURL(_rtmp, push_url, &_error) == false) {
        goto Failed;
    }
    _rtmp->m_errorCallback = RTMPErrorCallBack;
    _rtmp->m_connCallback = ConnectionTimeCallBack;
    _rtmp->m_userData = (__bridge void *)self;
    _rtmp->m_msgCounter = 1;
    _rtmp->Link.timeout = RTMP_RECEIVE_TIMEOUT;
    
    // 设置可写, 即发布流,这个函数必须在重连前使用,否则无效
    PILI_RTMP_EnableWrite(_rtmp);
    
    // 连接服务器
    if (PILI_RTMP_Connect(_rtmp, NULL, &_error) == false) {
        goto Failed;
    }
    
    // 连接流
    if (PILI_RTMP_ConnectStream(_rtmp, 0, &_error) == false) {
        goto Failed;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]) {
        [self.delegate socketStatus:self status:MTTLiveStarted];
    }
    
    [self sendMetaData];
    
    _isConnected = true;
    _isConnecting = false;
    _isReconnecting = false;
    _isSending = false;
    return 0;
    
Failed:
    PILI_RTMP_Close(_rtmp, &_error);
    PILI_RTMP_Free(_rtmp);
    _rtmp = NULL;
    [self reconnect];
    return -1;
}

void RTMPErrorCallBack(RTMPError *error, void *userData) {
    MTTStreamRTMPSocket *socket = (__bridge MTTStreamRTMPSocket *)userData;
    if (error->code < 0) {
        [socket reconnect];
    }
}

void ConnectionTimeCallBack(PILI_CONNECTION_TIME *conn_time, void *userData) {
    
}

- (void)sendMetaData {
    PILI_RTMPPacket packet;
    
    char pbuf[2048], *pend = pbuf + sizeof(pbuf);
    
    packet.m_nChannel = 0x03;                   // control channel (invoke)
    packet.m_headerType = RTMP_PACKET_SIZE_LARGE;
    packet.m_packetType = RTMP_PACKET_TYPE_INFO;
    packet.m_nTimeStamp = 0;
    packet.m_nInfoField2 = _rtmp->m_stream_id;
    packet.m_hasAbsTimestamp = TRUE;
    packet.m_body = pbuf + RTMP_MAX_HEADER_SIZE;
    
    char *enc = packet.m_body;
    enc = AMF_EncodeString(enc, pend, &av_setDataFrame);
    enc = AMF_EncodeString(enc, pend, &av_onMetaData);
    
    *enc++ = AMF_OBJECT;
    
    enc = AMF_EncodeNamedNumber(enc, pend, &av_duration, 0.0);
    enc = AMF_EncodeNamedNumber(enc, pend, &av_fileSize, 0.0);
    
    // videosize
    enc = AMF_EncodeNamedNumber(enc, pend, &av_width, _stream.videoConfiguration.videoSize.width);
    enc = AMF_EncodeNamedNumber(enc, pend, &av_height, _stream.videoConfiguration.videoSize.height);
    
    // video
    enc = AMF_EncodeNamedString(enc, pend, &av_videocodecid, &av_avc1);
    
    enc = AMF_EncodeNamedNumber(enc, pend, &av_videodatarate, _stream.videoConfiguration.videoBitRate / 1000.f);
    enc = AMF_EncodeNamedNumber(enc, pend, &av_framerate, _stream.videoConfiguration.videoFrameRate);
    
    // audio
    enc = AMF_EncodeNamedString(enc, pend, &av_audiocodecid, &av_mp4a);
    enc = AMF_EncodeNamedNumber(enc, pend, &av_audiodatarate, _stream.audioConfiguration.audioBitRate);
    
    enc = AMF_EncodeNamedNumber(enc, pend, &av_audiosamplerate, _stream.audioConfiguration.audioSampleRate);
    enc = AMF_EncodeNamedNumber(enc, pend, &av_audiosamplesize, 16.0);
    enc = AMF_EncodeNamedBoolean(enc, pend, &av_stereo, _stream.audioConfiguration.numberOfChannels == 2);
    
    // sdk version
    enc = AMF_EncodeNamedString(enc, pend, &av_encoder, &av_SDKVersion);
    
    *enc++ = 0;
    *enc++ = 0;
    *enc++ = AMF_OBJECT_END;
    
    packet.m_nBodySize = (uint32_t)(enc - packet.m_body);
    if (!PILI_RTMP_SendPacket(_rtmp, &packet, FALSE, &_error)) {
        return;
    }
}

- (void)reconnect {
    dispatch_async(self.rtmpSendQueue, ^{
        if (self.retryTimesNetworkBroken++ < self.reconnectCount && !self.isReconnecting) {
            self.isConnected = false;
            self.isConnecting = false;
            self.isReconnecting = true;
            dispatch_async(dispatch_get_main_queue(), ^{
               [self performSelector:@selector(_reconnect) withObject:nil afterDelay:self.reconnectInterval]; 
            });
        } else if (self.retryTimesNetworkBroken > self.reconnectCount){
            if (self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]) {
                [self.delegate socketStatus:self status:MTTLiveError];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(socketDidError:errorCode:)]) {
                [self.delegate socketDidError:self errorCode:MTTLiveSocketError_ReconnectTimeout];
            }
        }
    });
}

- (void)_reconnect {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _isReconnecting = false;
    if (_isConnected) {
        return;
    }
    
    _isReconnecting = false;
    if (_isConnected) {
        return;
    }
    
    if (_rtmp != NULL) {
        PILI_RTMP_Close(_rtmp, &_error);
        PILI_RTMP_Free(_rtmp);
        _rtmp = NULL;
    }
    
    _sendAudioHead = false;
    _sendVideoHead = false;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]) {
        [self.delegate socketStatus:self status:MTTLiveRefresh];
    }
    
    if (_rtmp != NULL) {
        PILI_RTMP_Close(_rtmp, &_error);
        PILI_RTMP_Free(_rtmp);
    }
    [self RTMP264_Connect:(char *)[_stream.url cStringUsingEncoding:NSASCIIStringEncoding]];
}

// MARK: - 停止socket
- (void)stop {
    dispatch_async(self.rtmpSendQueue, ^{
        [self _stop];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    });
}

- (void)_stop {
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]) {
        [self.delegate socketStatus:self status:MTTLiveStop];
    }
    
    if (_rtmp != NULL) {
        PILI_RTMP_Close(_rtmp, &_error);
        PILI_RTMP_Free(_rtmp);
        _rtmp = NULL;
    }
    
    [self clean];
}

- (void)clean {
    _isConnecting = false;
    _isReconnecting = false;
    _isSending = false;
    _isConnected = false;
    _sendAudioHead = false;
    _sendVideoHead = false;
    self.debugInfo = nil;
    [self.buffer removeAllFrame];
    
    self.retryTimesNetworkBroken = 0;
}

- (void)sendFrame:(MTTFrame *)frame {
    if (!frame) {
        return;
    }
    
    [self.buffer appendFrame:frame];
    if (!self.isSending) {
        [self sendFrame];
    }
}

- (void)sendFrame {
    __weak typeof(self) _self = self;
    dispatch_async(self.rtmpSendQueue, ^{
        if (!_self.isSending && _self.buffer.list.count > 0) {
            _self.isSending = YES;
            
            if (!_self.isConnected || _self.isReconnecting || _self.isConnecting || !self->_rtmp){
                _self.isSending = NO;
                return;
            }
            
            // 调用发送接口
            MTTFrame *frame = [_self.buffer popFirstFrame];
            if ([frame isKindOfClass:[MTTVideoFrame class]]) {
                if (!_self.sendVideoHead) {
                    _self.sendVideoHead = YES;
                    if(!((MTTVideoFrame*)frame).sps || !((MTTVideoFrame*)frame).pps){
                        _self.isSending = NO;
                        return;
                    }
                    [_self sendVideoHeader:(MTTVideoFrame *)frame];
                } else {
                    [_self sendVideo:(MTTVideoFrame *)frame];
                }
            } else {
                if (!_self.sendAudioHead) {
                    _self.sendAudioHead = YES;
                    if(!((MTTAudioFrame*)frame).audioInfo){
                        _self.isSending = NO;
                        return;
                    }
                    [_self sendAudioHeader:(MTTAudioFrame *)frame];
                } else {
                    [_self sendAudio:frame];
                }
            }
            
            //debug更新
            _self.debugInfo.totalFrame++;
            _self.debugInfo.dropFrame += _self.buffer.lastDropFrames;
            _self.buffer.lastDropFrames = 0;
            
            _self.debugInfo.dataFlow += frame.data.length;
            _self.debugInfo.elaspedMilli = CACurrentMediaTime() * 1000 - _self.debugInfo.timeStamp;
            if (_self.debugInfo.elaspedMilli < 1000) {
                _self.debugInfo.bandWidth += frame.data.length;
                if ([frame isKindOfClass:[MTTAudioFrame class]]) {
                    _self.debugInfo.capturedAudioCount++;
                } else {
                    _self.debugInfo.capturedVideoCount++;
                }
                
                _self.debugInfo.unsendCount = _self.buffer.list.count;
            } else {
                _self.debugInfo.currentBandWidth = _self.debugInfo.bandWidth;
                _self.debugInfo.currentCapturedAudioCount = _self.debugInfo.capturedAudioCount;
                _self.debugInfo.currentCapturedVideoCount = _self.debugInfo.capturedVideoCount;
                if (_self.delegate && [_self.delegate respondsToSelector:@selector(socketDebug:debugInfo:)]) {
                    [_self.delegate socketDebug:_self debugInfo:_self.debugInfo];
                }
                _self.debugInfo.bandWidth = 0;
                _self.debugInfo.capturedAudioCount = 0;
                _self.debugInfo.capturedVideoCount = 0;
                _self.debugInfo.timeStamp = CACurrentMediaTime() * 1000;
            }
            
            //修改发送状态
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                ///< 这里只为了不循环调用sendFrame方法 调用栈是保证先出栈再进栈
                _self.isSending = NO;
            });
            
        }
    });
}

- (void)sendVideoHeader:(MTTVideoFrame *)videoFrame {
    
    unsigned char *body = NULL;
    NSInteger iIndex = 0;
    NSInteger rtmpLength = 1024;
    const char *sps = videoFrame.sps.bytes;
    const char *pps = videoFrame.pps.bytes;
    NSInteger sps_len = videoFrame.sps.length;
    NSInteger pps_len = videoFrame.pps.length;
    
    body = (unsigned char *)malloc(rtmpLength);
    memset(body, 0, rtmpLength);
    
    body[iIndex++] = 0x17;
    body[iIndex++] = 0x00;
    
    body[iIndex++] = 0x00;
    body[iIndex++] = 0x00;
    body[iIndex++] = 0x00;
    
    body[iIndex++] = 0x01;
    body[iIndex++] = sps[1];
    body[iIndex++] = sps[2];
    body[iIndex++] = sps[3];
    body[iIndex++] = 0xff;
    
    /*sps*/
    body[iIndex++] = 0xe1;
    body[iIndex++] = (sps_len >> 8) & 0xff;
    body[iIndex++] = sps_len & 0xff;
    memcpy(&body[iIndex], sps, sps_len);
    iIndex += sps_len;
    
    /*pps*/
    body[iIndex++] = 0x01;
    body[iIndex++] = (pps_len >> 8) & 0xff;
    body[iIndex++] = (pps_len) & 0xff;
    memcpy(&body[iIndex], pps, pps_len);
    iIndex += pps_len;
    
    [self sendPacket:RTMP_PACKET_TYPE_VIDEO data:body size:iIndex nTimestamp:0];
    free(body);
}

- (void)sendVideo:(MTTVideoFrame *)frame {
    
    NSInteger i = 0;
    NSInteger rtmpLength = frame.data.length + 9;
    unsigned char *body = (unsigned char *)malloc(rtmpLength);
    memset(body, 0, rtmpLength);
    
    if (frame.isKeyFrame) {
        body[i++] = 0x17;        // 1:Iframe  7:AVC
    } else {
        body[i++] = 0x27;        // 2:Pframe  7:AVC
    }
    body[i++] = 0x01;    // AVC NALU
    body[i++] = 0x00;
    body[i++] = 0x00;
    body[i++] = 0x00;
    body[i++] = (frame.data.length >> 24) & 0xff;
    body[i++] = (frame.data.length >> 16) & 0xff;
    body[i++] = (frame.data.length >>  8) & 0xff;
    body[i++] = (frame.data.length) & 0xff;
    memcpy(&body[i], frame.data.bytes, frame.data.length);
    
    [self sendPacket:RTMP_PACKET_TYPE_VIDEO data:body size:(rtmpLength) nTimestamp:frame.timeStamp];
    free(body);
}

- (NSInteger)sendPacket:(unsigned int)nPacketType data:(unsigned char *)data size:(NSInteger)size nTimestamp:(uint64_t)nTimestamp {
    NSInteger rtmpLength = size;
    PILI_RTMPPacket rtmp_pack;
    PILI_RTMPPacket_Reset(&rtmp_pack);
    PILI_RTMPPacket_Alloc(&rtmp_pack, (uint32_t)rtmpLength);
    
    rtmp_pack.m_nBodySize = (uint32_t)size;
    memcpy(rtmp_pack.m_body, data, size);
    rtmp_pack.m_hasAbsTimestamp = 0;
    rtmp_pack.m_packetType = nPacketType;
    if (_rtmp) rtmp_pack.m_nInfoField2 = _rtmp->m_stream_id;
    rtmp_pack.m_nChannel = 0x04;
    rtmp_pack.m_headerType = RTMP_PACKET_SIZE_LARGE;
    if (RTMP_PACKET_TYPE_AUDIO == nPacketType && size != 4) {
        rtmp_pack.m_headerType = RTMP_PACKET_SIZE_MEDIUM;
    }
    rtmp_pack.m_nTimeStamp = (uint32_t)nTimestamp;
    
    NSInteger nRet = [self RtmpPacketSend:&rtmp_pack];
    
    PILI_RTMPPacket_Free(&rtmp_pack);
    return nRet;
}

- (NSInteger)RtmpPacketSend:(PILI_RTMPPacket *)packet {
    if (_rtmp && PILI_RTMP_IsConnected(_rtmp)) {
        int success = PILI_RTMP_SendPacket(_rtmp, packet, 0, &_error);
        return success;
    }
    return -1;
}

- (void)sendAudioHeader:(MTTAudioFrame *)audioFrame {
    
    NSInteger rtmpLength = audioFrame.audioInfo.length + 2;     /*spec data长度,一般是2*/
    unsigned char *body = (unsigned char *)malloc(rtmpLength);
    memset(body, 0, rtmpLength);
    
    /*AF 00 + AAC RAW data*/
    body[0] = 0xAF;
    body[1] = 0x00;
    memcpy(&body[2], audioFrame.audioInfo.bytes, audioFrame.audioInfo.length);          /*spec_buf是AAC sequence header数据*/
    [self sendPacket:RTMP_PACKET_TYPE_AUDIO data:body size:rtmpLength nTimestamp:0];
    free(body);
}

- (void)sendAudio:(MTTFrame *)frame {
    
    NSInteger rtmpLength = frame.data.length + 2;    /*spec data长度,一般是2*/
    unsigned char *body = (unsigned char *)malloc(rtmpLength);
    memset(body, 0, rtmpLength);
    
    /*AF 01 + AAC RAW data*/
    body[0] = 0xAF;
    body[1] = 0x01;
    memcpy(&body[2], frame.data.bytes, frame.data.length);
    [self sendPacket:RTMP_PACKET_TYPE_AUDIO data:body size:rtmpLength nTimestamp:frame.timeStamp];
    free(body);
}

- (dispatch_queue_t)rtmpSendQueue {
    if (!_rtmpSendQueue) {
        _rtmpSendQueue = dispatch_queue_create("cn.waitwalker.RTMPSendQueue", NULL);
    }
    return _rtmpSendQueue;
}

@end

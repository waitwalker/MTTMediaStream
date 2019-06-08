//
//  MTTLivePreview.m.m
//   
//
//  Created by waitwalker on 19/5/2.
//  Copyright © 2019年 live Interactive. All rights reserved.
//

#import "MTTLivePreview.h"
#import "MTTLiveSession.h"

inline static NSString *formatedSpeed(float bytes, float elapsed_milli) {
    if (elapsed_milli <= 0) {
        return @"N/A";
    }

    if (bytes <= 0) {
        return @"0 KB/s";
    }

    float bytes_per_sec = ((float)bytes) * 1000.f /  elapsed_milli;
    if (bytes_per_sec >= 1000 * 1000) {
        return [NSString stringWithFormat:@"%.2f MB/s", ((float)bytes_per_sec) / 1000 / 1000];
    } else if (bytes_per_sec >= 1000) {
        return [NSString stringWithFormat:@"%.1f KB/s", ((float)bytes_per_sec) / 1000];
    } else {
        return [NSString stringWithFormat:@"%ld B/s", (long)bytes_per_sec];
    }
}

@interface MTTLivePreview ()<MTTLiveSessionDelegate>

@property (nonatomic, strong) UIButton *beautyButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *startLiveButton;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) MTTLiveDebug *debugInfo;
@property (nonatomic, strong) MTTLiveSession *session;
@property (nonatomic, strong) UILabel *stateLabel;

@end

@implementation MTTLivePreview

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self requestAccessForVideo];
        [self requestAccessForAudio];
        
        [self setupSubviews];
    }
    return self;
}

- (void)requestAccessForVideo {
    __weak typeof(self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
    case AVAuthorizationStatusNotDetermined: {
        // 许可对话没有出现，发起授权许可
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_self.session setRunning:YES];
                    });
                }
            }];
        break;
    }
    case AVAuthorizationStatusAuthorized: {
        // 已经开启授权，可继续
        dispatch_async(dispatch_get_main_queue(), ^{
            [_self.session setRunning:YES];
        });
        break;
    }
    case AVAuthorizationStatusDenied:
    case AVAuthorizationStatusRestricted:
        // 用户明确地拒绝授权，或者相机设备无法访问

        break;
    default:
        break;
    }
}

- (void)requestAccessForAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
    case AVAuthorizationStatusNotDetermined: {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
        break;
    }
    case AVAuthorizationStatusAuthorized: {
        break;
    }
    case AVAuthorizationStatusDenied:
    case AVAuthorizationStatusRestricted:
        break;
    default:
        break;
    }
}

/** live status changed will callback */
- (void)liveSession:(nullable MTTLiveSession *)session liveStateDidChange:(MTTLiveState)state {
    NSLog(@"liveStateDidChange: %lu", (unsigned long)state);
    switch (state) {
        case MTTLiveReady:
        _stateLabel.text = @"未连接";
        break;
        case MTTLivePending:
        _stateLabel.text = @"连接中";
        break;
        case MTTLiveStarted:
        _stateLabel.text = @"已连接";
        break;
        case MTTLiveError:
        _stateLabel.text = @"连接错误";
        break;
        case MTTLiveStop:
        _stateLabel.text = @"未连接";
        break;
    default:
        break;
    }
}

/** live debug info callback */
- (void)liveSession:(nullable MTTLiveSession *)session debugInfo:(MTTLiveDebug *)debugInfo {
    NSLog(@"debugInfo uploadSpeed: %@", formatedSpeed(debugInfo.currentBandWidth, debugInfo.elaspedMilli));
}

/** callback socket errorcode */
- (void)liveSession:(nullable MTTLiveSession *)session errorCode:(MTTLiveSocketErrorCode)errorCode {
    NSLog(@"errorCode: %lu", (unsigned long)errorCode);
}

- (void)setupSubviews {
    _containerView = [UIView new];
    _containerView.frame = self.bounds;
    _containerView.backgroundColor = [UIColor clearColor];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_containerView];
    
    _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 80, 40)];
    _stateLabel.text = @"未连接";
    _stateLabel.textColor = [UIColor whiteColor];
    _stateLabel.font = [UIFont boldSystemFontOfSize:14.f];
    [_containerView addSubview:_stateLabel];
    
    _closeButton = [UIButton new];
    _closeButton.frame = CGRectMake(100, 100, 100, 44);
    [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_containerView addSubview:_closeButton];
    
    _cameraButton = [UIButton new];
    _cameraButton.frame = CGRectMake(100, 150, 100, 44);
    [_cameraButton setTitle:@"切换" forState:UIControlStateNormal];
    [_cameraButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    _cameraButton.exclusiveTouch = YES;
    [_cameraButton addTarget:self action:@selector(cameraButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_cameraButton];
    
    _beautyButton = [UIButton new];
    _beautyButton.frame = CGRectMake(100, 200, 100, 44);
    [_beautyButton setTitle:@"美颜" forState:UIControlStateNormal];
    [_beautyButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [_beautyButton addTarget:self action:@selector(beautyButtonAction) forControlEvents:UIControlEventTouchUpInside];
    _beautyButton.exclusiveTouch = YES;
    [_containerView addSubview:_beautyButton];
    
    _startLiveButton = [UIButton new];
    _startLiveButton.frame = CGRectMake(100, 250, 100, 44);
    [_startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
    [_startLiveButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    _startLiveButton.exclusiveTouch = YES;
    [_startLiveButton addTarget:self action:@selector(liveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_startLiveButton];
}

#pragma mark -- Getter Setter
- (MTTLiveSession *)session {
    if (!_session) {
        /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/
        /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/
        /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/


        /***   默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏 ***/
        MTTLiveVideoConfiguration *videoConfiguration = [MTTLiveVideoConfiguration new];
        videoConfiguration.videoSize = CGSizeMake(360, 640);
        videoConfiguration.videoBitRate = 800*1024;
        videoConfiguration.videoMaxBitRate = 1000*1024;
        videoConfiguration.videoMinBitRate = 500*1024;
        videoConfiguration.videoFrameRate = 24;
        videoConfiguration.videoMaxKeyframeInterval = 48;
        videoConfiguration.outputImageOrientation = UIInterfaceOrientationPortrait;
        videoConfiguration.autorotate = NO;
        videoConfiguration.sessionPreset = MTTCaptureSessionPreset720x1280;
        _session = [[MTTLiveSession alloc] initWithAudioConfiguration:[MTTLiveAudioConfiguration defaultConfiguration] videoConfiguration:videoConfiguration captureType:MTTLiveCaptureDefaultMask];

        /**    自己定制单声道  */
        /*
           MTTLiveAudioConfiguration *audioConfiguration = [MTTLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 1;
           audioConfiguration.audioBitrate = MTTLiveAudioBitRate_64Kbps;
           audioConfiguration.audioSampleRate = MTTLiveAudioSampleRate_44100Hz;
           _session = [[MTTLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[MTTLiveVideoConfiguration defaultConfiguration]];
         */

        /**    自己定制高质量音频96K */
        /*
           MTTLiveAudioConfiguration *audioConfiguration = [MTTLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = MTTLiveAudioBitRate_96Kbps;
           audioConfiguration.audioSampleRate = MTTLiveAudioSampleRate_44100Hz;
           _session = [[MTTLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[MTTLiveVideoConfiguration defaultConfiguration]];
         */

        /**    自己定制高质量音频96K 分辨率设置为540*960 方向竖屏 */

        /*
           MTTLiveAudioConfiguration *audioConfiguration = [MTTLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = MTTLiveAudioBitRate_96Kbps;
           audioConfiguration.audioSampleRate = MTTLiveAudioSampleRate_44100Hz;

           MTTLiveVideoConfiguration *videoConfiguration = [MTTLiveVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(540, 960);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 24;
           videoConfiguration.videoMaxKeyframeInterval = 48;
           videoConfiguration.orientation = UIInterfaceOrientationPortrait;
           videoConfiguration.sessionPreset = MTTCaptureSessionPreset540x960;

           _session = [[MTTLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */


        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向竖屏 */

        /*
           MTTLiveAudioConfiguration *audioConfiguration = [MTTLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = MTTLiveAudioBitRate_128Kbps;
           audioConfiguration.audioSampleRate = MTTLiveAudioSampleRate_44100Hz;

           MTTLiveVideoConfiguration *videoConfiguration = [MTTLiveVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(720, 1280);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 15;
           videoConfiguration.videoMaxKeyframeInterval = 30;
           videoConfiguration.landscape = NO;
           videoConfiguration.sessionPreset = MTTCaptureSessionPreset360x640;

           _session = [[MTTLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */


        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向横屏  */

        /*
           MTTLiveAudioConfiguration *audioConfiguration = [MTTLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = MTTLiveAudioBitRate_128Kbps;
           audioConfiguration.audioSampleRate = MTTLiveAudioSampleRate_44100Hz;

           MTTLiveVideoConfiguration *videoConfiguration = [MTTLiveVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(1280, 720);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 15;
           videoConfiguration.videoMaxKeyframeInterval = 30;
           videoConfiguration.landscape = YES;
           videoConfiguration.sessionPreset = MTTCaptureSessionPreset720x1280;

           _session = [[MTTLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
        */

        _session.delegate = self;
        _session.showDebugInfo = NO;
        _session.preView = self;
        
        /*本地存储*/
//        _session.saveLocalVideo = YES;
//        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
//        unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
//        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
//        _session.saveLocalVideoPath = movieURL;
        
        /*
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.alpha = 0.8;
        imageView.frame = CGRectMake(100, 100, 29, 29);
        imageView.image = [UIImage imageNamed:@"ios-29x29"];
        _session.warterMarkView = imageView;*/
        
    }
    return _session;
}

- (void)cameraButtonAction {
    AVCaptureDevicePosition devicePositon = self.session.captureDevicePosition;
    self.session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}


- (void)beautyButtonAction {
    self.session.beautyFace = !self.session.beautyFace;
    self.beautyButton.selected = !self.session.beautyFace;
}

- (void)liveButtonAction:(UIButton *)button {
    button.selected = !button.selected;
    if (self.startLiveButton.selected) {
        [self.startLiveButton setTitle:@"结束直播" forState:UIControlStateNormal];
        MTTLiveStreamInfo *stream = [MTTLiveStreamInfo new];
        stream.url = @"rtmp://192.168.199.233:1935/rtmplive/room";//@"rtmp://live.hkstv.hk.lxdns.com:1935/live/stream153";
        [self.session startLive:stream];
    } else {
        [self.startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
        [self.session stopLive];
    }
}

@end


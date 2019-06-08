//
//  BasePlayerViewController.m
//  MTTIjkPlayer
//
//  Created by waitwalker on 2019/5/25.
//  Copyright © 2019年 cn.waitwalker. All rights reserved.
//

#import "BasePlayerViewController.h"
#import "AppDelegate.h"

@interface BasePlayerViewController ()

@end

@implementation BasePlayerViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 确保在该控制器即将消失的时候关闭全屏模式
    ((AppDelegate *) [[UIApplication sharedApplication] delegate]).fullScreen = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.isLiveVideo = YES; // 设置为直播
    [self.view addSubview:self.playerView];
    // 测试链接 mp4、rtmp、m3u8
    // NSString *testUrl = @"http://flv2.bn.netease.com/videolib3/1604/28/fVobI0704/SD/fVobI0704-mobile.mp4";
     NSString *testUrl = @"rtmp://192.168.10.63:1935/rtmplive/room";
    //NSString *testUrl = @"http://dlhls.cdn.zhanqi.tv/zqlive/49427_jmACJ.m3u8";
    [self showPlayerViewWithUrl:testUrl title:@"视频的标题"];
    // 自动播放
    [self autoPlay];
    
}

#pragma mark -- MTTMediaPlayerViewDelegate

/// 点击关闭按钮
- (void)playerViewClosed:(MTTMediaPlayerView *)player {
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];
}

/// 全屏/非全屏切换
- (void)playerView:(MTTMediaPlayerView *)player fullscreen:(BOOL)fullscreen {
    
    if (fullscreen == YES) {
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight]
                                    forKey:@"orientation"];
    } else {
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationPortrait]
                                    forKey:@"orientation"];
    }
}

/// 播放失败
- (void)playerViewFailePlay:(MTTMediaPlayerView *)player {
    NSLog(@"播放失败");
}

/// 准备播放
- (BOOL)playerViewWillBeginPlay:(MTTMediaPlayerView *)player {
    NSLog(@"准备播放");
    return YES;
}

#pragma mark -- 旋转屏幕
// 改变View大小布局
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft ||
        [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        self.mediaPlayerView.frame = CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT);
        self.mediaPlayerView.player.view.frame = CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT);
        self.mediaPlayerView.mediaControl.fullScreenBtn.selected = YES;
        self.mediaPlayerView.isFullScreen = YES;
        [kWindow addSubview:self.mediaPlayerView];
    } else {
        self.mediaPlayerView.frame = CGRectMake(0, 0, size.width, size.width/16*9);
        self.mediaPlayerView.player.view.frame = CGRectMake(0, 0, size.width, size.width/16*9);
        self.mediaPlayerView.mediaControl.fullScreenBtn.selected = NO;
        self.mediaPlayerView.isFullScreen = NO;
        [self.playerView addSubview:self.mediaPlayerView];
    }
}

#pragma mark -- 加载 & 移除
- (void)showPlayerViewWithUrl:(NSString *)urlString title:(NSString *)title {
    [self removePlayViewSubViews];
    // 开启全屏模式
    ((AppDelegate *) [[UIApplication sharedApplication] delegate]).fullScreen = YES;
    [self.mediaPlayerView playerViewWithUrl:urlString WithTitle:title WithView:self.playerView WithDelegate:self];
}

- (void)removePlayerView {
    [self removePlayViewSubViews];
    // 关闭全屏模式
    ((AppDelegate *) [[UIApplication sharedApplication] delegate]).fullScreen = NO;
}

- (void)autoPlay {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 自动播放
        [weakSelf.mediaPlayerView.mediaControl playControl];
    });
}


#pragma mark -- private
// 移除播放器视图上面的所有子控件
- (void)removePlayViewSubViews {
    for(int i = 0; i < self.playerView.subviews.count; i++){
        [[self.playerView.subviews objectAtIndex:i] removeFromSuperview];
    }
}



#pragma mark -- getter
- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kMinPlayerHeight)];
        _playerView.backgroundColor = [UIColor lightGrayColor];

    }
    return _playerView;
}

- (MTTMediaPlayerView *)mediaPlayerView {
    if (!_mediaPlayerView) {
        _mediaPlayerView = [[MTTMediaPlayerView alloc] init];
        if (_isLiveVideo) {
            _mediaPlayerView.mediaControl.totalDurationLabel.hidden = YES;
            _mediaPlayerView.mediaControl.mediaProgressSlider.hidden = YES;
            _mediaPlayerView.mediaControl.currentTimeLabel.hidden = YES;
        }
    }
    return _mediaPlayerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


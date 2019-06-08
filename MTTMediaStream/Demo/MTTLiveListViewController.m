//
//  SecondViewController.m
//  MTTIjkPlayer
//
//  Created by waitwalker on 2019/5/26.
//  Copyright © 2019年 cn.waitwalker. All rights reserved.
//

#import "MTTLiveListViewController.h"

@interface MTTLiveListViewController ()

@end

@implementation MTTLiveListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.isLiveVideo = YES;
    [self.view addSubview:self.playerView];
   
    // 测试链接 http、rtmp、hls(m3u8)、本地视频等多种格式
//     NSString *testUrl = @"http://flv2.bn.netease.com/videolib3/1604/28/fVobI0704/SD/fVobI0704-mobile.mp4";
    NSString *testUrl = @"rtmp://192.168.199.233:1935/rtmplive/room";
//    NSString *testUrl = @"http://dlhls.cdn.zhanqi.tv/zqlive/49427_jmACJ.m3u8";
    [self showPlayerViewWithUrl:testUrl title:@"视频的标题"];
    [self autoPlay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:true];
}


@end

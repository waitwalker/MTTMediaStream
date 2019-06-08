//
//  BasePlayerViewController.h
//  MTTIjkPlayer
//
//  Created by waitwalker on 2019/5/25.
//  Copyright © 2019年 cn.waitwalker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MTTMediaPlayerView.h"

@interface BasePlayerViewController : UIViewController <MTTMediaPlayerViewDelegate>

@property (nonatomic, strong) UIView                    *playerView;      //播放器背景图片
@property (nonatomic, strong) MTTMediaPlayerView        *mediaPlayerView; //播放器
@property (nonatomic, assign) BOOL                      isLiveVideo;      // 是否是视频直播

// 加载播放器视图
- (void)showPlayerViewWithUrl:(NSString *)urlString title:(NSString *)title;
// 移除播放器视图
- (void)removePlayerView;
// 自动播放
- (void)autoPlay;

@end

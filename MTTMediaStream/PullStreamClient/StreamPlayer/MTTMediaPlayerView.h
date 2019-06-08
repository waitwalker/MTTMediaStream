//
//  MTTMediaPlayerView.h
//  MTTIjkPlayer
//
//  Created by waitwalker on 2019/6/10.
//  Copyright © 2019年 cn.waitwalker All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "MTTMediaControl.h"
#import "UIView+MTTExtend.h"

@class MTTMediaPlayerView;

@protocol MTTMediaPlayerViewDelegate <NSObject>

/**
 *  点击关闭按钮
 */
- (void)playerViewClosed:(MTTMediaPlayerView *)player;

/**
 *  全屏/非全屏切换
 */
- (void)playerView:(MTTMediaPlayerView *)player fullscreen:(BOOL)fullscreen;
/**
 *  播放失败
 */
- (void)playerViewFailePlay:(MTTMediaPlayerView *)player;


@optional

- (BOOL)playerViewWillBeginPlay:(MTTMediaPlayerView *)player;

@end




@interface MTTMediaPlayerView : UIView


@property (nonatomic, weak)   id<MTTMediaPlayerViewDelegate> delegate;
@property (nonatomic, strong) id<MTTKMediaPlayback>          player;
@property (nonatomic, strong) MTTMediaControl              * mediaControl;
@property (nonatomic, assign) BOOL                          shouldAutoplay;
@property (nonatomic, assign) BOOL                          isFullScreen;
@property (nonatomic, assign) BOOL                          pushPlayerPause;    // 是否push到下个界面
@property (nonatomic, assign) BOOL                          beginPlay;          // 开始播放
@property (nonatomic, assign) NSString                    * historyPlayingTime; // 历史播放时间
@property (nonatomic, strong) UIImageView                 * previewImage;       // 预览图
@property (nonatomic, strong) NSString                    * previewImageName;   // 预览图名字
@property (nonatomic, strong) NSString                    * previewImagePath;   // 预览图路径


- (instancetype)initWithFrame:(CGRect)frame uRL:(NSURL *)url title:(NSString *)title;
-(void)playerViewWithUrl:(NSString*)urlString WithTitle:(NSString*)title WithView:(UIView*)view WithDelegate:(UIViewController*)viewController;
- (void)setIsFullScreen:(BOOL)isFullScreen;


- (void)playerWillShow;
- (void)playerWillHide;
- (void)removePlayer;

/**
 *  预览图
 */
- (void)showPreviewImage:(id)imagePath;
- (void)showLocalPreviewImage:(NSString *)imageName;
// 获取视频文件的第一帧作为预览图
- (void)showFirstFramePreviewImage:(NSString *)videoPath;


@end


//
//  MTTMediaGesturesView.h
//  MTTIjkPlayer
//
//  Created by waitwalker on 2019/6/10.
//  Copyright © 2019年 cn.waitwalker All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MTTMediaGesturesViewDelegate <NSObject>
//移动
-(void)touchesMovedWith:(CGPoint)point;
//开始
-(void)touchesBeganWith:(CGPoint)point;

@end


@interface MTTMediaGesturesView : UIView

@property(nonatomic,assign) id<MTTMediaGesturesViewDelegate>delegate;

@end

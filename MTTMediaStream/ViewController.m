//
//  ViewController.m
//  MTTMediaStream
//
//  Created by LiuChuanan on 2019/5/28.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "ViewController.h"
#import "MTTGPUImageFilterManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *originalImageView = [UIImageView new];
    originalImageView.frame = CGRectMake(100, 100, 200, 150);
    originalImageView.image = [UIImage imageNamed:@"lin"];
    [self.view addSubview:originalImageView];
    
    UIImageView *renderImageView = [UIImageView new];
    renderImageView.frame = CGRectMake(100, 300, 200, 150);
    [self.view addSubview:renderImageView];
    
    UIImage *image = [MTTGPUImageFilterManager renderImage:originalImageView.image filterType:MTTGPUImageToonFilter];
    if (image) {
        renderImageView.image = image;
    }
    
}


@end

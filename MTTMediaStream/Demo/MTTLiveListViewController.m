//
//  MTTLiveListViewController.m
//  MTTMediaStream
//
//  Created by 刘传安 on 2019/6/8.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTLiveListViewController.h"
#import "MTTLiveViewController.h"

@interface MTTLiveListViewController ()

@end

@implementation MTTLiveListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 180) / 2.0, ([UIScreen mainScreen].bounds.size.height - 100) / 2.0, 180, 100)];
    [button setTitle:@"观看直播" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor yellowColor]];
    button.layer.cornerRadius = 10.0;
    button.clipsToBounds = true;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    button.layer.borderWidth = 0.5;
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor purpleColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)buttonAction:(UIButton *)button {
    MTTLiveViewController *vc = [MTTLiveViewController new];
    vc.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:vc animated:true];
}

@end

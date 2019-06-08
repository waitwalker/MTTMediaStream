//
//  MTTTabBarViewController.m
//  MTTMedia
//
//  Created by LiuChuanan on 2019/5/21.
//  Copyright © 2019 waitwalker. All rights reserved.
//

#import "MTTTabBarViewController.h"
#import "MTTLiveListViewController.h"
#import "MTTHomeViewController.h"

@interface MTTTabBarViewController ()

@end

@implementation MTTTabBarViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //主页
    MTTHomeViewController *home = [[MTTHomeViewController alloc]init];
    [self addChildViewController:home image:@"tabbar_home" selectedImage:@"tabbar_home_selected" title:@"开启直播"];
    
    //消息
    MTTLiveListViewController *list = [[MTTLiveListViewController alloc]init];
    [self addChildViewController:list image:@"tabbar_list" selectedImage:@"tabbar_list_selected" title:@"直播列表"];
}

/**
 *  添加子控制器
 *
 *  @param childViewController 子控制器
 *  @param image               tabBarItem正常状态图片
 *  @param selectedImage       tabBarItem选中状态图片
 *  @param title               标题
 */
- (void)addChildViewController:(UIViewController *)childViewController image:(NSString *)image selectedImage:(NSString *)selectedImage title:(NSString *)title {
    
    //标题
    childViewController.title = title;
    childViewController.view.backgroundColor = [UIColor whiteColor];
    
    //tabBarItem图片
    childViewController.tabBarItem.image = [UIImage imageNamed:image];
    childViewController.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //tabBarItem字体的设置
    //正常状态
    NSMutableDictionary *normalText = [NSMutableDictionary dictionary];
    normalText[NSForegroundColorAttributeName] = [UIColor colorWithRed:123/255.0 green:123/255.0 blue:123/255.0 alpha:1.0];
    [childViewController.tabBarItem setTitleTextAttributes:normalText forState:UIControlStateNormal];
    
    //选中状态
    NSMutableDictionary *selectedText = [NSMutableDictionary dictionary];
    selectedText[NSForegroundColorAttributeName] = [UIColor colorWithRed:51/255.0 green:153/255.0 blue:255/255.0 alpha:1.0];
    [childViewController.tabBarItem setTitleTextAttributes:selectedText forState:UIControlStateSelected];
    
    //导航控制器
    UINavigationController *navgationVC = [[UINavigationController alloc]initWithRootViewController:childViewController];
    
    [self addChildViewController:navgationVC];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

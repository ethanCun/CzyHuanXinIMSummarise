//
//  AppDelegate.m
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/21.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "AppDelegate.h"
//不含实时语音版本
#import <HyphenateLite/HyphenateLite.h>
#import "RootViewController.h"
#import "LoginViewController.h"
//导入easeUI
#import <EaseUI.h>

@interface AppDelegate ()<EMClientDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //环信
    EMOptions *options = [EMOptions optionsWithAppkey:APP_KEY];
    options.apnsCertName = DEBUG_CER_NAME;
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    #pragma mark - 保证在根控制器之前初始化EaseSDKHelper(之前我放在初始化根控制器之后 用户自动登录的时候 收到消息不走 messagesDidReceive 方法 [ 原因就是EaseSDKHelper未初始化 socket未建立连接 ]因此收不到消息 所以保证放在最开始的位置)
    [[EaseSDKHelper shareHelper] hyphenateApplication:application didFinishLaunchingWithOptions:launchOptions appkey:APP_KEY apnsCertName:DEBUG_CER_NAME otherConfig:nil];
    
    // 初始化web缓存配置, appkey需要自己去LeanCloud官网注册存储服务
//    [AVOSCloudCrashReporting enable];
//    [AVOSCloud setApplicationId:LearnClound_APPID clientKey:LearnClound_APPKEY];
    
    //设置根控制器
    if ([[CzyDefault objectForKey:isUserLogin] integerValue] == YES) {
        RootViewController *tabBarVc = [[RootViewController alloc] init];
        self.window.rootViewController = tabBarVc;
    }else{
        LoginViewController *loginVc = [[LoginViewController alloc] init];
        self.window.rootViewController = loginVc;
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    
    #pragma mark - 注意不要设置多个EMClientDelegate[之前我在此处设置了EMClientDelegate 又在RootViewController设置了EMClientDelegate 导致用户收到消息之后  点击进入消息列表界面 然后用户自动登录时 不走该代理方法（autoLoginDidCompleteWithError）从而无法更新未读消息数 （原因是因为继承于EaseConversationListViewController的会话列表界面不会释放 demo也一样）]
//    [[EMClient sharedClient] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    return YES;
}


// APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

// APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

@end

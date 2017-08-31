//
//  LoginViewController.m
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/21.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

/*
 注册：
 注册模式分两种，开放注册和授权注册。
 
 只有开放注册时，才可以客户端注册。开放注册是为了测试使用，正式环境中不推荐使用该方式注册环信账号。
 授权注册的流程应该是您服务器通过环信提供的 REST API 注册，之后保存到您的服务器或返回给客户端。
 */

#import "LoginViewController.h"
#import "RootViewController.h"
#import <HyphenateLite/HyphenateLite.h>
#import "RootViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *paswordTF;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

#pragma mark - 注册
- (IBAction)regi:(UIButton *)sender {
    
    [[EMClient sharedClient] registerWithUsername:_accountTF.text password:_paswordTF.text completion:^(NSString *aUsername, EMError *aError) {
        
        DLog(@"aUsername = %@", aUsername);
        DLog(@"aError = %@", aError.errorDescription);
        
        if (aError) {
            [[Tool share] showAlertWithTitle:aError.errorDescription msg:nil sure:nil sureTitle:@"确定" cancel:nil cancelTitle:nil];
        }else{
            [[Tool share] showAlertWithTitle:@"注册成功" msg:nil sure:nil sureTitle:@"确定" cancel:nil cancelTitle:nil];
            
            //learnClound注册
//            AVUser *user = [AVUser user];
//            user.username = aUsername;
//            user.password = _paswordTF.text;
////            user.email = @"511627807@qq.com";
//            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                
//                DLog(@"succeeded = %d error = %@", succeeded, error);
//            }];
        }
    }];
}

#pragma mark - 登录
- (IBAction)login:(UIButton *)sender {
    
    //须先调用退出登录 强制性退出 否则一直报已登录
    if ([EMClient sharedClient].options.isAutoLogin) {
        [[EMClient sharedClient] logout:YES];
    }
    
    [[EMClient sharedClient] loginWithUsername:_accountTF.text password:_paswordTF.text completion:^(NSString *aUsername, EMError *aError) {
        
        DLog(@"aUsername = %@", aUsername);
        DLog(@"aError = %@", aError.errorDescription);
        
        //自动登录
        if (aError == nil) {
            //环信实现自动登录
            [[EMClient sharedClient].options setIsAutoLogin:YES];
            //自己应用设置自动登录
            [CzyDefault setObject:@(YES) forKey:isUserLogin];
            //记录当前登录账号(账户)
            [CzyDefault setObject:aUsername forKey:customAccount];
            [CzyDefault synchronize];
            //存入数据库(昵称 头像等)
            UserModel *model = [UserModel new];
            model.account = aUsername;
            model.nickname = aUsername;
            model.huanXinId = aUsername;
            [[DataManaget share] insertUserWithModel:model];
            //调到到首页
            [UIApplication sharedApplication].keyWindow.rootViewController = [RootViewController new];
            //手动登录 显示用户未读取消息条数
            RootViewController *rootVc = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            [rootVc czyUnreadMessagesCount];
            
            //第三方后台登录
//            NSString *username = _accountTF.text;
//            NSString *password = _paswordTF.text;
//            [AVUser logInWithUsernameInBackground:username password:password block:^(AVUser *user, NSError *error) {
//                
//                DLog(@"user = %@ error = %@", user, error);
//
//            }];
            
        }else{
            [[Tool share] showAlertWithTitle:[NSString stringWithFormat:@"%d-%@", aError.code, aError.errorDescription] msg:nil sure:nil sureTitle:@"确定" cancel:nil cancelTitle:nil];
        }
    }];
}


@end

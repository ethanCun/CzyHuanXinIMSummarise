//
//  RootViewController.h
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/21.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITabBarController

//公开改变未读消息条数的方法
- (void)czyUnreadMessagesCount;
- (void)czyUnreadMessagesCountZero;

@end

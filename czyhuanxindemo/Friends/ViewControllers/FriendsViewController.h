//
//  FriendsViewController.h
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/21.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import <UIKit/UIKit.h>
//导入easeUI
#import <EaseUI.h>

@interface FriendsViewController : EaseUsersListViewController

//公开一个处理好友各种请求的方法给RootViewController调用
//好友请求变化时，更新好友请求未处理的个数
- (void)reloadApplyViewCount;

//操作好友的增加 删除 等 公开一个刷表的方法
- (void)loadDatas;

@end

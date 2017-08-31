//
//  MessageListViewController.h
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/29.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EaseUI.h>

//继承EaseMessageViewController 遵守EaseMessageViewControllerDelegate, EaseMessageViewControllerDataSource两个协议
@interface MessageListViewController : EaseMessageViewController<EaseMessageViewControllerDelegate, EaseMessageViewControllerDataSource>

@end

//
//  MainViewController.h
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/28.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EaseUI.h>

//继承EaseConversationListViewController 遵守EaseConversationListViewControllerDelegate EaseConversationListViewControllerDataSource
@interface MainViewController : EaseConversationListViewController<EaseConversationListViewControllerDataSource, EaseConversationListViewControllerDelegate>

@end

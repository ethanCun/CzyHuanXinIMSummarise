//
//  MainViewController.m
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/28.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#define CzyCustomChatController

#import "MainViewController.h"
#import <EaseUI.h>
#import "MessageListViewController.h" //聊天内容界面

@interface MainViewController ()

@end

@implementation MainViewController

#pragma mark - 生命周期
- (void)viewWillAppear:(BOOL)animated
{
    //加载会话列表
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //显示刷新
    self.showRefreshHeader = YES;
    
    //设置代理
    self.delegate = self;
    self.dataSource = self;
}


#pragma mark - EaseConversationListViewControllerDelegate
#pragma mark - 点击会话跳转到聊天界面
- (void)conversationListViewController:(EaseConversationListViewController *)conversationListViewController didSelectConversationModel:(id<IConversationModel>)conversationModel
{
    EaseConversationModel *model = (EaseConversationModel *)conversationModel;
    
    NSString *buddy = model.conversation.latestMessage.from;
    
    if (!buddy) {
        return;
    }
    
    //跳转到聊天页面
    MessageListViewController *messageListVc = [[MessageListViewController alloc] initWithConversationChatter:buddy conversationType:0];
    messageListVc.hidesBottomBarWhenPushed = YES;
    messageListVc.navigationItem.title = buddy;
    [self.navigationController pushViewController:messageListVc animated:YES];
    
    //发送消息已读的通知
    RootViewController *rootVc = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVc czyUnreadMessagesCount];
}

#pragma mark - EaseConversationListViewControllerDataSource

#pragma mark - conversation转model
- (id<IConversationModel>)conversationListViewController:(EaseConversationListViewController *)conversationListViewController modelForConversation:(EMConversation *)conversation
{
    EaseConversationModel *model = [[EaseConversationModel alloc] initWithConversation:conversation];
        
    return model;
}

#pragma mark - 获取最后一条消息的内容
- (NSAttributedString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController latestMessageTitleForConversationModel:(id<IConversationModel>)conversationModel
{
    EaseConversationModel *model = (EaseConversationModel *)conversationModel;
    
    EMMessage *latestMessage = model.conversation.latestMessage;

    //会话最后一条消息的内容
    NSString *contents = @"";
    
    if (latestMessage) {
        EMMessageBody *body = latestMessage.body;
        
        if (body.type == EMMessageBodyTypeText) {
            
            //判断是否需要转化为表情：系统emoji表情转换为表情编码
            NSString *receiveText = [EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:[(EMTextMessageBody *)body text]];
            contents = receiveText;
            
            if ([latestMessage.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
                
                contents = @"[动画表情]";
            }
            
        }
        return [[NSAttributedString alloc] initWithString:contents];
    }
    
    contents = @"[其他]";
    
    return [[NSAttributedString alloc] initWithString:contents];
}

//最后一条消息显示的时间
- (NSString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController latestMessageTimeForConversationModel:(id<IConversationModel>)conversationModel
{
    EaseConversationModel *model = (EaseConversationModel *)conversationModel;
    
    EMMessage *latestMessage = model.conversation.latestMessage;
    
    NSString *time;
    if (latestMessage) {
        time = [NSDate formattedTimeFromTimeInterval:latestMessage.timestamp];
    }
    
    return time;
}

#pragma mark - dealloc 移除代理 demo里面的会话界面也没释放
- (void)dealloc
{
    DLog(@"main dealloc!");
    
    self.delegate = nil;
    self.dataSource = nil;
}


@end

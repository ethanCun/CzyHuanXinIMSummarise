//
//  MessageListViewController.m
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/29.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "MessageListViewController.h"
#import "CustomMessageCell.h"

@interface MessageListViewController ()<EaseMessageCellDelegate>
{
    NSString *_buddy;
    EMConversationType _conversationType;
}

@end

@implementation MessageListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //显示刷新
    self.showRefreshHeader = YES;
    
    
    #pragma mark - 设置代理
    self.delegate = self;
    self.dataSource = self;
    
    //设置会话框样式
    //[self setConversationStyle];
    
#pragma mark - 聊天会话输入框自定义(底部整个框)
//    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(0, FULL_HEIGHT-200, FULL_WIDTH, 200)];
//    redView.backgroundColor = [UIColor redColor];
//    self.chatToolbar = redView;
    
#pragma mark - 自定义底部功能区域
//    [self.chatBarMoreView insertItemWithImage:[UIImage imageNamed:@"资料"] highlightedImage:nil title:@"资料"];
//    [self.chatBarMoreView updateItemWithImage:[UIImage imageNamed:@"资料"] highlightedImage:nil title:@"删除" atIndex:0];
//    [self.chatBarMoreView removeItematIndex:2];
    
    #pragma mark - 发送消息
    //发送文字消息
//    EMMessage *message = [EaseSDKHelper sendTextMessage:@"要发送的消息"
//                                                     to:@"6001"//接收方
//                                            messageType:EMChatTypeChat//消息类型
//                                             messageExt:nil]; //扩展信息
}

#pragma mark - 聊天会话样式自定义 聊天样式的自定义需要在 EaseMessageViewController 中 viewDidload 结束前设置。
- (void)setConversationStyle
{
    #pragma mark - 设置发送气泡
//    [[EaseBaseMessageCell appearance] setSendBubbleBackgroundImage:[[UIImage imageNamed:@"资料"] stretchableImageWithLeftCapWidth:5 topCapHeight:35]];
    #pragma mark - 设置接受气泡
//    [[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"退出"] stretchableImageWithLeftCapWidth:5 topCapHeight:35]];
    #pragma mark - 设置头像相关
    [[EaseBaseMessageCell appearance] setAvatarSize:20];
    [[EaseBaseMessageCell appearance] setAvatarCornerRadius:10];
    #pragma mark - 消息字体颜色设置
    [[EaseBaseMessageCell appearance] setMessageTextFont:[UIFont systemFontOfSize:16]];
    #pragma mark - 位置
    [[EaseBaseMessageCell appearance] setMessageLocationColor:[UIColor redColor]];
    #pragma mark - 语音图片数组
//    [[EaseBaseMessageCell appearance] setSendMessageVoiceAnimationImages:@[[UIImage imageNamed:@"组-1"],[UIImage imageNamed:@"资料"],[UIImage imageNamed:@"退出"]]];
}

#pragma mark - 下拉刷新
- (void)tableViewDidTriggerHeaderRefresh
{
    NSString *startMessageId = [(EMMessage *)self.messsagesSource.firstObject messageId];
    
    //要获取漫游消息的Conversation id
    [[EMClient sharedClient].chatManager asyncFetchHistoryMessagesFromServer:self.conversation.conversationId conversationType:_conversationType startMessageId:startMessageId pageSize:10 complation:^(EMCursorResult *aResult, EMError *aError) {
        
        [super tableViewDidTriggerHeaderRefresh];
    }];
}

#pragma mark - 实现自定义聊天样式
#pragma mark - EaseMessageViewControllerDelegate
#pragma mark - 获取消息自定义cell
- (UITableViewCell *)messageViewController:(UITableView *)tableView
                       cellForMessageModel:(id<IMessageModel>)messageModel
{
    NSDictionary *ext = messageModel.message.ext;
    //处理语音
    if ([ext objectForKey:@"em_recall"]) {
        NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
        EaseMessageTimeCell *recallCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        
        if (recallCell == nil) {
            recallCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
            recallCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        EMTextMessageBody *body = (EMTextMessageBody*)messageModel.message.body;
        recallCell.title = body.text;
        return recallCell;
    }
    return nil;
}

- (CGFloat)messageViewController:(EaseMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth
{
    NSDictionary *ext = messageModel.message.ext;
    if ([ext objectForKey:@"em_recall"]) {
        //返回时间分割cell的高度
        return self.timeCellHeight;
    }
    return 0;
}

#pragma mark - 选中消息的回调 实现这个方法则需要自己处理对语音 图片 位置的处理
//- (BOOL)messageViewController:(EaseMessageViewController *)viewController didSelectMessageModel:(id<IMessageModel>)messageModel
//{
//    #pragma mark - 点击消息播放语音(EMVoiceMessageBody)
//#warning 如果是text则不走这个方法 实现这个方法则需要自己处理对语音 图片 位置的处理
//    EaseMessageModel *model = (EaseMessageModel *)messageModel;
//    
//    DLog(@"选中消息的回调 :text = %@", model.message.body);
//    
//    return YES;
//}

- (void)messageViewControllerMarkAllMessagesAsRead:(EaseMessageViewController *)viewController
{
    RootViewController *rootVc = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVc czyUnreadMessagesCountZero];
}

#pragma mark - 读取消息 先走这个
- (void)messagesDidRead:(NSArray *)aMessages
{
    RootViewController *rootVc = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVc czyUnreadMessagesCountZero];
}
//再走didReceiveHasReadAckForModel
- (void)messageViewController:(EaseMessageViewController *)viewController didReceiveHasReadAckForModel:(id<IMessageModel>)messageModel
{
    RootViewController *rootVc = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVc czyUnreadMessagesCountZero];
}

- (BOOL)messageViewControllerShouldMarkMessagesAsRead:(EaseMessageViewController *)viewController
{
    return YES;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController shouldSendHasReadAckForMessage:(EMMessage *)message
                         read:(BOOL)read
{
    return YES;
}


#pragma mark - 选中头像的回调
- (void)messageViewController:(EaseMessageViewController *)viewController didSelectAvatarMessageModel:(id<IMessageModel>)messageModel
{
    EaseMessageModel *model = (EaseMessageModel *)messageModel;
    
    DLog(@"选中头像的回调 选中消息头像后，进入该消息发送者的个人信息:text = %@", model.message.body);
    
    
}

#pragma mark - 底部录音功能按钮状态回调
- (void)messageViewController:(EaseMessageViewController *)viewController didSelectRecordView:(UIView *)recordView withEvenType:(EaseRecordViewType)type
{
    switch (type) {
        case EaseRecordViewTypeTouchDown:
        {
            DLog(@"录音按钮按下");
            
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonTouchDown];
            }
        }
            break;
        case EaseRecordViewTypeDragInside:
        {
            DLog(@"手指移动到录音按钮内部");
            
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonDragInside];
            }
        }
            break;
        case EaseRecordViewTypeDragOutside:
        {
            DLog(@"手指移动到录音按钮外部");
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonDragOutside];
            }
        }
            break;
        case EaseRecordViewTypeTouchUpInside:
        {
            DLog(@"手指在录音按钮内部时离开");
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonTouchUpInside];
            }
            //移除
            [self.recordView removeFromSuperview];
        }
            break;
        case EaseRecordViewTypeTouchUpOutside:
        {
            DLog(@"手指在录音按钮外部时离开");
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonTouchUpOutside];
            }
            //移除
            [self.recordView removeFromSuperview];
        }
            break;
        default:
            break;
    }
}


#pragma mark - EaseMessageViewControllerDataSource
#pragma mark - 长按消息
- (BOOL)messageViewController:(EaseMessageViewController *)viewController canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController didLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"触发长按手势");
    
    //长按cell之后显示menu视图
    id obj = self.dataArray[indexPath.row];
    
    if (![obj isKindOfClass:[NSString class]]) {
        
        EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell becomeFirstResponder];
        self.menuIndexPath = indexPath;
        //显示消息长按菜单
        [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:[(EaseMessageModel *)cell.model bodyType]];
    }
    return YES;
}

#pragma mark - 将EMMessage类型转换为符合<IMessageModel>协议的类型，设置用户信息，消息显示用户昵称和头像 重新设置 会覆盖 cellForModel.
//- (id<IMessageModel>)messageViewController:(EaseMessageViewController *)viewController modelForMessage:(EMMessage *)message
//{
//    EaseMessageModel *model = [[EaseMessageModel alloc] initWithMessage:message];
//    
//    model.avatarImage = [UIImage imageNamed:@""];
//    model.nickname = @"";
//    
//    return model;
//}


@end

//
//  RootViewController.m
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/21.
//  Copyright © 2017年 macOfEthan. All rights reserved.

/*会话 好友管理等 全放在 根控制器管理*/

#import "RootViewController.h"
#import "MainViewController.h"
#import "MineViewController.h"
#import "FriendsViewController.h"
#import "LoginViewController.h"

@interface RootViewController ()<EMContactManagerDelegate,EMChatManagerDelegate, EMClientDelegate>
{
    MainViewController *_main;
    FriendsViewController *_friend;
    MineViewController *_mine;
}
//会话：未读消息数量
@property (nonatomic, assign) NSInteger unReadMessageCount;

@end

@implementation RootViewController

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _main = [MainViewController new];
    _friend = [FriendsViewController new];
    _mine = [MineViewController new];
    
    UINavigationController *mainNav = [[UINavigationController alloc] initWithRootViewController:_main];
    UINavigationController *friendsMav = [[UINavigationController alloc] initWithRootViewController:_friend];
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:_mine];
    
    _main.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"消息" image:[UIImage imageNamed:@"tabbar_chats"] selectedImage:[UIImage imageNamed:@"tabbar_chatsHL"]];
    _friend.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"好友列表" image:[UIImage imageNamed:@"tabbar_contacts"] selectedImage:[UIImage imageNamed:@"tabbar_contactsHL"]];
    _mine.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:[UIImage imageNamed:@"tabbar_setting"] selectedImage:[UIImage imageNamed:@"tabbar_settingHL"]];
    
    _main.title = @"会话";
    _friend.title = @"好友列表";
    _mine.title = @"设置";
    
    self.viewControllers = @[mainNav,
                             friendsMav,
                             mineNav];
    
    #pragma mark - 退出登录的时候 一定要移除代理 因此在dealloc中移除
    //好友关系管理代理
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    //消息代理
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    //用户代理
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
}

#pragma mark - EMClientDelegate 
#pragma mark - 自动登录完成 监听未显示消息条数
- (void)autoLoginDidCompleteWithError:(EMError *)aError
{
    if ([[EMClient sharedClient] isConnected]) {
        [self czyUnreadMessagesCount];
    }
    
    if (aError) {
        LoginViewController *loginVc = [[LoginViewController alloc] init];
        [UIApplication sharedApplication].keyWindow.rootViewController = loginVc;
    }
}

#pragma mark - EMChatManagerDelegate
- (void)userAccountDidLoginFromOtherDevice
{
    [self forceToLogOut];
}

- (void)userAccountDidForcedToLogout:(EMError *)aError
{
    [self forceToLogOut];
}

#pragma mark - 会话列表发生变化
- (void)conversationListDidUpdate:(NSArray *)aConversationList
{
    [self czyUnreadMessagesCount];
}

#pragma mark - 强制退出
- (void)forceToLogOut
{
    _main = nil;
    _friend = nil;
    _mine = nil;
    
    //退出登录 是否解除device token的绑定
    [[EMClient sharedClient] logout:NO];
}

#pragma mark - 监听 未读消息条数 基于socket封装
- (void)messagesDidReceive:(NSArray *)aMessages
{
    [self czyUnreadMessagesCount];
    
    //刷新会话列表
    [_main tableViewDidTriggerHeaderRefresh];
}

#pragma mark - 对方已读消息
- (void)messagesDidRead:(NSArray *)aMessages
{
    DLog(@"对方已读消息");
}

- (void)messagesDidDeliver:(NSArray *)aMessages
{
    DLog(@"消息已经传递");
}

#pragma mark - 设置会话未读消息数目
- (void)czyUnreadMessagesCount
{
    NSInteger count = [self unReadMessageCountAll];
    
    DLog(@"count = %ld", count);
    
    if (count > 0) {
        _main.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", count];
    }else{
        _main.navigationController.tabBarItem.badgeValue = nil;
    }
}

#pragma mark - 归零
- (void)czyUnreadMessagesCountZero
{
    _main.navigationController.tabBarItem.badgeValue = nil;
}

#pragma mark - 获取所有的未读消息数量
- (NSInteger)unReadMessageCountAll
{
    //置0
    _unReadMessageCount = 0;
    
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    
    for (EMConversation *conversation in conversations) {
        
        _unReadMessageCount += conversation.unreadMessagesCount;
        
        DLog(@"count = %d", conversation.unreadMessagesCount);

    }
    
    return _unReadMessageCount;
}

#pragma mark - 设置好友列表各种请求的数量


#pragma mark - EMContactManagerDelegate
//用户B同意用户A的加好友请求后，用户A会收到这个回调 aUsername==B
- (void)friendRequestDidApproveByUser:(NSString *)aUsername
{
    //这里接受回调的对象是发送好友请求的一方
    //测试好友请求  一定要保证当前账号 不是原来的 这里易出错 最好是卸载一次app
    DLog(@"friendRequestDidApproveByUser aUsername = %@", aUsername);
}

//用户B拒绝用户A的加好友请求后，用户A会收到这个回调
- (void)friendRequestDidDeclineByUser:(NSString *)aUsername
{
    DLog(@"friendRequestDidDeclineByUser aUsername = %@", aUsername);
    
    //此处收到回调的对象是好友请求发送方
    [[Tool share] showAlertWithTitle:[NSString stringWithFormat:@"%@拒绝了您的好友请求", aUsername] msg:nil sure:nil sureTitle:@"确定" cancel:nil cancelTitle:nil];
}

//用户B同意用户A的好友申请后，用户A和用户B都会收到这个回调
- (void)friendshipDidAddByUser:(NSString *)aUsername
{
    DLog(@"friendshipDidAddByUser");
    
    //失败：可能是因为已经是还有 或者当前用户错误（数据未清空）
    
    [[Tool share] showAlertWithTitle:[NSString stringWithFormat:@"添加好友成功"] msg:nil sure:nil sureTitle:@"确定" cancel:nil cancelTitle:nil];

    //重新加载数据 并刷新表格
    [_friend loadDatas];
}

//用户B删除与用户A的好友关系后，用户A，B会收到这个回调
- (void)friendshipDidRemoveByUser:(NSString *)aUsername
{
    DLog(@"friendshipDidRemoveByUser aUsername = %@", aUsername);
    
    //重新加载数据 并刷新表格
    [_friend loadDatas];
}

//用户B申请加A为好友后，用户A会收到这个回调 aMessage:好友邀请信息
- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername message:(NSString *)aMessage
{
    DLog(@"friendRequestDidReceiveFromUser aUsername = %@ aMessage = %@", aUsername, aMessage);
    
    #pragma mark - 设置好友列表界面未处理还有关系数量 并保存到本地数据库 （最好是保存到app服务器）
//    FriendShipModel *model = [[FriendShipManager share] searchAllFriendshipModels].firstObject;
//    
//    DLog(@"model = %@", model);
//    
//    if (model == nil) {
//        return;
//    }
//    
//    model.friendApplyCount ++;
//    
//    
//    [_friend reloadApplyViewCount];
    
//    return;
    
    //不在这里处理 点击好友列表再去处理好友请求
    [[Tool share] showAlertWithTitle:[NSString stringWithFormat:@"收到来自%@的好友请求:%@", aUsername, aMessage] msg:@"" sure:^(UIAlertAction *action) {
        
        //接受好友请求
        [[EMClient sharedClient].contactManager approveFriendRequestFromUser:aUsername completion:^(NSString *aUsername, EMError *aError) {
            
            DLog(@"aUsername = %@ aError = %@", aUsername, aError);
            
            if (aError) {
                [[Tool share] showAlertWithTitle:[NSString stringWithFormat:@"接受失败%d:%@", aError.code, aError.errorDescription] msg:nil sure:^(UIAlertAction *action) {
                    
                } sureTitle:@"确定" cancel:nil cancelTitle:nil];
            }else{
                
                
            }
        }];
        
    } sureTitle:@"接受" cancel:^(UIAlertAction *action) {
        
        //拒绝好友请求
        [[EMClient sharedClient].contactManager declineFriendRequestFromUser:aUsername completion:^(NSString *aUsername, EMError *aError) {
            
            DLog(@"aUsername = %@ aError = %@", aUsername, aError);
            
            if (aError) {
                [[Tool share] showAlertWithTitle:[NSString stringWithFormat:@"拒绝失败%d:%@", aError.code, aError.errorDescription] msg:nil sure:^(UIAlertAction *action) {
                    
                } sureTitle:@"确定" cancel:nil cancelTitle:nil];
            }else{
                
                
            }
        }];
        
    } cancelTitle:@"拒绝"];
}

#pragma mark - 退出登录的时候释放
#pragma mark - 退出登录的时候 一定要移除代理 因此在dealloc中移除
- (void)dealloc
{
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    
    DLog(@"dealloc");
}


@end

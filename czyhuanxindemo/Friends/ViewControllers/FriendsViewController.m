//
//  FriendsViewController.m
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/21.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "FriendsViewController.h"
#import "MessageListViewController.h" // 聊天内容界面
#import <HyphenateLite/HyphenateLite.h>
//#import "ApplyViewController.h"

@interface FriendsViewController ()<EaseUserCellDelegate, EMContactManagerDelegate, UIActionSheetDelegate>
//联系人及联系列表
@property (nonatomic, strong) NSMutableArray *contactDatas;
//索引
@property (nonatomic, strong) NSMutableArray *sectionTitles;
//账号登录的其他平台数量
@property (nonatomic, strong) NSMutableArray *otherPlatforms;

// 添加好友
@property (nonatomic, strong) UIBarButtonItem *addFriends;
//好友关系变化时 记录申请与通知的数量
@property (nonatomic, assign) NSInteger unapplyCount;


@end

@implementation FriendsViewController

#pragma mark - Getter
- (UIBarButtonItem *)addFriends
{
    if (!_addFriends) {
        self.addFriends = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriends:)];
    }
    return _addFriends;
}

- (NSMutableArray *)contactDatas
{
    if (!_contactDatas) {
        self.contactDatas = [NSMutableArray array];
    }
    return _contactDatas;
}

- (NSMutableArray *)sectionTitles
{
    if (!_sectionTitles) {
        self.sectionTitles = [NSMutableArray array];
    }
    return _sectionTitles;
}

- (NSMutableArray *)otherPlatforms
{
    if (!_otherPlatforms) {
        self.otherPlatforms = [NSMutableArray array];
    }
    return _otherPlatforms;
}

#pragma mark - 生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [self reloadApplyViewCount];
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.navigationItem.rightBarButtonItem = self.addFriends;
    

    //设置代理
//    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    
    //上下拉刷新
    self.showRefreshHeader = YES;
//    self.showRefreshFooter = YES;
//    [self tableViewDidTriggerHeaderRefresh];
//    [self tableViewDidTriggerFooterRefresh];
    
    //空白提示
    self.showTableBlankView = YES;
    
    //显示搜索框
    self.showSearchBar = YES;
}

#pragma mark - 开始刷新
- (void)tableViewDidTriggerHeaderRefresh
{
    [self showHudInView:self.view hint:@"正在加载"];
    
    //该账号在其他平台登录情况
    [[EMClient sharedClient].contactManager getSelfIdsOnOtherPlatformWithCompletion:^(NSArray *aList, EMError *aError) {
        
        for (NSString *platform in aList) {
            
            [self.otherPlatforms addObject:platform];
        }
        
    }];
    
    //重新加载数据
    [self loadDatas];

}

#pragma mark - 好友请求变化时，更新好友请求未处理的个数
- (void)reloadApplyViewCount
{
//    NSInteger count = [[[ApplyViewController shareController] dataSource] count];
    self.unapplyCount = [[[FriendShipManager share] searchAllFriendshipModels].firstObject friendApplyCount];
    
    DLog(@"self.unapplyCount = %ld", self.unapplyCount);
    
    [self.tableView reloadData];
}

#pragma mark - 添加好友
- (void)addFriends:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加好友" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"好友账号";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"添加理由";
    }];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //添加好友 同步方法，会阻塞当前线程
        [[EMClient sharedClient].contactManager addContact:alert.textFields.firstObject.text message:alert.textFields.lastObject.text];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:sure];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{
        
        
    }];
}


#pragma mark - 获取数据
- (void)loadDatas
{
    //先移除所有 这个会多次调用
    [self.contactDatas removeAllObjects];
    [self.sectionTitles removeAllObjects];
    
    //所有
    NSArray *contacts = [[EMClient sharedClient].contactManager getContacts];
    
    for (NSString *contactName in contacts) {
        [self.contactDatas addObject:contactName];
    }
    
    //储存名字 非模型
    NSMutableArray *contactsArr = [NSMutableArray array];
    
    //去除黑名单
    NSArray *blacks = [[EMClient sharedClient].contactManager getBlackList];
    for (NSString *blackName in blacks) {
        
        if ([self.contactDatas containsObject:blackName]) {
            [self.contactDatas removeObject:blackName];
        }
    }
    
    //contactsArr 只装名字 self.contactDatas 用来装模型
    [contactsArr addObjectsFromArray:self.contactDatas];
    [self.contactDatas removeAllObjects];
    
    //根据好友名称分组 并排序
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    [self.sectionTitles addObjectsFromArray:[collation sectionTitles]];
    
    //用来排序的数组
    NSMutableArray *sortedArr = [NSMutableArray array];
    
    for (NSInteger i=0; i<self.sectionTitles.count; i++) {
        
        NSMutableArray *sectionArr = [NSMutableArray array];
        
        [sortedArr addObject:sectionArr];
        
    }
    
    for (NSString *name in contactsArr) {
        
        EaseUserModel *model = [[EaseUserModel alloc] initWithBuddy:name];
        
        if (model) {
            model.nickname = name;
            model.avatarImage = [UIImage imageNamed:@"资料"];
            
            //获取首字母大写
            NSString *firstLetter = [EaseChineseToPinyin pinyinFromChineseString:name];
            
            NSInteger section;
            if (firstLetter.length > 0) {
                
                section = [[UILocalizedIndexedCollation currentCollation] sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
            }else{
                
                section = contactsArr.count - 1;
            }
            
            NSMutableArray *arr = [sortedArr objectAtIndex:section];
            [arr addObject:model];
        }
    }
    
    //对section内的每个数组排序
    for (NSInteger i=0; i<sortedArr.count; i++) {
        
        NSMutableArray *sectionArrays = [sortedArr objectAtIndex:i];
        
        NSArray *arr = [sectionArrays sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            EaseUserModel *model1 = (EaseUserModel *)obj1;
            EaseUserModel *model2 = (EaseUserModel *)obj2;
            
            NSString *firstLetter1 = [EaseChineseToPinyin pinyinFromChineseString:[model1.nickname lowercaseString]];
            NSString *firstLetter2 = [EaseChineseToPinyin pinyinFromChineseString:[model2.nickname lowercaseString]];
            
            return [firstLetter1 caseInsensitiveCompare:firstLetter2];
        }];
        
        //替换
        [sortedArr replaceObjectAtIndex:i withObject:arr];
    }
    
    //移除空的sectionArr 注意从后往前移除
    for (NSInteger i=sortedArr.count-1; i>=0; i--) {
        
        NSMutableArray *arr = sortedArr[i];
        
        if (arr.count == 0) {
            [sortedArr removeObjectAtIndex:i];
            [self.sectionTitles removeObjectAtIndex:i];
        }
    }
    
    //重新添加
    [self.contactDatas addObjectsFromArray:sortedArr];
    
    //刷表
    [self.tableView reloadData];
    
    //去除提示
    [self hideHud];
    //加载结束
    [self tableViewDidFinishTriggerHeader:YES reload:NO];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.contactDatas.count+2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        return 3;
    }else if (section == 1){
        return self.otherPlatforms.count;
    }else{
        return [self.contactDatas[section-2] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            NSString *userUdentify = @"notify";
            EaseUserCell *cell = (EaseUserCell *)[tableView dequeueReusableCellWithIdentifier:userUdentify];
            if (cell == nil) {
                cell = [[EaseUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userUdentify];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.titleLabel.text = @"申请与通知";
            cell.avatarView.image = [UIImage imageNamed:@""];
            cell.avatarView.badge = self.unapplyCount;
            
            return cell;
            
        }else if (indexPath.row == 1){
        
            NSString *userUdentify = @"group";
            EaseUserCell *cell = (EaseUserCell *)[tableView dequeueReusableCellWithIdentifier:userUdentify];
            if (cell == nil) {
                cell = [[EaseUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userUdentify];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.text = @"群组";
            
            return cell;
            
        }else{
        
            NSString *userUdentify = @"chatroom";
            EaseUserCell *cell = (EaseUserCell *)[tableView dequeueReusableCellWithIdentifier:userUdentify];
            if (cell == nil) {
                cell = [[EaseUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userUdentify];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.text = @"聊天室";
            
            return cell;
        }
    }else if (indexPath.section == 1){
    
        NSString *userUdentify = @"otherplatform";
        EaseUserCell *cell = (EaseUserCell *)[tableView dequeueReusableCellWithIdentifier:userUdentify];
        if (cell == nil) {
            cell = [[EaseUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userUdentify];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabel.text = self.otherPlatforms[indexPath.row];
        
        return cell;
    
    }else{
    
#pragma mark - 好友列表cell
        NSString *usedIdentify = [EaseUserCell cellIdentifierWithModel:nil];
        
        EaseUserCell *cell = (EaseUserCell *)[tableView dequeueReusableCellWithIdentifier:usedIdentify];
        
        if (cell == nil) {
            cell = [[EaseUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:usedIdentify];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = YES;
        
        EaseUserModel *model = self.contactDatas[indexPath.section-2][indexPath.row];
        
        cell.model = model;
        
#pragma mark - 当前cell在tabeleView的位置 设置了这个才会走 长按的代理
        cell.indexPath = indexPath;
        cell.delegate = self;
        
        return cell;
        
    }
}

#pragma mark - 跳转到聊天列表界面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section <= 1) {
        return;
    }
    
    EaseUserModel *model = self.contactDatas[indexPath.section-2][indexPath.row];
    
    #pragma mark - 初始化聊天页面initWithConversationChatter:conversationType
    MessageListViewController *messageListVc = [[MessageListViewController alloc] initWithConversationChatter:model.nickname conversationType:0];
    //隐藏tabbat
    messageListVc.hidesBottomBarWhenPushed = YES;
    //设置title
    messageListVc.navigationItem.title = model.nickname;
    [self.navigationController pushViewController:messageListVc animated:YES];
}

#pragma mark - 设置索引
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionTitles;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section <= 1) {
        return nil;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FULL_WIDTH, 30)];
    
    headerView.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *headerLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 20)];
    headerLab.text = [NSString stringWithFormat:@"%@",self.sectionTitles[section-2]];
    
    [headerView addSubview:headerLab];
    
    return headerView;
}

#pragma mark - 删除好友
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section <= 1) {
        return nil;
    }
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [[Tool share] showAlertWithTitle:@"确定删除该好友吗?" msg:nil sure:^(UIAlertAction *action) {
            
            EaseUserModel *model = self.contactDatas[indexPath.section-2][indexPath.row];
            
            //删除联系人
            [[EMClient sharedClient].contactManager deleteContact:model.nickname isDeleteConversation:YES];
            
            //重新加载数据
            [self loadDatas];
            
        } sureTitle:@"确定" cancel:^(UIAlertAction *action) {
            
            
        } cancelTitle:@"取消"];

    }];
    
    return @[delete];
}

#pragma mark - 设置高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return 0.1;
    }
    
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section <= 1) {
        return 44;
    }
    return 50;
}

#pragma mark - EaseUserCellDelegate
- (void)cellLongPressAtIndexPath:(NSIndexPath *)indexPath
{
    #pragma mark - 选中的好友(用户)cell长按回调

    if (indexPath.section <= 1) {
        return;
    }
    
    [[Tool share] showAlertWithTitle:@"加入黑名单" msg:nil sure:^(UIAlertAction *action) {
        
        EaseUserModel *model = self.contactDatas[indexPath.section-2][indexPath.row];
        
        //加入黑名单
        [[EMClient sharedClient].contactManager addUserToBlackList:model.nickname completion:^(NSString *aUsername, EMError *aError) {
            
            DLog(@"aUsername = %@, error = %@", aUsername, aError);
            
            if (!aError) {
                
                //重新加载好友列表
                [self loadDatas];
            }
            
        }];
        
    } sureTitle:@"确定" cancel:nil cancelTitle:@"取消"];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

}

#pragma mark - dealloc 退出登录的时候才销毁 push到消息界面并不会销毁
- (void)dealloc
{
    DLog(@"dealloc");
}

@end

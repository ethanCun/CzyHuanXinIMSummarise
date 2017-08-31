//
//  BlackListViewController.m
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/30.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "BlackListViewController.h"
#import <EaseUI.h>

@interface BlackListViewController ()
//黑名单数据源
@property (nonatomic, strong) NSMutableArray *blackList;
//索引下表集
@property (nonatomic, strong) NSMutableArray *sectionTitles;

@end

@implementation BlackListViewController

#pragma mark - Getter
- (NSMutableArray *)blackList
{
    if (!_blackList) {
        self.blackList = [NSMutableArray array];
    }
    return _blackList;
}

- (NSMutableArray *)sectionTitles
{
    if (!_sectionTitles) {
        self.sectionTitles = [NSMutableArray array];
    }
    return _sectionTitles;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDatas];
    
}

#pragma mark - 加载数据
- (void)loadDatas
{
    //多次调用 先移除
    [self.blackList removeAllObjects];
    [self.sectionTitles removeAllObjects];
    
    //黑名单
    NSArray *blackLists = [[EMClient sharedClient].contactManager getBlackListFromServerWithError:nil];

    //找索引
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    self.sectionTitles = [[collation sectionTitles] mutableCopy];
    
    //未排序的数组
    NSMutableArray *unSortedArr = [NSMutableArray array];
    
    for (NSInteger i=0; i<self.sectionTitles.count; i++) {
        
        NSMutableArray *indexes = [NSMutableArray array];
        
        [unSortedArr addObject:indexes];
    }
    
    //获取首字母
    for (NSString *name in blackLists) {
        
        //获取首字母
        NSString *firstLetter = [EaseChineseToPinyin pinyinFromChineseString:name];
        //获取下表
        NSInteger section = [[UILocalizedIndexedCollation currentCollation] sectionForObject:firstLetter collationStringSelector:@selector(uppercaseString)];
        //加入到指定数据源
        NSMutableArray *indexes = [unSortedArr objectAtIndex:section];
        //加入
        EaseUserModel *model = [[EaseUserModel alloc] initWithBuddy:name];
        model.nickname = name;
        [indexes addObject:model];
    }
    
    //对数据源排序
    for (NSInteger i=0; i<unSortedArr.count; i++) {
        
        NSArray *sortArr = [[unSortedArr objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            EaseUserModel *model1 = (EaseUserModel *)obj1;
            EaseUserModel *model2 = (EaseUserModel *)obj2;
            
            NSString *firstLetter1 = [EaseChineseToPinyin pinyinFromChineseString:model1.nickname];
            NSString *firsrtLetter2 = [EaseChineseToPinyin pinyinFromChineseString:model2.nickname];
            
            return [[firstLetter1 substringToIndex:1] caseInsensitiveCompare:[firsrtLetter2 substringToIndex:1]];
        }];
        
        //循环替换
        [unSortedArr replaceObjectAtIndex:i withObject:sortArr];
    }
    
    //去除空数组
    for (NSInteger i=unSortedArr.count-1; i>=0; i--) {
        
        if ([[unSortedArr objectAtIndex:i] count] == 0) {
            [unSortedArr removeObjectAtIndex:i];
            [self.sectionTitles removeObjectAtIndex:i];
        }
    }
    
    [self.blackList addObjectsFromArray:unSortedArr];
    
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.blackList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.blackList[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reusedId = [EaseUserCell cellIdentifierWithModel:nil];

    EaseUserCell *cell = (EaseUserCell *)[tableView dequeueReusableCellWithIdentifier:reusedId];
    
    if (cell == nil) {
        cell = [[EaseUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    EaseUserModel *model = self.blackList[indexPath.section][indexPath.row];
    
    cell.model = model;
    
    return cell;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionTitles;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FULL_WIDTH, 20)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *headerLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, FULL_WIDTH, 20)];
    headerLab.text = self.sectionTitles[section];
    [headerView addSubview:headerLab];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"移除黑名单" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [[Tool share] showAlertWithTitle:@"确定移除黑名单吗?" msg:nil sure:^(UIAlertAction *action) {
            
            [self showHudInView:[UIApplication sharedApplication].keyWindow hint:@"正在移除..."];
            
            EaseUserModel *model = self.blackList[indexPath.section][indexPath.row];
            
            [[EMClient sharedClient].contactManager removeUserFromBlackList:model.nickname completion:^(NSString *aUsername, EMError *aError) {
                
                if (!aError) {
                    
                    [self hideHud];
                    
                    //重新回去黑名单 刷表
                    [self loadDatas];
                    
                    [self.tableView reloadData];
                    
                }else{
                
                    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                    sleep(1);
                    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                }
            }];
            
        } sureTitle:@"确定" cancel:^(UIAlertAction *action) {
            
            
        } cancelTitle:@"取消"];
        
    }];
    
    return @[delete];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


@end

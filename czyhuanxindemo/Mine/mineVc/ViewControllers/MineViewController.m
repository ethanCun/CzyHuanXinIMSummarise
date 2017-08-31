//
//  MineViewController.m
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/21.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "MineViewController.h"
#import "LoginViewController.h"
#import <HyphenateLite/HyphenateLite.h>
#import "BlackListViewController.h" //黑名单
#import "ProfileListViewController.h" //个人简介

@interface MineViewController ()

@property (nonatomic, strong) NSMutableArray *titles;


@end

@implementation MineViewController

#pragma mark - Getter
- (NSMutableArray *)titles
{
    if (!_titles) {
        self.titles = [NSMutableArray array];
        [self.titles addObjectsFromArray:@[@"个人简介",@"黑名单"]];
    }
    return _titles;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *logout = [UIButton buttonWithType:UIButtonTypeCustom];
    logout.frame = CGRectMake(0, 0, 100, 30);
    [logout setTitle:@"退出登录" forState:UIControlStateNormal];
    logout.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    [logout setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [logout addTarget:self action:@selector(logOut:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = logout;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.titles[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        //个人简介
        ProfileListViewController *profileVc = [ProfileListViewController new];
        profileVc.navigationItem.title = @"个人简介";
        profileVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:profileVc animated:YES];
        
    }else if (indexPath.row == 1){
        //黑名单
        BlackListViewController *blackListVc = [[BlackListViewController alloc] init];
        blackListVc.hidesBottomBarWhenPushed = YES;
        blackListVc.navigationItem.title = @"黑名单";
        [self.navigationController pushViewController:blackListVc animated:YES];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - 退出登录
- (void)logOut:(UIButton *)sender
{
    [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
        
        if (aError) {
            [[Tool share] showAlertWithTitle:aError.errorDescription msg:nil sure:nil sureTitle:@"确定" cancel:nil cancelTitle:nil];
        }else{
            [CzyDefault removeObjectForKey:isUserLogin];
            [CzyDefault removeObjectForKey:customAccount];
            [CzyDefault synchronize];
            [UIApplication sharedApplication].keyWindow.rootViewController = [LoginViewController new];
            
            //清除数据库
            [[DataManaget share] deleteAllContacts];
        }
    }];
}

@end

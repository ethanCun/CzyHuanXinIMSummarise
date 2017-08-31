//
//  FriendShipManager.m
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/30.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "FriendShipManager.h"

@implementation FriendShipManager

static FriendShipManager *manager = nil;

+ (instancetype)share
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FriendShipManager alloc] init];
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (manager == nil) {
        
        manager = [super allocWithZone:zone];
        
        NSString *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
        
        manager.dataBase = [[FMDatabase alloc] initWithPath:[path stringByAppendingPathComponent:@"friendship.db3"]];
        
        if ([manager.dataBase open]) {
            DLog(@"创建数据库成功");
        }else{
            DLog(@"创建数据库失败");
        }
        
        [manager.dataBase open];
        
        BOOL ret = [manager.dataBase executeUpdate:@"create table if not exists friendshipTable(username text primary key, title text,message text, style int)"];
        if (ret) {
            DLog(@"创表成功");
        }else{
            DLog(@"创表失败");
        }
        
        [manager.dataBase close];
        
    }
    return manager;
}

- (BOOL)insertFriendShipWithModel:(FriendShipModel *)model
{
    [self.dataBase open];
    
    BOOL ret = [self.dataBase executeUpdate:@"insert into friendshipTable(username, title, message, style) values(?,?,?,?)", model.username, model.title, model.message, model.style];
    
    if (ret) {
        DLog(@"插入成功");
    }else{
        DLog(@"插入失败");
    }
    
    [self.dataBase close];
    
    return ret;
}

- (BOOL)deleteAllFriendShips
{
    [self.dataBase open];
    
    BOOL ret = [self.dataBase executeUpdate:@"delete from friendshipTable"];
    
    if (ret) {
        DLog(@"删除成功");
    }else{
        DLog(@"删除失败");
    }
    
    return ret;
}

- (BOOL)deleteFriendshipWithModel:(FriendShipModel *)model
{
    [self.dataBase open];
    
    BOOL ret = [self.dataBase executeUpdate:@"delete from friendshipTable where username = ?",model.username];
    
    if (ret) {
        DLog(@"删除成功");
    }else{
        DLog(@"删除失败");
    }
    
    return ret;
}

- (NSMutableArray *)searchAllFriendshipModels
{
    NSMutableArray *arr = [NSMutableArray array];
    
    [self.dataBase open];
    
    FMResultSet *set = [self.dataBase executeQuery:@"select * from friendshipTable"];
    while ([set next]) {
        
        FriendShipModel *model = [FriendShipModel new];
        model.username = [set stringForColumn:@"username"];
        model.title = [set stringForColumn:@"title"];
        model.message = [set stringForColumn:@"message"];
        model.style = [set intForColumn:@"style"];
        
        [arr addObject:model];
    }
    
    [self.dataBase close];
    
    return arr;
}

@end

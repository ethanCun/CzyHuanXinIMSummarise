//
//  DataManaget.m
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/25.
//  Copyright © 2017年 macOfEthan. All rights reserved.


//userTable:保存当前登录账户资料的表


#import "DataManaget.h"

@implementation DataManaget

static DataManaget *manager = nil;

+ (instancetype)share
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManaget alloc] init];
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (manager == nil) {
        
        manager = [super allocWithZone:zone];
        
        NSString *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
        
        manager.dataBase = [[FMDatabase alloc] initWithPath:[path stringByAppendingPathComponent:@"db.db3"]];
        
        if ([manager.dataBase open]) {
            DLog(@"创建数据库成功");
        }else{
            DLog(@"创建数据库失败");
        }
        
        [manager.dataBase open];
        
        BOOL ret = [manager.dataBase executeUpdate:@"create table if not exists userTable(account text primary key not null, message text,avatorUrl text, nickname text,huanXinId text, apnsPushName text)"];
        if (ret) {
            DLog(@"创表成功");
        }else{
            DLog(@"创表失败");
        }
        
        [manager.dataBase close];
        
    }
    return manager;
}

- (BOOL)insertUserWithModel:(UserModel *)model
{
    [self.dataBase open];
    
    BOOL ret = [self.dataBase executeUpdate:@"insert into userTable(account, message, avatorUrl, nickname, huanXinId,apnsPushName) values(?,?,?,?,?,?)", model.account, model.message,model.avatorUrl, model.nickname, model.huanXinId, model.apnsPushName];
    
    if (ret) {
        DLog(@"插入成功");
    }else{
        DLog(@"插入失败");
    }
    
    [self.dataBase close];
    
    return ret;
}

- (BOOL)deleteAllContacts
{
    [self.dataBase open];
    
    BOOL ret = [self.dataBase executeUpdate:@"delete from userTable"];
    
    if (ret) {
        DLog(@"删除成功");
    }else{
        DLog(@"删除失败");
    }
    
    return ret;
}

- (BOOL)deleteContactWithModel:(UserModel *)model
{
    [self.dataBase open];
    
    BOOL ret = [self.dataBase executeUpdate:@"delete from userTable where huanXinId = ?",model.huanXinId];
    
    if (ret) {
        DLog(@"删除成功");
    }else{
        DLog(@"删除失败");
    }
    
    return ret;
}

- (NSMutableArray *)searchAllModels
{
    NSMutableArray *arr = [NSMutableArray array];
    
    [self.dataBase open];
    
    FMResultSet *set = [self.dataBase executeQuery:@"select * from userTable"];
    while ([set next]) {
        
        UserModel *model = [UserModel new];
        model.account = [set stringForColumn:@"account"];
        model.message = [set stringForColumn:@"message"];
        model.avatorUrl = [set stringForColumn:@"avatorUrl"];
        model.nickname = [set stringForColumn:@"nickname"];
        model.huanXinId = [set stringForColumn:@"huanXinId"];
        model.apnsPushName = [set stringForColumn:@"apnsPushName"];
        
        [arr addObject:model];
    }
    
    [self.dataBase close];
    
    return arr;
}

- (BOOL)updateApnsPushNameWithModel:(UserModel *)model andApnsPushName:(NSString *)apnsPushName
{
    [self.dataBase open];
    
    BOOL ret = [self.dataBase executeUpdate:@"update userTable set apnsPushName = ? where account = ?", apnsPushName, model.account];
    if (ret) {
        DLog(@"更新成功");
    }else{
        DLog(@"更新失败");
    }
    
    return ret;
}

@end

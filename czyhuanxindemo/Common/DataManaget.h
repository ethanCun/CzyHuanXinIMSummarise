//
//  DataManaget.h
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/25.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "UserModel.h"

@interface DataManaget : NSObject

@property (nonatomic, strong) FMDatabase *dataBase;

+ (instancetype)share;

- (BOOL)insertUserWithModel:(UserModel *)model;

- (BOOL)deleteAllContacts;

- (NSMutableArray *)searchAllModels;

- (BOOL)updateApnsPushNameWithModel:(UserModel *)model andApnsPushName:(NSString *)apnsPushName;

@end

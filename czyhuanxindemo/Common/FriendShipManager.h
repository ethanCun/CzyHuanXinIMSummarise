//
//  FriendShipManager.h
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/30.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "FriendShipModel.h"

@interface FriendShipManager : NSObject

@property (nonatomic, strong) FMDatabase *dataBase;

+ (instancetype)share;

- (BOOL)insertFriendShipWithModel:(FriendShipModel *)model;

- (BOOL)deleteAllFriendShips;

- (BOOL)deleteFriendshipWithModel:(FriendShipModel *)model;

- (NSMutableArray *)searchAllFriendshipModels;



@end

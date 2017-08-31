//
//  UserModel.m
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/28.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"account = %@, nickname = %@, avatorUrl = %@, huanXinId = %@, message = %@, apnsPushName = %@", self.account, self.nickname, self.avatorUrl, self.huanXinId, self.message, self.apnsPushName];
}

@end

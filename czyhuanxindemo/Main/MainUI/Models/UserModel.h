//
//  UserModel.h
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/28.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, copy) NSString *message;

//登录账号
@property (nonatomic, copy) NSString *account;
//昵称
@property (nonatomic, copy) NSString *nickname;
//用户头像url
@property (nonatomic, copy) NSString *avatorUrl;
//环信id
@property (nonatomic, copy) NSString *huanXinId;
//推送名称
@property (nonatomic, copy) NSString *apnsPushName;


@end

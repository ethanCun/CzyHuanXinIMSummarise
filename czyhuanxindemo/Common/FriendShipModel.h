//
//  FriendShipModel.h
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/30.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ApplyStyle)
{
    ApplyStyleFriend,
    ApplyStyleGroup,
    ApplyStyleChatroom,
};

@interface FriendShipModel : NSObject

//好友

//申请好友名称
@property (nonatomic, copy) NSString *username;
//申请标题
@property (nonatomic, copy) NSString *title;
//申请附加信息
@property (nonatomic, copy) NSString *message;
//申请种类
@property (nonatomic, assign) ApplyStyle style;
//好友申请数量
@property (nonatomic, assign) NSInteger friendApplyCount;



//群组


//聊天室


@end

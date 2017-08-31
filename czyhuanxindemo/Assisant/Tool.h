//
//  Tool.h
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/21.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^Sure)(UIAlertAction *action);
typedef void(^Cancel)(UIAlertAction *action);

@interface Tool : NSObject

+ (instancetype)share;

//弹框
- (void)showAlertWithTitle:(NSString *)title msg:(NSString *)msg sure:(Sure)sure sureTitle:(NSString *)sureTitle cancel:(Cancel)cancel cancelTitle:(NSString *)cancelTitle;

//时间转换为时间戳
//- (long long)convertTimeWithdate:(NSDate *)date;

@end

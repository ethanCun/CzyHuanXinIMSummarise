//
//  Tool.m
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/21.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "Tool.h"

@implementation Tool
static Tool *tool = nil;

+ (instancetype)share
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[Tool alloc] init];
    });
    return tool;
}

- (void)showAlertWithTitle:(NSString *)title msg:(NSString *)msg sure:(Sure)sure sureTitle:(NSString *)sureTitle cancel:(Cancel)cancel cancelTitle:(NSString *)cancelTitle
{
    if (sureTitle.length == 0 && cancelTitle.length == 0) {
        return;
    }
    
    if (title.length == 0) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];

    if (sureTitle.length > 0) {
         UIAlertAction * s = [UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:sure];
        [alert addAction:s];

    }
    if (cancelTitle.length > 0) {
         UIAlertAction * c = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:cancel];
        [alert addAction:c];
    }
    
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [vc presentViewController:alert animated:YES completion:nil];
}

//- (long long)convertTimeWithdate:(NSDate *)date
//{
//    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
//    //指定年月日 时分秒
//    [dateFormatter setDateFormat:@"YYYY-mm-dd HH:mm:ss"];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Aisa/Shanghai"]];
//    
//    //将date按dateFormatter转换为string
//    NSString *locationStr = [dateFormatter stringFromDate:date];
//    //再将string转换为date
//    NSDate *newDate = [dateFormatter dateFromString:locationStr];
//    
//    return [[NSString stringWithFormat:@"%ld",(long)[newDate timeIntervalSince1970]] longLongValue];
//}

@end

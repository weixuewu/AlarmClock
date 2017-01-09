//
//  NSString+Alarm.m
//  AlarmClock
//
//  Created by weixuewu on 2016/12/20.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import "NSString+Alarm.h"

@implementation NSString (Alarm)

+(NSString *)convertToWeekString:(NSString *)weeks{
    if (weeks.length == 0) {
        return @"";
    }
    
    NSMutableArray *weekArray = [NSMutableArray arrayWithObjects:@{@"7":@"周日"},@{@"1":@"周一"},@{@"2":@"周二"},@{@"3":@"周三"},@{@"4":@"周四"},@{@"5":@"周五"},@{@"6":@"周六"}, nil];

    NSArray *array = [weeks componentsSeparatedByString:@" "];
    NSMutableArray *data = [NSMutableArray array];
    NSMutableArray *keyData = [NSMutableArray array];

    for (NSDictionary *dic in weekArray) {
        for (NSString *key in array) {
            if (key.length == 0) {
                continue;
            }
            NSString *string = [dic objectForKey:key];
            if (string.length > 0) {
                [data addObject:string];
                [keyData addObject:key];
            }
        }
    }
    
    if (keyData.count == 7) {
        return @"每天";
    }
    else if (keyData.count == 2){
        BOOL flag = NO;
        for (NSString *key in keyData) {
            if ([key intValue] >= 6 && [key intValue] <= 7) {
                flag = YES;
            }else{
                break;
            }
        }
        if (flag) {
            return @"周末";
        }
    }
    else if (keyData.count == 5){
        BOOL flag = NO;
        for (NSString *key in keyData) {
            if ([key intValue] >= 1 && [key intValue] <= 5) {
                flag = YES;
            }else{
                break;
            }
        }
        if (flag) {
            return @"工作日";
        }
    }
    
    return [data componentsJoinedByString:@" "];
}


+(NSString *)filterNull:(id)obj{
    if (obj) {
        if ([obj isKindOfClass:[NSNull class]]) {
            return @"";
        }
        else if ([obj isEqualToString:@"(null)"]){
            return @"";
        }
        else{
            return obj;
        }
    }else{
        return @"";
    }
}

+(NSString *)timeStringWithTimeInterval:(double)time{
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"HH:mm";
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

@end

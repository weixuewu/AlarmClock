//
//  NSString+Alarm.h
//  AlarmClock
//
//  Created by weixuewu on 2016/12/20.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Alarm)

+(NSString *)convertToWeekString:(NSString *)weeks;
+(NSString *)filterNull:(id)obj;
+(NSString *)timeStringWithTimeInterval:(double)time;

@end

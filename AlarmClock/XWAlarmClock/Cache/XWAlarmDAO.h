//
//  XWAlarmDAO.h
//  AlarmClock
//
//  Created by weixuewu on 2016/12/19.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWAlarm.h"

@interface XWAlarmDAO : NSObject

+(void)saveAlarm:(XWAlarm *)alarm;
+(void)updateValue:(NSString *)value forkey:(NSString *)key withId:(NSString *)alarmId;
+(void)removeAlarm:(XWAlarm *)alarm success:(void(^)())success failure:(void(^)(NSString *errorString))failure;
+(void)fetchAlarmListFromDBSuccess:(void(^)(NSMutableArray *array))success;

@end

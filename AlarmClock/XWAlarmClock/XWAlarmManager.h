//
//  XWBellPlayManager.h
//  AlarmClock
//
//  Created by weixuewu on 2016/12/15.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
@class XWAlarm;

@interface XWAlarmManager : NSObject

+(XWAlarmManager *)sharedInstance;
-(NSArray *)fetchBellsName;
-(void)playWithName:(NSString *)name;
-(void)playStop;
-(BOOL)isPlaying;

//使用 UNNotification 本地通知
+(void)registerNotification:(XWAlarm *)alarm;
+(void)removeNotification:(XWAlarm *)alarm;

@end

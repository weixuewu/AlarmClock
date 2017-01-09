//
//  XWAlarm.h
//  AlarmClock
//
//  Created by weixuewu on 2016/12/14.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWAlarm : NSObject<NSCopying>

@property (nonatomic, copy) NSString *alarmId; //用时间戳标记唯一
@property (nonatomic, copy) NSString *weeks;
@property (nonatomic, copy) NSString *bells;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, assign) BOOL isOpen;

@end

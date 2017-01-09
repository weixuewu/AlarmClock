//
//  XWAlarm.m
//  AlarmClock
//
//  Created by weixuewu on 2016/12/14.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import "XWAlarm.h"

@implementation XWAlarm

-(instancetype)init{
    self = [super init];
    if (self) {
        _weeks = @"";
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone{
    XWAlarm *alarm = [[[self class]allocWithZone:zone]init];
    alarm.alarmId  = [_alarmId mutableCopy];
    alarm.weeks    = [_weeks mutableCopy];
    alarm.bells    = [_bells mutableCopy];
    alarm.time     = _time;
    alarm.isOpen   = _isOpen;
    return alarm;
}

@end

//
//  XWAlarmListTableViewController.h
//  AlarmClock
//
//  Created by weixuewu on 2016/12/14.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XWAlarm.h"

typedef void(^AlarmChangeCompletion)(XWAlarm *alarm);

@interface XWAlarmListTableViewController : UITableViewController

@property (nonatomic, copy) AlarmChangeCompletion alarmResultBlock;

@end

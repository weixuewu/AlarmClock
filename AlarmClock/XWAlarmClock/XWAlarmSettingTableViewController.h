//
//  XWAlarmSettingTableViewController.h
//  AlarmClock
//
//  Created by weixuewu on 2016/12/14.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XWAlarm.h"

typedef void(^AlarmSettingConpletion)(XWAlarm *alarm);

@interface XWAlarmSettingTableViewController : UITableViewController
@property (nonatomic, copy) AlarmSettingConpletion completion;

-(instancetype)initWithAlarm:(XWAlarm *)alarm;

@end

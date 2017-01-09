//
//  XWAlarmListCell.h
//  AlarmClock
//
//  Created by weixuewu on 2016/12/16.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XWAlarm;

typedef void(^ChangeAlarmStateCompletion)(BOOL flag);

@interface XWAlarmListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UISwitch *alarmSwitch;
@property (copy, nonatomic) ChangeAlarmStateCompletion changeBlock;

-(void)configCell:(XWAlarm *)alarm;

-(CGFloat)fetchCellHeight:(XWAlarm *)alarm;

@end

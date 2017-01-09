//
//  XWAlarmPickerCell.h
//  AlarmClock
//
//  Created by weixuewu on 2016/12/14.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AlarmDatePickerChangeCompletion)(NSTimeInterval interval);

@interface XWAlarmPickerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (copy, nonatomic) AlarmDatePickerChangeCompletion block;

@end

//
//  XWAlarmSettingCell.h
//  AlarmClock
//
//  Created by weixuewu on 2016/12/14.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XWAlarmSettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *contentBtn;

-(void)configWithTitle:(NSString *)title content:(NSString *)content isIndicator:(BOOL)flag isSelected:(BOOL)selected;

@end

//
//  XWAlarmListCell.m
//  AlarmClock
//
//  Created by weixuewu on 2016/12/16.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import "XWAlarmListCell.h"
#import "XWAlarm.h"
#import "NSString+Alarm.h"

@interface XWAlarmListCell ()
@property (nonatomic, strong) XWAlarm *alarm;
@end
@implementation XWAlarmListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor blackColor];
    self.contentLabel.numberOfLines = 2;
}
- (IBAction)changeState:(UISwitch *)sender {
    self.alarm.isOpen = sender.isOn;
    if (self.changeBlock) {
        self.changeBlock(sender.isOn);
    }
    
    UIColor *lightGray = [UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1.0];
    
    NSString *dateString = [NSString timeStringWithTimeInterval:self.alarm.time];
    
    NSString *weeks = [NSString convertToWeekString:self.alarm.weeks];
    NSString *detail = [NSString stringWithFormat:@"闹钟, %@",weeks];
    if (self.alarm.weeks.length == 0) {
        detail = @"闹钟";
    }
    NSString *content = [NSString stringWithFormat:@"%@\n%@",dateString,detail];
    
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc]initWithString:content];
    [attributed addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0],NSForegroundColorAttributeName:lightGray} range:[content rangeOfString:detail]];
    if (self.alarm.isOpen) {
        [attributed addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:50.0],NSForegroundColorAttributeName:[UIColor whiteColor]} range:[content rangeOfString:dateString]];
        self.alarmSwitch.on = YES;
    }else{
        [attributed addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:50.0],NSForegroundColorAttributeName:lightGray} range:[content rangeOfString:dateString]];
        self.alarmSwitch.on = NO;
    }
    [self.contentLabel setAttributedText:attributed];

}

-(void)configCell:(XWAlarm *)alarm{
    
    self.alarm = alarm;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:alarm.time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"HH:mm";
    NSString *dateString = [formatter stringFromDate:date];
    
    UIColor *lightGray = [UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1.0];
    
    NSString *weeks = [NSString convertToWeekString:alarm.weeks];
    NSString *detail = [NSString stringWithFormat:@"闹钟, %@",weeks];
    if (alarm.weeks.length == 0) {
        detail = @"闹钟";
    }
    NSString *content = [NSString stringWithFormat:@"%@\n%@",dateString,detail];
    
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc]initWithString:content];
    [attributed addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0],NSForegroundColorAttributeName:lightGray} range:[content rangeOfString:detail]];
    if (alarm.isOpen) {
        [attributed addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:50.0],NSForegroundColorAttributeName:[UIColor whiteColor]} range:[content rangeOfString:dateString]];
        self.alarmSwitch.on = YES;
    }else{
        [attributed addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:50.0],NSForegroundColorAttributeName:lightGray} range:[content rangeOfString:dateString]];
        self.alarmSwitch.on = NO;
    }
    [self.contentLabel setAttributedText:attributed];
}

-(CGFloat)fetchCellHeight:(XWAlarm *)alarm{
    [self configCell:alarm];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 10;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

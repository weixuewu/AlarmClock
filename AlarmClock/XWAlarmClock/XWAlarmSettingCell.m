//
//  XWAlarmSettingCell.m
//  AlarmClock
//
//  Created by weixuewu on 2016/12/14.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import "XWAlarmSettingCell.h"

@implementation XWAlarmSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)configWithTitle:(NSString *)title content:(NSString *)content isIndicator:(BOOL)flag isSelected:(BOOL)selected{
    
    if (flag) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        self.accessoryType = UITableViewCellAccessoryNone;
        
        if (selected) {
            [self.contentBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        }else{
            [self.contentBtn setImage:nil forState:UIControlStateNormal];
        }
    }
    
    self.titleLabel.text = title;
    if (content) {
        [self.contentBtn setTitle:content forState:UIControlStateNormal];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  XWAlarmPickerCell.m
//  AlarmClock
//
//  Created by weixuewu on 2016/12/14.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import "XWAlarmPickerCell.h"
#import <objc/runtime.h>

@implementation XWAlarmPickerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.contentView.backgroundColor = [UIColor blackColor];
    self.datePicker.backgroundColor = [UIColor blackColor];
    [self.datePicker setTintColor:[UIColor whiteColor]];
    [self.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    //设置字体颜色
    unsigned int outCount;
    int i;
    objc_property_t *pProperty = class_copyPropertyList([UIDatePicker class], &outCount);
    for (i = outCount - 1; i >= 0; i--) {
        NSString *getPropertyName = [NSString stringWithCString:property_getName(pProperty[i]) encoding:NSUTF8StringEncoding];
        if([getPropertyName isEqualToString:@"textColor"])
        {
            [self.datePicker setValue:[UIColor whiteColor] forKey:@"textColor"];
        }
    }
    
    //设置中间分割线
    for (int i=0; i<self.datePicker.subviews[0].subviews.count; i++) {
        UIView *view = self.datePicker.subviews[0].subviews[i];
        if (view.frame.size.height < 1) {
            view.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
            view.layer.borderWidth = 0.5;
        }
    }
    
}

-(void)datePickerValueChanged:(UIDatePicker *)picker{
    if (self.block) {
        NSTimeInterval time = [picker.date timeIntervalSince1970];
        self.block(time);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

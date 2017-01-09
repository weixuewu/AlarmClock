//
//  XWSelectionTableViewController.h
//  AlarmClock
//
//  Created by weixuewu on 2016/12/15.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,SelectionType) {
    SelectionTypeWeeks = 0,
    SelectionTypeBells
};

typedef void(^SelectionBackCompletion)(NSArray *array);

@interface XWSelectionTableViewController : UITableViewController

-(instancetype)initWithType:(SelectionType)type data:(NSArray *)array completion:(SelectionBackCompletion)block;

@end

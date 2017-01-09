//
//  XWAlarmSettingTableViewController.m
//  AlarmClock
//
//  Created by weixuewu on 2016/12/14.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import "XWAlarmSettingTableViewController.h"
#import "XWAlarmPickerCell.h"
#import "XWAlarmSettingCell.h"
#import "XWSelectionTableViewController.h"
#import "XWAlarmDAO.h"
#import "NSString+Alarm.h"
#import "XWAlarmManager.h"

static NSString *alarmPickerCell = @"AlarmPickerCell";
static NSString *alarmSettingCell = @"AlarmSettingCell";

@interface XWAlarmSettingTableViewController ()
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) XWAlarm *alarm;
@property (nonatomic, strong) XWAlarm *oldAlarm;

@end

@implementation XWAlarmSettingTableViewController

-(instancetype)initWithAlarm:(XWAlarm *)alarm{
    self = [super init];
    if (self) {
        if (alarm) {
            _alarm = alarm;
            _oldAlarm = [alarm copy];
        }else{
            _alarm = [XWAlarm new];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"闹钟";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"存储" forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 60, 44)];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btn addTarget:self action:@selector(saveAlarm) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([XWAlarmPickerCell class]) bundle:nil] forCellReuseIdentifier:alarmPickerCell];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([XWAlarmSettingCell class]) bundle:nil] forCellReuseIdentifier:alarmSettingCell];

    self.titleArray = @[@"重复",@"铃声"];
}

-(void)saveAlarm{
    self.alarm.isOpen = YES;

    if (self.alarm.time == 0) {
        self.alarm.time = [[NSDate date] timeIntervalSince1970];
    }
    
    if (!self.alarm.alarmId) {
        
        NSString *timeStr = [NSString stringWithFormat:@"%.f",(double)[[NSDate date] timeIntervalSince1970]*1000];
        self.alarm.alarmId = timeStr;
    }
    
    //如果从已有alarm修改，先移除通知
    if (_oldAlarm) {
        [XWAlarmManager removeNotification:_oldAlarm];
    }
    
    [XWAlarmDAO saveAlarm:self.alarm];

    if (self.completion) {
        self.completion(self.alarm);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 180;
    }else{
        return 44;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        XWAlarmPickerCell *cell =[tableView dequeueReusableCellWithIdentifier:alarmPickerCell];
        if (self.alarm.time != 0) {
            cell.datePicker.date = [NSDate dateWithTimeIntervalSince1970:self.alarm.time];
        }
        cell.block = ^(NSTimeInterval interval){
            self.alarm.time = interval;
        };
        return cell;
    }
    
    XWAlarmSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:alarmSettingCell];
    if (indexPath.row == 0) {
        NSString *weeks = [NSString convertToWeekString:self.alarm.weeks];
        [cell configWithTitle:self.titleArray[indexPath.row] content:weeks isIndicator:YES isSelected:NO];
    }else{
        [cell configWithTitle:self.titleArray[indexPath.row] content:self.alarm.bells isIndicator:YES isSelected:NO];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        XWSelectionTableViewController *vc;
        if (indexPath.row == 0) {
            NSArray *array = [self.alarm.weeks componentsSeparatedByString:@" "];
            vc = [[XWSelectionTableViewController alloc]initWithType:SelectionTypeWeeks data:array completion:^(NSArray *array) {
                self.alarm.weeks = [array componentsJoinedByString:@" "];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
        }else{
            NSArray *array = [NSArray arrayWithObjects:self.alarm.bells, nil];
            vc = [[XWSelectionTableViewController alloc]initWithType:SelectionTypeBells data:array completion:^(NSArray *array){
                self.alarm.bells = [array firstObject];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end

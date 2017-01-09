//
//  XWAlarmListTableViewController.m
//  AlarmClock
//
//  Created by weixuewu on 2016/12/14.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import "XWAlarmListTableViewController.h"
#import "XWAlarmSettingTableViewController.h"
#import "XWAlarmListCell.h"
#import "XWAlarmDAO.h"
#import "XWAlarmManager.h"

static NSString *kAlarmListCell = @"AlarmListCell";

@interface XWAlarmListTableViewController ()
@property (nonatomic, strong) NSMutableArray *alarmArray;
@property (nonatomic, strong) XWAlarm *alarm;

@end

@implementation XWAlarmListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.title = @"闹钟";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"+" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [btn setFrame:CGRectMake(0, 0, 60, 44)];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btn addTarget:self action:@selector(addAlarm) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    [left setTitle:@"关闭" forState:UIControlStateNormal];
    [left setFrame:CGRectMake(0, 0, 60, 44)];
    [left setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [left addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:left];

    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([XWAlarmListCell class]) bundle:nil] forCellReuseIdentifier:kAlarmListCell];

    self.alarmArray = [NSMutableArray array];
    
    [self reload];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reload) name:@"reloadData" object:nil];
}

-(void)closeVC{
    if (self.alarmResultBlock) {
        self.alarmResultBlock(self.alarm);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)reload{
    [XWAlarmDAO fetchAlarmListFromDBSuccess:^(NSMutableArray *array) {
        self.alarmArray = array;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

-(void)addAlarm{
    XWAlarmSettingTableViewController *vc = [[XWAlarmSettingTableViewController alloc]initWithAlarm:nil];
    [vc setCompletion:^(XWAlarm *alarm){
        [self.alarmArray addObject:alarm];
        [self disposalData:alarm];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)disposalData:(XWAlarm *)alarm{
    
    self.alarm = [alarm copy];
    
    //保证只有一个是开的
    for (XWAlarm *alarm1 in self.alarmArray) {
        
        //新增与修改的alarm，注册通知
        if ([alarm.alarmId isEqualToString:alarm1.alarmId]) {
            [XWAlarmManager registerNotification:alarm];
            continue;
        }else if (alarm1.isOpen) {
            //其他注销通知
            alarm1.isOpen = NO;
            [XWAlarmManager removeNotification:alarm1];
            [XWAlarmDAO saveAlarm:alarm1];
        }
    }
    
    [self.tableView reloadData];

}

-(void)sortAlarmArray{
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"time" ascending:YES];
    [self.alarmArray sortUsingDescriptors:@[sort]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.alarmArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XWAlarmListCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlarmListCell];
    XWAlarm *alarm = self.alarmArray[indexPath.row];
    [cell configCell:alarm];
    [cell setChangeBlock:^(BOOL flag){
        if (flag) {
            [XWAlarmManager registerNotification:alarm];
            for (XWAlarm *alarm1 in self.alarmArray) {
                if ([alarm.alarmId isEqualToString:alarm1.alarmId]) {
                    continue;
                }else if (alarm1.isOpen) {
                    //其他注销通知
                    alarm1.isOpen = NO;
                    [XWAlarmManager removeNotification:alarm1];
                    [XWAlarmDAO saveAlarm:alarm1];
                }
            }
            self.alarm = [alarm copy];
        }else{
            [XWAlarmManager removeNotification:alarm];
            self.alarm = nil;
        }
        [XWAlarmDAO saveAlarm:alarm];
        
        [tableView reloadData];
    }];
    return cell;
}

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    XWAlarmListCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlarmListCell];
    return [cell fetchCellHeight:self.alarmArray[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XWAlarmSettingTableViewController *vc = [[XWAlarmSettingTableViewController alloc]initWithAlarm:self.alarmArray[indexPath.row]];
    [vc setCompletion:^(XWAlarm *alarm){
        //此处alarm的内存地址一样，其为同一个对象，所以只需要刷新即可
        [self disposalData:alarm];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XWAlarm *alarm = self.alarmArray[indexPath.row];
    [XWAlarmDAO removeAlarm:alarm success:^{
        if (alarm.isOpen) {
            [XWAlarmManager removeNotification:alarm];
            self.alarm = nil;
        }
        [self.alarmArray removeObject:alarm];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSString *errorString) {
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

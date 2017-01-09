//
//  XWSelectionTableViewController.m
//  AlarmClock
//
//  Created by weixuewu on 2016/12/15.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import "XWSelectionTableViewController.h"
#import "XWAlarmSettingCell.h"
#import "XWAlarmManager.h"

static NSString *alarmSettingCell = @"AlarmSettingCell";

@interface XWSelectionTableViewController ()

@property (nonatomic, assign) SelectionType type;
@property (nonatomic, copy)   SelectionBackCompletion completionBlock;
@property (nonatomic, strong) NSMutableArray *weeks;
@property (nonatomic, strong) NSMutableArray *selectedWeeks;
@property (nonatomic, strong) NSMutableArray *bells;
@property (nonatomic, copy)   NSString *selectedBell;

@end

@implementation XWSelectionTableViewController

-(instancetype)initWithType:(SelectionType)type data:(NSArray *)array completion:(SelectionBackCompletion)block{
    self = [super init];
    if (self) {
        _type = type;
        _completionBlock = block;
        if (type == SelectionTypeWeeks) {
            _selectedWeeks = [NSMutableArray arrayWithArray:array];
        }else if (type == SelectionTypeBells){
            _selectedBell = [array firstObject];
        }
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.type == SelectionTypeWeeks) {
        if (self.selectedWeeks.count > 0) {
            NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"self" ascending:YES];
            NSArray *array = [self.selectedWeeks sortedArrayUsingDescriptors:@[sort]];
            self.completionBlock(array);
        }
    }else if (self.type == SelectionTypeBells){
        if (self.selectedBell) {
            self.completionBlock(@[self.selectedBell]);
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    switch (self.type) {
        case SelectionTypeWeeks:
            self.title = @"重复";
            break;
        case SelectionTypeBells:
            self.title = @"铃声";
            [self fetchBells];
            break;
        default:
            break;
    }
    
    self.weeks = [NSMutableArray arrayWithObjects:@{@"7":@"周日"},@{@"1":@"周一"},@{@"2":@"周二"},@{@"3":@"周三"},@{@"4":@"周四"},@{@"5":@"周五"},@{@"6":@"周六"}, nil];
    
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([XWAlarmSettingCell class]) bundle:nil] forCellReuseIdentifier:alarmSettingCell];

}

-(void)fetchBells{
    self.bells = [NSMutableArray arrayWithArray:[[XWAlarmManager sharedInstance]fetchBellsName]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (self.type) {
        case SelectionTypeWeeks:
            return self.weeks.count;
            break;
        case SelectionTypeBells:
            return self.bells.count;
            break;
        default:
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XWAlarmSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:alarmSettingCell];
    switch (self.type) {
        case SelectionTypeWeeks:
        {
            NSString *week = [[self.weeks[indexPath.row] allKeys]firstObject];
            BOOL flag;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", week];
            NSArray *results = [self.selectedWeeks filteredArrayUsingPredicate:predicate];
            
            if (results.count > 0) {
                flag = YES;
            }else{
                flag = NO;
            }
            [cell configWithTitle:[self.weeks[indexPath.row] objectForKey:week] content:nil isIndicator:NO isSelected:flag];
        }
            break;
        case SelectionTypeBells:
        {
            NSString *bell = self.bells[indexPath.row];
            BOOL flag = NO;
            if ([bell isEqualToString:self.selectedBell]) {
                flag = YES;
            }

            [cell configWithTitle:self.bells[indexPath.row] content:nil isIndicator:NO isSelected:flag];
        }
            break;
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.type == SelectionTypeBells) {
        [[XWAlarmManager sharedInstance]playWithName:self.bells[indexPath.row]];
        NSString *bell = self.bells[indexPath.row];
        if (![bell isEqualToString:self.selectedBell]) {
            self.selectedBell = bell;
        }else{
            self.selectedBell = nil;
        }
        [tableView reloadData];

    }else{

        NSString *week = [[self.weeks[indexPath.row] allKeys]firstObject];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", week];
        NSArray *results = [self.selectedWeeks filteredArrayUsingPredicate:predicate];
        if (results.count > 0) {
            [self.selectedWeeks removeObject:week];
        }else{
            [self.selectedWeeks addObject:week];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}


- (void) dealloc {
    
    if (self.type == SelectionTypeBells) {
        [[XWAlarmManager sharedInstance]playStop];
    }
}
@end

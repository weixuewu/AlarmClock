//
//  XWAlarmDAO.m
//  AlarmClock
//
//  Created by weixuewu on 2016/12/19.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import "XWAlarmDAO.h"
#import "XWDataBaseManager.h"

static NSString *const Table_Name_Alarm = @"XWALarm";
static NSString *const k_alarmId        = @"alarmId";
static NSString *const k_weeks          = @"weeks";
static NSString *const k_bells          = @"bells";
static NSString *const k_time           = @"time";
static NSString *const k_isOpen         = @"isOpen";
static NSString *const Alarm_Insert_Sql = @"insert or replace into XWALarm (%@,%@,%@,%@,%@) values (?,?,?,?,?)";
static NSString *const Alarm_query_Sql  = @"select * from XWALarm where alarmId = '%@'";
static NSString *const Alarm_update_Sql = @"update XWALarm set weeks='%@',bells='%@',time='%@',isOpen='%@' where alarmId = '%@'";
static NSString *const Alarm_Delete_Sql  = @"delete from XWALarm where alarmId = '%@'";


@implementation XWAlarmDAO

+(void)saveAlarm:(XWAlarm *)alarm{
    
    [[XWDataBaseManager sharedInstance]doOperationInTransactionAsync:^(FMDatabase *db) {
        
        //查询有记录则更新，无记录则插入
        NSString *query = [NSString stringWithFormat:Alarm_query_Sql,alarm.alarmId];
        FMResultSet *resultSet = [db executeQuery:query];

        if ([resultSet next]) {
            NSString *update = [NSString stringWithFormat:Alarm_update_Sql,alarm.weeks,alarm.bells,@(alarm.time),[NSNumber numberWithBool:alarm.isOpen],alarm.alarmId];
            [db executeUpdate:update];
            
        }else{
            NSString *insertSql = [NSString stringWithFormat:Alarm_Insert_Sql,
                                   k_alarmId,
                                   k_weeks,
                                   k_bells,
                                   k_time,
                                   k_isOpen];
            [db executeUpdate:insertSql,alarm.alarmId,alarm.weeks,alarm.bells,@(alarm.time),[NSNumber numberWithBool:alarm.isOpen]];
        }
        [resultSet close];
    }];
}

+(void)updateValue:(NSString *)value forkey:(NSString *)key withId:(NSString *)alarmId{
    [[XWDataBaseManager sharedInstance]doOperationInTransactionAsync:^(FMDatabase *db) {
        
        NSString *sql = @"update XWALarm set %@='%@' where alarmId = '%@'";
        NSString *update = [NSString stringWithFormat:sql,key,value,alarmId];
        [db executeUpdate:update];
    }];
}

+(void)removeAlarm:(XWAlarm *)alarm success:(void (^)())success failure:(void (^)(NSString *))failure{
    
    [[XWDataBaseManager sharedInstance]doOperationInTransactionAsync:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:Alarm_Delete_Sql,alarm.alarmId];
        BOOL flag = [db executeUpdate:sql];
        
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            if (flag) {
                success();
            }else{
                failure(@"删除失败");
            }
        });
    }];
}

+(void)fetchAlarmListFromDBSuccess:(void (^)(NSMutableArray *))success{
    
    [[XWDataBaseManager sharedInstance]doOperationInTransactionAsync:^(FMDatabase *db) {
       
        FMResultSet *resultSet = [db executeQuery:@"select * from XWALarm"];
        NSMutableArray *array = [NSMutableArray array];
        while ([resultSet next]) {
            XWAlarm *alarm = [[XWAlarm alloc]init];
            alarm.alarmId = [resultSet stringForColumn:k_alarmId];
            alarm.weeks = [resultSet stringForColumn:k_weeks];
            alarm.bells = [resultSet stringForColumn:k_bells];
            alarm.time = [[resultSet stringForColumn:k_time]doubleValue];
            alarm.isOpen = [[resultSet stringForColumn:k_isOpen]boolValue];
            [array addObject:alarm];
        }
        [resultSet close];
        //排序
        NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"time" ascending:YES];
        [array sortUsingDescriptors:@[sort]];
        success([array mutableCopy]);
    }];
}

@end

//
//  XWDataBaseManager.m
//  AlarmClock
//
//  Created by weixuewu on 2016/12/19.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import "XWDataBaseManager.h"


@interface XWDataBaseManager ()

@property (nonatomic, strong) NSString *dbFilePath;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation XWDataBaseManager

+(XWDataBaseManager *)sharedInstance{
    static XWDataBaseManager *manager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[XWDataBaseManager alloc]init];
    });
    return manager;
}

-(void)createDBWithFileName:(NSString *)name{
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [NSString stringWithFormat:@"%@/%@",dirPath,name];
    NSLog(@"dbpath: %@",dbPath);
    BOOL flag = [[NSFileManager defaultManager]fileExistsAtPath:dbPath];
    if (!flag) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dbPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"create_table" ofType:@"sql"];
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@";"];
    NSArray *sqls_createTable = [[NSString stringWithContentsOfFile:filePath usedEncoding:nil error:nil]
                                 componentsSeparatedByCharactersInSet:characterSet];
    self.dbFilePath =
    [dbPath stringByAppendingPathComponent:@"data.sqlite"];
    
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.dbFilePath];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            for (NSString *sql in sqls_createTable) {
                if (sql.length > 0) {
                    [db executeUpdate:sql];
                }
            }
        }
        @catch (NSException *exception) {
            *rollback = YES;
            NSLog(@"database %@", [exception description]);
        }
        @finally {
        }
    }];
}

-(void)doOperationInTransactionAsync:(void (^)(FMDatabase *))operationBlock{
    @try {
        if (operationBlock != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                __weak __typeof(&*self)weakSelf = self;
                [weakSelf.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                    operationBlock(db);
                }];
            });
        }
    }
    @catch (NSException *exception) {
        NSLog(@"doOperationInTransaction async error");
    }
    @finally {
        
    }
}

@end

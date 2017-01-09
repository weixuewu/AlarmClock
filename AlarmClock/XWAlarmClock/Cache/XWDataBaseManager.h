//
//  XWDataBaseManager.h
//  AlarmClock
//
//  Created by weixuewu on 2016/12/19.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface XWDataBaseManager : NSObject

+(XWDataBaseManager *)sharedInstance;

-(void)createDBWithFileName:(NSString *)name;

-(void)doOperationInTransactionAsync:(void(^)(FMDatabase *db))operationBlock;

@end

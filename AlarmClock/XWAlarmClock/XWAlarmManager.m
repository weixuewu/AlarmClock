//
//  XWBellPlayManager.m
//  AlarmClock
//
//  Created by weixuewu on 2016/12/15.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import "XWAlarmManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "XWAlarm.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+Alarm.h"

@interface XWAlarmManager (){
    SystemSoundID soundId;
    CFURLRef		soundFileURLRef;

}

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation XWAlarmManager

-(instancetype)init{
    self = [super init];
    if (self) {
        soundId = kSystemSoundID_Vibrate;//震动
    }
    return self;
}

-(void)setupPlayer{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:NULL];
    [session setActive:YES error:NULL];
    
    NSString *path           = [[NSBundle mainBundle] pathForResource:@"wakeup" ofType:@"mp3"];
    NSURL *url               = [NSURL fileURLWithPath:path];
    self.audioPlayer         = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.audioPlayer.numberOfLoops = -1;
}

+(XWAlarmManager *)sharedInstance{
    static XWAlarmManager *manager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[XWAlarmManager alloc]init];
    });
    return manager;
}

-(void)playWithName:(NSString *)name{
    
//    播放系统铃声
//    NSString *path = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@.%@",name,@"caf"];
//    soundFileURLRef = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
//    OSStatus error = AudioServicesCreateSystemSoundID(soundFileURLRef,&soundId);
//    if (error != kAudioServicesNoError) {//获取的声音的时候，出现错误
//        NSLog(@"error = %d",(int)error);
//        soundId = kSystemSoundID_Vibrate;
//    }
//    AudioServicesPlaySystemSound(soundId);

    if (self.audioPlayer) {
        [self.audioPlayer stop];
    }
    
    NSString *path           = [self bundlePath:name];
    NSURL *url               = [NSURL fileURLWithPath:path];
    self.audioPlayer         = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.audioPlayer.numberOfLoops = -1;
    [self.audioPlayer play];
}

-(BOOL)isPlaying{
    
    if (self.audioPlayer) {
        return self.audioPlayer.isPlaying;
    }
    return NO;
}

-(NSArray *)fetchBellsName{
//    NSArray *array = @[@"alarm",@"sms-received6",@"Choo_Choo"];
//    return [array copy];
    
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator * myDirectoryEnumerator = [fileManager enumeratorAtPath:[NSBundle mainBundle].bundlePath];
    NSMutableArray * filePathArray = [[NSMutableArray alloc]init];//存放文件路径数组
    NSMutableArray * fileNameArray = [[NSMutableArray alloc]init];//存放文件名数组
    
    NSString * file;//声明文件名
    
    while (file = [myDirectoryEnumerator nextObject]) {
        if ([file.pathExtension isEqualToString:@"mp3"]) { //判断file的后缀名是否为mp3
            [filePathArray addObject:[self bundlePath:file]];
            [fileNameArray addObject:file];
        }
    }
    
    return [fileNameArray mutableCopy];
}

- (NSString *)bundlePath:(NSString *)fileName{
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
}

- (void) playStop {
//    AudioServicesDisposeSystemSoundID (soundId);
//    CFRelease (soundFileURLRef);
    
    if (self.audioPlayer) {
        [self.audioPlayer stop];
    }
}

/************对于指定天的创建多次，例如周一周二，可创建周一与周二两次，api不提供**********/

//使用 UNNotification 本地通知
+(void)registerNotification:(XWAlarm *)alarm{
    
    if (alarm.weeks.length > 0) {
        NSArray *array = [alarm.weeks componentsSeparatedByString:@" "];
        for (NSString *week in array) {
            if (week.length == 0) {
                continue;
            }
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:alarm.time];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSUInteger unitFlags = NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute;
            NSDateComponents *components1 = [calendar components:unitFlags fromDate:date];
            
            NSDateComponents *components2 = [[NSDateComponents alloc] init];
            int weekday = [week intValue] + 1;
            if (weekday == 8) {
                weekday = 1;
            }
            components2.weekday = weekday; //周几
            components2.hour    = components1.hour;
            components2.minute  = components1.minute;
            
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
                [self addNotification:alarm components:components2];

            }else{
                [self addNotificationIos8Later:alarm components:components2];
            }
        }
    }else{
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
            [self addNotification:alarm components:nil];
            
        }else{
            [self addNotificationIos8Later:alarm components:nil];
        }
    }
}

+(void)addNotification:(XWAlarm *)alarm components:(NSDateComponents *)components{
    
    // 使用 UNUserNotificationCenter 来管理通知
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    //需创建一个包含待通知内容的 UNMutableNotificationContent 对象，注意不是 UNNotificationContent ,此对象为不可变对象。
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"悦迪催眠"
                                                          arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:@"您的闹钟响了"
                                                         arguments:nil];
    NSString *soundName = [NSString filterNull:alarm.bells];
    if (soundName.length == 0) {
        soundName = @"wakeup.mp3";
    }
    content.sound = [UNNotificationSound soundNamed:soundName];
    
    //Notification Actions
    UNNotificationAction *closeAction = [UNNotificationAction actionWithIdentifier:@"action.close"
                                                                             title:@"关闭"
                                                                           options:UNNotificationActionOptionAuthenticationRequired];
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"alarm_category"
                                                                              actions:@[closeAction]
                                                                    intentIdentifiers:@[]
                                                                              options:UNNotificationCategoryOptionCustomDismissAction];
    [center setNotificationCategories:[NSSet setWithObject:category]];
    content.categoryIdentifier = @"alarm_category";

    UNNotificationRequest* request;
    
    if (components) {
        
        content.userInfo=@{@"alarmId":[NSString stringWithFormat:@"%@_%zd",alarm.alarmId,components.weekday],@"soundName":soundName};

        UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger
                                                  triggerWithDateMatchingComponents:components repeats:YES];
        
        NSString *identifier = [NSString stringWithFormat:@"%@_%zd",alarm.alarmId,components.weekday];
        request  = [UNNotificationRequest requestWithIdentifier:identifier
                                                        content:content
                                                        trigger:trigger];
        
    }
    else{
        
        content.userInfo=@{@"alarmId":alarm.alarmId,@"soundName":soundName};

        UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                      triggerWithTimeInterval:60
                                                      repeats:YES];
        request  = [UNNotificationRequest requestWithIdentifier:alarm.alarmId
                                                        content:content
                                                        trigger:trigger];
    }
    //添加推送成功后的处理！
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"添加推送成功");
    }];
}

//ios8及以上
+(void)addNotificationIos8Later:(XWAlarm *)alarm components:(NSDateComponents *)components{
    UILocalNotification *noti = [[UILocalNotification alloc]init];
    //设置触发通知的时期
    
    noti.timeZone = [NSTimeZone defaultTimeZone];
    noti.alertBody = @"您的闹钟响了";
    noti.alertAction = @"关闭";

    NSString *soundName = [NSString filterNull:alarm.bells];
    if (soundName.length == 0) {
        soundName = @"wakeup.mp3";
    }
    noti.soundName = soundName;
    
    if (components) {
        noti.userInfo=@{@"alarmId":[NSString stringWithFormat:@"%@_%zd",alarm.alarmId,components.weekday],@"soundName":soundName};
        
        NSCalendar *calender = [NSCalendar autoupdatingCurrentCalendar];
        NSDate *fireDate = [calender dateFromComponents:components];
        noti.fireDate = fireDate;
        noti.repeatInterval = NSCalendarUnitWeekday;

    }else{
        noti.repeatInterval = NSCalendarUnitMinute;
        noti.userInfo=@{@"alarmId":alarm.alarmId,@"soundName":soundName};
        NSDate *fireDate = [NSDate dateWithTimeIntervalSince1970:alarm.time];
        NSDate *newDate = [self convertAlarmDate:fireDate];
        noti.fireDate = newDate;
    }
    
    [[UIApplication sharedApplication]scheduleLocalNotification:noti];

}

+(void)removeNotification:(XWAlarm *)alarm{
    if (alarm.alarmId == nil) {
        return;
    }
    
    [[self sharedInstance]playStop];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        if (alarm.weeks.length > 0) {
            NSArray *array = [alarm.weeks componentsSeparatedByString:@" "];
            for (NSString *week in array) {
                if (week.length == 0) {
                    continue;
                }
                int weekday = [week intValue] + 1;
                if (weekday == 8) {
                    weekday = 1;
                }
                
                NSString *identifier = [NSString stringWithFormat:@"%@_%zd",alarm.alarmId,weekday];
                UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
                [center removePendingNotificationRequestsWithIdentifiers:@[identifier]];
            }
        }else{
            UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
            [center removePendingNotificationRequestsWithIdentifiers:@[alarm.alarmId]];
        }
    }else{
        
        //取消某一个通知
        NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
        //获取当前所有的本地通知
        if (!notificaitons || notificaitons.count <= 0) {
            return;
        }
        
        if (alarm.weeks.length > 0) {
            NSArray *array = [alarm.weeks componentsSeparatedByString:@" "];
            for (NSString *week in array) {
                if (week.length == 0) {
                    continue;
                }
                int weekday = [week intValue] + 1;
                if (weekday == 8) {
                    weekday = 1;
                }
                
                NSString *identifier = [NSString stringWithFormat:@"%@_%zd",alarm.alarmId,weekday];
                for (UILocalNotification *notify in notificaitons) {
                    NSString *alarmId = [notify.userInfo objectForKey:@"alarmId"];
                    if ([alarmId isEqualToString:identifier])
                    {
                        //取消一个特定的通知
                        [[UIApplication sharedApplication] cancelLocalNotification:notify];
                    }
                }
            }
        }else{
            NSString *identifier = [NSString stringWithFormat:@"%@",alarm.alarmId];
            for (UILocalNotification *notify in notificaitons) {
                NSString *alarmId = [notify.userInfo objectForKey:@"alarmId"];
                if ([alarmId isEqualToString:identifier])
                {
                    //取消一个特定的通知
                    [[UIApplication sharedApplication] cancelLocalNotification:notify];
                }
            }
        }
        
    }
}

//比较日期，确保闹钟时间是未来时间，过去时加一天
+(NSDate *)convertAlarmDate:(NSDate *)assginDate{
    
    NSTimeInterval nowDate = [[NSDate new] timeIntervalSince1970];
    NSTimeInterval checkDate = [assginDate timeIntervalSince1970];
    
    
    if(checkDate <= nowDate){
        
        NSCalendar *calendar         = [NSCalendar currentCalendar];
        NSUInteger flags;
        NSDateComponents *comps;
        
        flags                        = NSCalendarUnitYear
        | NSCalendarUnitMonth
        | NSCalendarUnitDay
        | NSCalendarUnitHour
        | NSCalendarUnitMinute;
        
        comps                        = [calendar components:flags fromDate:assginDate];
        
        NSDateComponents* components = [[NSDateComponents alloc] init];
        
        components.year              = comps.year;
        components.month             = comps.month;
        components.day               = comps.day + 1;
        components.hour              = comps.hour;
        components.minute            = comps.minute;
        components.second            = 0;
        
        NSDate *resultDate           = [calendar dateFromComponents:components];
        
        return resultDate;
        
        
    }else{
        
        return assginDate;
    }
}

@end

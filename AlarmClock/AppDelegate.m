//
//  AppDelegate.m
//  AlarmClock
//
//  Created by weixuewu on 2016/12/14.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import "AppDelegate.h"
#import "XWAlarmListTableViewController.h"
#import "XWDataBaseManager.h"
#import <UserNotifications/UserNotifications.h>
#import "XWAlarmManager.h"
#import "XWAlarmDAO.h"
#import "DXAlertView.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    XWAlarmListTableViewController *vc = [[XWAlarmListTableViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:42/255.0 green:34/255.0 blue:83/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];//设置导航栏按钮的
    //设置导航栏标题的属性
    NSDictionary *dict = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes: dict];
    
    [[XWDataBaseManager sharedInstance]createDBWithFileName:@"闹钟"];
    
    self.window.rootViewController = nav;
    
    
    //注册通知
    if([[UIDevice currentDevice].systemVersion floatValue] >= 10.0){
        //iOS10特有
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //必须些代理，不然无法监听通知的接受与点击
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if(granted){
                //允许点击
                NSLog(@"注册成功");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"%@",settings);
                }];
            }else{
                //点击不允许
                NSLog(@"注册失败");
            }
        }];
    }else{

        // iOS8注册本地通知类型
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:settings];

    }
    
    return YES;
}


#pragma mark - UNUserNotificationCenterDelegate
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSLog(@"哈哈");
    
    NSString* actionIdentifierStr = response.actionIdentifier;
    if ([actionIdentifierStr isEqualToString:@"action.close"]) {
        NSLog(@"关闭");
        NSString *identifier = response.notification.request.identifier;
        if ([identifier rangeOfString:@"_"].length == 0) {
            [center removePendingNotificationRequestsWithIdentifiers:@[identifier]];
            [XWAlarmDAO updateValue:@"0" forkey:@"isOpen" withId:identifier];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
        }
    }
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSLog(@"啧啧");
    
    if (![[XWAlarmManager sharedInstance] isPlaying]) {
        NSString *soundName = [notification.request.content.userInfo objectForKey:@"soundName"];
        [[XWAlarmManager sharedInstance]playWithName:soundName];
        
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:nil contentText:@"关闭闹钟" leftButtonTitle:@"稍后" rightButtonTitle:@"关闭"];
        [alert show];
        alert.leftBlock = ^() {
            [[XWAlarmManager sharedInstance]playStop];
        };
        alert.rightBlock = ^() {
            //判断，单个关闭，若是周期性，不关闭
            
            NSString *identifier = notification.request.identifier;
            if ([identifier rangeOfString:@"_"].length == 0) {
                [center removePendingNotificationRequestsWithIdentifiers:@[identifier]];
                [XWAlarmDAO updateValue:@"0" forkey:@"isOpen" withId:identifier];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
            }
            [[XWAlarmManager sharedInstance]playStop];

        };
        alert.dismissBlock = ^() {
            
        };
    }
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"收到本地推送：%@",notification);
    
    if (![[XWAlarmManager sharedInstance] isPlaying]) {
        NSString *soundName = [notification.userInfo objectForKey:@"soundName"];
        [[XWAlarmManager sharedInstance]playWithName:soundName];
        
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:nil contentText:@"关闭闹钟" leftButtonTitle:@"稍后" rightButtonTitle:@"关闭"];
        [alert show];
        alert.leftBlock = ^() {
            [[XWAlarmManager sharedInstance]playStop];
        };
        alert.rightBlock = ^() {
            //判断，单个关闭，若是周期性，不关闭
            NSString *alarmId = [notification.userInfo objectForKey:@"alarmId"];
            if ([alarmId rangeOfString:@"_"].length == 0) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                [XWAlarmDAO updateValue:@"0" forkey:@"isOpen" withId:alarmId];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
            }
            [[XWAlarmManager sharedInstance]playStop];
            
        };
        alert.dismissBlock = ^() {
            
        };
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"呵呵");

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

//
//  AppDelegate.m
//  WeatherSearch
//
//  Created by HGDQ on 15/10/9.
//  Copyright (c) 2015年 HGDQ. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

///**
// *  注册一个本地推送
// *
// *  @param alertTime 推送间隔时间
// */
//- (void)registerLocalNotification:(NSInteger)alertTime {
//	NSLog(@"发送通知");
//	UILocalNotification *notification = [[UILocalNotification alloc] init];
//	// 设置触发通知的时间
//	NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:alertTime];
//	notification.fireDate = fireDate;
//	// 时区  时区跟随时区变化
//	notification.timeZone = [NSTimeZone defaultTimeZone];
//	// 设置重复的间隔
//	notification.repeatInterval = kCFCalendarUnitSecond;
//	// 通知内容
//	notification.alertBody =  @"iOS本地推送";
//	// 设置icon右上角的显示数
//	notification.applicationIconBadgeNumber = 1;	
//	// 通知被触发时播放的声音
//	notification.soundName = UILocalNotificationDefaultSoundName;
//	// 通知参数
//	NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"iOS本地推送Demo" forKey:@"key"];
//	notification.userInfo = userDict;
//	
//	// ios8后，需要添加这个注册，才能得到授权
//	if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
//		UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
//		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
//																				 categories:nil];
//		[[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//		// 通知多长时间重复提示
//		notification.repeatInterval = NSCalendarUnitSecond;
//	}
//	else {
//		// 通知多长时间重复提示
//		notification.repeatInterval = NSCalendarUnitSecond;
//	}
//	// 执行注册的通知
//	[[UIApplication sharedApplication] scheduleLocalNotification:notification];
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	
//	[self registerLocalNotification:5];
	
//	
//	UIUserNotificationSettings * settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
//	[application registerUserNotificationSettings:settings];
//	[application registerForRemoteNotifications];
//	
//	NSDictionary * userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
//	if (userInfo) {
//		UILabel * label = [[UILabel alloc] init];
//		label.frame = CGRectMake(10, 250, 200, 200);
//		label.backgroundColor = [UIColor grayColor];
//		label.font = [UIFont systemFontOfSize:12];
//		label.text = [NSString stringWithFormat:@"%@",userInfo];
//		label.textColor = [UIColor greenColor];
//		[self.window.rootViewController.view addSubview:label];
//	} else {
//		NSLog(@"userInfo = nil");
//	}
	
	return YES;
}
///**
// *  推送注册后就会调用这个方法
// *
// *  @param application          application description
// *  @param notificationSettings notificationSettings description
// */
//- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
//	NSLog(@"注册");
//}
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//	NSLog(@"%@",userInfo);
//	/*
//	 aps =     {
//	 alert = "This is some fancy message.";
//	 badge = 1;
//	 };
//	 */
//}
//
//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
//	NSLog(@"deviceToken = %@",deviceToken);
//	//deviceToken = <f737d192 bdcbca82 bd7eab8e 60d1ec5a 32d6e2b2 d73ce8bc b14a435a 358666aa>
//}
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//	NSLog(@"%@",error);
//}
///**
// *  查看推送消息后调用的方法
// *  每次查看都会调用
// *  @param application  application description
// *  @param notification notification description
// */
//- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
//	NSLog(@"notification:%@",notification);
//	NSString *notMess = [notification.userInfo objectForKey:@"key"];
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"正在查看本地通知"
//													message:notMess
//												   delegate:nil
//										  cancelButtonTitle:@"确定"
//										  otherButtonTitles:nil];
//	[alert show];
//	// 更新applicationIconBadgeNumber
//	NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
//	badge--;
//	badge = badge >= 0 ? badge : 0;
//	[UIApplication sharedApplication].applicationIconBadgeNumber = badge;
//}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

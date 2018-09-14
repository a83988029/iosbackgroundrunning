//
//  AppDelegate.m
//  KeepAppActive
//
//  Created by 左博杨 on 2017/3/2.
//  Copyright © 2017年 左博杨. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()<CLLocationManagerDelegate>
@end

@implementation AppDelegate{
    CLLocationManager *locationMannager;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    locationMannager = [[CLLocationManager alloc] init];
    locationMannager.delegate = self;
    locationMannager.activityType = CLActivityTypeFitness;
    locationMannager.distanceFilter = kCLLocationAccuracyThreeKilometers;
    locationMannager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    locationMannager.allowsBackgroundLocationUpdates = YES; //允许后台刷新
    locationMannager.pausesLocationUpdatesAutomatically = NO;//允许自动暂停定位服务
    [locationMannager requestAlwaysAuthorization];
        
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [locationMannager startUpdatingLocation];
        [NSThread sleepForTimeInterval:5];
        [locationMannager stopUpdatingLocation];

        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            //第一次打开时系统还没允许使用定位，直接关闭会导致后台驻留失败，所以定位还未打开时不主动关闭，并不会增加太多耗电量。
            [locationMannager stopUpdatingLocation];

        }
        
    });
    
    return YES;
}

/** 苹果_用户位置更新后，会调用此函数 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [locationMannager stopUpdatingLocation];
    NSLog(@"success");
}

/** 苹果_定位失败后，会调用此函数 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"error");
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application{
    BOOL inBackground = YES;
    UIBackgroundTaskIdentifier __block bgTask;
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int i = 0;
        int j = 0;
        while (inBackground) {
            i = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"时间:%.2f",application.backgroundTimeRemaining);
            });
            [locationMannager startUpdatingLocation];
            while (i < 10 && inBackground) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"时间:%d 总时间:%d,剩余时间%.2f",i,j,application.backgroundTimeRemaining<180?application.backgroundTimeRemaining:180.0);
                });
                i++;
                j++;
                [NSThread sleepForTimeInterval:1];
            }
        }
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
                
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

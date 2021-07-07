//
//  AppDelegate.m
//  JTFaceAttendence
//
//  Created by 袁炳生 on 2021/7/7.
//

#import "AppDelegate.h"
#import "VedioCheckViewController.h"
#import "ConfigManager.h"
#import "SettingLoadingVC.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[ConfigManager manager] registerSDK];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    self.window.rootViewController = [[BaseNavigationController alloc] initWithRootViewController:[[SettingLoadingVC alloc] init]];
    [self.window makeKeyAndVisible];
    [self removeLaunchScreenCacheIfNeeded];
    return YES;
}

- (void)removeLaunchScreenCacheIfNeeded {
    NSString *filePath = [NSString stringWithFormat:@"%@/Library/SplashBoard", NSHomeDirectory()];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
     NSError *error = nil;
     [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];

     if (error) {
          NSLog(@"清除LaunchScreen缓存失败");
        } else {
          NSLog(@"清除LaunchScreen缓存成功");
        }
     }
 }


@end

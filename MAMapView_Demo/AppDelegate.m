//
//  AppDelegate.m
//  MAMapView_Demo
//
//  Created by apple on 2021/6/24.
//

#import "AppDelegate.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "ViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor    = [UIColor whiteColor];
    
    ViewController *HomeVC = [[ViewController alloc] init];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:HomeVC];
    
    self.window.rootViewController = nav;

    [self.window makeKeyAndVisible];

    
    //注册高德地图
    [AMapServices sharedServices].apiKey=@"601663b2ac6ae6a588e7521a0f5ae55b";
    
    
    return YES;
}





@end

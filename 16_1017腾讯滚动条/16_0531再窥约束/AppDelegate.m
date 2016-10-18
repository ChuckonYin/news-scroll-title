//
//  AppDelegate.m
//  16_0531再窥约束
//
//  Created by apple on 16/5/31.
//  Copyright © 2016年 pinAn.com. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    return YES;
}

@end

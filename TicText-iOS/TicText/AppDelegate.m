//
//  AppDelegate.m
//  TicText
//
//  Created by Kevin Yufei Chen on 1/27/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) TTRootViewController *rootViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self parseInitialization];
    [self setupColorScheme];
    [self setupNavigationController];
    
    // Track app open
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    [self handlePush:launchOptions];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL wasHandled = false;
    
    if ([PFFacebookUtils session]) {
        wasHandled |= [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
    } else {
        wasHandled |= [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    }
    
    //wasHandled |= [self handleActionURL:url];
    
    return wasHandled;
}

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


#pragma mark - ()

- (void)parseInitialization {
    [Parse setApplicationId:@"otEYQUdVy98OBM9SeUs8Zc1PrMy27EGMvEy80WaL" clientKey:@"qfTOvPp03kY8uSYVu3FkL72UWwW37Tx2B6L6Ppq9"];
    //[ParseCrashReporting enable];
    [PFFacebookUtils initializeFacebook];
}

- (void)setupColorScheme {
    // status bar
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    // navigation bar
    
}

- (void)setupNavigationController {
    // Navigation controller
    self.rootViewController = [[TTRootViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.rootViewController];
    self.navigationController.navigationBarHidden = YES;
    
    // set as root view controller of window
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
}

- (void)handlePush:(NSDictionary *)launchOptions {
    
}


@end

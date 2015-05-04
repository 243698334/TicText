//
//  AppDelegate.m
//  TicText
//
//  Created by Kevin Yufei Chen on 1/27/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "AppDelegate.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import "TTConstants.h"
#import "TTSession.h"
#import "TTErrorHandler.h"
#import "TTUser.h"
#import "TTTic.h"
#import "TTActivity.h"
#import "TTUserPrivateData.h"
#import "TTConversation.h"
#import "TTNewTic.h"

#import "TTRootViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) TTRootViewController *rootViewController;
@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self parseInitializationWithUIApplication:application launchOptions:launchOptions];
    [self setupColorScheme];
    [self setupNavigationController];
    [self handlePushNotificationsWithUIApplication:application launchOptions:launchOptions];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [TTErrorHandler handlePushNotificationError:error inViewController:self.rootViewController];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
        [self performSelector:@selector(postNotificationForNewTicWithUserInfo:) withObject:userInfo afterDelay:0.5];
    } else {
        [self postNotificationForNewTicWithUserInfo:userInfo];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[TTUser currentUser].privateData saveEventually];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([TTUser currentUser]) {
        [TTSession validateSessionInBackground];
    }
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTApplicationDidBecomeActive object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[PFFacebookUtils session] close];
}


#pragma mark - ()

- (void)parseInitializationWithUIApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
    [ParseCrashReporting enable];
    
    [TTUser registerSubclass];
    [TTTic registerSubclass];
    [TTActivity registerSubclass];
    [TTUserPrivateData registerSubclass];
    [TTConversation registerSubclass];
    [TTNewTic registerSubclass];
    
    [Parse enableLocalDatastore];
    
    [Parse setApplicationId:@"otEYQUdVy98OBM9SeUs8Zc1PrMy27EGMvEy80WaL"
                  clientKey:@"qfTOvPp03kY8uSYVu3FkL72UWwW37Tx2B6L6Ppq9"];
    
    [PFFacebookUtils initializeFacebook];
    
    [PFUser enableRevocableSessionInBackground];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [PFInstallation currentInstallation].badge = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
}

- (void)setupColorScheme {
    // status bar
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    // TODO: navigation bar
    
}

- (void)setupNavigationController {
    // Navigation controller
    self.rootViewController = [[TTRootViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.rootViewController];
    self.navigationController.navigationBarHidden = YES;
    
    // Set as root view controller of window
    self.window.rootViewController = self.navigationController;
    [self.window setTintColor:kTTUIPurpleColor];
    [self.window makeKeyAndVisible];
}

- (void)handlePushNotificationsWithUIApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
    NSDictionary *pushNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (pushNotificationPayload != nil || application.applicationIconBadgeNumber != 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kTTUserDefaultsConversationsViewControllerShouldRetrieveNewTicsKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:kTTUserDefaultsConversationsViewControllerShouldRetrieveNewTicsKey];
    }
}

- (void)postNotificationForNewTicWithUserInfo:(NSDictionary *)userInfo {
    // Push notification received while the app is active
    if ([[userInfo objectForKey:kTTPushNotificationPayloadTypeKey] isEqualToString:kTTPushNotificationPayloadTypeNewTic]) {
        NSString *ticId = [userInfo objectForKey:kTTPushNotificationPayloadTicIdKey];
        NSString *senderUserId = [userInfo objectForKey:kTTPushNotificationPayloadSenderUserIdKey];
        NSDate *sendTimestamp = [userInfo objectForKey:kTTPushNotificationPayloadSendTimestampKey];
        NSNumber *timeLimit = [userInfo objectForKey:kTTPushNotificationPayloadTimeLimitKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTApplicationDidReceiveNewTicWhileActiveNotification
                                                            object:nil
                                                          userInfo:@{kTTNotificationUserInfoTicIdKey: ticId, kTTNotificationUserInfoSenderUserIdKey: senderUserId, kTTNotificationUserInfoSendTimestampKey: sendTimestamp, kTTNotificationUserInfoTimeLimitKey: timeLimit}];
    }
}

@end
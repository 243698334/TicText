//
//  TTErrorHandler.m
//  TicText
//
//  Created by Kevin Yufei Chen on 4/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTErrorHandler.h"

#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <TSMessages/TSMessage.h>

@implementation TTErrorHandler

+ (void)handlePushNotificationError:(NSError *)error inViewController:(UIViewController *)viewController {
    if (viewController) {
        [TSMessage showNotificationInViewController:viewController title:@"Push Notification Failed" subtitle:error.localizedDescription type:TSMessageNotificationTypeError];
    } else {
        [TSMessage showNotificationWithTitle:@"Push Notification Failed" subtitle:error.localizedDescription type:TSMessageNotificationTypeError];
    }
}

+ (void)handleFacebookSessionError:(NSError *)error inViewController:(UIViewController *)viewController {
    
}

+ (void)handleParseSessionError:(NSError *)error inViewController:(UIViewController *)viewController {
    [TSMessage showNotificationInViewController:viewController ? viewController : [TSMessage defaultViewController] title:@"Invalid Session" subtitle:error.localizedDescription type:TSMessageNotificationTypeError];
}

@end

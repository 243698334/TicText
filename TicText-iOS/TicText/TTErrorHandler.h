//
//  TTErrorHandler.h
//  TicText
//
//  Created by Kevin Yufei Chen on 4/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTErrorHandler : NSObject

+ (void)handlePushNotificationError:(NSError *)error inViewController:(UIViewController *)viewController;

+ (void)handleFacebookSessionError:(NSError *)error inViewController:(UIViewController *)viewController;

+ (void)handleParseSessionError:(NSError *)error inViewController:(UIViewController *)viewController;

@end

//
//  TTExpirationTimer.h
//  TicText
//
//  Created by Terrence K on 3/7/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TTExpirationPickerController.h"

@class TTExpirationTimer;
@protocol TTExpirationTimerDelegate <NSObject>

- (void)expirationTimer:(TTExpirationTimer *)expirationTimer dismissedPickerWithExpiration:(NSTimeInterval)expiration;

@end

@interface TTExpirationTimer : UIButton <UIPickerViewDataSource, UIPickerViewDelegate, TTExpirationPickerControllerDelegate>

@property (nonatomic, weak) id<TTExpirationTimerDelegate> delegate;
@property (nonatomic) NSTimeInterval expirationTime;

// Use this method to create an instance of TTExpirationTimer.
+ (id)buttonWithDelegate:(id<TTExpirationTimerDelegate>)delegate;

+ (id)buttonWithDelegate:(id<TTExpirationTimerDelegate>)delegate
                 default:(NSTimeInterval)defaultTime;

@end

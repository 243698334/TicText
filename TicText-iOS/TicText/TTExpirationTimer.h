//
//  TTExpirationTimer.h
//  TicText
//
//  Created by Terrence K on 3/7/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TTExpirationTimer;
@protocol TTExpirationTimerDelegate <NSObject>

- (void)expirationTimerDesiresNewTime:(TTExpirationTimer *)expirationTimer;

@end

@interface TTExpirationTimer : UIButton

@property (nonatomic, strong) id<TTExpirationTimerDelegate> delegate;
@property (nonatomic) NSTimeInterval expirationTime;

// Use this method to create an instance of TTExpirationTimer.
+ (id)buttonWithDelegate:(id<TTExpirationTimerDelegate>)delegate;

+ (id)buttonWithDelegate:(id<TTExpirationTimerDelegate>)delegate
                 Default:(NSTimeInterval)defaultTime;

@end

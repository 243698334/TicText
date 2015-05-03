//
//  CountDownView.h
//  TicText
//
//  Created by Georgy Petukhov on 4/13/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTMessagesViewController.h"

@interface TTCountDownView : UIView
- (id)initWithFrame:(CGRect)aRect time:(NSTimeInterval)timeLimit delegate:(TTMessagesViewController *)delegate timeId:(NSDate *)timeId;
@end

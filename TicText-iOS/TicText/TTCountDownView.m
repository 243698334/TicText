//
//  TTCountDownView.m
//  TicText
//
//  Created by Georgy Petukhov on 4/13/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTCountDownView.h"
#import "TTMessagesViewController.h"
#import <PureLayout/PureLayout.h>

@interface TTCountDownView () {
    UILabel *timerLabel;
    int counter;
    TTMessagesViewController *delegate;
    NSDate *dateId;
    NSTimer *myTimer;
    BOOL addConstraints;
}

@end

@implementation TTCountDownView

- (id)initWithFrame:(CGRect)aRect time:(NSTimeInterval)timeLimit delegate:(TTMessagesViewController *)d timeId: (NSDate *)timeId{
    counter = (int)timeLimit;
    dateId = timeId;
    self = [super initWithFrame:aRect];
    delegate = d;
    if (self) {
        timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, 20)];
        //timerLabel.adjustsFontSizeToFitWidth = YES;
        //[timerLabel sizeToFit];
        //timerLabel.minimumFontSize = 0;
        [timerLabel setTextColor:kTTUIPurpleColor];
        [timerLabel setBackgroundColor:[UIColor clearColor]];
        [timerLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 10.0f]];
        timerLabel.text = [NSString stringWithFormat:@"%i", counter];
        [self addSubview:timerLabel];
        
        if(timeLimit > 0) {
            myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(timerAnimate)
                                   userInfo:nil
                                    repeats:YES];
        } else {
            timerLabel.text = @"Message expired";
        }
        [self setNeedsUpdateConstraints];
    }
    return self;
}


//animating the timer. every second the label showing seconds would change.
-(void)timerAnimate {
   // NSLog(@"timer tick!");
    timerLabel.text = [NSString stringWithFormat:@"%i sec", --counter];;
    if(counter == 0) {
        [myTimer invalidate];
        myTimer = nil;
        //[delegate timerIsZero:dateId];
        timerLabel.text = @"Message expired";
    }
}


//this method has to be implemented because we are using PureLayout framework.
-(void) updateConstraints {
    if(!addConstraints) {
        addConstraints = TRUE;
        [self autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.superview];
        [self autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.superview];
        [self autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.superview];
        [self autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.superview];
    }
    [super updateConstraints];
}



@end

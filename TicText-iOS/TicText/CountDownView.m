//
//  CountDownView.m
//  TicText
//
//  Created by Georgy Petukhov on 4/13/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "CountDownView.h"
#import "TTMessagesViewController.h"

@interface CountDownView () {
    UILabel *timerLabel;
    int counter;
    TTMessagesViewController *delegate;
    NSDate *dateId;
    NSTimer *myTimer;
}

@end

@implementation CountDownView

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
    
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(timerAnimate)
                                   userInfo:nil
                                    repeats:YES];
    }
    return self;
}

-(void)timerAnimate {
   // NSLog(@"timer tick!");
    timerLabel.text = [NSString stringWithFormat:@"%i sec", --counter];;
    if(counter == 0) {
        [myTimer invalidate];
        myTimer = nil;
        [delegate timerIsZero:dateId];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end

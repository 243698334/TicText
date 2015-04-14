//
//  CountDownView.m
//  TicText
//
//  Created by Georgy Petukhov on 4/13/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "CountDownView.h"

@interface CountDownView () {
    UILabel *timerLabel;
    int counter;
}

@end

@implementation CountDownView

- (id)initWithFrame:(CGRect)aRect time:(NSTimeInterval)timeLimit {
    counter = (int)timeLimit;
    self = [super initWithFrame:aRect];
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
    
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(timerAnimate)
                                   userInfo:nil
                                    repeats:YES];
    }
    return self;
}

-(void)timerAnimate {
    NSLog(@"timer tick!");
    timerLabel.text = [NSString stringWithFormat:@"%i sec", --counter];;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end

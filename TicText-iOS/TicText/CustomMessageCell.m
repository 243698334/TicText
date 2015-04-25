//
//  CustomMessageCell.m
//  TicText
//
//  Created by Georgy Petukhov on 4/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "CustomMessageCell.h"

@implementation CustomMessageCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)setExtraView:(UIView *)someView {
    [someView setTranslatesAutoresizingMaskIntoConstraints:NO];
    someView.frame = self.messageBubbleContainerView.bounds;
    
    [self.messageBubbleContainerView addSubview:someView];
    //[self.messageBubbleContainerView jsq_pinAllEdgesOfSubview:someView];
    _extraView = someView;
    
}

- (void) removeExtraView {
    [self.extraView removeFromSuperview];
}

@end

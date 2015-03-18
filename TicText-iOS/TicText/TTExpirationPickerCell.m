//
//  TTExpirationPickerCell.m
//  TicText
//
//  Created by Terrence K on 3/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTExpirationPickerCell.h"

@implementation TTExpirationPickerCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

#define kTextLabelFontSize 24.0f
#define kUnitsLabelFontSize 12.0f
#define kLabelWidthInset (4.0f)
#define kLabelHeightInset (4.0f)
- (void)setupView {
    CGRect textFrame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
    CGRect unitsFrame = CGRectMake(textFrame.size.width, 0, self.frame.size.width - textFrame.size.width, self.frame.size.height);
    
    textFrame = CGRectInset(textFrame, kLabelWidthInset, kLabelHeightInset);
    unitsFrame = CGRectInset(unitsFrame, kLabelWidthInset, kLabelHeightInset);
    
    self.textLabel = [[UILabel alloc] initWithFrame:textFrame];
    self.unitLabel = [[UILabel alloc] initWithFrame:unitsFrame];
    
    [self.textLabel setBackgroundColor:[UIColor whiteColor]];
    [self.textLabel setTextColor:kTTUIPurpleColor];
    [self.textLabel.layer setCornerRadius:self.textLabel.frame.size.width/2.0f];
    [self.textLabel setClipsToBounds:YES];
    
    [self.unitLabel setBackgroundColor:[UIColor clearColor]];
    [self.unitLabel setTextColor:[UIColor whiteColor]];
    
    [self.textLabel setFont:[UIFont systemFontOfSize:kTextLabelFontSize]];
    [self.unitLabel setFont:[UIFont systemFontOfSize:kUnitsLabelFontSize]];
    
    [self.textLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin];
    [self.unitLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin];
    
    [self.textLabel setTextAlignment:NSTextAlignmentCenter];
    [self.unitLabel setTextAlignment:NSTextAlignmentLeft];
    
    [self.unitLabel setHidden:YES]; // will be unhidden by the controller when pinned
    
    [self addSubview:self.textLabel];
    [self addSubview:self.unitLabel];
}

#pragma mark - NSCopying≥
- (id)copyWithZone:(NSZone *)zone {
    TTExpirationPickerCell *newCell = [[[self class] allocWithZone:zone] initWithFrame:self.frame];
    if (newCell) {
        newCell.textLabel.text = _textLabel.text;
        newCell.unitLabel.text = _unitLabel.text;
    }
    return newCell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  ScrollToTopView.m
//  AdjustingSectionHeader
//
//  Created by Jack Arendt on 3/14/15.
//  Copyright (c) 2015 John Arendt. All rights reserved.
//

#import "TTScrollToTopView.h"
#define kShrunkHeight 44
#import "TTConstants.h"

@interface TTScrollToTopView () {
    BOOL _visible;
}
@property (nonatomic, strong) UILabel *unreadLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@end

@implementation TTScrollToTopView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        CGFloat radius = kShrunkHeight - 20;
        self.backgroundColor = kTTUIPurpleColor;
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.bounds.size.width - 50, 10 + (frame.size.height - kShrunkHeight)/2, 30, radius) cornerRadius:radius/2];
        CAShapeLayer *rectLayer = [CAShapeLayer layer];
        rectLayer.path = rectPath.CGPath;
        rectLayer.fillColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:rectLayer];
        
        self.unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, self.bounds.size.width - 120, self.bounds.size.height)];
        self.unreadLabel.text = @"You have unread Tics";
        self.unreadLabel.minimumScaleFactor = 0.7;
        self.unreadLabel.adjustsFontSizeToFitWidth = YES;
        self.unreadLabel.textColor = [UIColor whiteColor];
        self.unreadLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.unreadLabel];
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 50, 10, 30, radius)];
        self.messageLabel.textColor = kTTUIPurpleColor;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.messageLabel];
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10 + (frame.size.height - kShrunkHeight)/2, radius, radius)];
        iv.image = [UIImage imageNamed:@"TicTextIconLightSmall"];
        [self addSubview:iv];
        
        UIButton *button = [[UIButton alloc] initWithFrame:self.bounds];
        [button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        [self setTableVisible:_visible];
    }
    return self;
}

-(void)setUnreadMessages:(NSInteger)unreadMessages {
    self.messageLabel.text = [NSString stringWithFormat:@"%li", (long)unreadMessages];
    if(unreadMessages == 0) {
        self.unreadLabel.text = @"You have no new Tics";
        self.unreadLabel.font = [UIFont fontWithName:@"Avenir-Light" size:self.unreadLabel.font.pointSize];
    }
}

-(void)setTableVisible:(BOOL)visible {
    _visible = visible;
    if(_visible) {
        self.unreadLabel.text = @"Tap to dismiss";
    }
    else {
        self.unreadLabel.text = @"You have unread Tics";
    }
}

-(void)buttonPressed {
    if(self.delegate) {
        [self.delegate unreadButtonPressed];
    }
}
@end

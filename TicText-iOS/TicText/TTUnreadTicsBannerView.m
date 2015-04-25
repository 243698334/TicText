//
//  ScrollToTopView.m
//  AdjustingSectionHeader
//
//  Created by Jack Arendt on 3/14/15.
//  Copyright (c) 2015 John Arendt. All rights reserved.
//

#import "TTUnreadTicsBannerView.h"
#define kShrunkHeight 44
#import "TTConstants.h"

@interface TTUnreadTicsBannerView () {
    BOOL _visible;
}

@property (nonatomic, assign) BOOL isUnreadTicsListVisible;
@property (nonatomic, strong) UIButton *bannerButton;

@end

@implementation TTUnreadTicsBannerView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.isUnreadTicsListVisible = NO;
        
        CGFloat radius = kShrunkHeight - 20;
        self.backgroundColor = kTTUIPurpleColor;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, self.bounds.size.width - 120, self.bounds.size.height)];
        self.titleLabel.minimumScaleFactor = 0.7;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        self.unreadTicsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 50, 10, 30, radius)];
        self.unreadTicsCountLabel.textColor = kTTUIPurpleColor;
        self.unreadTicsCountLabel.backgroundColor = [UIColor whiteColor];
        self.unreadTicsCountLabel.textAlignment = NSTextAlignmentCenter;
        CALayer *unreadTicsCountLabelLayer = self.unreadTicsCountLabel.layer;
        [unreadTicsCountLabelLayer setMasksToBounds:YES];
        [unreadTicsCountLabelLayer setCornerRadius:12];
        [self addSubview:self.unreadTicsCountLabel];
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10 + (frame.size.height - kShrunkHeight)/2, radius, radius)];
        iv.image = [UIImage imageNamed:@"TicTextIconLightSmall"];
        [self addSubview:iv];
        
        self.bannerButton = [[UIButton alloc] initWithFrame:self.bounds];
        [self.bannerButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.bannerButton];
        
    }
    return self;
}

- (void)reloadData {
    if (self.dataSource) {
        NSInteger numberOfUnreadTics = [self.dataSource numberOfUnreadTicsInUnreadTicsBannerView];
        self.unreadTicsCountLabel.text = [NSString stringWithFormat:@"%li", numberOfUnreadTics];
        self.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:self.titleLabel.font.pointSize];
    }
    [self updateTitleWithUnreadTicsListVisibile:self.isUnreadTicsListVisible];
}

- (void)updateTitleWithUnreadTicsListVisibile:(BOOL)visible {
    self.isUnreadTicsListVisible = visible;
    
    if (self.dataSource && [self.dataSource numberOfUnreadTicsInUnreadTicsBannerView] == 0) {
        self.titleLabel.text = @"You have no new Tics";
        return;
    }
    
    if (self.isUnreadTicsListVisible) {
        self.titleLabel.text = @"Tap to dismiss";
    } else {
        self.titleLabel.text = @"Tap to view your unread Tics";
    }
}

- (void)buttonPressed {
    if (self.delegate) {
        [self.delegate didTapUnreadTicsBanner];
    }
}

@end

//
//  TTComposeTableViewCell.m
//  TicText
//
//  Created by Kevin Yufei Chen on 4/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTComposeTableViewCell.h"

#import <PureLayout/PureLayout.h>
#import <ParseUI/ParseUI.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface TTComposeTableViewCell ()

@property (nonatomic) BOOL addedConstraints;

@property (nonatomic, strong) UIImageView *profilePictureImageView;
@property (nonatomic, strong) UILabel *displayNameLabel;

@end

CGFloat const kTTComposeTableViewCellHeight = 44;
CGFloat const kTTComposeTableViewCellPadding = 3;

@implementation TTComposeTableViewCell

+ (CGFloat)height {
    return kTTComposeTableViewCellHeight;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Profile picture
        self.profilePictureImageView = [[UIImageView alloc] init];
        self.profilePictureImageView.translatesAutoresizingMaskIntoConstraints = NO;
        CALayer *profilePictureLayer = self.profilePictureImageView.layer;
        [profilePictureLayer setBorderWidth:1.0];
        [profilePictureLayer setMasksToBounds:YES];
        [profilePictureLayer setBorderColor:[kTTUIPurpleColor CGColor]];
        [profilePictureLayer setCornerRadius:(kTTComposeTableViewCellHeight - 2 * kTTComposeTableViewCellPadding) / 2];
        [self.contentView addSubview:self.profilePictureImageView];
        
        // Display name label
        self.displayNameLabel = [[UILabel alloc] init];
        self.displayNameLabel.font = [UIFont fontWithName:kTTUIDefaultFont size:self.displayNameLabel.font.pointSize];
        self.displayNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.displayNameLabel];
        
        self.addedConstraints = NO;
    }
    return self;
}

- (void)updateConstraints {
    if (!self.addedConstraints) {
        // Profile picture
        [self.profilePictureImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kTTComposeTableViewCellPadding, kTTComposeTableViewCellPadding, kTTComposeTableViewCellPadding, kTTComposeTableViewCellPadding) excludingEdge:ALEdgeTrailing];
        [self.profilePictureImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.profilePictureImageView];
        
        // display name
        [self.displayNameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.profilePictureImageView withOffset:kTTComposeTableViewCellPadding * 2];
        [self.displayNameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kTTComposeTableViewCellPadding];
        [self.displayNameLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kTTComposeTableViewCellPadding];
        
        self.addedConstraints = YES;
    }
    [super updateConstraints];
}

- (void)updateWithUser:(TTUser *)user {
    [self.profilePictureImageView sd_setImageWithURL:[NSURL URLWithString:user.profilePicture.url] placeholderImage:[UIImage imageNamed:@"ProfilePicturePlaceholder"]];
    //        self.profilePictureImageView.file = fetchedUser.profilePicture; // TODO: Use the small profile picture
    //        [self.profilePictureImageView loadInBackground];
    self.displayNameLabel.text = user.displayName;

//    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        TTUser *fetchedUser = (TTUser *)object;
//        [self.profilePictureImageView sd_setImageWithURL:[NSURL URLWithString:fetchedUser.profilePicture.url] placeholderImage:[UIImage imageNamed:@"ProfilePicturePlaceholder"]];
////        self.profilePictureImageView.file = fetchedUser.profilePicture; // TODO: Use the small profile picture
////        [self.profilePictureImageView loadInBackground];
//        self.displayNameLabel.text = fetchedUser.displayName;
//    }];
}

@end

//
//  TTConversationTableViewCell.m
//  TicText
//
//  Created by Kevin Yufei Chen on 4/12/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTConversationTableViewCell.h"

#import <PureLayout/PureLayout.h>

@interface TTConversationTableViewCell ()

@property (nonatomic) BOOL addedConstraints;

@property (nonatomic, strong) UIImageView *profilePictureImageView;
@property (nonatomic, strong) UILabel *displayNameLabel;
@property (nonatomic, strong) UILabel *lastTicLabel;
@property (nonatomic, strong) UILabel *timestampLabel;

@end

CGFloat const kCellHeight = 70;
CGFloat const kPadding = 8;
CGFloat const kTimestampWidth = 40;

@implementation TTConversationTableViewCell

+ (CGFloat)height {
    return kCellHeight;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Profile picture
        self.profilePictureImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile"]];
        self.profilePictureImageView.translatesAutoresizingMaskIntoConstraints = NO;
        CALayer *profilePictureLayer = self.profilePictureImageView.layer;
        [profilePictureLayer setBorderWidth:2.0];
        [profilePictureLayer setMasksToBounds:YES];
        [profilePictureLayer setBorderColor:[kTTUIPurpleColor CGColor]];
        [profilePictureLayer setCornerRadius:(kCellHeight - 2 * kPadding) / 2.0];
        [self.contentView addSubview:self.profilePictureImageView];

        
        // Display name label
        self.displayNameLabel = [[UILabel alloc] init];
        self.displayNameLabel.font = [UIFont fontWithName:@"Avenir" size:self.displayNameLabel.font.pointSize];
        self.displayNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.displayNameLabel];
        
        // Last Tic label
        self.lastTicLabel = [[UILabel alloc] init];
        self.lastTicLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.lastTicLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.lastTicLabel.numberOfLines = 0;
        self.lastTicLabel.font = [UIFont fontWithName:@"Avenir-Light" size:self.displayNameLabel.font.pointSize - 4];
        self.lastTicLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.lastTicLabel];
        
        // Timestamp label
        self.timestampLabel = [[UILabel alloc] init];
        self.timestampLabel.font = [UIFont fontWithName:@"Avenir-Light" size:12];
        self.timestampLabel.textColor = [UIColor grayColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.timestampLabel];
        
        self.addedConstraints = NO;
    }
    return self;
}

- (void)updateConstraints {
    if (!self.addedConstraints) {
        // Profile picture
        [self.profilePictureImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kPadding, kPadding, kPadding, kPadding) excludingEdge:ALEdgeTrailing];
        [self.profilePictureImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.profilePictureImageView];
        
        // display name
        [self.displayNameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.profilePictureImageView withOffset:kPadding];
        [self.displayNameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kPadding];
        [self.displayNameLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kPadding * 2 + kTimestampWidth];
        [self.displayNameLabel autoSetDimension:ALDimensionHeight toSize:(kCellHeight - 2 * kPadding) / 2];
        
        // last tic
        [self.lastTicLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.profilePictureImageView withOffset:kPadding];
        [self.lastTicLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kPadding];
        [self.lastTicLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kPadding];
        [self.lastTicLabel autoSetDimension:ALDimensionHeight toSize:(kCellHeight - 2 * kPadding) / 2];
        
        // timestamp
        [self.timestampLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kPadding];
        [self.timestampLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kPadding];
        
        self.addedConstraints = YES;
    }
    [super updateConstraints];
}

- (void)updateWithConversation:(TTConversation *)conversation {
    // update display name and profile picture
    [conversation.recipient fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        TTUser *recipient = (TTUser *)object;
        self.profilePictureImageView.image = [UIImage imageWithData:recipient.profilePicture];
        if (conversation.type == kTTConversationTypeAnonymous) {
            self.displayNameLabel.text = @"Anonymous"; // TODO generate fake names
        } else {
            self.displayNameLabel.text = recipient.displayName;
        }
    }];
    
    // update last tic
    if (conversation.lastTic == nil) {
        self.lastTicLabel.text = @"[Draft]"; // TODO concatenate the content of the draft
    } else {
        if (conversation.lastTic.status == kTTTicStatusRead) {
            [conversation.lastTic fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                TTTic *lastTic = (TTTic *)object;
                if (lastTic.contentType == kTTTicContentTypeText) {
                    self.lastTicLabel.text = [NSString stringWithUTF8String:[lastTic.content bytes]];
                } else if (lastTic.contentType == kTTTicContentTypeImage) {
                    self.lastTicLabel.text = @"[Image]";
                } else if (lastTic.contentType == kTTTicContentTypeVoice) {
                    self.lastTicLabel.text = @"[Voice]";
                }
            }];
        } else if (conversation.lastTic.status == kTTTicStatusUnread) {
            self.lastTicLabel.text = @"[New Tic]";
            self.lastTicLabel.font = [UIFont boldSystemFontOfSize:self.lastTicLabel.font.pointSize];
        } else if (conversation.lastTic.status == kTTTIcStatusExpired) {
            self.lastTicLabel.text = @"[Expired]";
        }
    }
    
    // update timestamp
    NSTimeInterval secondsSinceLastTic = fabs([conversation.lastActivityTimestamp timeIntervalSinceNow]);
    unsigned dateComponentsFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *todaysDateComponents = [[NSCalendar currentCalendar] components:dateComponentsFlags fromDate:[NSDate date]];
    NSDateComponents *lastTicDateComponents = [[NSCalendar currentCalendar] components:dateComponentsFlags fromDate:conversation.lastActivityTimestamp];
    BOOL lastTicIsToday = [todaysDateComponents month] == [lastTicDateComponents month]
    && [todaysDateComponents day] == [lastTicDateComponents day]
    && [todaysDateComponents year] == [lastTicDateComponents year];
    NSDateFormatter *lastTicTimestampFormatter = [[NSDateFormatter alloc] init];
    
    if (secondsSinceLastTic < 60) {
        self.timestampLabel.text = @"Just now";
    } else if (secondsSinceLastTic < 60 * 60) {
        NSUInteger numberOfMinutes = secondsSinceLastTic / 60;
        self.timestampLabel.text = [NSString stringWithFormat:@"%ld %@", numberOfMinutes, numberOfMinutes == 1 ? @"min" :@"mins"];
    } else if (lastTicIsToday) {
        self.timestampLabel.text = [NSDateFormatter localizedStringFromDate:conversation.lastActivityTimestamp dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    } else {
        [lastTicTimestampFormatter setDateStyle:NSDateFormatterMediumStyle];
        [lastTicTimestampFormatter setDoesRelativeDateFormatting:YES];
        if (secondsSinceLastTic < 60 * 60 * 24 * 7) {
            lastTicTimestampFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEE" options:0 locale:[NSLocale currentLocale]];
        } else {
            lastTicTimestampFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM d" options:0 locale:[NSLocale currentLocale]];
        }
        self.timestampLabel.text = [lastTicTimestampFormatter stringFromDate:conversation.lastActivityTimestamp];
    }
    
    [self.contentView setNeedsUpdateConstraints];
}

@end

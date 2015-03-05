//
//  TTSettingsViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTSettingsViewController.h"
#import "TTFindFriendsViewController.h"

@interface TTSettingsViewController ()

@property (nonatomic, strong) UISwitch *receiveNewTicNotificationSwitch;
@property (nonatomic, strong) UISwitch *receiveExpireSoonNotificationSwitch;
@property (nonatomic, strong) UISwitch *receiveReadByRecipientNotificationSwitch;

@end

@implementation TTSettingsViewController

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        // initial settings...
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Settings";
    self.tableView.scrollEnabled = NO;
    
    self.receiveNewTicNotificationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.receiveExpireSoonNotificationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.receiveReadByRecipientNotificationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.receiveNewTicNotificationSwitch.on = YES;
    self.receiveExpireSoonNotificationSwitch.on = NO;
    self.receiveReadByRecipientNotificationSwitch.on = NO;
    [self.receiveNewTicNotificationSwitch setOnTintColor:kTTUIPurpleColor];
    [self.receiveExpireSoonNotificationSwitch setOnTintColor:kTTUIPurpleColor];
    [self.receiveReadByRecipientNotificationSwitch setOnTintColor:kTTUIPurpleColor];
    
    __unsafe_unretained __block TTSettingsViewController *safeSelf = self;
    
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        section.headerTitle = @"Notification";
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"New Tic";
            cell.accessoryView = safeSelf.receiveNewTicNotificationSwitch;
        } whenSelected:^(NSIndexPath *indexPath) {
            [safeSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Expire Soon";
            cell.accessoryView = safeSelf.receiveExpireSoonNotificationSwitch;
        } whenSelected:^(NSIndexPath *indexPath) {
            [safeSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Read by Recipient";
            cell.accessoryView = safeSelf.receiveReadByRecipientNotificationSwitch;
        } whenSelected:^(NSIndexPath *indexPath) {
            [safeSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
    }];
    
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleSubtitle;
            cell.textLabel.text = @"In-App Notification";
            cell.detailTextLabel.text = @"Banners, Sounds, Vibrate";
        } whenSelected:^(NSIndexPath *indexPath) {
            [safeSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        
        section.footerTitle = @"Turn on push notification so you won't miss your Tics. ";
    }];
    
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleSubtitle;
            cell.textLabel.text = @"See which friends are on TicText";
            cell.detailTextLabel.text = @"Click to view";
        } whenSelected:^(NSIndexPath *indexPath) {
            [safeSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
            TTFindFriendsViewController *ffvc = [[TTFindFriendsViewController alloc] init];
            [safeSelf presentViewController:ffvc animated:YES completion:nil];
        }];
    }];

    
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.cellStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Like us on Facebook";
        } whenSelected:^(NSIndexPath *indexPath) {
            [safeSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.cellStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Technical Support";
        } whenSelected:^(NSIndexPath *indexPath) {
            [safeSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.cellStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"About";
        } whenSelected:^(NSIndexPath *indexPath) {
            [safeSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
    }];
    
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleDefault;
            cell.textLabel.text = @"Log Out";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor redColor];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } whenSelected:^(NSIndexPath *indexPath) {
            [safeSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTUserDidLogOutNotification object:nil];
        }];

    }];
    
}

@end

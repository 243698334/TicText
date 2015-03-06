//
//  TTSettingsViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTSettingsViewController.h"
#import "TTFindFriendsViewController.h"
#import "TTSettings.h"

@interface TTSettingsViewController ()

@property (nonatomic, strong) UISwitch *receiveNewTicNotificationSwitch;
@property (nonatomic, strong) UISwitch *receiveExpireSoonNotificationSwitch;
@property (nonatomic, strong) UISwitch *receiveReadByRecipientNotificationSwitch;
@property (nonatomic, strong) MFMailComposeViewController *mc;

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
    self.mc = [[MFMailComposeViewController alloc] init];
    self.mc.mailComposeDelegate = self;
    self.navigationItem.title = @"Settings";
    self.tableView.scrollEnabled = YES;
    
    self.receiveNewTicNotificationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.receiveExpireSoonNotificationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.receiveReadByRecipientNotificationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.receiveNewTicNotificationSwitch.on = [TTSettings getNewTicNotificationPreference];
    self.receiveExpireSoonNotificationSwitch.on = [TTSettings getExpireSoonNotificationPreference];
    self.receiveReadByRecipientNotificationSwitch.on = [TTSettings getReadNotificationPreference];
    [self.receiveNewTicNotificationSwitch setOnTintColor:kTTUIPurpleColor];
    [self.receiveExpireSoonNotificationSwitch setOnTintColor:kTTUIPurpleColor];
    [self.receiveReadByRecipientNotificationSwitch setOnTintColor:kTTUIPurpleColor];
    
    [self.receiveNewTicNotificationSwitch addTarget:self action:@selector(changeNotificationPreferences) forControlEvents:UIControlEventValueChanged];
    [self.receiveExpireSoonNotificationSwitch addTarget:self action:@selector(changeNotificationPreferences) forControlEvents:UIControlEventValueChanged];
    [self.receiveReadByRecipientNotificationSwitch addTarget:self action:@selector(changeNotificationPreferences) forControlEvents:UIControlEventValueChanged];
    
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
            cell.textLabel.text = @"In-App Notifications";
            cell.detailTextLabel.text = @"Tapping this takes you to the settings app";
        } whenSelected:^(NSIndexPath *indexPath) {
            [safeSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
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
            UIGraphicsBeginImageContextWithOptions(safeSelf.view.bounds.size, NO, [UIScreen mainScreen].scale);
            [((UIWindow *)[UIApplication sharedApplication].windows.firstObject).layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *ss = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            ffvc.screenshot = ss;
            [safeSelf presentViewController:ffvc animated:YES completion:nil];
        }];
    }];

    
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.cellStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Like us on Facebook";
        } whenSelected:^(NSIndexPath *indexPath) {
            NSString *urlString = @"https://www.facebook.com/pages/TicText/587674271368005";
            NSURL *url = [NSURL URLWithString:urlString];
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://profile/587674271368005"]]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/587674271368005"]];
            }
            else {
                [[UIApplication sharedApplication] openURL:url];
            }
            [safeSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.cellStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Technical Support";
        } whenSelected:^(NSIndexPath *indexPath) {
            [safeSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
            safeSelf.mc.navigationBar.tintColor = kTTUIPurpleColor;
            [safeSelf.mc setSubject:@"TicText Technical Support"];
            [safeSelf.mc setToRecipients:@[@"jack.arendt93@gmail.com"]];
            [safeSelf presentViewController:safeSelf.mc animated:YES completion:nil];
        }];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.cellStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"About";
        } whenSelected:^(NSIndexPath *indexPath) {
            NSString *urlString = @"https://www.facebook.com/pages/TicText/587674271368005";
            NSURL *url = [NSURL URLWithString:urlString];
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://profile/587674271368005"]]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/587674271368005"]];
            }
            else {
                [[UIApplication sharedApplication] openURL:url];
            }
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

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    NSLog(@"HEY");
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)changeNotificationPreferences {
    [TTSettings changeNotificationPreferences:self.receiveNewTicNotificationSwitch.on expireSoon:self.receiveExpireSoonNotificationSwitch.on read:self.receiveReadByRecipientNotificationSwitch.on];
}


@end

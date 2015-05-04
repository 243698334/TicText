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

#define kFacebookURL @"https://www.facebook.com/pages/TicText/587674271368005"
#define kFacebookAppURL @"fb://profile/587674271368005"

@interface TTSettingsViewController ()

@property (nonatomic, strong) UISwitch *receiveNewTicNotificationSwitch;
@property (nonatomic, strong) UISwitch *receiveExpireSoonNotificationSwitch;
@property (nonatomic, strong) UISwitch *receiveReadByRecipientNotificationSwitch;
@property (nonatomic, strong) MFMailComposeViewController *mc;
@property (nonatomic, strong) HFStretchableTableHeaderView *stretchableTableHeaderView;
@property (nonatomic, strong) ProfileHeaderView *headerView;

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
    
    self.stretchableTableHeaderView = [[HFStretchableTableHeaderView alloc] init];
    self.headerView = [[ProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.5333 * self.view.bounds.size.width)];
    self.stretchableTableHeaderView = [[HFStretchableTableHeaderView alloc] init];
    [self.stretchableTableHeaderView stretchHeaderForTableView:self.tableView withView:self.headerView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
    
    self.receiveNewTicNotificationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.receiveExpireSoonNotificationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.receiveReadByRecipientNotificationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.receiveNewTicNotificationSwitch.on = [TTSettings newTicNotificationPreference];
    self.receiveExpireSoonNotificationSwitch.on = [TTSettings expireSoonNotificationPreference];
    self.receiveReadByRecipientNotificationSwitch.on = [TTSettings readNotificationPreference];
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
            [safeSelf presentViewController:ffvc animated:YES completion:nil];
        }];
    }];
    
    
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.cellStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Like us on Facebook";
        } whenSelected:^(NSIndexPath *indexPath) {
            NSString *urlString = kFacebookURL;
            NSURL *url = [NSURL URLWithString:urlString];
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kFacebookAppURL]]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kFacebookAppURL]];
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
            NSString *urlString = kFacebookURL;
            NSURL *url = [NSURL URLWithString:urlString];
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kFacebookAppURL]]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kFacebookAppURL]];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.stretchableTableHeaderView scrollViewDidScroll:scrollView];
}

- (void)viewDidLayoutSubviews
{
    [self.stretchableTableHeaderView resizeView];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    NSLog(@"HEY");
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)changeNotificationPreferences {
    [TTSettings changeNotificationPreferences:self.receiveNewTicNotificationSwitch.on expireSoon:self.receiveExpireSoonNotificationSwitch.on read:self.receiveReadByRecipientNotificationSwitch.on];
}

-(void)edit {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *name = [UIAlertAction actionWithTitle:@"Edit Name" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIAlertController *changeName = [UIAlertController alertControllerWithTitle:@"Change Name" message:@"What is your new name?" preferredStyle:UIAlertControllerStyleAlert];
        [changeName addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = @"new name";
            textField.text = [TTUser currentUser].displayName;
        }];
        UIAlertAction *change = [UIAlertAction actionWithTitle:@"Change" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            UITextField * textField = changeName.textFields.firstObject;
            TTUser *_user = [TTUser currentUser];
            _user.displayName = textField.text;
            [_user saveInBackgroundWithBlock:^(BOOL success, NSError *err){
                if(success) {
                    [self.headerView refreshValues];
                }
            }];
        }];
        
        UIAlertAction *cancelNameChange = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
            
        }];
        
        [changeName addAction:change];
        [changeName addAction:cancelNameChange];
        [self presentViewController:changeName animated:YES completion:nil];

    }];
    
    UIAlertAction *profilePicture = [UIAlertAction actionWithTitle:@"Edit Profile Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        UIAlertController *changePicture = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Take New Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * alert){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:NULL];
        }];
        
        UIAlertAction *photos = [UIAlertAction actionWithTitle:@"Choose From Camera Roll" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alert){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:NULL];
        }];
        
        UIAlertAction *cancelPhotos = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            
        }];
        
        [changePicture addAction:camera];
        [changePicture addAction:photos];
        [changePicture addAction:cancelPhotos];
        [self presentViewController:changePicture animated:YES completion:nil];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
        
    }];
    
    [alertController addAction:name];
    [alertController addAction:profilePicture];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image =  (UIImage*) [info objectForKey:UIImagePickerControllerOriginalImage];
    TTUser * _user = [TTUser currentUser];
    [_user setProfilePicture:UIImageJPEGRepresentation(image, 0.8)];
    [_user saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
        if(success) {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Save Successful!" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
            [controller addAction:dismiss];
            [self presentViewController:controller animated:YES completion:nil];
        }
        else {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Something went wrong" message:@"Your picture could not be saved." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
            [controller addAction:dismiss];
            [self presentViewController:controller animated:YES completion:nil];
        }
    }];
    [self.headerView refreshValues];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

//
//  TTRootViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/11/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTRootViewController.h"

#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <TSMessages/TSMessage.h>
#import "TTConstants.h"
#import "TTSession.h"
#import "TTUtility.h"
#import "TTErrorHandler.h"

#import "TTLogInViewController.h"
#import "TTFindFriendsViewController.h"
#import "TTConversationsViewController.h"
#import "TTContactsViewController.h"
#import "TTProfileViewController.h"
#import "TTSettingsViewController.h"

@interface TTRootViewController ()

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) BOOL sessionIsValid;

@property (nonatomic, strong) TTLogInViewController *logInViewController;
@property (nonatomic, strong) TTFindFriendsViewController *findFriendsViewController;
@property (nonatomic, strong) TTConversationsViewController *conversationsViewController;
@property (nonatomic, strong) TTContactsViewController *contactsViewController;
@property (nonatomic, strong) TTProfileViewController *profileViewController;
@property (nonatomic, strong) TTSettingsViewController *settingsViewController;
@property (nonatomic, strong) UINavigationController *conversationsNavigationController;
@property (nonatomic, strong) UINavigationController *contactsNavigationController;
@property (nonatomic, strong) UINavigationController *profileNavigationController;
@property (nonatomic, strong) UINavigationController *settingsNavigationController;
@property (nonatomic, strong) UITabBarController *tabBarController;

@end

@implementation TTRootViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionIsValid = NO;
    self.view.backgroundColor = kTTUIPurpleColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveNewTicWhileActive:) name:kTTApplicationDidReceiveNewTicWhileActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDataDidBecomeAvailable:) name:kTTUserDataDidBecomeAvailableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidBecomeInvalid:) name:kTTSessionDidBecomeInvalidNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logInViewControllerDidFinishLogIn) name:kTTLogInViewControllerDidFinishLogInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logInViewControllerDidFinishSignUp) name:kTTLogInViewControllerDidFinishSignUpNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogOut) name:kTTUserDidLogOutNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [TTSession validateSessionInBackground];
    if ([TTSession isValidLastChecked]) {
        self.sessionIsValid = YES;
        [TTSession syncFriendsDataInBackground];
        [self fetchOrUpdateUserData];
    } else {
        self.sessionIsValid = NO;
        [self presentLogInViewControllerAnimated:YES];
    }
}

#pragma mark - TTRootViewController

- (void)fetchOrUpdateUserData {
    if ([[TTUser currentUser] isDataAvailable] && [[TTUser currentUser].privateData isDataAvailable]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTUserDataDidBecomeAvailableNotification object:nil];
        [[TTUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [[TTUser currentUser].privateData fetchIfNeededInBackground];
        }];
    } else {
        NSLog(@"Current user availability: %@", [TTUser currentUser].isDataAvailable ? @"YES" : @"NO");
        NSLog(@"Current user private data availability: %@", [TTUser currentUser].privateData.isDataAvailable ? @"YES" : @"NO");
        // Must synchromously prepare all data before proceed.
        if (![TTUtility isParseReachable] || ![TTUtility isInternetReachable]) {
            NSLog(@"Parse is not reachable. Query from local datastore. ");
            PFQuery *userPrivateDataQuery = [TTUserPrivateData query];
            [userPrivateDataQuery fromPinWithName:kTTLocalDatastorePrivateDataPinName];
            [userPrivateDataQuery whereKey:kTTUserPrivateDataUserIdKey equalTo:[TTUser currentUser].objectId];
            [userPrivateDataQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [TTUser currentUser].privateData = (TTUserPrivateData *)object;
                PFQuery *friendsQuery = [TTUser query];
                [friendsQuery fromPinWithName:kTTLocalDatastoreFriendsPinName];
                NSMutableArray *friendIds = [[NSMutableArray alloc] init];
                for (TTUser *currentFriend in [TTUser currentUser].privateData.friends) {
                    [friendIds addObject:currentFriend.objectId];
                }
                [friendsQuery whereKey:@"objectId" containedIn:friendIds];
                [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    [TTUser currentUser].privateData.friends = objects;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTTUserDataDidBecomeAvailableNotification object:nil];
                }];
            }];
        } else {
            [[TTUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [[TTUser currentUser].privateData fetchIfNeededInBackground];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTUserDataDidBecomeAvailableNotification object:nil];
            }];
        }
    }
}

- (void)presentLogInViewControllerAnimated:(BOOL)animated {
    if (self.logInViewController.isViewLoaded && self.logInViewController.view.window) {
        // If the LogInViewController is already displayed on the screen then do nothing.
        return;
    }
    self.logInViewController = [[TTLogInViewController alloc] init];
    [self presentViewController:self.logInViewController animated:animated completion:nil];
}

- (void)presentMainUserInterface {
    self.conversationsViewController = [[TTConversationsViewController alloc] init];
    self.contactsViewController = [[TTContactsViewController alloc] init];
    self.profileViewController = [[TTProfileViewController alloc] init];
    self.settingsViewController = [[TTSettingsViewController alloc] init];
    self.conversationsNavigationController = [[UINavigationController alloc] initWithRootViewController:self.conversationsViewController];
    self.contactsNavigationController = [[UINavigationController alloc] initWithRootViewController:self.contactsViewController];
    self.profileNavigationController = [[UINavigationController alloc] initWithRootViewController:self.profileViewController];
    self.settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:self.settingsViewController];
    
    UITabBarItem *conversationsTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tics"
                                                                          image:[UIImage imageNamed:@"TicsTabBarIcon"]
                                                                  selectedImage:[UIImage imageNamed:@"TicsTabBarIconSelected"]];
    UITabBarItem *contactsTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Contacts"
                                                                     image:[UIImage imageNamed:@"ContactsTabBarIcon"]
                                                             selectedImage:[UIImage imageNamed:@"ContactsTabBarIconSelected"]];
    UITabBarItem *profileTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Me"
                                                                    image:[UIImage imageNamed:@"MeTabBarIcon"]
                                                            selectedImage:[UIImage imageNamed:@"MeTabBarIconSelected"]];
    UITabBarItem *settingsTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings"
                                                                     image:[UIImage imageNamed:@"SettingsTabBarIcon"]
                                                             selectedImage:[UIImage imageNamed:@"SettingsTabBarIconSelected"]];
    [self.conversationsNavigationController setTabBarItem:conversationsTabBarItem];
    [self.contactsNavigationController setTabBarItem:contactsTabBarItem];
    [self.profileNavigationController setTabBarItem:profileTabBarItem];
    [self.settingsNavigationController setTabBarItem:settingsTabBarItem];
    
    self.tabBarController = [[UITabBarController alloc] init];
    [self.tabBarController setViewControllers:@[self.conversationsNavigationController,
                                                self.contactsNavigationController,
                                                self.profileNavigationController,
                                                self.settingsNavigationController]];
    [[UITabBar appearance] setSelectedImageTintColor:kTTUIPurpleColor];
    [[UITabBar appearance] setAlpha:1.0];
    [self.navigationController setViewControllers:@[self, self.tabBarController] animated:NO];
}


- (void)logInViewControllerDidFinishLogIn {
    self.sessionIsValid = YES;
    [self.logInViewController dismissViewControllerAnimated:YES completion:nil];
    [self presentMainUserInterface];
    [TTUtility setupPushNotifications];
}

- (void)logInViewControllerDidFinishSignUp {
    [self logInViewControllerDidFinishLogIn];
    self.findFriendsViewController = [[TTFindFriendsViewController alloc] init];
    self.findFriendsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:self.findFriendsViewController animated:YES completion:nil];
}

- (void)userDidLogOut {
    self.sessionIsValid = NO;
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [TTSession logOutWithBlock:^(NSError *error) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        self.conversationsViewController = nil;
        self.contactsViewController = nil;
        self.profileViewController = nil;
        self.settingsViewController = nil;
        [self.progressHUD removeFromSuperview];
    }];
}

- (void)userDataDidBecomeAvailable:(NSNotification *)notification {
    [self presentMainUserInterface];
}

- (void)sessionDidBecomeInvalid:(NSNotification *)notification {
    if (self.sessionIsValid == NO) {
        return;
    }
    self.sessionIsValid = NO;
    NSError *error = [[notification userInfo] objectForKey:kTTNotificationUserInfoErrorKey];
    if (error) {
        [TTErrorHandler handleParseSessionError:error inViewController:self];
    }
    [TTSession logOutWithBlock:^(NSError *error) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        self.conversationsViewController = nil;
        self.contactsViewController = nil;
        self.profileViewController = nil;
        self.settingsViewController = nil;
    }];
}

- (void)applicationDidReceiveNewTicWhileActive:(NSNotification *)notification {
    if (self.conversationsViewController.isViewLoaded && self.conversationsViewController.view.window) {
        // conversation view controller is presented
        return;
    }
    
    if (self.conversationsViewController.isMessagesViewControllerPresented) {
        // messages view controller is presented
        return;
    }
    
    [TSMessage showNotificationInViewController:self.tabBarController
                                          title:@"Someone just sent you a Tic."
                                       subtitle:@"TAP HERE to see your unread Tics and conversations."
                                          image:[UIImage imageNamed:@"TicInAppNotificationIcon"]
                                           type:TSMessageNotificationTypeWarning
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:^(void) {
                                           self.tabBarController.selectedViewController = self.conversationsNavigationController;
                                           [TSMessage dismissActiveNotification];
                                       }
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionNavBarOverlay
                           canBeDismissedByUser:YES];
}

@end

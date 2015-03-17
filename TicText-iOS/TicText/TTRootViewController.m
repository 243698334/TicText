//
//  TTRootViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/11/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTRootViewController.h"

#import "TTLogInViewController.h"
#import "TTFindFriendsViewController.h"
#import "TTConversationsViewController.h"
#import "TTContactsViewController.h"
#import "TTProfileViewController.h"
#import "TTSettingsViewController.h"

@interface TTRootViewController ()

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) BOOL sessionIsInvalid;

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
    
    self.sessionIsInvalid = YES;
    self.view.backgroundColor = kTTUIPurpleColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidBecomeInvalid:) name:kTTSessionDidBecomeInvalidNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logInViewControllerDidFinishLogIn) name:kTTLogInViewControllerDidFinishLogInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logInViewControllerDidFinishSignUp) name:kTTLogInViewControllerDidFinishSignUpNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogOut) name:kTTUserDidLogOutNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[TTSession sharedSession] validateSessionInBackground];
    if ([[TTSession sharedSession] isValidLastChecked]) {
        [[TTSession sharedSession] fetchAndPinAllFriendsInBackground];
        [self presentMainUserInterface];
    } else {
        [self presentLogInViewControllerAnimated:YES];
    }
}

#pragma mark - TTRootViewController

- (void)sessionDidBecomeInvalid:(NSNotification *)notification {
    if (!self.sessionIsInvalid) {
        return;
    }
    self.sessionIsInvalid = NO;
    NSError *error = [[notification userInfo] objectForKey:kTTNotificationUserInfoErrorKey];
    if (error) {
        [self handleError:error];
    }
    [[TTSession sharedSession] logOut:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
        self.conversationsViewController = nil;
        self.contactsViewController = nil;
        self.profileViewController = nil;
        self.settingsViewController = nil;
    }];
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
    self.sessionIsInvalid = YES;
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
    self.sessionIsInvalid = NO;
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[TTSession sharedSession] logOut:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
        self.conversationsViewController = nil;
        self.contactsViewController = nil;
        self.profileViewController = nil;
        self.settingsViewController = nil;
        [self.progressHUD removeFromSuperview];
    }];
}

- (void)handleError:(NSError *)error {
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        [self showAlertViewWithErrorTitle:@"Something went wrong" errorMessage:[FBErrorUtility userMessageForError:error]];
    } else {
        if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
            // log in cancelled
            NSLog(@"Log in cancelled error: %@", error);
            [self showAlertViewWithErrorTitle:@"Login cancelled" errorMessage:@"Please log back in with Facebook. "];
        } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
            // invalid session
            NSLog(@"Invalid session error: %@", error);
            [self showAlertViewWithErrorTitle:@"Session Error" errorMessage:@"Your current session is no longer valid. Please log in agian. "];
        } else {
            NSLog(@"Other error: %@", error);
            [self showAlertViewWithErrorTitle:@"Invalid session" errorMessage:@"You have been logged out. "];
        }
    }
}

- (void)showAlertViewWithErrorTitle:(NSString *)title errorMessage:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


@end

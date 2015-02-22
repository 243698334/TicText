//
//  TTRootViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/11/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTRootViewController.h"

@interface TTRootViewController ()

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) BOOL shouldPresentFindFriendsViewController;

@property (nonatomic, strong) TTLogInViewController *logInViewController;
@property (nonatomic, strong) TTFindFriendsViewController *findFriendsViewController;
@property (nonatomic, strong) TTConversationsViewController *conversationsViewController;
@property (nonatomic, strong) TTContactsViewController *contactsViewController;
@property (nonatomic, strong) TTProfileViewController *profileViewController;
@property (nonatomic, strong) TTSettingsViewController *settingsViewController;

@end

@implementation TTRootViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kTTUIPurpleColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidBecomeInvalid:) name:kTTParseSessionDidBecomeInvalidNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidBecomeInvalid:) name:kTTFacebookSessionDidBecomeInvalidNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logInViewControllerDidFinishLogIn) name:kTTLogInViewControllerDidFinishLogInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logInViewControllerDidFinishSignUp) name:kTTLogInViewControllerDidFinishSignUpNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[TTSession sharedSession] validateSessionInBackground];
}

// Temporary IBAction method
- (IBAction)logOutForTesting:(id)sender {
    [[TTSession sharedSession] logOut:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self presentLogInViewControllerForLogIn:NO animated:YES];
    }];
}


#pragma mark - TTRootViewController

- (void)sessionDidBecomeInvalid:(NSNotification *)notification {
    NSError *error = [[notification userInfo] objectForKey:@"error"];
    if (error) {
        [self handleError:error];
    }
    [[TTSession sharedSession] logOut:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self presentLogInViewControllerForLogIn:NO animated:YES];
    }];
}

- (void)presentLogInViewControllerIfNeeded {
    if (![[TTSession sharedSession] isValidLastChecked]) {
        [self presentLogInViewControllerForLogIn:NO animated:YES];
    }
}

- (void)presentLogInViewControllerForLogIn:(BOOL)presentForLogIn animated:(BOOL)animated {
    if (self.logInViewController.isViewLoaded && self.logInViewController.view.window) {
        // If the LogInViewController is already displayed on the screen do nothing.
        return;
    }
    self.logInViewController = [[TTLogInViewController alloc] init];
    self.logInViewController.presentForLogIn = presentForLogIn;
    [self presentViewController:self.logInViewController animated:animated completion:nil];
}


- (void)logInViewControllerDidFinishLogIn {
    [self.logInViewController dismissViewControllerAnimated:YES completion:nil];
    [TTUtility setupPushNotifications];
}

- (void)logInViewControllerDidFinishSignUp {
    [self logInViewControllerDidFinishLogIn];
    self.findFriendsViewController = [[TTFindFriendsViewController alloc] init];
    self.findFriendsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:self.findFriendsViewController animated:YES completion:nil];
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
            [self showAlertViewWithErrorTitle:@"Something went wrong" errorMessage:@"Please retry"];
        }
    }
}

- (void)showAlertViewWithErrorTitle:(NSString *)title errorMessage:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


@end

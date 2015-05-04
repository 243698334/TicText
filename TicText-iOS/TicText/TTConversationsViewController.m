//
//  TTConversationsViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTConversationsViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <TSMessages/TSMessageView.h>
#import <PureLayout/PureLayout.h>
#import <AudioToolbox/AudioServices.h>
#import "TTMessagesViewController.h"

#import "TTUtility.h"
#import "TTUser.h"
#import "TTConversation.h"
#import "TTNewTic.h"
#import "TTErrorHandler.h"

@interface TTConversationsViewController ()

@property (nonatomic, strong) TTMessagesViewController *messagesViewController;

@property (nonatomic, assign) BOOL isNewTicsDropdownViewVisible;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) TTNewTicsBannerView *receivedNewTicsBannerView;
@property (nonatomic, strong) TTNewTicsDropdownView *receivedNewTicsDropdownView;
@property (nonatomic, strong) TTComposeView *composeView;
@property (nonatomic, strong) UITableView *conversationsTableView;

@property (nonatomic, strong) NSTimer *updateVisibleConversationCellsTimer;
@property (nonatomic, strong) NSTimer *updateVisibleNewTicCellsTimer;

@property (nonatomic, strong) NSMutableArray *conversations;

// properties for New Tics Dropdown View
@property (nonatomic, strong) NSMutableDictionary *receivedNewTicsDictionary;
@property (nonatomic, strong) NSArray *receivedNewTicsSortedKeys;
@property (nonatomic, strong) NSString *receivedNewTicsDropdownViewSelectedSenderId;

@end

@implementation TTConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.receivedNewTicsDictionary = [[NSMutableDictionary alloc] init];
    [self loadInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadConversations];
    [self loadNewTics];
    if (self.updateVisibleConversationCellsTimer != nil) {
        [self.updateVisibleConversationCellsTimer invalidate];
    }
    self.updateVisibleConversationCellsTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateVisibleConversationCells) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadDataForViews];
    [self updateVisibleConversationCells];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveNewTicWhileActive:) name:kTTApplicationDidReceiveNewTicWhileActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideNewTicsDropdownView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTTApplicationDidReceiveNewTicWhileActiveNotification object:nil];
}

- (BOOL)isMessagesViewControllerPresented {
    return self.messagesViewController != nil && self.messagesViewController.isViewLoaded && self.messagesViewController.view.window;
}

- (void)loadInterface {
    // navigation bar
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"TicText";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showComposeView)];
    
    // new Tics banner view
    self.isNewTicsDropdownViewVisible = NO;
    self.receivedNewTicsBannerView = [[TTNewTicsBannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [TTNewTicsBannerView height])];
    self.receivedNewTicsBannerView.delegate = self;
    self.receivedNewTicsBannerView.dataSource = self;
    [self.view addSubview:self.receivedNewTicsBannerView];
    
    // conversations table view
    self.conversationsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [TTNewTicsBannerView height], self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.conversationsTableView.delegate = self;
    self.conversationsTableView.dataSource = self;
    self.conversationsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.conversationsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.conversationsTableView registerClass:[TTConversationTableViewCell class] forCellReuseIdentifier:[TTConversationTableViewCell reuseIdentifier]];
    [self.view addSubview:self.conversationsTableView];
}

- (void)loadConversations {
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadConversationsInBackgroundFromLocal:YES completion:^(BOOL conversationsDidLoad, NSError *error) {
        if (error) {
            [TSMessage showNotificationInViewController:self title:@"Local Datastore Failed" subtitle:@"We are unable to locally load your conversations at this moment. Please wait for few seconds while we reload them from our server. " type:TSMessageNotificationTypeWarning];
            [self loadConversationsInBackgroundFromLocal:NO completion:^(BOOL conversationsDidLoad, NSError *error) {
                [self.progressHUD removeFromSuperview];
                if (conversationsDidLoad) {
                    [TSMessage showNotificationInViewController:self title:@"Conversations Synced" subtitle:@"We have just synced your conversations with our server. " type:TSMessageNotificationTypeSuccess];
                    [self reloadDataForViews];
                } else {
                    // TODO: no conversations
                }
            }];
        } else {
            if (conversationsDidLoad) {
                [self.progressHUD removeFromSuperview];
                [self reloadDataForViews];
            } else {
                [self.progressHUD removeFromSuperview];
                [self loadConversationsInBackgroundFromLocal:NO completion:^(BOOL conversationsDidLoad, NSError *error) {
                    if (conversationsDidLoad) {
                        [self reloadDataForViews];
                    } else {
                        // TODO: no conversations
                    }
                }];
            }
        }
    }];
}

- (void)loadNewTics {
    PFQuery *receivedNewTicsQuery = [TTNewTic query];
    [receivedNewTicsQuery fromPinWithName:kTTLocalDatastoreNewTicsPinName];
    [receivedNewTicsQuery whereKey:kTTNewTicRecipientUserIdKey equalTo:[TTUser currentUser].objectId];
    [receivedNewTicsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (TTNewTic *currentReceivedNewTic in objects) {
                BOOL isReceivedNewTicDuplicate = NO;
                for (NSString *currentSenderId in self.receivedNewTicsSortedKeys) {
                    if (isReceivedNewTicDuplicate) {
                        break;
                    }
                    NSMutableArray *receivedNewTicsFromCurrentSender = [self.receivedNewTicsDictionary objectForKey:currentSenderId];
                    for (TTNewTic *currentNewTic in receivedNewTicsFromCurrentSender) {
                        if ([currentNewTic.ticId isEqualToString:currentReceivedNewTic.ticId]) {
                            isReceivedNewTicDuplicate = YES;
                            break;
                        }
                    }
                }
                
                if (!isReceivedNewTicDuplicate) {
                    [self storeNewTic:currentReceivedNewTic];
                }
            }
        }
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kTTUserDefaultsConversationsViewControllerShouldRetrieveNewTicsKey] isEqual:@YES]) {
            [TTNewTic retrieveNewTicsInBackgroundWithBlock:^(NSArray *receivedNewTics, NSError *error) {
                for (NSDictionary *currentReceivedNewTicDictionary in receivedNewTics) {
                    TTNewTic *currentReceivedNewTic = [TTNewTic object];
                    currentReceivedNewTic.ticId = [currentReceivedNewTicDictionary objectForKey:kTTNewTicTicIdKey];
                    currentReceivedNewTic.status = [currentReceivedNewTicDictionary objectForKey:kTTNewTicStatusKey];
                    currentReceivedNewTic.senderUserId = [currentReceivedNewTicDictionary objectForKey:kTTNewTicSenderUserIdKey];
                    currentReceivedNewTic.recipientUserId = [currentReceivedNewTicDictionary objectForKey:kTTNewTicRecipientUserIdKey];
                    currentReceivedNewTic.sendTimestamp = [currentReceivedNewTicDictionary objectForKey:kTTNewTicSendTimestampKey];
                    currentReceivedNewTic.timeLimit = [[currentReceivedNewTicDictionary objectForKey:kTTNewTicTimeLimitKey] doubleValue];
                    
                    BOOL isReceivedNewTicDuplicate = NO;
                    for (NSString *currentSenderId in self.receivedNewTicsSortedKeys) {
                        if (isReceivedNewTicDuplicate) {
                            break;
                        }
                        NSMutableArray *receivedNewTicsFromCurrentSender = [self.receivedNewTicsDictionary objectForKey:currentSenderId];
                        for (TTNewTic *currentNewTic in receivedNewTicsFromCurrentSender) {
                            if ([currentNewTic.ticId isEqualToString:currentReceivedNewTic.ticId]) {
                                isReceivedNewTicDuplicate = YES;
                                break;
                            }
                        }
                    }
                    
                    if (!isReceivedNewTicDuplicate) {
                        [self storeNewTic:currentReceivedNewTic];
                    }
                }
                [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:kTTUserDefaultsConversationsViewControllerShouldRetrieveNewTicsKey];
                [self.receivedNewTicsDropdownView reloadData];
                [self.receivedNewTicsBannerView reloadData];
            }];
        } else {
            [self.receivedNewTicsDropdownView reloadData];
            [self.receivedNewTicsBannerView reloadData];
        }
    }];
}

- (void)updateVisibleConversationCells {
    NSArray *indexPathsArray = [self.conversationsTableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in indexPathsArray) {
        TTConversation *currentConversation = [self.conversations objectAtIndex:indexPath.row];
        UITableViewCell *currentCell = [self.conversationsTableView cellForRowAtIndexPath:indexPath];
        if ([currentCell isKindOfClass:[TTConversationTableViewCell class]]) {
            if (![TTUtility isParseReachable] || ![TTUtility isInternetReachable]) {
                // use local cache when parse is not reachable
                [(TTConversationTableViewCell *)currentCell updateWithConversation:currentConversation];
            } else {
                if (currentConversation.objectId == nil) {
                    // the current conversation object has not been saved to server yet
                    [(TTConversationTableViewCell *)currentCell updateWithConversation:currentConversation];
                } else {
                    // an existing conversation, refresh before load onto UI
                    [currentConversation fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if (error != nil) {
                            TTConversation *updatedCurrentConversation = (TTConversation *)object;
                            [(TTConversationTableViewCell *)currentCell updateWithConversation:updatedCurrentConversation];
                        }
                    }];
                }
            }
        }
    }
}

- (void)updateVisibleNewTicCells {
    [self.receivedNewTicsDropdownView reloadData];
}

- (void)showComposeView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(hideComposeView)];
    self.composeView = [[TTComposeView alloc] initWithFrame:CGRectMake(0, -self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - 49)];
    self.composeView.delegate = self;
    self.composeView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.view addSubview:self.composeView];
    
    CGRect composeViewExpandedFrame = self.composeView.frame;
    composeViewExpandedFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.composeView.frame = composeViewExpandedFrame;
    } completion:^(BOOL finished) {
        [self.composeView reloadData];
    }];
}

- (void)hideComposeView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showComposeView)];
    
    CGRect composeViewCollapsedFrame = self.composeView.frame;
    composeViewCollapsedFrame.origin.y = composeViewCollapsedFrame.origin.y - composeViewCollapsedFrame.size.height;
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        self.composeView.frame = composeViewCollapsedFrame;
    } completion:^(BOOL finished) {
        [self.composeView removeFromSuperview];
    }];
}

- (void)showNewTicsDropdownView {
    self.isNewTicsDropdownViewVisible = YES;
    [self.receivedNewTicsBannerView updateTitleWithNewTicsDropdownVisibile:self.isNewTicsDropdownViewVisible];
    
    self.receivedNewTicsDropdownView = [[TTNewTicsDropdownView alloc] initWithFrame:CGRectMake(0, [TTNewTicsBannerView height], self.view.bounds.size.width, 0)];
    self.receivedNewTicsDropdownView.delegate = self;
    self.receivedNewTicsDropdownView.dataSource = self;
    self.receivedNewTicsDropdownView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.view addSubview:self.receivedNewTicsDropdownView];
    
    CGRect receivedNewTicsDropdownViewExpandedFrame = self.receivedNewTicsDropdownView.frame;
    receivedNewTicsDropdownViewExpandedFrame.size.height = [TTNewTicsDropdownView initialHeight];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.receivedNewTicsDropdownView.frame = receivedNewTicsDropdownViewExpandedFrame;
    } completion:^(BOOL finished) {
        [self.receivedNewTicsDropdownView reloadData];
        self.updateVisibleNewTicCellsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateVisibleNewTicCells) userInfo:nil repeats:YES];
    }];
}

- (void)hideNewTicsDropdownView {
    self.isNewTicsDropdownViewVisible = NO;
    [self.receivedNewTicsBannerView updateTitleWithNewTicsDropdownVisibile:self.isNewTicsDropdownViewVisible];
    
    // remove all subviews for the animation
    for (UIView *currentSubview in self.receivedNewTicsDropdownView.subviews) {
        [currentSubview removeFromSuperview];
    }
    
    CGRect receivedNewTicsDropdownViewCollapsedFrame = self.receivedNewTicsDropdownView.frame;
    receivedNewTicsDropdownViewCollapsedFrame.size.height = 0;
    
    CGRect receivedNewTicsBannerViewCollapsedFrame = self.receivedNewTicsBannerView.frame;
    receivedNewTicsBannerViewCollapsedFrame.size.height = [TTNewTicsBannerView height];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.receivedNewTicsDropdownView.frame = receivedNewTicsDropdownViewCollapsedFrame;
        self.receivedNewTicsBannerView.frame = receivedNewTicsBannerViewCollapsedFrame;
    } completion:^(BOOL finished) {
        [self.receivedNewTicsDropdownView removeFromSuperview];
    }];
}

- (void)reloadDataForViews {
    // reload data for scroll to top view
    [self.receivedNewTicsBannerView reloadData];
    
    // reload data for new Tics view
    [self.receivedNewTicsDropdownView reloadData];
    
    // reload data for conversations
    [self.conversationsTableView reloadData];
}


#pragma mark - TTComposeViewDelegate

- (void)composeViewDidSelectContact:(TTUser *)contact anonymous:(BOOL)anonymous {
    [self hideComposeView];
    
    PFQuery *conversationQuery = [TTConversation query];
    if (![TTUtility isParseReachable]) {
        [conversationQuery fromLocalDatastore];
    }
    [conversationQuery fromPinWithName:kTTLocalDatastoreConversationsPinName];
    [conversationQuery whereKey:kTTConversationUserIdKey equalTo:contact.objectId];
    [conversationQuery whereKey:kTTConversationTypeKey notEqualTo:kTTConversationTypeAnonymous];
    [conversationQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error && error.code != kPFErrorObjectNotFound) {
            [TTErrorHandler handleParseSessionError:error inViewController:self];
        } else {
            TTConversation *currentConversation = nil;
            if (object == nil) {
                TTTic *draftTic = [TTTic object];
                draftTic.status = kTTTicStatusDrafting;
                draftTic.type = kTTTicTypeDraft;
                draftTic.sendTimestamp = draftTic.receiveTimestamp = [NSDate date];
                draftTic.sender = [TTUser currentUser];
                draftTic.recipient = contact;
                draftTic.content = [@"[Empty]" dataUsingEncoding:NSUTF8StringEncoding];
                draftTic.ACL = [PFACL ACLWithUser:[TTUser currentUser]];
                TTConversation *newConversation = [TTConversation object];
                newConversation.type = anonymous ? kTTConversationTypeAnonymous : kTTConversationTypeDefault;
                newConversation.recipient = contact;
                newConversation.lastTic = draftTic;
                newConversation.userId = [TTUser currentUser].objectId;
                [draftTic pinInBackgroundWithName:kTTLocalDatastoreTicsPinName];
                [newConversation pinInBackgroundWithName:kTTLocalDatastoreConversationsPinName block:^(BOOL succeeded, NSError *error) {
                    [newConversation saveEventually];
                }];
                currentConversation = newConversation;
            } else {
                currentConversation = (TTConversation *)object;
            }
            self.messagesViewController = [TTMessagesViewController messagesViewControllerWithConversation:currentConversation];
            self.messagesViewController.hidesBottomBarWhenPushed = YES;
            self.messagesViewController.isKeyboardFirstResponder = YES;
            [self.navigationController pushViewController:self.messagesViewController animated:YES];
        }
    }];
}


#pragma mark - TTNewTicsBannerViewDelegate

- (void)didTapNewTicsBanner {
    if (self.isNewTicsDropdownViewVisible) {
        [self hideNewTicsDropdownView];
    } else {
        [self showNewTicsDropdownView];
    }
}


#pragma mark - TTNewTicsBannerViewDataSource

- (NSInteger)numberOfNewTicsInNewTicsBannerView {
    NSInteger numberOfNewTics = 0;
    for (NSString *currentSenderId in self.receivedNewTicsSortedKeys) {
        NSMutableArray *receivedNewTicsFromCurrentSender = [self.receivedNewTicsDictionary objectForKey:currentSenderId];
        numberOfNewTics += [receivedNewTicsFromCurrentSender count];
    }
    return numberOfNewTics;
}


#pragma mark - TTNewTicsDropdownViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldShowTicsFromSameSenderWhenNewTicsDropdownViewDidSelectRowAtIndex:(NSInteger)index {
    if (tableView.tag == kTTNewTicsDropdownViewAllNewTicsTableViewTag) {
        NSMutableArray *receivedNewTicsFromCurrentSender = [self.receivedNewTicsDictionary objectForKey:[self.receivedNewTicsSortedKeys objectAtIndex:index]];
        if ([receivedNewTicsFromCurrentSender count] > 1) {
            self.receivedNewTicsDropdownViewSelectedSenderId = [self.receivedNewTicsSortedKeys objectAtIndex:index];
            return YES;
        } else {
            TTNewTic *currentNewTic = [receivedNewTicsFromCurrentSender firstObject];
            [[TTUser query] getObjectInBackgroundWithId:currentNewTic.senderUserId block:^(PFObject *object, NSError *error) {
                if (error) {
                    [TTErrorHandler handleParseSessionError:error inViewController:self];
                } else {
                    TTUser *recipient = (TTUser *)object;
                    PFQuery *conversationQuery = [TTConversation query];
                    [conversationQuery includeKey:kTTConversationLastTicKey];
                    [conversationQuery whereKey:kTTConversationRecipientKey equalTo:recipient];
                    [conversationQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if (error) {
                            [TTErrorHandler handleParseSessionError:error inViewController:self];
                        } else {
                            TTConversation *currentConversation = nil;
                            if (object != nil) {
                                currentConversation = (TTConversation *)object;
                            } else {
                                TTTic *draftTic = [TTTic object];
                                draftTic.status = kTTTicStatusDrafting;
                                draftTic.type = kTTTicTypeDraft;
                                draftTic.sendTimestamp = draftTic.receiveTimestamp = [NSDate date];
                                draftTic.sender = [TTUser currentUser];
                                draftTic.recipient = recipient;
                                draftTic.content = [@"[Empty]" dataUsingEncoding:NSUTF8StringEncoding];
                                draftTic.ACL = [PFACL ACLWithUser:[TTUser currentUser]];
                                TTConversation *newConversation = [TTConversation object];
                                newConversation.type = kTTConversationTypeDefault;
                                newConversation.recipient = recipient;
                                newConversation.lastTic = draftTic;
                                newConversation.userId = [TTUser currentUser].objectId;
                                [draftTic pinInBackgroundWithName:kTTLocalDatastoreTicsPinName];
                                [newConversation pinInBackgroundWithName:kTTLocalDatastoreConversationsPinName block:^(BOOL succeeded, NSError *error) {
                                    [newConversation saveEventually];
                                }];
                                currentConversation = newConversation;
                            }
                            [self hideNewTicsDropdownView];
                            self.messagesViewController = [TTMessagesViewController messagesViewControllerWithConversation:currentConversation];
                            self.messagesViewController.hidesBottomBarWhenPushed = YES;
                            self.messagesViewController.isKeyboardFirstResponder = YES;
                            [self.navigationController pushViewController:self.messagesViewController animated:YES];
                        }
                    }];
                }
            }];
            return NO;
        }
    }
    
    if (tableView.tag == kTTNewTicsDropdownViewSameSenderNewTicsTableViewTag) {
        NSMutableArray *receivedNewTicsFromSelectedSender = [self.receivedNewTicsDictionary objectForKey:self.receivedNewTicsDropdownViewSelectedSenderId];
        TTNewTic *currentNewTic = [receivedNewTicsFromSelectedSender objectAtIndex:index];
        [[TTUser query] getObjectInBackgroundWithId:currentNewTic.senderUserId block:^(PFObject *object, NSError *error) {
            if (error) {
                [TTErrorHandler handleParseSessionError:error inViewController:self];
            } else {
                TTUser *recipient = (TTUser *)object;
                PFQuery *conversationQuery = [TTConversation query];
                [conversationQuery includeKey:kTTConversationLastTicKey];
                [conversationQuery whereKey:kTTConversationRecipientKey equalTo:recipient];
                [conversationQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (error) {
                        [TTErrorHandler handleParseSessionError:error inViewController:self];
                    } else {
                        TTConversation *currentConversation = nil;
                        if (object != nil) {
                            currentConversation = (TTConversation *)object;
                        } else {
                            TTTic *draftTic = [TTTic object];
                            draftTic.status = kTTTicStatusDrafting;
                            draftTic.type = kTTTicTypeDraft;
                            draftTic.sendTimestamp = draftTic.receiveTimestamp = [NSDate date];
                            draftTic.sender = [TTUser currentUser];
                            draftTic.recipient = recipient;
                            draftTic.content = [@"[Empty]" dataUsingEncoding:NSUTF8StringEncoding];
                            draftTic.ACL = [PFACL ACLWithUser:[TTUser currentUser]];
                            TTConversation *newConversation = [TTConversation object];
                            newConversation.type = kTTConversationTypeDefault;
                            newConversation.recipient = recipient;
                            newConversation.lastTic = draftTic;
                            newConversation.userId = [TTUser currentUser].objectId;
                            [draftTic pinInBackgroundWithName:kTTLocalDatastoreTicsPinName];
                            [newConversation pinInBackgroundWithName:kTTLocalDatastoreConversationsPinName block:^(BOOL succeeded, NSError *error) {
                                [newConversation saveEventually];
                            }];
                            currentConversation = newConversation;
                        }
                        [self hideNewTicsDropdownView];
                        self.messagesViewController = [TTMessagesViewController messagesViewControllerWithConversation:currentConversation];
                        self.messagesViewController.hidesBottomBarWhenPushed = YES;
                        self.messagesViewController.isKeyboardFirstResponder = YES;
                        [self.navigationController pushViewController:self.messagesViewController animated:YES];
                    }
                }];
            }
        }];
        return NO;
    }
    return NO;
}

- (void)newTicsDropdownViewDidTapBackButton {
    self.receivedNewTicsDropdownViewSelectedSenderId = nil;
}

- (void)newTicsDropdownViewDidTapClearAllExpiredTicsButton {
    for (NSString *currentSenderId in self.receivedNewTicsSortedKeys) {
        NSMutableArray *receivedNewTicsFromCurrentSender = [self.receivedNewTicsDictionary objectForKey:currentSenderId];
        for (TTNewTic *currentNewTic in receivedNewTicsFromCurrentSender) {
            if ([currentNewTic.status isEqualToString:kTTNewTicStatusExpired]) {
                [receivedNewTicsFromCurrentSender removeObject:currentNewTic];
                [currentNewTic unpinInBackground];
            }
        }
        if ([receivedNewTicsFromCurrentSender count] == 0) {
            [self.receivedNewTicsDictionary removeObjectForKey:currentSenderId];
        }
    }
    [self sortNewTicsDictionary];
    [self.receivedNewTicsDropdownView reloadData];
    [self.receivedNewTicsBannerView reloadData];
}

#pragma mark - TTNewTicsDropdownViewDataSource

- (NSInteger)numberOfRowsInNewTicsDropdownViewTableView:(UITableView *)tableView {
    if (tableView.tag == kTTNewTicsDropdownViewAllNewTicsTableViewTag) {
        return [self.receivedNewTicsDictionary count];
    }
    
    if (tableView.tag == kTTNewTicsDropdownViewSameSenderNewTicsTableViewTag) {
        if (self.receivedNewTicsDropdownViewSelectedSenderId) {
            return [[self.receivedNewTicsDictionary objectForKey:self.receivedNewTicsDropdownViewSelectedSenderId] count];
        }
    }
    
    return 0;
}

- (NSInteger)numberOfUnreadTicsInNewTicsDropdownView {
    NSInteger numberOfUnreadTics = 0;
    for (NSString *currentSenderId in self.receivedNewTicsSortedKeys) {
        NSMutableArray *receivedNewTicsFromCurrentSender = [self.receivedNewTicsDictionary objectForKey:currentSenderId];
        for (TTNewTic *currentNewTic in receivedNewTicsFromCurrentSender) {
            if ([currentNewTic.status isEqualToString:kTTNewTicStatusUnread]) {
                numberOfUnreadTics++;
            }
        }
    }
    return numberOfUnreadTics;
}

- (NSInteger)numberOfExpiredTicsInNewTicsDropdownView {
    NSInteger numberOfExpiredTics = 0;
    for (NSString *currentSenderId in self.receivedNewTicsSortedKeys) {
        NSMutableArray *receivedNewTicsFromCurrentSender = [self.receivedNewTicsDictionary objectForKey:currentSenderId];
        for (TTNewTic *currentNewTic in receivedNewTicsFromCurrentSender) {
            if ([currentNewTic.status isEqualToString:kTTNewTicStatusExpired]) {
                numberOfExpiredTics++;
            }
        }
    }
    return numberOfExpiredTics;
}

- (TTNewTicsDropdownTableViewCell *)tableView:(UITableView *)tableView cellForRowInNewTicsDropdownViewAtIndex:(NSInteger)index {
    TTNewTicsDropdownTableViewCell *receivedNewTicsDropdownTableViewCell = [[TTNewTicsDropdownTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[TTNewTicsDropdownTableViewCell reuseIdentifier]];
    
    if (tableView.tag == kTTNewTicsDropdownViewAllNewTicsTableViewTag) {
        NSMutableArray *receivedNewTicsFromCurrentSender = [self.receivedNewTicsDictionary objectForKey:[self.receivedNewTicsSortedKeys objectAtIndex:index]];
        if ([receivedNewTicsFromCurrentSender count] > 1) {
            [receivedNewTicsDropdownTableViewCell updateCellWithNumberOfTicsFromSameSender:[receivedNewTicsFromCurrentSender count]];
        } else {
            TTNewTic *currentNewTic = [receivedNewTicsFromCurrentSender firstObject];
            NSTimeInterval currentTicTimeLeft = currentNewTic.timeLimit - [[NSDate date] timeIntervalSinceDate:currentNewTic.sendTimestamp];
            if ((NSInteger)currentTicTimeLeft < 1) {
                currentNewTic.status = kTTNewTicStatusExpired;
            }
            [receivedNewTicsDropdownTableViewCell updateCellWithSendTimestamp:currentNewTic.sendTimestamp timeLimit:currentNewTic.timeLimit];
        }
    }
    
    if (tableView.tag == kTTNewTicsDropdownViewSameSenderNewTicsTableViewTag) {
        NSMutableArray *receivedNewTicsFromSelectedSender = [self.receivedNewTicsDictionary objectForKey:self.receivedNewTicsDropdownViewSelectedSenderId];
        TTNewTic *currentNewTic = [receivedNewTicsFromSelectedSender objectAtIndex:index];
        NSTimeInterval currentTicTimeLeft = currentNewTic.timeLimit - [[NSDate date] timeIntervalSinceDate:currentNewTic.sendTimestamp];
        if ((NSInteger)currentTicTimeLeft < 1) {
            currentNewTic.status = kTTNewTicStatusExpired;
        }
        [receivedNewTicsDropdownTableViewCell updateCellWithSendTimestamp:currentNewTic.sendTimestamp timeLimit:currentNewTic.timeLimit];
    }
    return receivedNewTicsDropdownTableViewCell;
}


#pragma mark - UITableViewDataSource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isNewTicsDropdownViewVisible) {
        [self hideNewTicsDropdownView];
        
    }
    //NSLog(@"scrollViewDidScroll");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.conversations count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TTConversationTableViewCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TTConversation *currentConversation = [self.conversations objectAtIndex:indexPath.row];
    self.messagesViewController = [TTMessagesViewController messagesViewControllerWithConversation:currentConversation];
    self.messagesViewController.hidesBottomBarWhenPushed = YES;
    self.messagesViewController.isKeyboardFirstResponder = NO;
    [self.navigationController pushViewController:self.messagesViewController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTConversation *currentConversation = [self.conversations objectAtIndex:indexPath.row];
    TTConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TTConversationTableViewCell reuseIdentifier] forIndexPath:indexPath];
    [cell updateWithConversation:currentConversation];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TTConversation *conversation = [self.conversations objectAtIndex:indexPath.row];
        [conversation deleteEventually];
        [conversation unpinInBackground];
        [self.conversations removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)loadConversationsInBackgroundFromLocal:(BOOL)isLocalQuery completion:(void (^)(BOOL conversationsDidLoad, NSError *error))completion {
    PFQuery *conversationsQuery = [TTConversation query];
    if (isLocalQuery) {
        [conversationsQuery fromPinWithName:kTTLocalDatastoreConversationsPinName];
    }
    [conversationsQuery includeKey:kTTConversationLastTicKey];
    [conversationsQuery whereKey:kTTConversationUserIdKey equalTo:[TTUser currentUser].objectId];
    [conversationsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects == nil || [objects count] == 0) {
            if (completion) {
                completion(NO, error);
            }
        } else {
            self.conversations = [objects mutableCopy];
            [self.conversations sortUsingComparator:^NSComparisonResult(TTConversation *firstConversation, TTConversation *secondConversation) {
                TTTic *firstTic = firstConversation.lastTic;
                TTTic *secondTic = secondConversation.lastTic;
                NSDate *firstLastActivityTimestamp = [firstTic.status isEqualToString:kTTTicStatusRead] ? firstTic.receiveTimestamp : firstTic.sendTimestamp;
                NSDate *secondLastActivityTimestamp = [secondTic.status isEqualToString:kTTTicStatusRead] ? secondTic.receiveTimestamp : secondTic.sendTimestamp;
                return [secondLastActivityTimestamp compare:firstLastActivityTimestamp];
            }];
            
            if (completion) {
                completion(YES, error);
            }
        }
    }];
}

- (void)applicationDidReceiveNewTicWhileActive:(NSNotification *)notification {
    AudioServicesPlayAlertSound(1033);
    
    NSDictionary *newTicNotificationUserInfo = notification.userInfo;
    NSString *unreadTicId = [newTicNotificationUserInfo objectForKey:kTTNotificationUserInfoTicIdKey];
    NSString *senderUserId = [newTicNotificationUserInfo objectForKey:kTTNotificationUserInfoSenderUserIdKey];
    NSString *sendTimestampString = [newTicNotificationUserInfo objectForKey:kTTNotificationUserInfoSendTimestampKey];
    NSNumber *timeLimit = [newTicNotificationUserInfo objectForKey:kTTNotificationUserInfoTimeLimitKey];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    TTNewTic *receivedNewTic = [TTNewTic object];
    receivedNewTic.ticId = unreadTicId;
    receivedNewTic.senderUserId = senderUserId;
    receivedNewTic.recipientUserId = [TTUser currentUser].objectId;
    receivedNewTic.sendTimestamp = [dateFormatter dateFromString:sendTimestampString];
    receivedNewTic.timeLimit = [timeLimit doubleValue];
    
    [self storeNewTic:receivedNewTic];
    [self performNewTicAnimation];
    [self performSelector:@selector(reloadDataForViews) withObject:nil afterDelay:0.25];
}

- (void)storeNewTic:(TTNewTic *)receivedNewTic {
    [receivedNewTic pinInBackgroundWithName:kTTLocalDatastoreNewTicsPinName block:^(BOOL succeeded, NSError *error) {
        [receivedNewTic saveEventually];
    }];
    NSMutableArray *receivedNewTicsFromSameSender = [self.receivedNewTicsDictionary objectForKey:receivedNewTic.senderUserId];
    if (receivedNewTicsFromSameSender == nil) {
        receivedNewTicsFromSameSender = [[NSMutableArray alloc] initWithObjects:receivedNewTic, nil];
        [self.receivedNewTicsDictionary setObject:receivedNewTicsFromSameSender forKey:receivedNewTic.senderUserId];
    } else {
        [receivedNewTicsFromSameSender addObject:receivedNewTic];
    }
    [self sortNewTicsDictionary];
}

- (void)sortNewTicsDictionary {
    self.receivedNewTicsSortedKeys = [self.receivedNewTicsDictionary keysSortedByValueUsingComparator:^NSComparisonResult(NSMutableArray *ticsFromFirstSender, NSMutableArray *ticsFromSecondSender) {
        NSTimeInterval leastTimeLeftFromFirstSender = ((TTNewTic *)[ticsFromFirstSender firstObject]).timeLimit - [[NSDate date] timeIntervalSinceDate:((TTNewTic *)[ticsFromFirstSender firstObject]).sendTimestamp];
        for (TTNewTic *currentNewTicFromFirstSender in ticsFromFirstSender) {
            NSTimeInterval currentTicTimeLeftFromFirstSender = currentNewTicFromFirstSender.timeLimit - [[NSDate date] timeIntervalSinceDate:currentNewTicFromFirstSender.sendTimestamp];
            if (currentTicTimeLeftFromFirstSender < leastTimeLeftFromFirstSender) {
                leastTimeLeftFromFirstSender = currentTicTimeLeftFromFirstSender;
            }
        }
        
        NSTimeInterval leastTimeLeftFromSecondSender = ((TTNewTic *)[ticsFromSecondSender firstObject]).timeLimit - [[NSDate date] timeIntervalSinceDate:((TTNewTic *)[ticsFromSecondSender firstObject]).sendTimestamp];
        for (TTNewTic *currentNewTicFromSecondSender in ticsFromSecondSender) {
            NSTimeInterval currentTicTimeLeftFromSecondSender = currentNewTicFromSecondSender.timeLimit - [[NSDate date] timeIntervalSinceDate:currentNewTicFromSecondSender.sendTimestamp];
            if (currentTicTimeLeftFromSecondSender < leastTimeLeftFromSecondSender) {
                leastTimeLeftFromSecondSender = currentTicTimeLeftFromSecondSender;
            }
        }
        
        return leastTimeLeftFromFirstSender > leastTimeLeftFromSecondSender;
    }];
}

- (void)performNewTicAnimation {
    [self hideComposeView];
    BOOL shouldBringBackNewTicsDropdownView = self.isNewTicsDropdownViewVisible;
    [self hideNewTicsDropdownView];
    
    TTNewTicsBannerView *animationScrollToTopView = [[TTNewTicsBannerView alloc] initWithFrame:self.receivedNewTicsBannerView.frame];
    animationScrollToTopView.titleLabel.text = @"";
    animationScrollToTopView.numberOfNewTicsLabel.text = self.receivedNewTicsBannerView.numberOfNewTicsLabel.text;
    animationScrollToTopView.alpha = 0.0;
    CGPoint animationNewTicsCountLabelInitialCenter = animationScrollToTopView.numberOfNewTicsLabel.center;
    
    [self.receivedNewTicsBannerView addSubview:animationScrollToTopView];
    [self.receivedNewTicsBannerView bringSubviewToFront:animationScrollToTopView];
    
    CGFloat zoomInScale = 1.3;
    CGFloat zoomOutScale = 1 / zoomInScale;
    
    [UIView animateWithDuration:0.2 animations:^{
        // title label fade out
        animationScrollToTopView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            // new tics count label move to center
            animationScrollToTopView.numberOfNewTicsLabel.center = animationScrollToTopView.center;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                // zoom in
                animationScrollToTopView.numberOfNewTicsLabel.transform = CGAffineTransformScale(animationScrollToTopView.numberOfNewTicsLabel.transform, zoomInScale, zoomInScale);
            } completion:^(BOOL finished) {
                // update count
                animationScrollToTopView.numberOfNewTicsLabel.text = [NSString stringWithFormat:@"%ld", [self numberOfNewTicsInNewTicsBannerView]];
                [UIView animateWithDuration:0.1 animations:^{
                    // zoom out
                    animationScrollToTopView.numberOfNewTicsLabel.transform = CGAffineTransformScale(animationScrollToTopView.numberOfNewTicsLabel.transform, zoomOutScale, zoomOutScale);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.25 delay:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                        // move back to initial position
                        animationScrollToTopView.numberOfNewTicsLabel.center = animationNewTicsCountLabelInitialCenter;
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.2 animations:^{
                            // title label fade back in
                            animationScrollToTopView.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            [animationScrollToTopView removeFromSuperview];
                            if (shouldBringBackNewTicsDropdownView) {
                                [self showNewTicsDropdownView];
                            }
                        }];
                    }];
                }];
            }];
        }];
    }];
}

@end

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
#import "TTErrorHandler.h"

@interface TTConversationsViewController ()

@property (nonatomic, strong) TTMessagesViewController *messagesViewController;

@property (nonatomic, assign) BOOL isNewTicsDropdownViewVisible;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) TTNewTicsBannerView *receivedNewTicsBannerView;
@property (nonatomic, strong) TTNewTicsDropdownView *receivedNewTicsDropdownView;
@property (nonatomic, strong) TTComposeView *composeView;
@property (nonatomic, strong) UITableView *conversationsTableView;

@property (nonatomic, strong) NSTimer *updateCellTimer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizer;

@property (nonatomic, strong) NSMutableArray *conversations;
@property (nonatomic, strong) NSMutableArray *receivedNewTics;

@end

@implementation TTConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.receivedNewTics = [[NSMutableArray alloc] init];
    
    TTTic *unreadTic1 = [TTTic unreadTicWithId:@"fakeId1"];
    unreadTic1.sender = [TTUser objectWithoutDataWithObjectId:@"fakeId1"];
    unreadTic1.sendTimestamp = [NSDate date];
    unreadTic1.timeLimit = 100;
    [self.receivedNewTics addObject:unreadTic1];
    
    TTTic *unreadTic2 = [TTTic unreadTicWithId:@"fakeId2"];
    unreadTic2.sender = [TTUser objectWithoutDataWithObjectId:@"fakeId2"];
    unreadTic2.sendTimestamp = [NSDate date];
    unreadTic2.timeLimit = 150;
    [self.receivedNewTics addObject:unreadTic2];
    
    TTTic *unreadTic3 = [TTTic unreadTicWithId:@"fakeId3"];
    unreadTic3.sender = [TTUser objectWithoutDataWithObjectId:@"fakeId2"];
    unreadTic3.sendTimestamp = [NSDate date];
    unreadTic3.timeLimit = 200;
    [self.receivedNewTics addObject:unreadTic3];
    
    TTTic *unreadTic4 = [TTTic unreadTicWithId:@"fakeId4"];
    unreadTic4.sender = [TTUser objectWithoutDataWithObjectId:@"fakeId4"];
    unreadTic4.sendTimestamp = [NSDate date];
    unreadTic4.timeLimit = 2500;
    [self.receivedNewTics addObject:unreadTic4];
    
    TTTic *unreadTic5 = [TTTic unreadTicWithId:@"fakeId5"];
    unreadTic5.sender = [TTUser objectWithoutDataWithObjectId:@"fakeId5"];
    unreadTic5.sendTimestamp = [NSDate date];
    unreadTic5.timeLimit = 3600 * 72;
    [self.receivedNewTics addObject:unreadTic5];
    
    TTTic *unreadTic6 = [TTTic unreadTicWithId:@"fakeId6"];
    unreadTic6.sender = [TTUser objectWithoutDataWithObjectId:@"fakeId2"];
    unreadTic6.sendTimestamp = [NSDate date];
    unreadTic6.timeLimit = 4690;
    [self.receivedNewTics addObject:unreadTic6];
    
    TTTic *unreadTic7 = [TTTic unreadTicWithId:@"fakeId7"];
    unreadTic7.sender = [TTUser objectWithoutDataWithObjectId:@"fakeId2"];
    unreadTic7.sendTimestamp = [NSDate date];
    unreadTic7.timeLimit = -1;
    [self.receivedNewTics addObject:unreadTic7];
    
    [self.receivedNewTics sortUsingComparator:^NSComparisonResult(TTTic *firstUnreadTic, TTTic *secondUnreadTic) {
        NSTimeInterval firstUnreadTicTimeLeft = firstUnreadTic.timeLimit - [[NSDate date] timeIntervalSinceDate:firstUnreadTic.sendTimestamp];
        NSTimeInterval secondUnreadTicTimeLeft = secondUnreadTic.timeLimit - [[NSDate date] timeIntervalSinceDate:secondUnreadTic.sendTimestamp];
        if (firstUnreadTicTimeLeft < 0) {
            return NSOrderedAscending;
        } else if (secondUnreadTicTimeLeft < 0) {
            return NSOrderedDescending;
        } else {
            return firstUnreadTicTimeLeft > secondUnreadTicTimeLeft;
        }
    }];
    
    [self loadInterface];
    self.swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeVerticallyWithGestureRecognizer:)];
    self.swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    [self.conversationsTableView addGestureRecognizer:self.swipeGestureRecognizer];
    
}

- (void)didSwipeVerticallyWithGestureRecognizer:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    if (self.isNewTicsDropdownViewVisible) {
        if ([swipeGestureRecognizer locationInView:self.view].y > [TTNewTicsDropdownView height] + [TTNewTicsBannerView height]) {
            [self hideNewTicsDropdownView];
            NSLog(@"hi");
        }
    }
    NSLog(@"didSwipeVerticallyWithGestureRecognizer");
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadConversations];
    if (self.updateCellTimer != nil) {
        [self.updateCellTimer invalidate];
    }
    self.updateCellTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateVisibleCells) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadDataForViews];
    [self updateVisibleCells];
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
    self.navigationItem.title = @"TicText";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showComposeView)];
    
    // set up tableview
    self.conversationsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.conversationsTableView.delegate = self;
    self.conversationsTableView.dataSource = self;
    self.conversationsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.conversationsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.conversationsTableView registerClass:[TTConversationTableViewCell class] forCellReuseIdentifier:[TTConversationTableViewCell reuseIdentifier]];
    [self.view addSubview:self.conversationsTableView];
    
    // scroll to top view
    self.receivedNewTicsBannerView = [[TTNewTicsBannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [TTNewTicsBannerView height])];
    self.receivedNewTicsBannerView.delegate = self;
    self.receivedNewTicsBannerView.dataSource = self;
    
    self.isNewTicsDropdownViewVisible = NO;
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

- (void)updateVisibleCells {
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

- (void)showComposeView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(hideComposeView)];
    self.composeView = [[TTComposeView alloc] initWithFrame:CGRectMake(0, -(self.view.bounds.size.height - 49 - 44 - 20), self.view.bounds.size.width, self.view.bounds.size.height - 49)];
    self.composeView.delegate = self;
    self.composeView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.view addSubview:self.composeView];
    
    CGRect composeViewExpandedFrame = self.composeView.frame;
    composeViewExpandedFrame.origin.y = 64;
    
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
    [self.receivedNewTicsBannerView addSubview:self.receivedNewTicsDropdownView];
    [self.receivedNewTicsBannerView bringSubviewToFront:self.receivedNewTicsDropdownView];
    
    CGRect receivedNewTicsDropdownViewExpandedFrame = self.receivedNewTicsDropdownView.frame;
    receivedNewTicsDropdownViewExpandedFrame.size.height = [TTNewTicsDropdownView height];
    
    CGRect receivedNewTicsBannerViewExpandedFrame = self.receivedNewTicsBannerView.frame;
    receivedNewTicsBannerViewExpandedFrame.size.height = receivedNewTicsBannerViewExpandedFrame.size.height + [TTNewTicsDropdownView height];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.receivedNewTicsDropdownView.frame = receivedNewTicsDropdownViewExpandedFrame;
        self.receivedNewTicsBannerView.frame = receivedNewTicsBannerViewExpandedFrame;
    } completion:^(BOOL finished) {
        [self.receivedNewTicsDropdownView reloadData];
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
    return [self.receivedNewTics count];
}


#pragma mark - TTNewTicsDropdownViewDelegate

- (void)receivedNewTicsDropdownViewDidSelectNewTicAtIndex:(NSInteger)index {
    NSLog(@"Selected unread Tic at index: %li", index);
    TTTic *selectedNewTic = [self.receivedNewTics objectAtIndex:index];
}


#pragma mark - TTNewTicsDropdownViewDataSource

- (NSInteger)numberOfRowsInNewTicsDropdownView {
    return [self.receivedNewTics count];
}

- (NSInteger)numberOfUnreadTicsInNewTicsDropdownView {
    return 6;
}

- (NSInteger)numberOfExpiredTicsInNewTicsDropdownView {
    return 1;
}

- (TTNewTicsDropdownTableViewCell *)unreadTicsListView:(TTNewTicsDropdownView *)unreadTicsListView cellForRowAtIndex:(NSInteger)index {
    TTNewTicsDropdownTableViewCell *unreadTicsListTableViewCell = [[TTNewTicsDropdownTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[TTNewTicsDropdownTableViewCell reuseIdentifier]];
    [unreadTicsListTableViewCell updateWithUnreadTic:[self.receivedNewTics objectAtIndex:index]];
    return unreadTicsListTableViewCell;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.receivedNewTicsBannerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isNewTicsDropdownViewVisible) {
        return self.receivedNewTicsBannerView.bounds.size.height;// + self.unreadTicsListView.bounds.size.height;
    }
    else {
        return self.receivedNewTicsBannerView.bounds.size.height;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TTConversation *conversation = [self.conversations objectAtIndex:indexPath.row];
        [conversation deleteEventually];
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
                NSDate *firstLastActivityTimestamp = firstTic.status == kTTTicStatusRead ? firstTic.receiveTimestamp : firstTic.sendTimestamp;
                NSDate *secondLastActivityTimestamp = secondTic.status == kTTTicStatusRead ? secondTic.receiveTimestamp : secondTic.sendTimestamp;
                return [secondLastActivityTimestamp compare:firstLastActivityTimestamp];
            }];
            
            if (completion) {
                completion(YES, error);
            }
        }
    }];
}



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
                draftTic.content = [@"" dataUsingEncoding:NSUTF8StringEncoding];
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

- (void)applicationDidReceiveNewTicWhileActive:(NSNotification *)notification {
    AudioServicesPlayAlertSound(1033);
    NSDictionary *newTicNotificationUserInfo = notification.userInfo;
    NSString *unreadTicId = [newTicNotificationUserInfo objectForKey:kTTNotificationUserInfoTicIdKey];
    NSString *senderUserId = [newTicNotificationUserInfo objectForKey:kTTNotificationUserInfoSenderUserIdKey];
    NSDate *sendTimestamp = [newTicNotificationUserInfo objectForKeyedSubscript:kTTNotificationUserInfoSendTimestampKey];
    NSNumber *timeLimit = [newTicNotificationUserInfo objectForKey:kTTNotificationUserInfoTimeLimitKey];
    
    TTTic *receivedNewTic = [TTTic unreadTicWithId:unreadTicId];
    receivedNewTic.sender = [TTUser objectWithoutDataWithObjectId:senderUserId];
    receivedNewTic.sendTimestamp = sendTimestamp;
    receivedNewTic.timeLimit = [timeLimit doubleValue];
    [self.receivedNewTics addObject:receivedNewTic];
    [self.receivedNewTics sortUsingComparator:^NSComparisonResult(TTTic *firstNewTic, TTTic *secondNewTic) {
        NSTimeInterval firstNewTicTimeLeft = firstNewTic.timeLimit - [[NSDate date] timeIntervalSinceDate:firstNewTic.sendTimestamp];
        NSTimeInterval secondNewTicTimeLeft = secondNewTic.timeLimit - [[NSDate date] timeIntervalSinceDate:secondNewTic.sendTimestamp];
        if (firstNewTicTimeLeft <= 0) {
            firstNewTic.status = kTTTicStatusExpired;
        }
        
        if (secondNewTicTimeLeft <= 0) {
            secondNewTic.status = kTTTicStatusExpired;
        }
        
        if (firstNewTicTimeLeft < 0) {
            return NSOrderedAscending;
        } else if (secondNewTicTimeLeft < 0) {
            return NSOrderedDescending;
        } else {
            return firstNewTicTimeLeft < secondNewTicTimeLeft;
        }
    }];
    
    [self performNewTicAnimation];
    [self performSelector:@selector(reloadDataForViews) withObject:nil afterDelay:0.25];
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
                animationScrollToTopView.numberOfNewTicsLabel.text = [NSString stringWithFormat:@"%li", (unsigned long)[self.receivedNewTics count]];
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

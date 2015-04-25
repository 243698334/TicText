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
#import "TTMessagesViewController.h"

#import "TTUtility.h"
#import "TTUser.h"
#import "TTConversation.h"
#import "TTErrorHandler.h"

@interface TTConversationsViewController ()

@property (nonatomic, strong) TTMessagesViewController *messagesViewController;

@property (nonatomic, assign) BOOL isUnreadTicsListVisible;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) TTUnreadTicsBannerView *unreadTicsBannerView;
@property (nonatomic, strong) TTUnreadTicsListView *unreadTicsListView;
@property (nonatomic, strong) TTComposeView *composeView;
@property (nonatomic, strong) UITableView *conversationsTableView;

@property (nonatomic, strong) NSTimer *updateCellTimer;

@property (nonatomic, strong) NSMutableArray *conversations;
@property (nonatomic, strong) NSMutableArray *unreadTics;

@end

@implementation TTConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.unreadTics = [[NSMutableArray alloc] init];
    [self loadInterface];
    
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
    self.unreadTicsBannerView = [[TTUnreadTicsBannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.unreadTicsBannerView.delegate = self;
    self.unreadTicsBannerView.dataSource = self;
    
    // unread tics view
//    self.unreadTicsListView = [[TTUnreadTicsListView alloc] initWithFrame:CGRectMake(0, 54, self.view.bounds.size.width, 44 * self.unreadTics.count)];
//    self.unreadTicsListView.delegate = self;
//    self.unreadTicsListView.dataSource = self;
//    self.unreadTicsListView.clipsToBounds = YES;
//    self.unreadTicsListView.frame = CGRectMake(0, self.unreadTicsBannerView.bounds.size.height, self.view.bounds.size.height, 0); //Set frame again to shrink to 0.
    self.isUnreadTicsListVisible = NO;
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
    self.composeView = [[TTComposeView alloc] initWithFrame:CGRectMake(0, self.unreadTicsBannerView.bounds.size.height - 20, self.view.frame.size.width, self.view.frame.size.height - 49)];
    self.composeView.delegate = self;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromBottom;
    transition.delegate = self;
    [self.view addSubview:self.composeView];
    [self.composeView.layer addAnimation:transition forKey:nil];
}

- (void)hideComposeView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showComposeView)];
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        self.composeView.frame = CGRectMake(self.composeView.frame.origin.x, self.composeView.frame.origin.y - self.composeView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self.composeView removeFromSuperview];
    }];
}

- (void)showUnreadTicsListView {
    self.isUnreadTicsListVisible = YES;
    [self.unreadTicsBannerView updateTitleWithUnreadTicsListVisibile:self.isUnreadTicsListVisible];
    self.unreadTicsListView = [[TTUnreadTicsListView alloc] initWithFrame:CGRectMake(0, 44 + 20 + 44, self.view.frame.size.width, self.unreadTics.count * [TTUnreadTicsListTableViewCell height])];
    self.unreadTicsListView.delegate = self;
    self.unreadTicsListView.dataSource = self;
    [self.view addSubview:self.unreadTicsListView];
    [self.unreadTicsListView expand];
    
//
//    //[self.unreadTicsListView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.conversationsTableView.tableHeaderView];
//    [UIView animateKeyframesWithDuration:0.2 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
//        self.unreadTicsListView.frame = CGRectMake(0, 44 + 20 + 44, self.view.frame.size.width, self.unreadTics.count * [TTUnreadTicsListTableViewCell height]);
//    } completion:^(BOOL finished) {
//    }];
    
    
    
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.25;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionPush;
//    transition.subtype = kCATransitionFromBottom;
//    transition.delegate = self;
    //[self.view bringSubviewToFront:self.unreadTicsBannerView];
    //[self.conversationsTableView reloadData];
    //[self.unreadTicsListView.layer addAnimation:transition forKey:nil];
}

- (void)hideUnreadTicsListView {
    self.isUnreadTicsListVisible = NO;
    [self.unreadTicsBannerView updateTitleWithUnreadTicsListVisibile:self.isUnreadTicsListVisible];
    [self.unreadTicsListView collapse];
    [self.unreadTicsListView removeFromSuperview];
    //    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
//        self.unreadTicsListView.frame = CGRectMake(self.unreadTicsListView.frame.origin.x, self.unreadTicsListView.frame.origin.y - self.unreadTicsListView.frame.size.height, self.unreadTicsListView.frame.size.width, 0);
//    } completion:^(BOOL finished) {
//        [self.unreadTicsListView removeFromSuperview];
//    }];
}

#pragma mark - TTUnreadTicsBannerViewDelegate

- (void)didTapUnreadTicsBanner {
    if (self.isUnreadTicsListVisible) {
        [self hideUnreadTicsListView];
    } else {
        [self showUnreadTicsListView];
    }
}


#pragma mark - TTUnreadTicsBannerViewDataSource

- (NSInteger)numberOfUnreadTicsInUnreadTicsBannerView {
    return [self.unreadTics count];
}


#pragma mark - TTUnreadTicsListViewDelegate

- (void)unreadTicsListViewDidSelectUnreadTicAtIndex:(NSInteger)index {
    NSLog(@"Selected unread Tic at index: %li", index);
}

#pragma mark - TTUnreadTicsListViewDataSource

- (NSInteger)numberOfRowsInUnreadTicsList {
    return [self.unreadTics count];
}

- (TTUnreadTicsListTableViewCell *)unreadTicsListView:(TTUnreadTicsListView *)unreadTicsListView cellForRowAtIndex:(NSInteger)index {
    TTUnreadTicsListTableViewCell *unreadTicsListTableViewCell = [[TTUnreadTicsListTableViewCell alloc] init];
    unreadTicsListTableViewCell.backgroundColor = kTTUIPurpleColor;
    [unreadTicsListTableViewCell updateWithUnreadTic:[self.unreadTics objectAtIndex:index]];
    return unreadTicsListTableViewCell;
}

- (void)reloadDataForViews {
    // reload data for scroll to top view
    [self.unreadTicsBannerView reloadData];
    
    // reload data for unread Tics
    self.unreadTicsListView.frame = CGRectMake(0, 54, self.view.bounds.size.width, 44 * self.unreadTics.count);
    [self.unreadTicsListView reloadData];
    
    // reload data for conversations
    [self.conversationsTableView reloadData];
}


#pragma mark - UITableViewDataSource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self hideUnreadTicsListView];
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
//    CGFloat height = 0;
//    if (self.isUnreadTicsListVisible) {
//        height = self.unreadTicsBannerView.bounds.size.height;// + self.unreadTicsListView.bounds.size.height;
//    } else {
//        height = self.unreadTicsBannerView.bounds.size.height;
//    }
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
//    NSLog(@"%f", height);
//    [view addSubview:self.unreadTicsBannerView];
//    
//    if (self.isUnreadTicsListVisible) {
//        //[view addSubview:self.unreadTicsListView];
//    }
    return self.unreadTicsBannerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isUnreadTicsListVisible) {
        return self.unreadTicsBannerView.bounds.size.height;// + self.unreadTicsListView.bounds.size.height;
    }
    else {
        return self.unreadTicsBannerView.bounds.size.height;
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


- (void)hideTable {
    self.isUnreadTicsListVisible = NO;
    [self.unreadTicsBannerView updateTitleWithUnreadTicsListVisibile:self.isUnreadTicsListVisible];
    [UIView animateKeyframesWithDuration:0.2 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        self.unreadTicsListView.frame = CGRectMake(0, self.unreadTicsBannerView.bounds.size.height, self.unreadTicsListView.bounds.size.width, 0);
    } completion:nil];
}

- (void)applicationDidReceiveNewTicWhileActive:(NSNotification *)notification {
    NSDictionary *newTicNotificationUserInfo = notification.userInfo;
    NSString *unreadTicId = [newTicNotificationUserInfo objectForKey:kTTNotificationUserInfoTicIdKey];
    NSString *senderUserId = [newTicNotificationUserInfo objectForKey:kTTNotificationUserInfoSenderUserIdKey];
    NSNumber *timeLimit = [newTicNotificationUserInfo objectForKey:kTTNotificationUserInfoTimeLimitKey];
    
    NSLog(@"new Tic id: %@, sender id: %@, time limit: %@", unreadTicId, senderUserId, timeLimit);
    [[[UIAlertView alloc] initWithTitle:@"Unread Tic" message:[NSString stringWithFormat:@"new Tic id: %@, sender id: %@, time limit: %@", unreadTicId, senderUserId, timeLimit] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    TTTic *unreadTic = [TTTic unreadTicWithId:unreadTicId];
    unreadTic.sender = [TTUser objectWithoutDataWithObjectId:senderUserId];
    unreadTic.timeLimit = [timeLimit doubleValue];
    [self.unreadTics addObject:unreadTic];
    
    [self performNewTicAnimation];
    [self performSelector:@selector(reloadDataForViews) withObject:nil afterDelay:0.25];
}

- (void)performNewTicAnimation {
    [self hideComposeView];
    [self hideTable];
    
    TTUnreadTicsBannerView *animationScrollToTopView = [[TTUnreadTicsBannerView alloc] initWithFrame:self.unreadTicsBannerView.frame];
    animationScrollToTopView.titleLabel.text = @"";
    animationScrollToTopView.unreadTicsCountLabel.text = self.unreadTicsBannerView.unreadTicsCountLabel.text;
    animationScrollToTopView.alpha = 0.0;
    CGPoint animationUnreadTicsCountLabelInitialCenter = animationScrollToTopView.unreadTicsCountLabel.center;
    
    [self.unreadTicsBannerView addSubview:animationScrollToTopView];
    [self.unreadTicsBannerView bringSubviewToFront:animationScrollToTopView];
    
    CGFloat zoomInScale = 1.3;
    CGFloat zoomOutScale = 1 / zoomInScale;
    
    [UIView animateWithDuration:0.2 animations:^{
        // title label fade out
        animationScrollToTopView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            // unread tics count label move to center
            animationScrollToTopView.unreadTicsCountLabel.center = animationScrollToTopView.center;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                // zoom in
                animationScrollToTopView.unreadTicsCountLabel.transform = CGAffineTransformScale(animationScrollToTopView.unreadTicsCountLabel.transform, zoomInScale, zoomInScale);
            } completion:^(BOOL finished) {
                // update count
                animationScrollToTopView.unreadTicsCountLabel.text = [NSString stringWithFormat:@"%li", [self.unreadTics count]];
                [UIView animateWithDuration:0.1 animations:^{
                    // zoom out
                    animationScrollToTopView.unreadTicsCountLabel.transform = CGAffineTransformScale(animationScrollToTopView.unreadTicsCountLabel.transform, zoomOutScale, zoomOutScale);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.25 delay:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                        // move back to initial position
                        animationScrollToTopView.unreadTicsCountLabel.center = animationUnreadTicsCountLabelInitialCenter;
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.2 animations:^{
                            // title label fade back in
                            animationScrollToTopView.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            [animationScrollToTopView removeFromSuperview];
                        }];
                    }];
                }];
            }];
        }];
    }];
}
@end

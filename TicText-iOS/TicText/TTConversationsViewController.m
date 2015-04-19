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
#import "TTMessagesViewController.h"

#import "TTUtility.h"
#import "TTUser.h"
#import "TTConversation.h"

@interface TTConversationsViewController ()

@property (nonatomic) BOOL tableVisible;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) TTScrollToTopView *scrollToTopView;
@property (nonatomic, strong) TTUnreadTicsView *unreadTicsView;
@property (nonatomic, strong) TTComposeView *composeView;
@property (nonatomic, strong) UITableView *conversationsTableView;

@property (nonatomic, strong) NSTimer *updateCellTimer;

@property (nonatomic, strong) NSMutableArray *conversations;
@property (nonatomic, strong) NSMutableArray *unreadTics;

@end

@implementation TTConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadConversations];
    self.updateCellTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateVisibleCells) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadDataForViews];
    [self updateVisibleCells];
}

- (void)loadInterface {
    // navigation bar
    self.navigationItem.title = @"TicText";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showComposeView)];
    
    // set up tableview
    self.conversationsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.conversationsTableView.delegate = self;
    self.conversationsTableView.dataSource = self;
    [self.conversationsTableView registerClass:[TTConversationTableViewCell class] forCellReuseIdentifier:@"cell"];
    self.conversationsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.conversationsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.conversationsTableView registerClass:[TTConversationTableViewCell class] forCellReuseIdentifier:[TTConversationTableViewCell reuseIdentifier]];
    [self.view addSubview:self.conversationsTableView];
    
    // scroll to top view
    self.scrollToTopView = [[TTScrollToTopView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.scrollToTopView.unreadMessages = [self.unreadTics count];
    self.scrollToTopView.delegate = self;
    
    // unread tics view
    self.unreadTicsView = [[TTUnreadTicsView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, 44 * self.unreadTics.count)];
    self.unreadTicsView.delegate = self;
    self.unreadTicsView.clipsToBounds = YES;
    self.unreadTicsView.frame = CGRectMake(0, self.scrollToTopView.bounds.size.height, self.view.bounds.size.height, 0); //Set frame again to shrink to 0.
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
                        [TSMessage showNotificationInViewController:self title:@"Concersations Synced" subtitle:@"We have just synced your conversations with our server. " type:TSMessageNotificationTypeSuccess];
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
            [currentConversation fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (error != nil) {
                    TTConversation *updatedCurrentConversation = (TTConversation *)object;
                    [(TTConversationTableViewCell *)currentCell updateWithConversation:updatedCurrentConversation];
                }
            }];
        }
    }
}

- (void)showComposeView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(collapseComposeView)];
    self.composeView = [[TTComposeView alloc] initWithFrame:CGRectMake(0, self.scrollToTopView.bounds.size.height - 20, self.view.frame.size.width, self.view.frame.size.height - 49)];
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

- (void)collapseComposeView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showComposeView)];
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        self.composeView.frame = CGRectMake(self.composeView.frame.origin.x, self.composeView.frame.origin.y - self.composeView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self.composeView removeFromSuperview];
    }];
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
    TTUser *currentFriend = ((TTConversation *)[self.conversations objectAtIndex:indexPath.row]).recipient;
    TTMessagesViewController *messagesViewController = [TTMessagesViewController messagesViewControllerWithRecipient:currentFriend];
    messagesViewController.hidesBottomBarWhenPushed = YES;
    messagesViewController.isKeyboardFirstResponder = NO;
    [self.navigationController pushViewController:messagesViewController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTConversation *currentConversation = [self.conversations objectAtIndex:indexPath.row];
    TTConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TTConversationTableViewCell reuseIdentifier] forIndexPath:indexPath];
    //[cell.profilePictureImageView.layer setCornerRadius:([TTConversationTableViewCell height] - 2 * [TTConversationTableViewCell profilePicturePadding]) / 2.0];
    [cell updateWithConversation:currentConversation];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    if (self.tableVisible) {
        height = self.scrollToTopView.bounds.size.height + self.unreadTicsView.bounds.size.height;
    } else {
        height = self.scrollToTopView.bounds.size.height;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
    [view addSubview:self.scrollToTopView];
    
    if (self.tableVisible) {
        [view addSubview:self.unreadTicsView];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.tableVisible) {
        return self.scrollToTopView.bounds.size.height + self.unreadTicsView.bounds.size.height;
    }
    else {
        return self.scrollToTopView.bounds.size.height;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (NSInteger)numberOfUnreadMessages {
    return [self.unreadTics count];
}

- (void)unreadMessagesdidSwipe:(id)unreadView {
    [self hideTable];
}

- (NSString *)timeStampForMessageAtIndex:(NSInteger)index {
    return @"Nothing";
}

- (void)loadConversationsInBackgroundFromLocal:(BOOL)isLocalQuery completion:(void (^)(BOOL conversationsDidLoad, NSError *error))completion {
    PFQuery *conversationsQuery = [TTConversation query];
    if (isLocalQuery) {
        [conversationsQuery fromPinWithName:kTTLocalDatastoreConversationsPinName];
    }
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
            if (!isLocalQuery) {
                [TTConversation unpinAllObjectsInBackgroundWithName:kTTLocalDatastoreConversationsPinName block:^(BOOL succeeded, NSError *error) {
                    [TTConversation pinAllInBackground:self.conversations withName:kTTLocalDatastoreConversationsPinName];
                }];
            }
            if (completion) {
                completion(YES, error);
            }
        }
    }];
}

- (void)reloadDataForViews {
    // reload data for unread Tics
    self.unreadTicsView.frame = CGRectMake(0, 44, self.view.bounds.size.width, 44 * self.unreadTics.count);
    [self.unreadTicsView reloadData];
    
    // reload data for conversations
    [self.conversationsTableView reloadData];
}

- (void)composeViewDidSelectContact:(TTUser *)contact {
    [self collapseComposeView];
    [contact fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *err) {
        TTUser *currentFriend = (TTUser *)object;
        PFQuery *conversationQuery = [TTConversation query];
        [conversationQuery fromPinWithName:kTTLocalDatastoreConversationsPinName];
        [conversationQuery whereKey:kTTConversationUserIdKey equalTo:currentFriend.objectId];
        [conversationQuery whereKey:kTTConversationTypeKey notEqualTo:kTTConversationTypeAnonymous];
        [conversationQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            TTConversation *currentConversation = nil;
            if (error || object == nil) {
                currentConversation = [TTConversation object];
                currentConversation.type = kTTConversationTypeDefault;
                currentConversation.userId = currentFriend.objectId;
                currentConversation.recipient = currentFriend;
                currentConversation.lastTic = nil;
                [currentConversation pinInBackgroundWithName:kTTLocalDatastoreConversationsPinName];
                [currentConversation saveEventually];
            } else {
                currentConversation = (TTConversation *)object;
            }
            TTMessagesViewController *messagesViewController = [TTMessagesViewController messagesViewControllerWithRecipient:currentFriend];
            messagesViewController.hidesBottomBarWhenPushed = YES;
            messagesViewController.isKeyboardFirstResponder = YES;
            [self.navigationController pushViewController:messagesViewController animated:YES];
        }];
        
    }];
}

- (void)unreadButtonPressed {
    self.tableVisible = !self.tableVisible;
    [self.scrollToTopView setTableVisible:self.tableVisible];
    if(self.tableVisible) {
        [self.conversationsTableView reloadData];
        [UIView animateKeyframesWithDuration:0.2 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
            self.unreadTicsView.frame = CGRectMake(0, self.scrollToTopView.bounds.size.height, self.unreadTicsView.bounds.size.width, 44 * [self.unreadTics count]);
        } completion:^(BOOL finished) {
        }];
    }
    
    else {
        [UIView animateKeyframesWithDuration:0.2 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
            self.unreadTicsView.frame = CGRectMake(0, self.scrollToTopView.bounds.size.height, self.unreadTicsView.bounds.size.width, 0);
        } completion:^(BOOL finished) {
            [self.conversationsTableView reloadData];
        }];
    }
}


- (void)hideTable {
    self.tableVisible = NO;
    [self.scrollToTopView setTableVisible:self.tableVisible];
    [UIView animateKeyframesWithDuration:0.2 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        self.unreadTicsView.frame = CGRectMake(0, self.scrollToTopView.bounds.size.height, self.unreadTicsView.bounds.size.width, 0);
    } completion:nil];
}

- (void)generateFakeConversations {
    NSLog(@"Generating fake conversations...");
    
    PFQuery *conversationsQuery = [TTConversation query];
    [conversationsQuery fromPinWithName:kTTLocalDatastoreConversationsPinName];
    [TTConversation unpinAll:[conversationsQuery findObjects]];
    [TTConversation unpinAllObjectsWithName:kTTLocalDatastoreConversationsPinName];
    [TTConversation unpinAllObjectsWithName:kTTLocalDatastoreTicsPinName];
    
    
    TTConversation *fakeConversation1 = [TTConversation object];
    TTTic *fakeLastTic1 = [TTTic object];
    [fakeLastTic1 pinWithName:kTTLocalDatastoreTicsPinName];
    fakeLastTic1.status = kTTTicStatusRead;
    fakeLastTic1.type = kTTTicTypeDefault;
    fakeLastTic1.contentType = kTTTicContentTypeText;
    fakeLastTic1.content = [@"This is a normal read Tic read 10 min ago." dataUsingEncoding:NSUTF8StringEncoding];
    fakeLastTic1.sendTimestamp = [NSDate dateWithTimeInterval:-700 sinceDate:[NSDate date]];
    fakeLastTic1.receiveTimestamp = [NSDate dateWithTimeInterval:-600 sinceDate:[NSDate date]];
    [fakeConversation1 pinWithName:kTTLocalDatastoreConversationsPinName];
    fakeConversation1.type = kTTConversationTypeDefault;
    fakeConversation1.recipient = [TTUser currentUser];
    fakeConversation1.lastTic = fakeLastTic1;
    
    TTConversation *fakeConversation2 = [TTConversation object];
    TTTic *fakeLastTic2 = [TTTic object];
    [fakeLastTic2 pinWithName:kTTLocalDatastoreTicsPinName];
    fakeLastTic2.status = kTTTicStatusUnread;
    fakeLastTic2.type = kTTTicTypeDefault;
    fakeLastTic2.contentType = kTTTicContentTypeText;
    fakeLastTic2.content = [@"This is an unread tic. " dataUsingEncoding:NSUTF8StringEncoding];
    fakeLastTic2.sendTimestamp = [NSDate dateWithTimeInterval:-90000 sinceDate:[NSDate date]];
    fakeLastTic2.receiveTimestamp = nil;
    [fakeConversation2 pinWithName:kTTLocalDatastoreConversationsPinName];
    fakeConversation2.type = kTTConversationTypeDefault;
    fakeConversation2.recipient = [TTUser currentUser];
    fakeConversation2.lastTic = fakeLastTic2;
    
    TTConversation *fakeConversation3 = [TTConversation object];
    TTTic *fakeLastTic3 = [TTTic object];
    [fakeLastTic3 pinWithName:kTTLocalDatastoreTicsPinName];
    fakeLastTic3.status = kTTTicStatusUnread;
    fakeLastTic3.type = kTTTIcTypeAnonymous;
    fakeLastTic3.contentType = kTTTicContentTypeText;
    fakeLastTic3.content = [@"This is an anonymous Tic sent 30sec ago. " dataUsingEncoding:NSUTF8StringEncoding];
    fakeLastTic3.sendTimestamp = [NSDate dateWithTimeInterval:-30 sinceDate:[NSDate date]];
    fakeLastTic3.receiveTimestamp = nil;
    [fakeConversation3 pinWithName:kTTLocalDatastoreConversationsPinName];
    fakeConversation3.type = kTTConversationTypeAnonymous;
    fakeConversation3.recipient = [TTUser currentUser];
    fakeConversation3.lastTic = fakeLastTic3;
    
    TTConversation *fakeConversation4 = [TTConversation object];
    TTTic *fakeLastTic4 = [TTTic object];
    [fakeLastTic4 pinWithName:kTTLocalDatastoreTicsPinName];
    fakeLastTic4.status = kTTTIcStatusExpired;
    fakeLastTic4.type = kTTTicTypeDefault;
    fakeLastTic4.contentType = kTTTicContentTypeText;
    fakeLastTic4.content = [@"This is an expired Tic sent 3 hours ago." dataUsingEncoding:NSUTF8StringEncoding];
    fakeLastTic4.sendTimestamp = [NSDate dateWithTimeInterval:-10800 sinceDate:[NSDate date]];
    fakeLastTic4.receiveTimestamp = nil;
    [fakeConversation4 pinWithName:kTTLocalDatastoreConversationsPinName];
    fakeConversation4.type = kTTConversationTypeDefault;
    fakeConversation4.recipient = [TTUser currentUser];
    fakeConversation4.lastTic = fakeLastTic4;
}


@end

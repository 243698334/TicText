//
//  TTMessagesViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/25/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTMessagesViewController.h"

#import <AudioToolbox/AudioServices.h>
#import "TTTic.h"
#import "TTActivity.h"

#import "TTExpirationDomain.h"

#import "CountDownView.h"
#import "CustomMessageCell.h"

#define kDefaultExpirationTime 3600
#define kExpirationTimerIcon @"TicsTabBarIcon"

@interface JSQMessagesViewController (PrivateMethods)

- (void)jsq_setToolbarBottomLayoutGuideConstant:(CGFloat)constant;
- (void)jsq_adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy;

@end

@interface JSQMessagesCollectionViewCellOutgoing (Timeout)

//@property (nonatomic, strong) UIView *extraview;
- (void)setExtraView:(UIView *) someView;

@end

@implementation JSQMessagesCollectionViewCellOutgoing (Timeout)

- (void)setExtraView:(UIView *) someView {
    [someView setTranslatesAutoresizingMaskIntoConstraints:NO];
    someView.frame = self.messageBubbleContainerView.bounds;
    
    [self.messageBubbleContainerView addSubview:someView];
    //[self.messageBubbleContainerView jsq_pinAllEdgesOfSubview:someView];
    //self.extraview = someView;
}

@end

@interface TTMessagesViewController ()

@property (nonatomic, strong) UIView *expirationToolbar;
@property (nonatomic, strong) TTExpirationPickerController *pickerController;

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) BOOL isFetchingTic;

@property (nonatomic, strong) TTUser *recipient;

@property (nonatomic, strong) NSMutableArray *tics;
@property (nonatomic, strong) NSMutableArray *jsqMessages;

// @TODO: need customization
@property (nonatomic, strong) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (nonatomic, strong) JSQMessagesBubbleImageFactory *bubbleFactory;
@end

@implementation TTMessagesViewController

+ (instancetype)messagesViewController {
    TTMessagesViewController *viewController = [super messagesViewController];
    
    viewController.view.backgroundColor = [UIColor grayColor];
    viewController.navigationItem.title = @"Some Dialog";
    viewController.hidesBottomBarWhenPushed = YES;
    
    UIButton *expirationTimerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [expirationTimerButton setImage:[UIImage imageNamed:kExpirationTimerIcon] forState:UIControlStateNormal];
    viewController.inputToolbar.contentView.leftBarButtonItem = expirationTimerButton;
    
    viewController.expirationTime = kDefaultExpirationTime;
    [viewController setupExpirationToolbar];
    
    return viewController;
}

+ (TTMessagesViewController *)messagesViewControllerWithRecipient:(TTUser *)recipient {
    TTMessagesViewController *messagesViewController = [self messagesViewController];
    messagesViewController.recipient = recipient;
    
    messagesViewController.navigationItem.title = messagesViewController.recipient.displayName; // this is called before self.recipient is set
    
    messagesViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:messagesViewController action:@selector(confirmCleanTicHistory)];
    
    [TSMessage setDelegate:messagesViewController];
    [TSMessage addCustomDesignFromFileWithName:@"TTInAppNotificationDesign.json"];
    
    messagesViewController.senderId = [[TTUser currentUser].objectId copy];
    messagesViewController.senderDisplayName = [[TTUser currentUser].displayName copy];
    
    messagesViewController.tics = [[NSMutableArray alloc] init];
    messagesViewController.jsqMessages = [[NSMutableArray alloc] init];
    
    messagesViewController.isFetchingTic = NO;
    messagesViewController.bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    messagesViewController.outgoingBubbleImageData = [messagesViewController.bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    messagesViewController.incomingBubbleImageData = [messagesViewController.bubbleFactory incomingMessagesBubbleImageWithColor:kTTUIPurpleColor];
    
    [messagesViewController loadTicHistory];
    
    return messagesViewController;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewTic:) name:kTTApplicationDidReceiveNewTicWhileActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.expirationToolbar setFrame:[self expirationToolbarFrame]];
}

- (void)didReceiveNewTic:(NSNotification *)notification {
    AudioServicesPlayAlertSound(1033); // "Telegraph" sound
    NSString *ticId = [notification.userInfo objectForKey:kTTNotificationUserInfoTicIdKey];
    NSString *senderUserId = [notification.userInfo objectForKey:kTTNotificationUserInfoSenderUserIdKey];
    if ([senderUserId isEqualToString:self.recipient.objectId]) {
        // Same sender, new empty bubble
        JSQMessage *unreadJSQMessage = [[JSQMessage alloc] initWithSenderId:senderUserId senderDisplayName:self.recipient.displayName date:[NSDate date] text:@"Tap to read this Tic"];
        TTTic *unreadTic = [TTTic unreadTicWithId:ticId];
        [self.jsqMessages addObject:unreadJSQMessage];
        [self.tics addObject:unreadTic];
        [self finishReceivingMessageAnimated:YES];
    } else {
        // In-app notification
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"You have got a new Tic from someone else. "
                                           subtitle:@"Tap to see your unread Tics. "
                                              image:[UIImage imageNamed:@"TicInAppNotificationIcon"]
                                               type:TSMessageNotificationTypeMessage
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:^(void) {
                                               [self.navigationController popViewControllerAnimated:YES];
                                           }
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionNavBarOverlay
                               canBeDismissedByUser:YES];
    }
}

- (void)loadTicHistory {
    PFQuery *sentTicsQuery = [TTTic query];
    [sentTicsQuery whereKey:kTTTicSenderKey equalTo:[TTUser currentUser]];
    [sentTicsQuery whereKey:kTTTicRecipientKey equalTo:self.recipient];
    
    PFQuery *receivedTicsQuery = [TTTic query];
    [receivedTicsQuery whereKey:kTTTicSenderKey equalTo:self.recipient];
    [receivedTicsQuery whereKey:kTTTicRecipientKey equalTo:[TTUser currentUser]];
    
    PFQuery *loadTicHistoryQuery = [PFQuery orQueryWithSubqueries:@[sentTicsQuery, receivedTicsQuery]];
    [loadTicHistoryQuery setLimit:50];
    [loadTicHistoryQuery includeKey:kTTTicSenderKey];
    [loadTicHistoryQuery orderByAscending:kTTTicSendTimestampKey];
    [loadTicHistoryQuery fromLocalDatastore];
    [loadTicHistoryQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [TSMessage showNotificationInViewController:self
                                                  title:@"Local Datastore Error"
                                               subtitle:@"We are unable to load your Tic history. "
                                                   type:TSMessageNotificationTypeError];
        } else {
            for (TTTic *tic in objects) {
                JSQMessage *jsqMessage = [self jsqMessageWithTic:tic];
                [self.tics addObject:tic];
                [self.jsqMessages addObject:jsqMessage];
            }
            if ([objects count] > 0) {
                [self finishReceivingMessageAnimated:YES];
            }
        }
    }];
}

#define kExpirationToolbarHeight 32.0f
#define kExpirationToolbarAlpha 0.60f
- (CGRect)expirationToolbarFrame {
    return CGRectMake(0, self.inputToolbar.frame.origin.y - kExpirationToolbarHeight,
                      self.inputToolbar.frame.size.width, kExpirationToolbarHeight);
}

- (void)setupExpirationToolbar {
    self.expirationToolbar = [[UIView alloc] initWithFrame:[self expirationToolbarFrame]];
    [self.expirationToolbar setBackgroundColor:[UIColor whiteColor]];
    [self.expirationToolbar setAlpha:kExpirationToolbarAlpha];
    
    self.expirationLabel = [[UILabel alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, self.expirationToolbar.frame.size.width, self.expirationToolbar.frame.size.height), 8.0f, 8.0f)];
    [self.expirationLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.expirationLabel setAdjustsFontSizeToFitWidth:YES];
    [self.expirationLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self.expirationToolbar addSubview:self.expirationLabel];
    
    [self.view addSubview:self.expirationToolbar];
    
    [self refreshExpirationToolbar:self.expirationTime];
}

- (void)refreshExpirationToolbar:(NSTimeInterval)expiration {
    [self.expirationLabel setText:[TTExpirationDomain stringForTimeInterval:expiration]];
}

- (void)jsq_setToolbarBottomLayoutGuideConstant:(CGFloat)constant {
    [super jsq_setToolbarBottomLayoutGuideConstant:(CGFloat)constant];
    
    [self.expirationToolbar setFrame:[self expirationToolbarFrame]];
}

- (void)jsq_adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy {
    [super jsq_adjustInputToolbarForComposerTextViewContentSizeChange:dy];
    
    [self.expirationToolbar setFrame:[self expirationToolbarFrame]];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    [self.pickerController dismiss];
    
    self.pickerController = [[TTExpirationPickerController alloc] initWithExpirationTime:self.expirationTime];
    [self.pickerController setDelegate:self];
    [self.pickerController present];
}

#pragma mark - Helpers
- (void)confirmCleanTicHistory {
    [TSMessage showNotificationInViewController:self
                                          title:@"Clean Tic History"
                                       subtitle:[NSString stringWithFormat:@"This action will clean all your Tics with %@. \nTap to confirm. Wait a few seconds or swipe up to dismiss. ", self.recipient.displayName]
                                          image:[UIImage imageNamed:@"TicInAppNotificationIcon"]
                                           type:TSMessageNotificationTypeWarning
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:^(void) {
                                           [TSMessage dismissActiveNotificationWithCompletion:^{
                                               [self cleanTicHistory];
                                           }];
                                       }
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
}

- (void)cleanTicHistory {
    PFQuery *sentTicsQuery = [TTTic query];
    [sentTicsQuery whereKey:kTTTicSenderKey equalTo:[TTUser currentUser]];
    [sentTicsQuery whereKey:kTTTicRecipientKey equalTo:self.recipient];
    
    PFQuery *receivedTicsQuery = [TTTic query];
    [receivedTicsQuery whereKey:kTTTicSenderKey equalTo:self.recipient];
    [receivedTicsQuery whereKey:kTTTicRecipientKey equalTo:[TTUser currentUser]];
    
    PFQuery *cleanTicHistoryQuery = [PFQuery orQueryWithSubqueries:@[sentTicsQuery, receivedTicsQuery]];
    [cleanTicHistoryQuery fromLocalDatastore];
    [cleanTicHistoryQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [TSMessage showNotificationInViewController:self
                                                  title:@"Local Datastore Error"
                                               subtitle:@"We are unable to clean your Tic history. "
                                                   type:TSMessageNotificationTypeError];
        } else {
            for (TTTic *tic in objects) {
                [tic unpinInBackgroundWithName:kTTLocalDatastoreTicsPinName];
                [self.jsqMessages removeAllObjects];
                [self.tics removeAllObjects];
            }
            if ([objects count] > 0) {
                [self finishReceivingMessageAnimated:YES];
                [TSMessage showNotificationInViewController:self
                                                      title:@"Done"
                                                   subtitle:[NSString stringWithFormat:@"All your Tics with %@ has been deleted locally. ", self.recipient.displayName]
                                                       type:TSMessageNotificationTypeSuccess];
            }
            if ([objects count] > 0) {
                [self finishReceivingMessageAnimated:YES];
            }
        }
    }];
}

- (void)sendTic:(TTTic *)tic {
    [tic saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            TTActivity *sendTicActivity = [TTActivity activityWithType:kTTActivityTypeSendTic tic:tic];
            [sendTicActivity saveEventually:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Activity saved. ");
                } else {
                    NSLog(@"Failed to save Activity, error: %@", error);
                }
            }];
        } else {
            NSLog(@"Failed to save Tic, error: %@", error);
        }
    }];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    // Play sound
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    // New JSQMessage
    JSQMessage *newJSQMessage = [[JSQMessage alloc] initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:date text:text];
    
    // New Tic
    TTTic *newTic = [self ticWithType:kTTTicTypeDefault sender:[TTUser currentUser] recipient:self.recipient timeLimit:self.expirationTime message:newJSQMessage];
    [newTic pinInBackgroundWithName:kTTLocalDatastoreTicsPinName];
    
    // Add to local array
    [self.tics addObject:newTic];
    [self.jsqMessages addObject:newJSQMessage];
    
    [self finishSendingMessageAnimated:YES];
    [self sendTic:newTic];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.jsqMessages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.jsqMessages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    } else {
        return self.incomingBubbleImageData;
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.jsqMessages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        // @TODO: profile picture
    }
    else {
        // @TODO: profile picture
    }
    
    JSQMessagesAvatarImage *testAvatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"profile"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    return testAvatar;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    // Show timestamp for each Tic
    JSQMessage *message = [self.jsqMessages objectAtIndex:indexPath.item];
    return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.jsqMessages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.jsqMessages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}


#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.jsqMessages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //use the code below to implement adding the timer subview. looks like subclassing is no longer necessary. just add the subview to messageBubbleImageView
    self.isFetchingTic = YES;
    TTTic *unreadTic = [self.tics objectAtIndex:indexPath.item];
    if (![unreadTic.status isEqualToString:kTTTicStatusUnread]) {
        //return;
    }
    
    NSLog(@"tapped message bubble method invoked.");
    //CustomMessageCell *tappedCell = (CustomMessageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    // tappedCell.textView
    //tappedCell.mediaView = nil;
    //[tappedCell removeExtraView];
    //tappedCell.textView = [[JSQMessagesCellTextView alloc] init];
    //tappedCell.textView.text = @"your secret message";
    //[tappedCell.textView setHidden:YES];
    //MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:tappedCell.messageBubbleImageView];
//[tappedCell.messageBubbleImageView addSubview:progressHUD];
    //progressHUD.opacity = 0;
    //[progressHUD show:YES];

    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    int w = cell.bounds.size.width;
    int h = cell.bounds.size.height;
    CGRect viewRect = CGRectMake(-1, -1, w, h);
    NSLog(@"%d %d", w, h);
    TTTic *theTic = [self.tics objectAtIndex:indexPath.item];
    if (theTic.status == kTTTicStatusRead) {
        NSLog(@"The tic has been read before that's why it just should show the message.");
        return cell;
    }
    if (![cell.messageBubbleContainerView viewWithTag:1234]) {
        //NSTimeInterval currTime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval timeLeft =  theTic.timeLimit + theTic.sendTimestamp.timeIntervalSinceNow;
        //NSLog(@"%d", theTic.sendTimestamp.timeIntervalSinceNow);
        //if (timeLeft > 0) {
            CountDownView *myView = [[CountDownView alloc] initWithFrame:viewRect time:timeLeft delegate:self timeId:theTic.sendTimestamp];
            [myView setTag:1234];
            NSLog(@"the countdownview has been created");
            myView.layer.borderWidth = 2;
            myView.layer.cornerRadius = 10;
            myView.layer.borderColor = [kTTUIPurpleColor CGColor];
            myView.opaque = YES;
            myView.backgroundColor = [UIColor whiteColor];
            //[(JSQMessagesCollectionViewCellOutgoing *)cell setExtraView: myView];
            [cell.messageBubbleContainerView addSubview:myView];
            //[cell bringSubviewToFront:cell.textView];
        //} else {
            //[self timerIsZero:theTic.sendTimestamp];
       // }
    } else {
        NSLog(@"the countdownview is reused");
        //CountDownView *myView = (CountDownView *)[cell.messageBubbleContainerView viewWithTag:1234];
        //[myView setTime:theTime.timeLimit];
        //[myView setHidden:NO];
    }
    //cell.textView.hidden = YES;
    
    //JSQMessage *message = [self.jsqMessages objectAtIndex:indexPath.item];
    
   /* if (!message.isMediaMessage) {
        
        if ([message.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }*/
    return cell;
}


#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *currentMessage = [self.jsqMessages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.jsqMessages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0f;
}


#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender {
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"tapped message bubble method invoked.");

    
    if (self.isFetchingTic) {
        //return;
    }
    
    self.isFetchingTic = YES;
    TTTic *unreadTic = [self.tics objectAtIndex:indexPath.item];
    if (![unreadTic.status isEqualToString:kTTTicStatusUnread]) {
       // return;
    }
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    
    TTTic *theTic = [self.tics objectAtIndex:indexPath.item];
    
    //cell.textView.text = theTic.;
    
    CountDownView *cdView = (CountDownView *)[cell.messageBubbleContainerView viewWithTag:1234];
    //NSLog(cdView);
    NSTimeInterval timeLeft =  theTic.timeLimit + theTic.sendTimestamp.timeIntervalSinceNow;
    if(timeLeft > 0) {
        [cell.textView setHidden:NO];
        [cdView setHidden:YES];
        theTic.status = kTTTicStatusRead;
        
        //[TTTic fetchTicInBackgroundWithId:theTic.objectId timestamp:theTic.sendTimestamp completion:^(TTTic *fetchedTic, NSError *error) {
          //
        //}];
        [theTic saveInBackground];

        NSLog(@"The status of the tic should have been updated to StatusRead");
    }
//    for (UIView *v in cell.messageBubbleImageView.subviews) {
//        [v removeFromSuperview];
//    }
    //NSLog(@"message bubble view must have been removed!");
    //NSLog(@"tapped message bubble method invoked.");
    //CustomMessageCell *tappedCell = (CustomMessageCell *)[collectionView cellForItemAtIndexPath:indexPath];
   // tappedCell.textView
    //tappedCell.mediaView = nil;
    //[tappedCell removeExtraView];
    //tappedCell.textView = [[JSQMessagesCellTextView alloc] init];
    //tappedCell.textView.text = @"your secret message";
    //[tappedCell.textView setHidden:YES];
    //MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:tappedCell.messageBubbleImageView];
    //[tappedCell.messageBubbleImageView addSubview:progressHUD];
    //progressHUD.opacity = 0;
    //[progressHUD show:YES];
/*
    [TTTic fetchTicInBackgroundWithId:unreadTic.objectId timestamp:[NSDate date] completion:^(TTTic *fetchedTic, NSError *error) {
        if (fetchedTic) {
            [fetchedTic pinInBackgroundWithName:kTTLocalDatastoreTicsPinName];
            fetchedTic.status = kTTTicStatusRead;
            JSQMessage *fetchedJSQMessage = [self jsqMessageWithTic:fetchedTic];
            [self.tics replaceObjectAtIndex:indexPath.item withObject:fetchedTic];
            [self.jsqMessages replaceObjectAtIndex:indexPath.item withObject:fetchedJSQMessage];
        } else {
            [TSMessage showNotificationInViewController:self title:@"You are too late!" subtitle:@"This Tic has already expired. " type:TSMessageNotificationTypeWarning];
            NSDate *emptyMessageDate = ((JSQMessage *)[self.jsqMessages objectAtIndex:indexPath.item]).date;
            JSQMessage *expiredMessage = [[JSQMessage alloc] initWithSenderId:self.recipient.objectId senderDisplayName:self.recipient.displayName date:emptyMessageDate text:@"Expired"];
            [self.jsqMessages replaceObjectAtIndex:indexPath.item withObject:expiredMessage];
            unreadTic.status = kTTTIcStatusExpired;
        }
        //[progressHUD removeFromSuperview];
        [tappedCell.textView setHidden:NO];
        [self finishReceivingMessageAnimated:YES];
        self.isFetchingTic = NO;
    }];*/
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation {
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
    
}

#pragma mark - TTMessagesViewController

- (TTTic *)ticWithType:(NSString *)type sender:(TTUser *)sender recipient:(TTUser *)recipient timeLimit:(NSTimeInterval)timeLimit message:(JSQMessage *)message {
    TTTic *newTic = [TTTic object];
    newTic.type = type;
    newTic.sender = sender;
    newTic.recipient = recipient;
    newTic.timeLimit = timeLimit;
    newTic.sendTimestamp = message.date;
    newTic.receiveTimestamp = nil;
    newTic.status = kTTTicStatusUnread;
    if (message.isMediaMessage) {
        // @TODO: determine media type?
        newTic.contentType = nil;
        newTic.content = nil;
    } else {
        newTic.contentType = kTTTicContentTypeText;
        newTic.content = [message.text dataUsingEncoding:NSUTF8StringEncoding];
    }
    return newTic;
}

- (JSQMessage *)jsqMessageWithTic:(TTTic *)tic {
    TTUser *sender = tic.sender;
    return [[JSQMessage alloc] initWithSenderId:sender.objectId senderDisplayName:sender.displayName date:tic.sendTimestamp text:[NSString stringWithUTF8String:[tic.content bytes]]];
}

#pragma mark - TSMessageView

- (void)customizeMessageView:(TSMessageView *)messageView {
    messageView.alpha = 0.95;
}

#pragma mark - TTExpirationPickerControllerDelegate
- (void)pickerController:(TTExpirationPickerController *)controller didFinishWithExpiration:(NSTimeInterval)expirationTime {
    if (controller == self.pickerController) {
        self.expirationTime = expirationTime;
        [self refreshExpirationToolbar:expirationTime];
    }
}

#pragma mark - CountDownViewDelegate
- (void)timerIsZero:(NSDate *)timestamp {
    int counter = 0;
    for (TTTic *tic in self.tics){
        if(tic.sendTimestamp == timestamp) {
            [self.tics removeObjectAtIndex:counter];
            break;
        }
        counter++;
    }
    counter = 0;
    for (JSQMessage *msg in self.jsqMessages) {
        if(msg.date == timestamp) {
            [self.jsqMessages removeObjectAtIndex:counter];
            break;
        }
        counter++;
    }
    [self.collectionView reloadData];
}

@end

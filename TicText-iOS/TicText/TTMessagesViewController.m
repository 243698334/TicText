//
//  TTMessagesViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/25/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTMessagesViewController.h"

#import <AudioToolbox/AudioServices.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <JSQMessagesViewController/JSQMessagesKeyboardController.h>

#import "TTTic.h"
#import "TTActivity.h"

#import "TTExpirationDomain.h"
#import "UIView+Screenshot.h"
#import "UIImage+SquareImage.h"

#import "TTMessagesToolbarItem.h"
#import "TTTextToolbarItem.h"
#import "TTImageToolbarItem.h"
#import "TTAnonymousToolbarItem.h"
#import "TTExpirationToolbarItem.h"

#define kImageLoadAmount 10

@interface JSQMessagesViewController (PrivateMethods)

- (void)loadTicHistory;
- (void)finishReceivingMessageAnimated:(BOOL)animated;

- (void)setupMessagesToolbar;
- (CGRect)inputToolbarFrame;
- (CGRect)messagesToolbarFrame;
- (CGRect)toolbarContentViewFrame;
- (void)removeCurrentToolbarContentView;
- (void)setupToolbarContentView:(UIView *)view;
- (void)updateCustomUI;
- (void)jsq_setToolbarBottomLayoutGuideConstant:(CGFloat)constant;
- (void)jsq_adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy;
- (void)jsq_updateCollectionViewInsets;

- (CGRect)caculateInputToolbarFrameHidden:(BOOL)hidden;
- (void)setInputToolbarHiddenState:(BOOL)hidden;
- (UIWindow *)frontWindow;

@end

@interface TTMessagesViewController ()

@property (nonatomic) CGFloat realToolbarBottomLayoutGuideConstrant;
@property (strong, nonatomic) JSQMessagesKeyboardController *keyboardController;

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) BOOL isFetchingTic;

@property (nonatomic, strong) TTConversation *conversation;
@property (nonatomic, strong) TTUser *recipient;
@property (nonatomic, strong) NSMutableArray *tics;
@property (nonatomic, strong) NSMutableArray *jsqMessages;

// image picker view
@property (nonatomic, strong) NSMutableArray *imagesFromCameraRoll;

@property (nonatomic, strong) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (nonatomic, strong) JSQMessagesBubbleImageFactory *bubbleFactory;

@end

@implementation TTMessagesViewController

+ (TTMessagesViewController *)messagesViewControllerWithRecipient:(TTUser *)recipient {
    TTMessagesViewController *messagesViewController = [TTMessagesViewController messagesViewController];
    messagesViewController.recipient = recipient;
    return messagesViewController;
}

+ (TTMessagesViewController *)messagesViewControllerWithConversation:(TTConversation *)conversation {
    TTMessagesViewController *messagesViewController = [TTMessagesViewController messagesViewController];
    messagesViewController.recipient = conversation.recipient;
    messagesViewController.conversation = conversation;
    return messagesViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.recipient.displayName;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(confirmCleanTicHistory)];
    self.view.backgroundColor = [UIColor grayColor];
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.inputToolbar.contentView.backgroundColor = [UIColor whiteColor];
    self.inputToolbar.contentView.rightBarButtonItem.tintColor = kTTUIPurpleColor;
    
    self.expirationTime = kDefaultExpirationTime; // @TODO Load from user settings
    [self setupMessagesToolbar];
    
    
    [TSMessage setDelegate:self];
    [TSMessage addCustomDesignFromFileWithName:@"TTInAppNotificationDesign.json"];
    
    self.senderId = [[TTUser currentUser].objectId copy];
    self.senderDisplayName = [[TTUser currentUser].displayName copy];
    
    self.tics = [[NSMutableArray alloc] init];
    self.jsqMessages = [[NSMutableArray alloc] init];
    
    self.isFetchingTic = NO;
    self.bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [self.bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [self.bubbleFactory incomingMessagesBubbleImageWithColor:kTTUIPurpleColor];
    
    [self loadTicHistory];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewTic:) name:kTTApplicationDidReceiveNewTicWhileActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowPhotoLibrary) name:kTTScrollingImagePickerDidTapImagePickerButton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickImageFromScrollingImagePickerWithObject:) name:kTTScrollingUIImagePickerDidChooseImage object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.conversation.lastTic.type == kTTTicTypeDraft && self.messagesToolbar.selectedIndex == kTTMessagesToolbarSelectedItemNone) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        [self.messagesToolbar selectItemAtIndex:0];
        NSString *draftTicContent = [NSString stringWithUTF8String:[self.conversation.lastTic.content bytes]];
        if ([draftTicContent isEqualToString:@"[Empty]"]) {
            draftTicContent = @"";
        }
        self.inputToolbar.contentView.textView.text = draftTicContent;
    }
    
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    [self jsq_setToolbarBottomLayoutGuideConstant:0];
    
    if (self.messagesToolbar.selectedIndex != kTTMessagesToolbarSelectedItemNone) {
        if (![self.inputToolbar.contentView.textView isFirstResponder]) {
            [self.inputToolbar.contentView.textView becomeFirstResponder];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self updateCurrentConversation];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self updateCustomUI];
}

- (void)updateCurrentConversation {
    TTTic *draftTic = [TTTic object];
    draftTic.status = kTTTicStatusDrafting;
    draftTic.type = kTTTicTypeDraft;
    draftTic.sendTimestamp = draftTic.receiveTimestamp = [NSDate date];
    draftTic.sender = [TTUser currentUser];
    draftTic.recipient = self.recipient;
    draftTic.ACL = [PFACL ACLWithUser:[TTUser currentUser]];

    if ([self.inputToolbar.contentView.textView.text length] > 0) {
        if (self.conversation.lastTic == nil || self.conversation.lastTic.type != kTTTicTypeDraft) {
            draftTic.content = [self.inputToolbar.contentView.textView.text dataUsingEncoding:NSUTF8StringEncoding];
            self.conversation.lastTic = draftTic;
        } else {
            self.conversation.lastTic.content = [self.inputToolbar.contentView.textView.text dataUsingEncoding:NSUTF8StringEncoding];
        }
    } else {
        if ([self.tics count] > 0) {
            self.conversation.lastTic = [self.tics lastObject];
        } else {
            draftTic.content = [@"[Empty]" dataUsingEncoding:NSUTF8StringEncoding];
            self.conversation.lastTic = draftTic;
        }
    }
    [self.conversation saveEventually];
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
            NSInteger loadedTicsCount = 0;
            for (TTTic *tic in objects) {
                if (![tic.status isEqualToString:kTTTicStatusDrafting]) {
                    JSQMessage *jsqMessage = [self jsqMessageWithTic:tic];
                    [self.tics addObject:tic];
                    [self.jsqMessages addObject:jsqMessage];
                    loadedTicsCount++;
                }
            }
            if (loadedTicsCount > 0) {
                [self finishReceivingMessageAnimated:YES];
            }
        }
    }];
}

- (void)setupMessagesToolbar {
    self.messagesToolbar = [[TTMessagesToolbar alloc] initWithFrame:[self messagesToolbarFrame]];
    self.messagesToolbar.delegate = self;
    [self.view addSubview:self.messagesToolbar];
    
    [self.inputToolbar setHidden:YES];
}

- (CGRect)inputToolbarFrame {
    if (self.messagesToolbar.selectedIndex == 0) {
        CGFloat originY = self.view.frame.size.height - self.realToolbarBottomLayoutGuideConstrant - kMessagesToolbarHeight - self.inputToolbar.frame.size.height;
        return CGRectMake(0, originY,
                          self.inputToolbar.frame.size.width, self.inputToolbar.frame.size.height);
    } else {
        return [self messagesToolbarFrame];
    }
}

- (CGRect)messagesToolbarFrame {
    return CGRectMake(0, self.view.frame.size.height - self.realToolbarBottomLayoutGuideConstrant - kMessagesToolbarHeight,
                      self.inputToolbar.frame.size.width, self.inputToolbar.frame.size.height);
}

- (CGRect)toolbarContentViewFrame {
    UIWindow *frontWindow = [self frontWindow];
    CGFloat originY = self.view.frame.size.height - self.realToolbarBottomLayoutGuideConstrant;
    CGRect frame = CGRectMake(0, originY,
                              self.view.frame.size.width, self.keyboardController.currentKeyboardFrame.size.height);
    
    return [frontWindow convertRect:frame fromView:self.view];
}

- (void)removeCurrentToolbarContentView {
    [self.toolbarContentView removeFromSuperview];
}

- (void)setupToolbarContentView:(UIView *)view {
    UIWindow *frontWindow = [self frontWindow];
    
    // Arrange background view
    self.toolbarContentView = view;
    CGRect frame = [self toolbarContentViewFrame];
    frame.origin.y = [UIScreen mainScreen].bounds.size.height;
    self.toolbarContentView.frame = frame;
    
    [frontWindow addSubview:self.toolbarContentView];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.toolbarContentView.frame = [self toolbarContentViewFrame];
    } completion:^(BOOL finished) {
        if (finished ) {
            [frontWindow bringSubviewToFront:self.toolbarContentView];
        }
    }];
}

- (void)updateCustomUI {
    [self.inputToolbar setFrame:[self inputToolbarFrame]];
    [self.messagesToolbar setFrame:[self messagesToolbarFrame]];
    [self.toolbarContentView setFrame:[self toolbarContentViewFrame]];
    [UIView animateWithDuration:0 animations:^{ // Fixes Auto Layout resize "jaggedness"
        [self.toolbarContentView layoutIfNeeded];
    }];
}

- (void)jsq_setToolbarBottomLayoutGuideConstant:(CGFloat)constant {
    // Save the real constant so we can restore it when we hide the input toolbar.
    // The input toolbar will be hidden when an item that's not the TTTextToolbarItem is selected.
    self.realToolbarBottomLayoutGuideConstrant = constant;
    
    // Offset the input toolbar by |kMessagesToolbarHeight| so we can put the messagesToolbar
    // below the inputToolbar.
    if (self.messagesToolbar.selectedIndex == 0) {
        [super jsq_setToolbarBottomLayoutGuideConstant:constant + kMessagesToolbarHeight];
    } else {
        [super jsq_setToolbarBottomLayoutGuideConstant:constant];
    }
    
    [self updateCustomUI];
}

- (void)jsq_adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy {
    [super jsq_adjustInputToolbarForComposerTextViewContentSizeChange:dy];
    
    [self updateCustomUI];
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

- (TTTic *)createTicWithMessegeText:(NSString *)text mediaContent:(id)mediaContent senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    // Play sound
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    // New JSQMessage
    JSQMessage *newJSQMessage = nil;
    
    // New Tic and anonymous status
    NSString *ticType = kTTTicTypeDefault;
    if (self.isAnonymous) {
        ticType = kTTTicTypeAnonymous;
    }
    TTTic *newTic = nil;
    
    // Tic can't contain both text and media content
    if (text) {
        newJSQMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                           senderDisplayName:senderDisplayName
                                                        date:date
                                                        text:text];
        newTic = [self ticWithMessage:newJSQMessage mediaFile:nil];
    } else {
        // Media Item
        JSQPhotoMediaItem *mediaItem = nil;
        PFFile *file = nil;
        
        if ([mediaContent isKindOfClass:[UIImage class]]) {
            mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:(UIImage *)mediaContent];
            mediaItem.appliesMediaViewMaskAsOutgoing = [[TTUser currentUser].objectId isEqualToString:senderId];
            file = [PFFile fileWithData:UIImageJPEGRepresentation((UIImage *)mediaContent, 0.6)];
        }
        newJSQMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                           senderDisplayName:senderDisplayName
                                                        date:date
                                                       media:mediaItem];
        newTic = [self ticWithMessage:newJSQMessage mediaFile:file];
    }
    
    // Add to local array
    [self.tics addObject:newTic];
    [self.jsqMessages addObject:newJSQMessage];
    
    [self finishSendingMessageAnimated:YES];
    return newTic;
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

- (void)sendTicWithMediaContent:(TTTic *)tic {
    [tic saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
            [TSMessage showNotificationInViewController:self
                                                  title:@"Connection Error"
                                               subtitle:@"Unable to send media content."
                                                   type:TSMessageNotificationTypeError];
            // TODO:provide resend option?
        }
    }];
}

- (void)didPickImageFromScrollingImagePickerWithObject:(NSNotification *)notification {
    TTTic *newTic = [self createTicWithMessegeText:nil mediaContent:[[notification userInfo] objectForKey:kTTScrollingUIImagePickerChosenImageKey] senderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date]];
    
    [self sendTicWithMediaContent:newTic];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    TTTic *newTic = [self createTicWithMessegeText:text mediaContent:nil senderId:self.senderId senderDisplayName:self.senderDisplayName date:date];
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
        return [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:[[TTUser currentUser].profilePicture getData]] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    }
    else {
        return [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:[self.recipient.profilePicture getData]] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    }
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
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessage *message = [self.jsqMessages objectAtIndex:indexPath.item];
    
    if (!message.isMediaMessage) {
        
        if ([message.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
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
    if (self.isFetchingTic) {
        return;
    }
    
    self.isFetchingTic = YES;
    TTTic *unreadTic = [self.tics objectAtIndex:indexPath.item];
    if (![unreadTic.status isEqualToString:kTTTicStatusUnread]) {
        return;
    }
    
    JSQMessagesCollectionViewCell *tappedCell = (JSQMessagesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [tappedCell.textView setHidden:YES];
    [tappedCell.mediaView setHidden:YES];
    //    MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:tappedCell.messageBubbleImageView];
    //    [tappedCell.messageBubbleImageView addSubview:progressHUD];
    MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:tappedCell.messageBubbleContainerView];
    [tappedCell.messageBubbleContainerView addSubview:progressHUD];
    progressHUD.opacity = 0;
    [progressHUD show:YES];
    
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
            unreadTic.status = kTTTicStatusExpired;
        }
        [progressHUD removeFromSuperview];
        [tappedCell.textView setHidden:NO];
        [tappedCell.mediaView setHidden:NO];
        [self finishReceivingMessageAnimated:YES];
        self.isFetchingTic = NO;
    }];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation {
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - TTMessagesViewController

- (TTTic *)ticWithMessage:(JSQMessage *)message mediaFile:(PFFile *)mediaFile {
    TTTic *newTic = [TTTic object];
    newTic.type = (self.isAnonymous) ? kTTTicTypeAnonymous : kTTTicTypeDefault;
    newTic.sender = [TTUser currentUser];
    newTic.recipient = self.recipient;
    newTic.timeLimit = self.expirationTime;
    newTic.sendTimestamp = message.date;
    newTic.receiveTimestamp = nil;
    newTic.status = kTTTicStatusUnread;
    if (message.isMediaMessage) {
        // image
        newTic.contentType = kTTTicContentTypeImage;
        newTic.mediaContent = mediaFile;
        
        // TODO:voice
        
        newTic.content = nil;
    } else {
        newTic.contentType = kTTTicContentTypeText;
        newTic.content = [message.text dataUsingEncoding:NSUTF8StringEncoding];
    }
    return newTic;
}

- (JSQMessage *)jsqMessageWithTic:(TTTic *)tic {
    TTUser *sender = tic.sender;
    PFFile *mediaContent = tic.mediaContent;
    
    if (mediaContent) {
        // TODO:classify more media types
        JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
        mediaItem.appliesMediaViewMaskAsOutgoing = [[TTUser currentUser].objectId isEqualToString:self.senderId];
        
        [mediaContent getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (error) {
                [TSMessage showNotificationInViewController:self
                                                      title:@"Connection Error"
                                                   subtitle:@"Unable to fetch media content."
                                                       type:TSMessageNotificationTypeError];
            } else {
                mediaItem.image = [UIImage imageWithData:imageData];
                [self.collectionView reloadData];
            }
        }];
        
        return [[JSQMessage alloc] initWithSenderId:sender.objectId senderDisplayName:sender.displayName date:tic.sendTimestamp media:mediaItem];
    } else {
        return [[JSQMessage alloc] initWithSenderId:sender.objectId senderDisplayName:sender.displayName date:tic.sendTimestamp text:[NSString stringWithUTF8String:[tic.content bytes]]];
    }
}

#pragma mark - TSMessageView

- (void)customizeMessageView:(TSMessageView *)messageView {
    messageView.alpha = 0.95;
}

#pragma mark - TTMessagesToolbarDelegate

#define kInputToolbarHideAnimationDuration 0.44
#define kInputToolbarShowAnimationDuration 0.23

- (CGRect)calculateInputToolbarFrameHidden:(BOOL)hidden {
    // @Remark: This subroutine might be redundant. It might only be necessary to call |inputToolbarFrame|.
    if (hidden) {
        return CGRectOffset([self inputToolbarFrame], 0, self.inputToolbar.frame.size.height);
    } else {
        return [self inputToolbarFrame];
    }
}

- (void)setInputToolbarHiddenState:(BOOL)hidden {
    if (!hidden) {
        [self.inputToolbar setHidden:NO];
    }
    
    CGFloat animationDuration = (hidden) ? kInputToolbarHideAnimationDuration : kInputToolbarShowAnimationDuration;
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         [self.inputToolbar setFrame:[self calculateInputToolbarFrameHidden:hidden]];
                         if (hidden) {
                             [self.messagesToolbar.topBorder setAlpha:1.0f];
                         } else {
                             [self.messagesToolbar.topBorder setAlpha:0.0f];
                         }
                     } completion:^(BOOL finished) {
                         if (finished) {
                             if (hidden) {
                                 [self.inputToolbar setHidden:YES];
                             } else {
                                 [self.inputToolbar setHidden:NO]; // hack to fix a rapid switching bug
                             }
                             [self jsq_setToolbarBottomLayoutGuideConstant:self.realToolbarBottomLayoutGuideConstrant];
                         }
                     }];
}

- (void)messagesToolbar:(TTMessagesToolbar *)toolbar willShowItem:(TTMessagesToolbarItem *)item {
    if (toolbar != self.messagesToolbar) {
        return;
    }
    
    if (![self.inputToolbar.contentView.textView isFirstResponder]) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
    }
    
    if ([item isKindOfClass:[TTTextToolbarItem class]]) {
        [self setInputToolbarHiddenState:NO];
    } else {
        [self setInputToolbarHiddenState:YES];
    }
    
    if ([item isKindOfClass:[TTImageToolbarItem class]]) {
        [self loadImagesFromCameraRollWithAmount:kImageLoadAmount inScrollingImagePickerView:((TTImageToolbarItem *)item).scrollingImagePickerView];
        ((TTImageToolbarItem *)item).scrollingImagePickerView.delegate = self;
    }
    
    [self removeCurrentToolbarContentView];
    [self setupToolbarContentView:item.contentView];
    
    NSLog(@"TTMessagesViewController-messagesToolbar: Item shown with class: %@", item.class);
}

#pragma mark - TTScrollingImagePickerViewDelegate

- (void)needLoadMoreImagesForScrollingImagePicker:(TTScrollingImagePickerView *)scrollingImagePickerView {
    [self loadImagesFromCameraRollWithAmount:kImageLoadAmount inScrollingImagePickerView:scrollingImagePickerView];
}

- (void)loadImagesFromCameraRollWithAmount:(NSInteger)amount inScrollingImagePickerView:(TTScrollingImagePickerView *)scrollingImagePickerView {
    if (self.imagesFromCameraRoll == nil) {
        self.imagesFromCameraRoll = [[NSMutableArray alloc] init];
    }
    
    self.progressHUD = [MBProgressHUD showHUDAddedTo:scrollingImagePickerView animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[[ALAssetsLibrary alloc] init] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                NSUInteger lastIndex = group.numberOfAssets - [self.imagesFromCameraRoll count];
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        NSInteger lo = lastIndex - amount;
                        NSInteger hi = lastIndex;
                        if (lo < 0) {
                            lo = 0;
                        }
                        if (index >= lo && index < hi) {
                            UIImage *image = [UIImage imageWithCGImage:[[result defaultRepresentation] fullScreenImage]];
                            [self.imagesFromCameraRoll addObject:[UIImage squareImageWithImage:image scaledToSize:300]];
                            NSLog(@"------------Loading Images #%ld -------------", index);
                        }
                    } else {
                        *stop = YES;
                        NSLog(@"------------Finished Loading Images-------------");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [scrollingImagePickerView setImages:self.imagesFromCameraRoll];
                            [self.progressHUD removeFromSuperview];
                        });
                        
                    }
                }];
            }
        } failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [TSMessage showNotificationWithTitle:@"Permission Denied"
                                            subtitle:@"Please allow TicText to access your Camera Roll."
                                                type:TSMessageNotificationTypeError];
            });
            
        }];
    });
    
}

- (void)messagesToolbar:(TTMessagesToolbar *)toolbar willHideItem:(TTMessagesToolbarItem *)item {
    if (toolbar != self.messagesToolbar) {
        return;
    }
    
    NSLog(@"TTMessagesViewController-messagesToolbar: Item hidden with class: %@", item.class);
}

- (void)messagesToolbar:(TTMessagesToolbar *)toolbar setAnonymousTic:(BOOL)anonymous {
    if (toolbar == self.messagesToolbar) {
        self.isAnonymous = anonymous;
    }
}

- (void)messagesToolbar:(TTMessagesToolbar *)toolbar setExpirationTime:(NSTimeInterval)expirationTime {
    if (toolbar == self.messagesToolbar) {
        self.expirationTime = expirationTime;
    }
}

#pragma mark - TextView Delegate
#define kTTMessagesViewControllerToolbarItemDeselectOnKeyboardHideDelay 0.4
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [super textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [super textViewDidEndEditing:textView];
    
    if (self.presentedViewController == nil) {
        [self deselectCurrentToolbarItem]; // only hide when we intentionally dismiss the keyboard
    }
}

#pragma mark - UIImagePicker
- (void)willShowPhotoLibrary {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        [TSMessage showNotificationWithTitle:@"Permission Denied"
                                    subtitle:@"Please allow TicText to access your Camera Roll."
                                        type:TSMessageNotificationTypeError];
    }
    
    NSString *type = (NSString *)kUTTypeImage;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:type]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.mediaTypes = [NSArray arrayWithObject:type];
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:type]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePickerController.mediaTypes = [NSArray arrayWithObject:type];
    } else {
        [TSMessage showNotificationWithTitle:@"Permission Denied"
                                    subtitle:@"Please allow TicText to access your Camera Roll."
                                        type:TSMessageNotificationTypeError];
    }
    
    imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *picture = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (picture != nil) {
        TTTic *newTic = [self createTicWithMessegeText:nil mediaContent:picture senderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date]];
        
        [self sendTicWithMediaContent:newTic];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper Methods
- (UIWindow *)frontWindow {
    return [[[UIApplication sharedApplication] windows] lastObject];
}

- (void)deselectCurrentToolbarItem {
    [self.messagesToolbar deselectItemAtIndex:self.messagesToolbar.selectedIndex];
    [self.messagesToolbar setSelectedIndex:kTTMessagesToolbarSelectedItemNone];
}

@end

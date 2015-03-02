//
//  TTMessagesViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/25/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTMessagesViewController.h"
#import "TTUser.h"
#import "TTTic.h"
#import "TTActivity.h"

#define HCK @"9vre9oQlWh"
#define HCK_DEV @"YlnkEyAQyF"
#define KEVIN @"4ynJPt9u9w"
#define KEVIN_DEV @"F8ekXoLCGN"

@interface TTMessagesViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL isLoading;

@property (nonatomic, strong) NSMutableArray *tics;
@property (nonatomic, strong) NSMutableArray *jsqMessages;
@property (nonatomic, strong) NSString *senderUserId;
@property (nonatomic, strong) NSString *recipientUserId;

// @TODO: need customization
@property (nonatomic, strong) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (nonatomic, strong) JSQMessagesBubbleImageFactory *bubbleFactory;

@end

@implementation TTMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTics) name:kTTApplicationDidReceiveNewTicWhileActiveNotification object:nil];
    
    self.senderId = [[TTUser currentUser].objectId copy];
    self.senderDisplayName = [[TTUser currentUser].displayName copy];
    
    self.tics = [[NSMutableArray alloc] init];
    self.jsqMessages = [[NSMutableArray alloc] init];
    self.senderUserId = [TTUser currentUser].objectId;
    if ([self.senderId isEqualToString:HCK]) {
        self.recipientUserId = HCK_DEV;
    } else if ([self.senderId isEqualToString:HCK_DEV]) {
        self.recipientUserId = HCK;
    } else if ([self.senderId isEqualToString:KEVIN]) {
        self.recipientUserId = KEVIN_DEV;
    } else {
        self.recipientUserId = KEVIN;
    }
    
    self.bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [self.bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [self.bubbleFactory incomingMessagesBubbleImageWithColor:kTTUIPurpleColor];
    
    self.isLoading = NO;
    [self loadTics];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(loadTics) userInfo:nil repeats:YES];
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    // Play sound
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    // New JSQMessage
    JSQMessage *newJSQMessage = [[JSQMessage alloc] initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:date text:text];
    
    // New Tic
    TTTic *newTic = [self ticWithType:kTTTicTypeDefault senderUserId:self.senderUserId recipientUserId:self.recipientUserId timeLimit:10 message:newJSQMessage];
    [newTic pinInBackground];
    
    // Add to local array
    [self.tics addObject:newTic];
    [self.jsqMessages addObject:newJSQMessage];
    
    [self finishSendingMessageAnimated:YES];
    [self sendTic:newTic];
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

- (void)loadTics {
    if (self.isLoading == NO) {
        self.isLoading = YES;
        JSQMessage *mostRecentJSQMessage = [self.jsqMessages lastObject];
        
        PFQuery *query = [TTTic query];
        if (mostRecentJSQMessage != nil) {
            [query whereKey:kTTTicSendTimestampKey greaterThan:mostRecentJSQMessage.date];
        }
        [query includeKey:kTTTicSenderKey];
        [query orderByDescending:kTTTicSendTimestampKey];
        [query setLimit:50];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (error == nil) {
                for (TTTic *tic in [objects reverseObjectEnumerator]) {
                    TTUser *sender = [tic objectForKey:kTTTicSenderKey];
                    
                    // New JSQMessage
                    JSQMessage *newJSQMessage = [[JSQMessage alloc] initWithSenderId:sender.objectId senderDisplayName:sender.displayName date:tic.sendTimestamp text:[NSString stringWithUTF8String:[tic.content bytes]]];
                    
                    // Add to local array
                    [self.tics addObject:tic];
                    [self.jsqMessages addObject:newJSQMessage];
                }
                if ([objects count] != 0) {
                    [self finishReceivingMessage];
                }
            } else {
                NSLog(@"Network error");
            }
            self.isLoading = NO;
        }];
    }
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    NSLog(@"didPressAccessoryButton");
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
        //
    }
    else {
        //
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
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  iOS7-style sender name labels
     */
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

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender {
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Tapped message bubble!");
    TTTic *tic = [self.tics objectAtIndex:indexPath.item];
    if ([tic.senderUserId isEqualToString:self.senderUserId]) {
        NSLog(@"No need to fetch self tic");
    } else {
        TTActivity *fetchTicActivity = [TTActivity activityWithType:kTTActivityTypeFetchTic tic:tic];
        [fetchTicActivity saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Fetch Tic successfully");
            } else {
                NSLog(@"Failed to fetch Tic, error: %@", error);
            }
        }];
    }
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation {
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - TTMessagesViewController

- (TTTic *)ticWithType:(NSString *)type senderUserId:(NSString *)senderUserId recipientUserId:(NSString *)recipientUserId timeLimit:(NSTimeInterval)timeLimit message:(JSQMessage *)message {
    TTTic *newTic = [TTTic object];
    newTic.type = type;
    newTic.senderUserId = senderUserId;
    newTic.recipientUserId = recipientUserId;
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

- (JSQMessage *)messageWithTic:(TTTic *)tic {
    // @TODO: change this to query
    TTUser *sender = [tic objectForKey:kTTTicSenderKey];
    return [[JSQMessage alloc] initWithSenderId:tic.senderUserId senderDisplayName:sender.displayName date:tic.sendTimestamp text:[NSString stringWithUTF8String:[tic.content bytes]]];
}

@end

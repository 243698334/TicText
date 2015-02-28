//
//  TTMessagesViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/25/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTMessagesViewController.h"
#import "MBProgressHUD.h"
#import "TTUser.h"
#import "TTTic.h"

@interface TTMessagesViewController () {
    
    BOOL isLoading;
    
    NSMutableArray *users;
    NSMutableArray *messages;
    NSMutableDictionary *avatars;
    
    JSQMessagesBubbleImage *outgoingBubbleImageData;
    JSQMessagesBubbleImage *incomingBubbleImageData;
    
//    JSQMessagesAvatarImage *defaultAvatarImageData;
    
}
@end

@implementation TTMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTics) name:@"kTTAppDelegateDidReceiveNewTicWhileAppActiveNotification" object:nil];
    
    users = [[NSMutableArray alloc] init];
    messages = [[NSMutableArray alloc] init];
    avatars = [[NSMutableDictionary alloc] init];

    
    self.senderId = [TTUser currentUser].objectId;
    self.senderDisplayName = [TTUser currentUser].displayName;
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:kTTUIPurpleColor];
    
    // TODO: look at dis
//    defaultAvatarImageData = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:[TTUser currentUser].profilePicture] diameter:64.0];
    
    isLoading = NO;
    [self loadTics];
}

- (void)loadTics {

    if (isLoading == NO) {

        isLoading = YES;
        JSQMessage *message_last = [messages lastObject];

        
        PFQuery *query = [TTTic query];
//        [query fromLocalDatastore];
//        [query whereKey:@"senderUserId" equalTo:[TTUser currentUser].objectId];
        [query whereKey:@"recipientUserId" equalTo:[TTUser currentUser].objectId];
        if (message_last != nil) [query whereKey:kTTTicSendTimestampKey greaterThan:message_last.date];
        [query orderByDescending:kTTTicSendTimestampKey];
        [query setLimit:50];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

            if (error == nil) {
                NSLog(@"Query for tics succeed with %ld tics", [objects count]);
                for (TTTic *tic in [objects reverseObjectEnumerator]) {
                    
                    [self addMessage:tic];

                }

                if ([objects count] != 0) [self finishReceivingMessage];

            } else {
                // TODO: handle failed loading
            }

            isLoading = NO;

        }];

    }

}

- (void)addMessage:(TTTic *)tic {
    // add correpsonding user for a message
    TTUser *user = [tic objectForKey:@"sender"];
    [users addObject:user];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:user.objectId
                                             senderDisplayName:user.displayName
                                                          date:[NSDate date]
                                                          text:[NSString stringWithUTF8String:[tic.content bytes]]];

    [messages addObject:message];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Some stuff"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"A stuff", @"Another stuff", nil];
    [action showInView:self.view];
}


- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    
    [self sendMessage:text Picture:nil];
}

- (void)sendMessage:(NSString *)text Picture:(UIImage *)picture {
    
    TTTic *tic = [TTTic object];
    [tic pinInBackground];
    tic.type = kTTTicTypeDefault;
    tic.contentType = kTTTicContentTypeText;
    tic.status = kTTTicStatusUnread;
    tic.senderUserId = [TTUser currentUser].objectId;
    tic.recipientUserId = @"GDg1z1J0TN"; // kevindev's objectId
    tic.sendTimestamp = [NSDate date];
    tic.content = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    [tic saveEventually:^(BOOL succeeded, NSError *error) {
        if (error == nil) {
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            [self loadTics];
        } else {
            // TODO: handle failed sending
        }
    }];

    [self finishSendingMessage];
    
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [messages objectAtIndex:indexPath.item];
}

// Bubble
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return outgoingBubbleImageData;
    }
    return incomingBubbleImageData;
}

// Avatar
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: should allow customized avatar image.
    // use facebook profile picture for now
    TTUser *user = users[indexPath.item];
    if (avatars[user.objectId] == nil) {
//        avatars[user.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:[user objectForKey:@"profilePicture"]] diameter:64.0];
//        [self.collectionView reloadData];
        PFFile *fileThumbnail = [user objectForKey:@"profilePicture"];
        [fileThumbnail getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            
            if (error == nil) {
                
                avatars[user.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData] diameter:64.0];
                [self.collectionView reloadData];
                
            }
        }];
    }
    return avatars[user.objectId];
}

// Show a timestamp for every X messages
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.item % 3 == 0) {
//        JSQMessage *message = [messages objectAtIndex:indexPath.item];
//        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
//    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([previousMessage.senderId isEqualToString:message.senderId]) {
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
    return [messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    if (!message.isMediaMessage) {
        if ([message.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        } else {
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
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return 0.0f;
    }
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item-1];
        if ([previousMessage.senderId isEqualToString:message.senderId]) {
            return 0.0f;
        }
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0f;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender {
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: tap bubble to see the content
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation {
    NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        //        if (buttonIndex == 0)	ShouldStartCamera(self, YES);
        //        if (buttonIndex == 1)	ShouldStartPhotoLibrary(self, YES);
        NSLog(@"clickedButtonAtIndex");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *picture = info[UIImagePickerControllerEditedImage];
    [self sendMessage:@"[Picture message]" Picture:picture];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

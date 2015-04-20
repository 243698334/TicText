//
//  TTMessagesViewControllerTests.m
//  TicText
//
//  Created by Kevin Yufei Chen on 3/8/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "TTTestHelper.h"

#import "TTMessagesViewController.h"
#import "TTExpirationDomain.h"
#import "TTConstants.h"
#import "TTTic.h"


@interface TTMessagesViewController (Test)

@property (nonatomic) NSTimeInterval expirationTime;
@property (nonatomic, strong) UIView *expirationToolbar;

@property (nonatomic, strong) UILabel *expirationLabel;
@property (nonatomic, strong) TTExpirationPickerController *pickerController;

- (void)loadTicHistory;
- (void)finishReceivingMessageAnimated:(BOOL)animated;
- (void)refreshExpirationToolbar:(NSTimeInterval)expiration;

@end

@interface TTMessagesViewControllerTests : XCTestCase

@property (nonatomic, strong) id mockMessagesViewController;
@property (nonatomic, strong) id mockRecipient;

@end

// @Remark: For some reason, these tests require you to be signed in because the |loadTicHistory| method in |TTMessagesViewController| calls |TTUser.currentUser| and then sets it in a |PFQuery|.
@implementation TTMessagesViewControllerTests

- (void)setUp {
    [super setUp];
    self.mockRecipient = OCMClassMock([TTUser class]);
    OCMStub([self.mockRecipient objectId]).andReturn(@"fakeUserId");
    OCMStub([self.mockRecipient displayName]).andReturn(@"fakeName");
    self.mockMessagesViewController = OCMPartialMock([TTMessagesViewController messagesViewControllerWithRecipient:self.mockRecipient]);
    OCMStub([self.mockMessagesViewController loadTicHistory]);
    [self.mockMessagesViewController viewDidLoad];
    [self.mockMessagesViewController viewWillAppear:NO];
}

- (void)testDidReceiveNewTicFromRecipient {
    // Arrange
    NSString *ticId = @"fakeTicId";
    NSString *userId = ((TTUser *)self.mockRecipient).objectId;
    id mockTic = OCMClassMock([TTTic class]);
    OCMStub([mockTic unreadTicWithId:[OCMArg any]]).andReturn([TTTic object]);
    OCMExpect([self.mockMessagesViewController finishReceivingMessageAnimated:[OCMArg any]]);
    
    // Act
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTApplicationDidReceiveNewTicWhileActiveNotification
                                                        object:nil
                                                      userInfo:@{kTTNotificationUserInfoTicIdKey : ticId,
                                                                 kTTNotificationUserInfoSenderUserIdKey: userId}];
    
    // Assert
    OCMVerifyAll(self.mockMessagesViewController);
}

- (void)testDidReceiveNewTicFromSomeoneElse {
    // Arrange
    NSString *ticId = @"fakeTicId";
    NSString *userId = @"anotherFakeUserId";
    id mockTic = OCMClassMock([TTTic class]);
    OCMStub([mockTic unreadTicWithId:[OCMArg any]]).andReturn([TTTic object]);
    id mockTSMessages = OCMClassMock([TSMessage class]);
    OCMExpect([mockTSMessages showNotificationInViewController:[OCMArg any]
                                          title:[OCMArg isEqual:@"You have got a new Tic from someone else. "]
                                       subtitle:[OCMArg isEqual:@"Tap to see your unread Tics. "]
                                          image:[OCMArg isEqual:[UIImage imageNamed:@"TicInAppNotificationIcon"]]
                                           type:TSMessageNotificationTypeMessage
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:[OCMArg any]
                                    buttonTitle:[OCMArg isNil]
                                 buttonCallback:[OCMArg isNil]
                                     atPosition:TSMessageNotificationPositionNavBarOverlay
                           canBeDismissedByUser:[OCMArg isNil]]);
    
    // Act
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTApplicationDidReceiveNewTicWhileActiveNotification
                                                        object:nil
                                                      userInfo:@{kTTNotificationUserInfoTicIdKey : ticId,
                                                                 kTTNotificationUserInfoSenderUserIdKey: userId}];
    
    // Assert
    OCMVerifyAll(mockTSMessages);
}

- (void)testSetupMessagesToolbar {
    // @stub
}

- (void)testInputToolbarFrame {
    // @stub
}

- (void)testMessagesToolbarFrame {
    // @stub
}

- (void)testToolbarContentViewFrame {
    // @stub
}

- (void)testRemoveCurrentToolbarContentView {
    // @stub
}

- (void)testSetupToolbarContentView {
    // @stub
}

- (void)testUpdateCustomUI {
    // @stub
}

- (void)testJsq_setToolbarBottomLayoutGuideConstant {
    // @stub
}

- (void)testSendButtonExpirationTime {
    // @stub
}

- (void)testSendButtonTicType {
    // @stub
}

- (void)testCaculateInputToolbarFrameHidden {
    // @stub
}

- (void)testMessagesToolbarWillShowItem {
    // @stub
}

- (void)testMessagesToolbarWillHideItem {
    // @stub
}

- (void)testMessagesToolbarSetAnonymousTic {
    // @stub
}

- (void)testMessagesToolbarSetExpirationTime {
    // @stub
}

- (void)testCurrentExpirationTime {
    // @stub
}

@end

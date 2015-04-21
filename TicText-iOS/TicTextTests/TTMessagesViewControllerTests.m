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
#import "TTMessagesToolbarItem.h"
#import "TTTextToolbarItem.h"

#import <JSQMessagesViewController/JSQMessagesKeyboardController.h>

@interface TTMessagesViewController (Test)

@property (strong, nonatomic) JSQMessagesKeyboardController *keyboardController;
@property (nonatomic) CGFloat realToolbarBottomLayoutGuideConstrant;

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

- (CGRect)calculateInputToolbarFrameHidden:(BOOL)hidden;
- (void)setInputToolbarHiddenState:(BOOL)hidden;
- (UIWindow *)frontWindow;

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
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    vc.messagesToolbar = nil;
    
    XCTAssertNil(vc.messagesToolbar, "pre-condition");
    
    // Act
    [vc setupMessagesToolbar];
    
    // Assert
    XCTAssertNotNil(vc);
    XCTAssertEqual(vc.messagesToolbar.delegate, vc);
    XCTAssertEqual(vc.messagesToolbar.superview, vc.view);
}

- (void)testInputToolbarFrameForZeroLayoutGuideAndVisible {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    CGRect frame = CGRectMake(0, 0, 480, 640);
    [vc.view setFrame:frame];
    
    [vc setupMessagesToolbar];
    [vc.messagesToolbar setSelectedIndex:0];
    
    XCTAssertNotNil(vc.messagesToolbar, "pre-condition");
    XCTAssertEqual(vc.messagesToolbar.selectedIndex, 0, "pre-condition");
    
    vc.realToolbarBottomLayoutGuideConstrant = 0;
    
    // Act
    CGRect result = [vc inputToolbarFrame];
    
    // Assert
    XCTAssertEqual(result.origin.x, 0);
    XCTAssertEqual(result.origin.y, 640 - 44 - vc.inputToolbar.frame.size.height);
    XCTAssertEqual(result.size.width, vc.inputToolbar.frame.size.width);
    XCTAssertEqual(result.size.height, vc.inputToolbar.frame.size.height);
}

- (void)testInputToolbarFrameForNonZeroLayoutGuideAndVisible {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    CGRect frame = CGRectMake(0, 0, 480, 640);
    [vc.view setFrame:frame];
    
    [vc setupMessagesToolbar];
    [vc.messagesToolbar setSelectedIndex:0];
    
    XCTAssertNotNil(vc.messagesToolbar, "pre-condition");
    XCTAssertEqual(vc.messagesToolbar.selectedIndex, 0, "pre-condition");
    
    vc.realToolbarBottomLayoutGuideConstrant = 120;
    
    // Act
    CGRect result = [vc inputToolbarFrame];
    
    // Assert
    XCTAssertEqual(result.origin.x, 0);
    XCTAssertEqual(result.origin.y, 640 - 44 - 120 - vc.inputToolbar.frame.size.height);
    XCTAssertEqual(result.size.width, vc.inputToolbar.frame.size.width);
    XCTAssertEqual(result.size.height, vc.inputToolbar.frame.size.height);
}

- (void)testInputToolbarFrameForZeroLayoutGuideAndInvisible {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    CGRect frame = CGRectMake(0, 0, 480, 640);
    [vc.view setFrame:frame];
    
    [vc setupMessagesToolbar];
    [vc.messagesToolbar setSelectedIndex:1];
    
    XCTAssertNotNil(vc.messagesToolbar, "pre-condition");
    XCTAssertEqual(vc.messagesToolbar.selectedIndex, 1, "pre-condition");

    vc.realToolbarBottomLayoutGuideConstrant = 0;
    
    // Act
    CGRect result = [vc inputToolbarFrame];
    
    // Assert
    XCTAssertTrue(CGRectEqualToRect(result, [vc messagesToolbarFrame]));
}

- (void)testInputToolbarFrameForNonZeroLayoutGuideAndInvisible {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    CGRect frame = CGRectMake(0, 0, 480, 640);
    [vc.view setFrame:frame];
    
    [vc setupMessagesToolbar];
    [vc.messagesToolbar setSelectedIndex:1];
    
    XCTAssertNotNil(vc.messagesToolbar, "pre-condition");
    XCTAssertEqual(vc.messagesToolbar.selectedIndex, 1, "pre-condition");

    vc.realToolbarBottomLayoutGuideConstrant = 120;
    
    // Act
    CGRect result = [vc inputToolbarFrame];
    
    // Assert
    XCTAssertTrue(CGRectEqualToRect(result, [vc messagesToolbarFrame]));
}

- (void)testMessagesToolbarFrameZeroLayoutGuide {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    CGRect frame = CGRectMake(0, 0, 480, 640);
    [vc.view setFrame:frame];
    
    vc.realToolbarBottomLayoutGuideConstrant = 0;
    
    // Act
    CGRect result = [vc messagesToolbarFrame];
    
    // Assert
    CGRect expected = CGRectMake(0, 640 - kMessagesToolbarHeight, vc.inputToolbar.frame.size.width, vc.inputToolbar.frame.size.height);
    XCTAssertTrue(CGRectEqualToRect(result, expected));
}

- (void)testMessagesToolbarFrameNonZeroLayoutGuide {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    CGRect frame = CGRectMake(0, 0, 480, 640);
    [vc.view setFrame:frame];
    
    vc.realToolbarBottomLayoutGuideConstrant = 120;
    
    // Act
    CGRect result = [vc messagesToolbarFrame];
    
    // Assert
    CGRect expected = CGRectMake(0, 640 - 120 - kMessagesToolbarHeight, vc.inputToolbar.frame.size.width, vc.inputToolbar.frame.size.height);
    XCTAssertTrue(CGRectEqualToRect(result, expected));
}

- (void)testToolbarContentViewFrameZeroLayoutGuide {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    CGRect frame = CGRectMake(0, 0, 480, 640);
    [vc.view setFrame:frame];
    
    vc.realToolbarBottomLayoutGuideConstrant = 0;
    
    // Act
    CGRect result = [vc toolbarContentViewFrame];
    
    // Assert
    UIWindow *window = vc.frontWindow;
    CGFloat expectedOriginY = vc.view.frame.size.height - 0;
    CGRect expected = CGRectMake(0, expectedOriginY,
                                 vc.view.frame.size.width,
                                 vc.view.frame.size.height - expectedOriginY);
    expected = [window convertRect:expected fromView:vc.view];

    XCTAssertTrue(CGRectEqualToRect(result, expected));
}

- (void)testToolbarContentViewFrameNonZeroLayoutGuide {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    CGRect frame = CGRectMake(0, 0, 480, 640);
    [vc.view setFrame:frame];
    
    vc.realToolbarBottomLayoutGuideConstrant = 120;
    
    // Act
    CGRect result = [vc toolbarContentViewFrame];
    
    // Assert
    UIWindow *window = vc.frontWindow;
    CGFloat expectedOriginY = vc.view.frame.size.height - 120;
    CGRect expected = CGRectMake(0, expectedOriginY,
                                 vc.view.frame.size.width,
                                 vc.view.frame.size.height - expectedOriginY);
    expected = [window convertRect:expected fromView:vc.view];
    
    XCTAssertTrue(CGRectEqualToRect(result, expected));
}

- (void)testRemoveCurrentToolbarContentView {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    
    vc.toolbarContentView = [[UIView alloc] init];
    [vc.view addSubview:vc.toolbarContentView];
    
    XCTAssertNotNil(vc.toolbarContentView);
    XCTAssertNotNil(vc.toolbarContentView.superview);
    
    // Act
    [vc removeCurrentToolbarContentView];
    
    // Assert
    XCTAssertNil(vc.toolbarContentView.superview);
}

- (void)testSetupToolbarContentView {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    UIWindow *window = vc.frontWindow;
    
    UIView *viewUnderTest = [[UIView alloc] init];
    
    XCTAssertNil(viewUnderTest.superview);
    
    // Act
    [vc setupToolbarContentView:viewUnderTest];
    
    // Assert
    XCTAssertEqual(viewUnderTest.superview, window);
    XCTAssertTrue(CGRectEqualToRect(viewUnderTest.frame, vc.toolbarContentViewFrame));
    
    // Cleanup
    [viewUnderTest removeFromSuperview];
}

- (void)testUpdateCustomUI {
    // Arrange
    XCTAssertNotNil([self.mockMessagesViewController inputToolbar], "pre-condition");
    XCTAssertNotNil([self.mockMessagesViewController messagesToolbar], "pre-condition");
    
    UIView *someContentView = [[UIView alloc] init];
    [self.mockMessagesViewController setToolbarContentView:someContentView];
    
    XCTAssertNotNil([self.mockMessagesViewController toolbarContentView], "pre-condition");

    [[self.mockMessagesViewController inputToolbar] setFrame:CGRectZero];
    [[self.mockMessagesViewController messagesToolbar] setFrame:CGRectZero];
    [[self.mockMessagesViewController toolbarContentView] setFrame:CGRectZero];
    
    // Act
    [self.mockMessagesViewController updateCustomUI];
    
    // Assert
    XCTAssertTrue(CGRectEqualToRect([self.mockMessagesViewController inputToolbar].frame, [self.mockMessagesViewController inputToolbarFrame]));
    XCTAssertTrue(CGRectEqualToRect([self.mockMessagesViewController messagesToolbar].frame, [self.mockMessagesViewController messagesToolbarFrame]));
    XCTAssertTrue(CGRectEqualToRect([self.mockMessagesViewController toolbarContentView].frame, [self.mockMessagesViewController toolbarContentViewFrame]));
}

- (void)testJsq_setToolbarBottomLayoutGuideConstantZero {
    // Arrange
    OCMExpect([self.mockMessagesViewController updateCustomUI]);
    
    [self.mockMessagesViewController setRealToolbarBottomLayoutGuideConstrant:-1];
    
    XCTAssertNotEqual([self.mockMessagesViewController realToolbarBottomLayoutGuideConstrant], 0);
    
    // Act
    [self.mockMessagesViewController jsq_setToolbarBottomLayoutGuideConstant:0];
    
    // Assert
    OCMVerifyAll(self.mockMessagesViewController);
    
    XCTAssertEqual([self.mockMessagesViewController realToolbarBottomLayoutGuideConstrant], 0);
}

- (void)testJsq_setToolbarBottomLayoutGuideConstantSomeValue {
    // Arrange
    OCMExpect([self.mockMessagesViewController updateCustomUI]);
    
    [self.mockMessagesViewController setRealToolbarBottomLayoutGuideConstrant:0];
    
    XCTAssertEqual([self.mockMessagesViewController realToolbarBottomLayoutGuideConstrant], 0);
    
    // Act
    [self.mockMessagesViewController jsq_setToolbarBottomLayoutGuideConstant:120];
    
    // Assert
    OCMVerifyAll(self.mockMessagesViewController);
    
    XCTAssertEqual([self.mockMessagesViewController realToolbarBottomLayoutGuideConstrant], 120);
}

- (void)testTic1 {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    
    TTUser *recipientUser = (TTUser *)[TTUser user];
    vc.recipient = recipientUser;
    vc.isAnonymous = YES;
    vc.expirationTime = 1234;
    
    // Act
    TTTic *result = [vc ticWithMessage:nil];
    
    // Assert
    XCTAssertEqual(result.recipient, recipientUser);
    XCTAssertEqual(result.type, kTTTIcTypeAnonymous);
    XCTAssertEqual(result.timeLimit, 1234);
}

- (void)testTic2 {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    
    TTUser *recipientUser = (TTUser *)[TTUser user];
    vc.recipient = recipientUser;
    vc.isAnonymous = NO;
    vc.expirationTime = 1234;
    
    // Act
    TTTic *result = [vc ticWithMessage:nil];
    
    // Assert
    XCTAssertEqual(result.recipient, recipientUser);
    XCTAssertEqual(result.type, kTTTicTypeDefault);
    XCTAssertEqual(result.timeLimit, 1234);
}

- (void)testTic3 {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    
    TTUser *recipientUser = (TTUser *)[TTUser user];
    vc.recipient = recipientUser;
    vc.isAnonymous = NO;
    vc.expirationTime = 12;
    
    // Act
    TTTic *result = [vc ticWithMessage:nil];
    
    // Assert
    XCTAssertEqual(result.recipient, recipientUser);
    XCTAssertEqual(result.type, kTTTicTypeDefault);
    XCTAssertEqual(result.timeLimit, 12);
}

- (void)testTic4 {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    
    TTUser *recipientUser = (TTUser *)[TTUser user];
    vc.recipient = recipientUser;
    vc.isAnonymous = YES;
    vc.expirationTime = 1234;
    
    JSQMessage *someMessage = [[JSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:@"some text"];
    XCTAssertFalse(someMessage.isMediaMessage);
    
    // Act
    TTTic *result = [vc ticWithMessage:someMessage];
    
    // Assert
    XCTAssertEqual(result.recipient, recipientUser);
    XCTAssertEqual(result.type, kTTTIcTypeAnonymous);
    XCTAssertEqual(result.timeLimit, 1234);
    XCTAssertEqual(result.contentType, kTTTicContentTypeText);
    XCTAssertEqualObjects(result.content, [someMessage.text dataUsingEncoding:NSUTF8StringEncoding]);
}

- (void)testCaculateInputToolbarFrameHidden {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    BOOL hidden = YES;
    
    // Act
    CGRect result = [vc calculateInputToolbarFrameHidden:hidden];
    
    // Assert
    CGRect expected = CGRectOffset(vc.inputToolbarFrame, 0, vc.inputToolbar.frame.size.height);
    
    XCTAssertTrue(CGRectEqualToRect(result, expected));
}

- (void)testCaculateInputToolbarFrameVisible {
    // Arrange
    TTMessagesViewController *vc = [[TTMessagesViewController alloc] init];
    BOOL hidden = NO;
    
    // Act
    CGRect result = [vc calculateInputToolbarFrameHidden:hidden];
    
    // Assert
    CGRect expected = vc.inputToolbarFrame;
    
    XCTAssertTrue(CGRectEqualToRect(result, expected));
}

- (void)testMessagesToolbarWillShowItem {
    // @Comment: I spent a couple of hours trying to find a way to test the invocation of |becomeFirstResponder| on the textView using partial mocks, but was unable to find a way that didn't result in an EXC_BAD_ACCESS or a malloc_error_break exception. So for now, that isn't tested.
    
    // Arrange
    JSQMessagesInputToolbar *inputToolbar = [self.mockMessagesViewController inputToolbar];
    JSQMessagesComposerTextView *textView = inputToolbar.contentView.textView;
    
    XCTAssertNotNil(inputToolbar);
    XCTAssertNotNil(textView);
    
    TTMessagesToolbar *toolbar = [[TTMessagesToolbar alloc] init];
    [self.mockMessagesViewController setMessagesToolbar:toolbar];
    
    TTMessagesToolbarItem *item = [[TTMessagesToolbarItem alloc] init];
    
    XCTAssertFalse([item isKindOfClass:[TTTextToolbarItem class]]);
    
    OCMExpect([self.mockMessagesViewController setInputToolbarHiddenState:YES]);
    OCMExpect([self.mockMessagesViewController removeCurrentToolbarContentView]);
    OCMExpect([self.mockMessagesViewController setupToolbarContentView:item.contentView]);
    
    // Act
    [self.mockMessagesViewController messagesToolbar:toolbar willShowItem:item];
    
    // Assert
    OCMVerifyAll(self.mockMessagesViewController);
}

- (void)testMessagesToolbarWillShowItemTextToolbarItem {
    // @Comment: I spent a couple of hours trying to find a way to test the invocation of |becomeFirstResponder| on the textView using partial mocks, but was unable to find a way that didn't result in an EXC_BAD_ACCESS or a malloc_error_break exception. So for now, that isn't tested.
    
    // Arrange
    JSQMessagesInputToolbar *inputToolbar = [self.mockMessagesViewController inputToolbar];
    JSQMessagesComposerTextView *textView = inputToolbar.contentView.textView;
    
    XCTAssertNotNil(inputToolbar);
    XCTAssertNotNil(textView);
    
    TTMessagesToolbar *toolbar = [[TTMessagesToolbar alloc] init];
    [self.mockMessagesViewController setMessagesToolbar:toolbar];
    
    TTTextToolbarItem *item = [[TTTextToolbarItem alloc] init];
    
    XCTAssertTrue([item isKindOfClass:[TTTextToolbarItem class]]);
    
    OCMExpect([self.mockMessagesViewController setInputToolbarHiddenState:NO]);
    OCMExpect([self.mockMessagesViewController removeCurrentToolbarContentView]);
    OCMExpect([self.mockMessagesViewController setupToolbarContentView:item.contentView]);
    
    // Act
    [self.mockMessagesViewController messagesToolbar:toolbar willShowItem:item];
    
    // Assert
    OCMVerifyAll(self.mockMessagesViewController);
}

- (void)testMessagesToolbarWillHideItem {
    // @Note: No tests because the method body is currently empty.
}

- (void)testMessagesToolbarSetAnonymousTicTrue {
    // Arrange
    TTMessagesToolbar *toolbar = [[TTMessagesToolbar alloc] init];
    [self.mockMessagesViewController setMessagesToolbar:toolbar];
    
    // Act
    [self.mockMessagesViewController messagesToolbar:toolbar setAnonymousTic:YES];
    
    // Assert
    XCTAssertTrue([self.mockMessagesViewController isAnonymous]);
}

- (void)testMessagesToolbarSetAnonymousTicFalse {
    // Arrange
    TTMessagesToolbar *toolbar = [[TTMessagesToolbar alloc] init];
    [self.mockMessagesViewController setMessagesToolbar:toolbar];
    
    // Act
    [self.mockMessagesViewController messagesToolbar:toolbar setAnonymousTic:NO];
    
    // Assert
    XCTAssertFalse([self.mockMessagesViewController isAnonymous]);
}

- (void)testMessagesToolbarSetExpirationTimeZero {
    // Arrange
    TTMessagesToolbar *toolbar = [[TTMessagesToolbar alloc] init];
    [self.mockMessagesViewController setMessagesToolbar:toolbar];
    
    [self.mockMessagesViewController setExpirationTime:1234];
    
    // Act
    XCTAssertGreaterThan([self.mockMessagesViewController expirationTime], 0);
    [self.mockMessagesViewController messagesToolbar:toolbar setExpirationTime:0];
    
    // Assert
    XCTAssertEqual([self.mockMessagesViewController expirationTime], 0);
    
    // Act
    XCTAssertEqual([self.mockMessagesViewController expirationTime], 0);
    [self.mockMessagesViewController messagesToolbar:toolbar setExpirationTime:0];
    
    // Assert
    XCTAssertEqual([self.mockMessagesViewController expirationTime], 0);
}

- (void)testMessagesToolbarSetExpirationTimeNonZero {
    // Arrange
    TTMessagesToolbar *toolbar = [[TTMessagesToolbar alloc] init];
    [self.mockMessagesViewController setMessagesToolbar:toolbar];
    
    [self.mockMessagesViewController setExpirationTime:1];
    
    // Act
    XCTAssertGreaterThan([self.mockMessagesViewController expirationTime], 0);
    [self.mockMessagesViewController messagesToolbar:toolbar setExpirationTime:2];

    // Assert
    XCTAssertEqual([self.mockMessagesViewController expirationTime], 2);
    
    // Arrange
    [self.mockMessagesViewController setExpirationTime:0];
    
    // Act
    XCTAssertEqual([self.mockMessagesViewController expirationTime], 0);
    [self.mockMessagesViewController messagesToolbar:toolbar setExpirationTime:2];
    
    // Assert
    XCTAssertEqual([self.mockMessagesViewController expirationTime], 2);
}

- (void)testCurrentExpirationTime {
    // Arrange
    [self.mockMessagesViewController setExpirationTime:0];
    
    // Act
    NSTimeInterval result = [self.mockMessagesViewController expirationTime];
    
    // Assert
    XCTAssertEqual(result, 0);
    
    // Arrange
    [self.mockMessagesViewController setExpirationTime:43];
    
    // Act
    result = [self.mockMessagesViewController expirationTime];
    
    // Arrange
    XCTAssertEqual(result, 43);
}

@end

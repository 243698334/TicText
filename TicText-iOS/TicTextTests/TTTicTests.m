//
//  TTTicTests.m
//  TicText
//
//  Created by Kevin Yufei Chen on 3/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "TTTic.h"

@interface TTTicTests : XCTestCase

@property (nonatomic, strong) id mockTic;

@end

@implementation TTTicTests

- (void)setUp {
    [super setUp];
    self.mockTic = OCMClassMock([TTTic class]);
}

- (void)testUnreadTicWithId {
    // Arrange
    NSString *fakeTicId = @"fakeTicId";
    
    // Act
    TTTic *fakeUnreadTic = [TTTic unreadTicWithId:fakeTicId];
    
    // Assert
    XCTAssertEqual(fakeUnreadTic.objectId, fakeTicId);
    XCTAssertEqual(fakeUnreadTic.status, kTTTicStatusUnread);
}

- (void)testFetchTicInBackgroundCloudFunctionError {
    // Arrange
    NSString *fakeTicId = @"fakeTicId";
    NSDate *fakeTimestamp = [NSDate date];
    id mockPFCloud = OCMClassMock([PFCloud class]);
    OCMStub([mockPFCloud callFunctionInBackground:[OCMArg any] withParameters:[OCMArg any] block:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^callFunctionInBackgroundBlock)(id object, NSError *error) = nil;
        [invocation getArgument:&callFunctionInBackgroundBlock atIndex:4];
        NSError *fakeError = [NSError errorWithDomain:@"fakeDoman" code:0 userInfo:nil];
        callFunctionInBackgroundBlock(nil, fakeError);
    });
    
    // Act & Assert
    [TTTic fetchTicInBackgroundWithId:fakeTicId timestamp:fakeTimestamp completion:^(TTTic *fetchedTic, NSError *error) {
        XCTAssertNil(fetchedTic);
        XCTAssertNotNil(error);
    }];
}

- (void)testFetchTicInBackgroundCloudSuccess {
    // Arrange
    NSString *fakeTicId = @"fakeTicId";
    NSDate *fakeTimestamp = [NSDate date];
    TTTic *fakeTic = [TTTic objectWithoutDataWithObjectId:fakeTicId];
    id mockPFCloud = OCMClassMock([PFCloud class]);
    OCMStub([mockPFCloud callFunctionInBackground:[OCMArg any] withParameters:[OCMArg any] block:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^callFunctionInBackgroundBlock)(id object, NSError *error) = nil;
        [invocation getArgument:&callFunctionInBackgroundBlock atIndex:4];
        callFunctionInBackgroundBlock(fakeTic, nil);
    });
    
    // Act & Assert
    [TTTic fetchTicInBackgroundWithId:fakeTicId timestamp:fakeTimestamp completion:^(TTTic *fetchedTic, NSError *error) {
        XCTAssertEqualObjects(fetchedTic, fakeTic);
        XCTAssertNil(error);
    }];
}

@end

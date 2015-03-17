//
//  TTActivityTests.m
//  TicText
//
//  Created by Kevin Yufei Chen on 3/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "TTActivity.h"

@interface TTActivityTests : XCTestCase

@property (nonatomic, strong) id mockActivity;

@end

@implementation TTActivityTests

- (void)setUp {
    [super setUp];
    self.mockActivity = OCMClassMock([TTActivity class]);
}

- (void)testActivityWithTypeAndTic {
    // Arrange
    NSString *fakeType = @"fakeType";
    TTTic *fakeTic = [TTTic object];
    
    // Act
    TTActivity *fakeActivity = [TTActivity activityWithType:fakeType tic:fakeTic];
    
    // Assert
    XCTAssertEqual(fakeActivity.type, fakeType);
    XCTAssertEqual(fakeActivity.tic, fakeTic);
}

@end

//
//  TTUtilityTests.m
//  TicText
//
//  Created by Terrence K on 2/21/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "TTUtility.h"

@interface TTUtilityTests : XCTestCase

@end

@implementation TTUtilityTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testSetupPushNotifications {
    // Arrange
    id mockApplication = OCMClassMock([UIApplication class]);
    OCMStub([mockApplication sharedApplication]).andReturn(mockApplication);
    
    OCMExpect([mockApplication registerUserNotificationSettings:[OCMArg any]]);
    OCMExpect([mockApplication registerForRemoteNotifications]);
    
    // Act
    [TTUtility setupPushNotifications];
    
    // Assert
    OCMVerifyAll(mockApplication);
}

@end

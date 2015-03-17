//
//  TTExpirationDomain.swift
//  TicText
//
//  Created by Terrence K on 3/16/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit
import XCTest

class TTExpirationDomainTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSingleton() {
        let firstObject = TTExpirationDomain.sharedDomain()
        let secondObject = TTExpirationDomain.sharedDomain()
        XCTAssert(firstObject === secondObject, "Singleton is not implemented properly.")
    }
    
    func testExpirationUnitsClassAccessor() {
        let sharedArray = TTExpirationDomain.sharedDomain().expirationUnits as [TTExpirationUnit]
        let classArray = TTExpirationDomain.expirationUnits() as [TTExpirationUnit]
        XCTAssertEqual(sharedArray, classArray, "Class method expirationUnits does not return the same array as the singleton's expirationUnits property.")
    }
    
    var helperNonZeroMinValueUnits: [TTExpirationUnit] {
        get {
            // TODO: Return an array of units with nonzero minValue.
            return [TTExpirationUnit]()
        }
    }
    
    func testStringForTimeIntervalInstantly() {
        XCTAssert(false, "stub")
    }
    
    func testStringForTimeIntervalSecondsOnly() {
        XCTAssert(false, "stub")
    }
    
    func testStringForTimeIntervalMinutesOnly() {
        XCTAssert(false, "stub")
    }
    
    func testStringForTimeIntervalHoursOnly() {
        XCTAssert(false, "stub")
    }
    
    func testStringForTimeIntervalSecondsMinutes() {
        XCTAssert(false, "stub")
    }
    
    func testStringForTimeIntervalSecondsHours() {
        XCTAssert(false, "stub")
    }
    
    func testStringForTimeIntervalMinutesHours() {
        XCTAssert(false, "stub")
    }
    
    func testStringForTimeIntervalMaximumValue() {
        XCTAssert(false, "stub")
    }
    
    func testSetUnitsForExpirationInstantly() {
        XCTAssert(false, "stub")
    }
    
    func testSetUnitsForExpirationSecondsOnly() {
        XCTAssert(false, "stub")
    }
    
    func testSetUnitsForExpirationMinutesOnly() {
        XCTAssert(false, "stub")
    }
    
    func testSetUnitsForExpirationHoursOnly() {
        XCTAssert(false, "stub")
    }
    
    func testSetUnitsForExpirationSecondsMinutes() {
        XCTAssert(false, "stub")
    }
    
    func testSetUnitsForExpirationSecondsHours() {
        XCTAssert(false, "stub")
    }
    
    func testSetUnitsForExpirationMinutesHours() {
        XCTAssert(false, "stub")
    }
    
    func testSetUnitsForExpirationMaximumValue() {
        XCTAssert(false, "stub")
    }
    
    func testSetUnitsForExpirationNonzeroMinValue() {
        XCTAssert(false, "stub")
    }
    
    func testExpirationTimeFromUnitsInstantly() {
        XCTAssert(false, "stub")
    }
    
    func testExpirationTimeFromUnitsSecondsOnly() {
        XCTAssert(false, "stub")
    }
    
    func testExpirationTimeFromUnitsMinutesOnly() {
        XCTAssert(false, "stub")
    }
    
    func testExpirationTimeFromUnitsHoursOnly() {
        XCTAssert(false, "stub")
    }
    
    func testExpirationTimeFromUnitsMinutesSeconds() {
        XCTAssert(false, "stub")
    }
    
    func testExpirationTimeFromUnitsHoursSeconds() {
        XCTAssert(false, "stub")
    }
    
    func testExpirationTimeFromUnitsHoursMinutes() {
        XCTAssert(false, "stub")
    }
    
    func testExpirationTimeFromUnitsMaxValue() {
        XCTAssert(false, "stub")
    }
    
    func testExpirationTimeFromUnitsNonzeroMinValue() {
        XCTAssert(false, "stub")
    }
}

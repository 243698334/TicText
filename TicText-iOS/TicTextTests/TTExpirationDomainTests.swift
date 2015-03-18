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
    
    func testBusinessSpecifications() {
        // Arrange
        let domain = TTExpirationDomain.sharedDomain()
        
        let components = NSDateComponents()
        components.hour = 13
        components.minute = 43
        components.second = 22
        
        // Pre-Condition
        XCTAssertEqual(domain.expirationUnits.count, 3, "did you forget to update tests?")
        
        // Act
        let expirationUnits = domain.expirationUnits as [TTExpirationUnit]
        var hourRelevantData = expirationUnits[0].relevantValueFromDateComponentsBlock(components)
        var minuteRelevantData = expirationUnits[1].relevantValueFromDateComponentsBlock(components)
        var secondRelevantData = expirationUnits[2].relevantValueFromDateComponentsBlock(components)
        
        // Assert
        XCTAssertEqual(hourRelevantData, 13, "bad block")
        XCTAssertEqual(minuteRelevantData, 43, "bad block")
        XCTAssertEqual(secondRelevantData, 22, "bad block")
    }
    
    var helperNonZeroMinValueUnits: [TTExpirationUnit] {
        get {
            let firstUnit = TTExpirationUnit()
            firstUnit.singularTitle = "firstUnit"
            firstUnit.pluralTitle = "firstUnits"
            firstUnit.minValue = 8
            firstUnit.maxValue = 99
            firstUnit.minimumDisplayWidth = 3
            firstUnit.currentValue = 22
            
            let secondUnit = TTExpirationUnit()
            secondUnit.singularTitle = "secondUnit"
            secondUnit.pluralTitle = "secondUnits"
            secondUnit.minValue = 12
            secondUnit.maxValue = 119
            secondUnit.minimumDisplayWidth = 2
            secondUnit.currentValue = 16
            
            return [firstUnit, secondUnit]
        }
    }
    
    func testStringForTimeIntervalInstantly() {
        // Act
        let result = TTExpirationDomain.stringForTimeInterval(0)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire instantly.", "mismatch")
    }
    
    func testStringForTimeIntervalSecondsOnly() {
        // Act
        var result = TTExpirationDomain.stringForTimeInterval(1)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 1 second.", "mismatch")
        
        // Act
        result = TTExpirationDomain.stringForTimeInterval(43)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 43 seconds.", "mismatch")
    }
    
    func testStringForTimeIntervalMinutesOnly() {
        // Act
        var result = TTExpirationDomain.stringForTimeInterval(60 * 1)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 1 minute.", "mismatch")
        
        // Act
        result = TTExpirationDomain.stringForTimeInterval(60 * 5)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 5 minutes.", "mismatch")
    }
    
    func testStringForTimeIntervalHoursOnly() {
        // Act
        var result = TTExpirationDomain.stringForTimeInterval(60 * 60 * 1)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 1 hour.", "mismatch")
        
        // Act
        result = TTExpirationDomain.stringForTimeInterval(60 * 60 * 6)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 6 hours.", "mismatch")
    }
    
    func testStringForTimeIntervalSecondsMinutes() {
        // Act
        var result = TTExpirationDomain.stringForTimeInterval(60 * 1 + 43)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 1 minute and 43 seconds.", "mismatch")
        
        // Act
        result = TTExpirationDomain.stringForTimeInterval(60 * 43 + 1)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 43 minutes and 1 second.", "mismatch")
        
        // Act
        result = TTExpirationDomain.stringForTimeInterval(60 * 1 + 1)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 1 minute and 1 second.", "mismatch")
        
        // Act
        result = TTExpirationDomain.stringForTimeInterval(60 * 2 + 36)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 2 minutes and 36 seconds.", "mismatch")
    }
    
    func testStringForTimeIntervalSecondsHours() {
        // Act
        var result = TTExpirationDomain.stringForTimeInterval(60 * 60 * 1 + 43)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 1 hour and 43 seconds.", "mismatch")
        
        // Act
        result = TTExpirationDomain.stringForTimeInterval(60 * 60 *  43 + 1)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 43 hours and 1 second.", "mismatch")
        
        // Act
        result = TTExpirationDomain.stringForTimeInterval(60 * 60 *  1 + 1)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 1 hour and 1 second.", "mismatch")
        
        // Act
        result = TTExpirationDomain.stringForTimeInterval(60 * 60 *  2 + 36)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 2 hours and 36 seconds.", "mismatch")
    }
    
    func testStringForTimeIntervalMinutesHours() {
        // Act
        var result = TTExpirationDomain.stringForTimeInterval(60 * 60 * 1 + 60 * 43)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 1 hour and 43 minutes.", "mismatch")
        
        // Act
        result = TTExpirationDomain.stringForTimeInterval(60 * 60 *  43 + 60 * 1)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 43 hours and 1 minute.", "mismatch")
        
        // Act
        result = TTExpirationDomain.stringForTimeInterval(60 * 60 *  1 + 60 * 1)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 1 hour and 1 minute.", "mismatch")
        
        // Act
        result = TTExpirationDomain.stringForTimeInterval(60 * 60 *  2 + 60 * 36)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 2 hours and 36 minutes.", "mismatch")
    }
    
    func testStringForTimeIntervalMaximumValue() {
        // Act
        var result = TTExpirationDomain.stringForTimeInterval(60 * 60 * 23 + 60 * 59 + 59)
        
        // Assert
        XCTAssertEqual(result, "Your Tic will expire in 23 hours, 59 minutes, and 59 seconds.", "mismatch")
    }
    
    func testSetUnitsForExpirationInstantly() {
        // Arrange
        let expirationUnits = TTExpirationDomain.expirationUnits()
        
        // Act
        TTExpirationDomain.setUnits(expirationUnits, forExpirationTime: 0)
        
        // Assert
        XCTAssertEqual(expirationUnits.count, 3, "did you update the number of expiration units, but forget to add new tests?")
        XCTAssertEqual(expirationUnits[0].currentValue, 0, "mismatch")
        XCTAssertEqual(expirationUnits[1].currentValue, 0, "mismatch")
        XCTAssertEqual(expirationUnits[2].currentValue, 0, "mismatch")
    }
    
    func testSetUnitsForExpirationSecondsOnly() {
        // Arrange
        let expirationUnits = TTExpirationDomain.expirationUnits()
        
        // Act
        TTExpirationDomain.setUnits(expirationUnits, forExpirationTime: 55)
        
        // Assert
        XCTAssertEqual(expirationUnits.count, 3, "did you update the number of expiration units, but forget to add new tests?")
        XCTAssertEqual(expirationUnits[0].currentValue, 0, "mismatch")
        XCTAssertEqual(expirationUnits[1].currentValue, 0, "mismatch")
        XCTAssertEqual(expirationUnits[2].currentValue, 55, "mismatch")
    }
    
    func testSetUnitsForExpirationMinutesOnly() {
        // Arrange
        let expirationUnits = TTExpirationDomain.expirationUnits()
        
        // Act
        TTExpirationDomain.setUnits(expirationUnits, forExpirationTime: 46 * 60)
        
        // Assert
        XCTAssertEqual(expirationUnits.count, 3, "did you update the number of expiration units, but forget to add new tests?")
        XCTAssertEqual(expirationUnits[0].currentValue, 0, "mismatch")
        XCTAssertEqual(expirationUnits[1].currentValue, 46, "mismatch")
        XCTAssertEqual(expirationUnits[2].currentValue, 0, "mismatch")
    }
    
    func testSetUnitsForExpirationHoursOnly() {
        // Arrange
        let expirationUnits = TTExpirationDomain.expirationUnits()
        
        // Act
        TTExpirationDomain.setUnits(expirationUnits, forExpirationTime: 22 * 60 * 60)
        
        // Assert
        XCTAssertEqual(expirationUnits.count, 3, "did you update the number of expiration units, but forget to add new tests?")
        XCTAssertEqual(expirationUnits[0].currentValue, 22, "mismatch")
        XCTAssertEqual(expirationUnits[1].currentValue, 0, "mismatch")
        XCTAssertEqual(expirationUnits[2].currentValue, 0, "mismatch")
    }
    
    func testSetUnitsForExpirationSecondsMinutes() {
        // Arrange
        let expirationUnits = TTExpirationDomain.expirationUnits()
        
        // Act
        TTExpirationDomain.setUnits(expirationUnits, forExpirationTime: 11 * 60 + 42)
        
        // Assert
        XCTAssertEqual(expirationUnits.count, 3, "did you update the number of expiration units, but forget to add new tests?")
        XCTAssertEqual(expirationUnits[0].currentValue, 0, "mismatch")
        XCTAssertEqual(expirationUnits[1].currentValue, 11, "mismatch")
        XCTAssertEqual(expirationUnits[2].currentValue, 42, "mismatch")
    }
    
    func testSetUnitsForExpirationSecondsHours() {
        // Arrange
        let expirationUnits = TTExpirationDomain.expirationUnits()
        
        // Act
        TTExpirationDomain.setUnits(expirationUnits, forExpirationTime: 12 * 60 * 60 + 42)
        
        // Assert
        XCTAssertEqual(expirationUnits.count, 3, "did you update the number of expiration units, but forget to add new tests?")
        XCTAssertEqual(expirationUnits[0].currentValue, 12, "mismatch")
        XCTAssertEqual(expirationUnits[1].currentValue, 0, "mismatch")
        XCTAssertEqual(expirationUnits[2].currentValue, 42, "mismatch")
    }
    
    func testSetUnitsForExpirationMinutesHours() {
        // Arrange
        let expirationUnits = TTExpirationDomain.expirationUnits()
        
        // Act
        TTExpirationDomain.setUnits(expirationUnits, forExpirationTime: 23 * 60 * 60 + 11 * 60)
        
        // Assert
        XCTAssertEqual(expirationUnits.count, 3, "did you update the number of expiration units, but forget to add new tests?")
        XCTAssertEqual(expirationUnits[0].currentValue, 23, "mismatch")
        XCTAssertEqual(expirationUnits[1].currentValue, 11, "mismatch")
        XCTAssertEqual(expirationUnits[2].currentValue, 0, "mismatch")
    }
    
    func testSetUnitsForExpirationMaximumValue() {
        // Arrange
        let expirationUnits = TTExpirationDomain.expirationUnits()
        
        // Act
        TTExpirationDomain.setUnits(expirationUnits, forExpirationTime: 23 * 60 * 60 + 59 * 60 + 59)
        
        // Assert
        XCTAssertEqual(expirationUnits.count, 3, "did you update the number of expiration units, but forget to add new tests?")
        XCTAssertEqual(expirationUnits[0].currentValue, 23, "mismatch")
        XCTAssertEqual(expirationUnits[1].currentValue, 59, "mismatch")
        XCTAssertEqual(expirationUnits[2].currentValue, 59, "mismatch")
    }
    
    func testSetUnitsForExpirationNonzeroMinValue() {
        // Arrange
        let expirationUnits = helperNonZeroMinValueUnits
        
        // Act
        TTExpirationDomain.setUnits(expirationUnits, forExpirationTime: 150)
        
        // Assert
        XCTAssertEqual(expirationUnits[0].currentValue, 8, "minimum value not set properly")
        XCTAssertEqual(expirationUnits[1].currentValue, 30, "wrong leftover value")
        
        // Act
        TTExpirationDomain.setUnits(expirationUnits, forExpirationTime: 11)
        
        // Assert
        XCTAssertEqual(expirationUnits[0].currentValue, 8, "minimum value not set properly")
        XCTAssertEqual(expirationUnits[1].currentValue, 12, "minimum value not set properly")
        
        // Act
        TTExpirationDomain.setUnits(expirationUnits, forExpirationTime: 10 * 120 + 6)
        
        // Assert
        XCTAssertEqual(expirationUnits[0].currentValue, 10, "wrong significant value")
        XCTAssertEqual(expirationUnits[1].currentValue, 12, "minimum value not set properly")
        
        // Act
        TTExpirationDomain.setUnits(expirationUnits, forExpirationTime: 10 * 120 + 22)
        
        // Assert
        XCTAssertEqual(expirationUnits[0].currentValue, 10, "wrong significant value")
        XCTAssertEqual(expirationUnits[1].currentValue, 22, "wrong leftover value")
    }
    
    func testExpirationTimeFromUnitsInstantly() {
        // Arrange
        var expirationUnits = TTExpirationDomain.expirationUnits() as [TTExpirationUnit]
        XCTAssertEqual(expirationUnits.count, 3, "did you forget to add new tests for new units?")
        
        expirationUnits[0].currentValue = 0
        expirationUnits[1].currentValue = 0
        expirationUnits[2].currentValue = 0
        
        // Act
        let result = TTExpirationDomain.expirationTimeFromUnits(expirationUnits)
        
        // Assert
        XCTAssertEqual(result, 0, "invalid conversion")
    }
    
    func testExpirationTimeFromUnitsSecondsOnly() {
        // Arrange
        var expirationUnits = TTExpirationDomain.expirationUnits() as [TTExpirationUnit]
        XCTAssertEqual(expirationUnits.count, 3, "did you forget to add new tests for new units?")
        
        expirationUnits[0].currentValue = 0
        expirationUnits[1].currentValue = 0
        expirationUnits[2].currentValue = 33
        
        // Act
        let result = TTExpirationDomain.expirationTimeFromUnits(expirationUnits)
        
        // Assert
        XCTAssertEqual(result, 33, "invalid conversion")
    }
    
    func testExpirationTimeFromUnitsMinutesOnly() {
        // Arrange
        var expirationUnits = TTExpirationDomain.expirationUnits() as [TTExpirationUnit]
        XCTAssertEqual(expirationUnits.count, 3, "did you forget to add new tests for new units?")
        
        expirationUnits[0].currentValue = 0
        expirationUnits[1].currentValue = 27
        expirationUnits[2].currentValue = 0
        
        // Act
        let result = TTExpirationDomain.expirationTimeFromUnits(expirationUnits)
        
        // Assert
        XCTAssertEqual(result, 27 * 60, "invalid conversion")
    }
    
    func testExpirationTimeFromUnitsHoursOnly() {
        // Arrange
        var expirationUnits = TTExpirationDomain.expirationUnits() as [TTExpirationUnit]
        XCTAssertEqual(expirationUnits.count, 3, "did you forget to add new tests for new units?")
        
        expirationUnits[0].currentValue = 13
        expirationUnits[1].currentValue = 0
        expirationUnits[2].currentValue = 0
        
        // Act
        let result = TTExpirationDomain.expirationTimeFromUnits(expirationUnits)
        
        // Assert
        XCTAssertEqual(result, 13 * 60 * 60, "invalid conversion")
    }
    
    func testExpirationTimeFromUnitsMinutesSeconds() {
        // Arrange
        var expirationUnits = TTExpirationDomain.expirationUnits() as [TTExpirationUnit]
        XCTAssertEqual(expirationUnits.count, 3, "did you forget to add new tests for new units?")
        
        expirationUnits[0].currentValue = 0
        expirationUnits[1].currentValue = 11
        expirationUnits[2].currentValue = 56
        
        // Act
        let result = TTExpirationDomain.expirationTimeFromUnits(expirationUnits)
        
        // Assert
        XCTAssertEqual(result, 11 * 60 + 56, "invalid conversion")
    }
    
    func testExpirationTimeFromUnitsHoursSeconds() {
        // Arrange
        var expirationUnits = TTExpirationDomain.expirationUnits() as [TTExpirationUnit]
        XCTAssertEqual(expirationUnits.count, 3, "did you forget to add new tests for new units?")
        
        expirationUnits[0].currentValue = 7
        expirationUnits[1].currentValue = 0
        expirationUnits[2].currentValue = 35
        
        // Act
        let result = TTExpirationDomain.expirationTimeFromUnits(expirationUnits)
        
        // Assert
        XCTAssertEqual(result, 7 * 60 * 60 + 35, "invalid conversion")
    }
    
    func testExpirationTimeFromUnitsHoursMinutes() {
        // Arrange
        var expirationUnits = TTExpirationDomain.expirationUnits() as [TTExpirationUnit]
        XCTAssertEqual(expirationUnits.count, 3, "did you forget to add new tests for new units?")
        
        expirationUnits[0].currentValue = 7
        expirationUnits[1].currentValue = 26
        expirationUnits[2].currentValue = 0
        
        // Act
        let result = TTExpirationDomain.expirationTimeFromUnits(expirationUnits)
        
        // Assert
        XCTAssertEqual(result, 7 * 60 * 60 + 26 * 60, "invalid conversion")
    }
    
    func testExpirationTimeFromUnitsMaxValue() {
        // Arrange
        var expirationUnits = TTExpirationDomain.expirationUnits() as [TTExpirationUnit]
        XCTAssertEqual(expirationUnits.count, 3, "did you forget to add new tests for new units?")
        
        expirationUnits[0].currentValue = 23
        expirationUnits[1].currentValue = 59
        expirationUnits[2].currentValue = 59
        
        // Act
        let result = TTExpirationDomain.expirationTimeFromUnits(expirationUnits)
        
        // Assert
        XCTAssertEqual(result, 23 * 60 * 60 + 59 * 60 + 59, "invalid conversion")
    }
}

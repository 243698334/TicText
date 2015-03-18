//
//  TTExpirationUnitTests.swift
//  TicText
//
//  Created by Terrence K on 3/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit
import XCTest

class TTExpirationUnitTests: XCTestCase {

    let expirationUnit = TTExpirationUnit()
    
    override func setUp() {
        super.setUp()
        
        expirationUnit.singularTitle = "parsec"
        expirationUnit.pluralTitle = "parsecs"
        expirationUnit.minValue = 1000
        expirationUnit.maxValue = 9999
    }
    
    func testStringValueSameAsMinimumWidth() {
        // Arrange
        expirationUnit.minimumDisplayWidth = 4
        expirationUnit.minValue = 1000
        
        // Act
        let stringValue = expirationUnit.stringValueForIndex(234)
        
        // Assert
        XCTAssertEqual(stringValue, "1234", "string values do not match")
    }
    
    func testStringValueLessThanMinimumWidth() {
        // Arrange
        expirationUnit.minimumDisplayWidth = 4
        expirationUnit.minValue = 10
        expirationUnit.maxValue = 9999
        
        // Act
        let stringValue = expirationUnit.stringValueForIndex(34)
        
        // Assert
        XCTAssertEqual(stringValue, "0044", "string values do not match")
    }

    func testStringValueGreaterThanMinimumWidth() {
        // Arrange
        expirationUnit.minimumDisplayWidth = 2
        expirationUnit.minValue = 1000
        
        // Act
        let stringValue = expirationUnit.stringValueForIndex(234)
        
        // Assert
        XCTAssertEqual(stringValue, "1234", "string values do not match")
    }
}

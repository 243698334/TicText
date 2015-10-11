//
//  TTExpirationPickerControllerTests.swift
//  TicText
//
//  Created by Terrence K on 3/16/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit
import XCTest

class TTExpirationPickerControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testInitWithExpirationTimeZero() {
        // Arrange/Act
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        
        // Assert
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(0), 0, "bad selected hour")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(1), 0, "bad selected minute")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(2), 0, "bad selected second")
        
        XCTAssertEqual(pickerController.expirationTime, 0, "bad expiration time")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire instantly.", "bad previewLabel")
    }
    
    func testInitWithExpirationTimeSecondsOnly() {
        // Arrange/Act
        let pickerController = TTExpirationPickerController(expirationTime: 43)
        
        // Assert
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(0), 0, "bad selected hour")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(1), 0, "bad selected minute")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(2), 43, "bad selected second")
        
        XCTAssertEqual(pickerController.expirationTime, 43, "bad expiration time")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 43 seconds.", "bad previewLabel")
    }
    
    func testInitWithExpirationTimeMinutesOnly() {
        // Arrange/Act
        let pickerController = TTExpirationPickerController(expirationTime: 27 * 60)
        
        // Assert
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(0), 0, "bad selected hour")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(1), 27, "bad selected minute")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(2), 0, "bad selected second")
        
        XCTAssertEqual(pickerController.expirationTime, 27 * 60, "bad expiration time")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 27 minutes.", "bad previewLabel")
    }
    
    func testInitWithExpirationTimeHoursOnly() {
        // Arrange/Act
        let pickerController = TTExpirationPickerController(expirationTime: 17 * 60 * 60)
        
        // Assert
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(0), 17, "bad selected hour")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(1), 0, "bad selected minute")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(2), 0, "bad selected second")
        
        XCTAssertEqual(pickerController.expirationTime, 17 * 60 * 60, "bad expiration time")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 17 hours.", "bad previewLabel")
    }
    
    func testInitWithExpirationTimeSecondsMinutes() {
        // Arrange/Act
        let pickerController = TTExpirationPickerController(expirationTime: 45 * 60 + 49)
        
        // Assert
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(0), 0, "bad selected hour")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(1), 45, "bad selected minute")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(2), 49, "bad selected second")
        
        XCTAssertEqual(pickerController.expirationTime, 45 * 60 + 49, "bad expiration time")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 45 minutes and 49 seconds.", "bad previewLabel")
    }
    
    func testInitWithExpirationTimeHoursMinutes() {
        // Arrange/Act
        let pickerController = TTExpirationPickerController(expirationTime: 23 * 60 * 60 + 49 * 60)
        
        // Assert
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(0), 23, "bad selected hour")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(1), 49, "bad selected minute")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(2), 0, "bad selected second")
        
        XCTAssertEqual(pickerController.expirationTime, 23 * 60 * 60 + 49 * 60, "bad expiration time")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 23 hours and 49 minutes.", "bad previewLabel")
    }
    
    func testInitWithExpirationTimeHoursSeconds() {
        // Arrange/Act
        let pickerController = TTExpirationPickerController(expirationTime: 23 * 60 * 60 + 37)
        
        // Assert
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(0), 23, "bad selected hour")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(1), 0, "bad selected minute")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(2), 37, "bad selected second")
        
        XCTAssertEqual(pickerController.expirationTime, 23 * 60 * 60 + 37, "bad expiration time")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 23 hours and 37 seconds.", "bad previewLabel")
    }
    
    func testInitWithExpirationTimeMax() {
        // Arrange/Act
        let pickerController = TTExpirationPickerController(expirationTime: 23 * 60 * 60 + 59 * 60 + 59)
        
        // Assert
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(0), 23, "bad selected hour")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(1), 59, "bad selected minute")
        XCTAssertEqual(pickerController.pickerView.selectedRowInComponent(2), 59, "bad selected second")
        
        //XCTAssertEqual(pickerController.expirationTime, 23 * 60 * 60 + 59 * 60 + 59, "bad expiration time")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 23 hours, 59 minutes, and 59 seconds.", "bad previewLabel")
    }
    
    func testPresent() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        
        // Pre-Condition
        XCTAssertNil(pickerController.backgroundView, "backgroundView already exists?")
        
        // Act
        pickerController.present()
        
        // Assert
        XCTAssertNotNil(pickerController.backgroundView, "backgroundView not created")
        
        // Clean-up
        pickerController.dismiss()
    }
    
    func testSelectRowSecondsZeroOnly() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 43)
        
        // Act
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 0, inComponent: 2)
        
        // Assert
        XCTAssertEqual(pickerController.expirationTime, 0, "bad expirationTime")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire instantly.", "bad previewLabel")
    }
    
    func testSelectRowSecondsNonZeroOnly() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        
        // Act
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 43, inComponent: 2)
        
        // Assert
        XCTAssertEqual(pickerController.expirationTime, 43, "bad expirationTime")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 43 seconds.", "bad previewLabel")
    }
    
    func testSelectRowSecondsMaxValueOnly() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        
        // Act
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 59, inComponent: 2)
        
        // Assert
        XCTAssertEqual(pickerController.expirationTime, 59, "bad expirationTime")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 59 seconds.", "bad previewLabel")
    }
    
    func testSelectRowMinutesZeroOnly() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 22 * 60)
        
        // Act
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 0, inComponent: 1)
        
        // Assert
        XCTAssertEqual(pickerController.expirationTime, 0, "bad expirationTime")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire instantly.", "bad previewLabel")
    }
    
    func testSelectRowMinutesNonZeroOnly() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        
        // Act
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 22, inComponent: 1)
        
        // Assert
        XCTAssertEqual(pickerController.expirationTime, 22 * 60, "bad expirationTime")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 22 minutes.", "bad previewLabel")
    }
    
    func testSelectRowMinutesMaxValueOnly() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        
        // Act
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 22, inComponent: 1)
        
        // Assert
        XCTAssertEqual(pickerController.expirationTime, 22 * 60, "bad expirationTime")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 22 minutes.", "bad previewLabel")
    }
    
    func testSelectRowHoursZeroOnly() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 24 * 60 * 60)
        
        // Act
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 0, inComponent: 0)
        
        // Assert
        XCTAssertEqual(pickerController.expirationTime, 0, "bad expirationTime")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire instantly.", "bad previewLabel")
    }
    
    func testSelectRowHoursNonZeroOnly() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        
        // Act
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 17, inComponent: 0)
        
        // Assert
        XCTAssertEqual(pickerController.expirationTime, 17 * 60 * 60, "bad expirationTime")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 17 hours.", "bad previewLabel")
    }
    
    func testSelectRowHoursMaxValueOnly() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        
        // Act
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 23, inComponent: 0)
        
        // Assert
        XCTAssertEqual(pickerController.expirationTime, 23 * 60 * 60, "bad expirationTime")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 23 hours.", "bad previewLabel")
    }
    
    func testSelectRowMinutesSecondsComposite() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        
        // Act
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 17, inComponent: 1)
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 43, inComponent: 2)
        
        // Assert
        XCTAssertEqual(pickerController.expirationTime, 17 * 60 + 43, "bad expirationTime")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 17 minutes and 43 seconds.", "bad previewLabel")
    }
    
    func testSelectRowHoursSecondsComposite() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        
        // Act
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 6, inComponent: 0)
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 27, inComponent: 2)
        
        // Assert
        XCTAssertEqual(pickerController.expirationTime, 6 * 60 * 60 + 27, "bad expirationTime")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 6 hours and 27 seconds.", "bad previewLabel")
    }
    
    func testSelectRowHoursMinutesComposite() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        
        // Act
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 5, inComponent: 0)
        pickerController.pickerView(pickerController.pickerView, didSelectRow: 22, inComponent: 1)
        
        // Assert
        XCTAssertEqual(pickerController.expirationTime, 5 * 60 * 60 + 22 * 60, "bad expirationTime")
        XCTAssertEqual(pickerController.previewLabel.text!, "Your Tic will expire in 5 hours and 22 minutes.", "bad previewLabel")
    }
    
    func testNumberOfComponentsZero() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        
        // Act
        pickerController.expirationUnits = []
        
        // Assert
        XCTAssertEqual(pickerController.numberOfComponentsInPickerView(pickerController.pickerView), 0, "non-zero # of components")
    }
    
    func testNumberOfComponentsThree() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        
        // Act
        pickerController.expirationUnits = [TTExpirationUnit(), TTExpirationUnit(), TTExpirationUnit()]
        
        // Assert
        XCTAssertEqual(pickerController.numberOfComponentsInPickerView(pickerController.pickerView), 3, "wrong # of components")
    }
    
    func testNumberOfRowsZero() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        let zeroRowUnit = TTExpirationUnit()
        
        zeroRowUnit.singularTitle = "zeroRowUnit"
        zeroRowUnit.pluralTitle = "zeroRowUnits"
        zeroRowUnit.minValue = 0
        zeroRowUnit.maxValue = -1
        zeroRowUnit.minimumDisplayWidth = 2
        zeroRowUnit.currentValue = 0
        
        // Act
        pickerController.expirationUnits = [zeroRowUnit]
        
        // Assert
        XCTAssertEqual(pickerController.pickerView(pickerController.pickerView, numberOfRowsInComponent: 0), 0, "wrong # of components")
    }
    
    func testNumberOfRowsSameMinValueMaxValue() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        let sameMinMaxValueUnit = TTExpirationUnit()
        
        sameMinMaxValueUnit.singularTitle = "zeroRowUnit"
        sameMinMaxValueUnit.pluralTitle = "zeroRowUnits"
        sameMinMaxValueUnit.minValue = 23
        sameMinMaxValueUnit.maxValue = 23
        sameMinMaxValueUnit.minimumDisplayWidth = 2
        sameMinMaxValueUnit.currentValue = 0
        
        // Act
        pickerController.expirationUnits = [sameMinMaxValueUnit]
        
        // Assert
        XCTAssertEqual(pickerController.pickerView(pickerController.pickerView, numberOfRowsInComponent: 0), 1, "wrong # of components")
    }
    
    func testNumberOfRowsZeroMinValue() {
        // Arrange
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        let zeroMinValueUnit = TTExpirationUnit()
        
        zeroMinValueUnit.singularTitle = "zeroRowUnit"
        zeroMinValueUnit.pluralTitle = "zeroRowUnits"
        zeroMinValueUnit.minValue = 0
        zeroMinValueUnit.maxValue = 33
        zeroMinValueUnit.minimumDisplayWidth = 2
        zeroMinValueUnit.currentValue = 0
        
        // Act
        pickerController.expirationUnits = [zeroMinValueUnit]
        
        // Assert
        XCTAssertEqual(pickerController.pickerView(pickerController.pickerView, numberOfRowsInComponent: 0), 34, "wrong # of components")
    }
    
    func testNumberOfRowsNonZeroMinValue() {
        let pickerController = TTExpirationPickerController(expirationTime: 0)
        let nonZeroMinValueUnit = TTExpirationUnit()
        
        nonZeroMinValueUnit.singularTitle = "zeroRowUnit"
        nonZeroMinValueUnit.pluralTitle = "zeroRowUnits"
        nonZeroMinValueUnit.minValue = 21
        nonZeroMinValueUnit.maxValue = 44
        nonZeroMinValueUnit.minimumDisplayWidth = 2
        nonZeroMinValueUnit.currentValue = 0
        
        // Act
        pickerController.expirationUnits = [nonZeroMinValueUnit]
        
        // Assert
        XCTAssertEqual(pickerController.pickerView(pickerController.pickerView, numberOfRowsInComponent: 0), 24, "wrong # of components")
    }
}

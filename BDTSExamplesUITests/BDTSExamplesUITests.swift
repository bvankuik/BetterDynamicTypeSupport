//
//  BDTSExamplesUITests.swift
//  BDTSExamplesUITests
//
//  Created by Bart van Kuik on 03/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import XCTest
import BetterDynamicTypeSupport

class BDTSExamplesUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testDefaultStepper() {
        let app = XCUIApplication()
        app.buttons["Test stepper"].tap()
        
        let resultTextField = app.textFields["Result of stepper"]
        let value: String = resultTextField.value as! String
        XCTAssert(value == "0.0")

//        let stepperIncrementElement = app/*@START_MENU_TOKEN@*/.otherElements["Stepper increment"]/*[[".otherElements[\"Stepper\"].otherElements[\"Stepper increment\"]",".otherElements[\"Stepper increment\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        stepperIncrementElement.tap()
//        stepperIncrementElement.tap()
//        stepperIncrementElement.tap()
//        stepperIncrementElement.tap()
//        stepperIncrementElement.tap()
        
    }

}

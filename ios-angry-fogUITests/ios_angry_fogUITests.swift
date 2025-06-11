//
//  ios_angry_fogUITests.swift
//  ios-angry-fogUITests
//
//  Created by Mariia Glushenkova on 2.6.2025.
//

import XCTest

final class ios_angry_fogUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    // 🔧 Generic helper to test a button inside a tab
        func navigateAndTapButton(tabName: String, buttonId: String, timeout: TimeInterval = 2) {
            let app = XCUIApplication()
            app.launch()

            // Navigate to specific tab
            let tabButton = app.tabBars.buttons[tabName]
            XCTAssertTrue(tabButton.waitForExistence(timeout: timeout), "Tab \(tabName) should exist")
            tabButton.tap()

            // Find and tap the button
            let button = app.buttons[buttonId]
            XCTAssertTrue(button.waitForExistence(timeout: timeout), "Button \(buttonId) should exist")
            XCTAssertTrue(button.isHittable, "Button \(buttonId) should be tappable")
            button.tap()
        }
    
    // Specific test using the helper
      @MainActor
      func testShowCountrySelectorButtonIsAccessibleAndTappable() throws {
          navigateAndTapButton(tabName: "Travel Mode", buttonId: "showCountrySelector")
      }
    // Specific test using the helper
      @MainActor
      func testShowReportSelectorButtonIsAccessibleAndTappable() throws {
          navigateAndTapButton(tabName: "Report", buttonId: "SendReport")
      }

}

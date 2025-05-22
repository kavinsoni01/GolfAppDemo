//
//  GolfAppDemoUITests.swift
//  GolfAppDemoUITests
//
//  Created by Kavin's Macbook on 22/05/25.
//

import XCTest

final class GolfAppDemoUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    ///  Test if the search bar is visible and can accept input
    func testSearchBarExistsAndAcceptsInput() {
        let searchBar = app.searchFields["GolfSearchBar"]
        XCTAssertTrue(searchBar.exists)
        
        searchBar.tap()
        searchBar.typeText("Texas")
        
        XCTAssertEqual(searchBar.value as? String, "Texas")
    }

    ///  Test loader appears on performing a search
    func testLoaderAppearsDuringSearch() {
        let searchBar = app.searchFields["GolfSearchBar"]
        searchBar.tap()
        searchBar.typeText("Nevada\n")
        
        let loader = app.activityIndicators["GlobalLoader"]
        XCTAssertTrue(loader.waitForExistence(timeout: 3))
    }

    ///  Test empty state UI shows when there are no results
    func testEmptyStateAppears() {
        let searchBar = app.searchFields["GolfSearchBar"]
        searchBar.tap()
        searchBar.typeText("zzzzz\n") // Assuming no such result

        let emptyStateTitle = app.staticTexts["No Results Found"]
        XCTAssertTrue(emptyStateTitle.waitForExistence(timeout: 5))
    }

    ///  Test list shows when results are returned
    func testTableShowsResults() {
        let searchBar = app.searchFields["GolfSearchBar"]
        searchBar.tap()
        searchBar.typeText("Florida\n")

        let cell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
}

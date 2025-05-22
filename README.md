# GolfAppDemo

GolfAppDemo Developer Guide
Table of Contents
	1	Project Overview
	2	Architecture
	3	Core Features
	4	How to Run
	5	Network Or APIs 
	6	UI Components
	7	Utilities Classes
	8	Environment & Dependencies

Project Overview
GolfAppDemo is an iOS app that allows users to search and browse a list of golf courses via an external API.

 Architecture
	•	Pattern: MVVM (Model-View-ViewModel)
	•	Networking: URLSession with a base service and endpoint builder
	•	Error Handling: Swift Result<T, Error> pattern
	•	Loader/UI State: Custom singleton Loader class and utility extensions
	•	UI Testing: XCTest and Swift Testing framework (not completed) 

 Core Features
	•	 Search golf courses using search_query
	•	 Realtime network connectivity detection using NWPathMonitor
	•	 Custom Loader for blocking UI feedback
	•	 Common UIAlertController wrapper for showing alerts
	•	 Empty states for UITableView when there's no data

 How to Run
	1	Open GolfAppDemo.xcodeproj in Xcode 15+
	2	Select iPhone 15 or similar simulator
	3	Press Cmd + R to run the app

 Network Or APIs 
BaseAPIService.swift:
	•	Manages all GET calls
	•	Adds Authorization headers
	•	Converts response using Codable
	•	Logs cURL for debugging
ApiService.swift:
	•	Provides callGetGolfCourseList(searchText:completion:)
	•	Internally uses BaseAPIService.get(...)
apiService.callGetGolfCourseList(searchText: "New York") { result in
    switch result {
    case .success(let data):
        print(data)
    case .failure(let error):
        print("Error: \(error)")
    }
}

 UI Components
UIViewController+showAlert.swift
Reusable alert method:
showAlert(
  title: "Error",
  message: "Network not available",
  type: .alert,
  actions: [("Retry", .default, { self.retryCall() })],
  cancelTitle: "Cancel"
)
UITableView+EmptyState.swift
Shows empty view with image, title, and message.
tableView.setEmptyView(
  title: "No Courses Found",
  message: "Try another search.",
  image: UIImage(named: "empty")
)
UISearchBar+DoneButton.swift
Adds “Done” button to keyboard in UISearchBar.
searchBar.addDoneButtonOnKeyboard()

 Utilities
Loader.swift
Loader.shared.showLoader()
Loader.shared.hideLoader()
Blocks UI with semi-transparent overlay and spinner.
NetworkMonitor.swift
if NetworkMonitor.shared.isConnected {
  // Continue
} else {
  // Show no internet alert
}

 Testing
UI Tests (XCTest)
Located in GolfAppDemoUITests.swift:
func testExample() throws {
    let app = XCUIApplication()
    app.launch()
    // Interact with UI
}
Unit Tests (Swift Testing)
Located in GolfAppDemoUnitTests.swift:
@Test func testEndpointGeneration() throws {
    let service = BaseAPIService()
    let url = service.endpoint("courses")
    #expect(url == "https://api.golfcourseapi.com/v1/courses")
}

 Environment & Dependencies
	•	 iOS 15+
	•	Swift 5.9
	•	 No third-party libraries (vanilla UIKit + Foundation)
	•	 XCTest + Swift Testing for Unit/UI tests

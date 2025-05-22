//
//  GolfCourseListViewModel.swift
//  GolfAppDemo
//
//  Created by Kavin's Macbook on 22/05/25.
//

import UIKit
import Foundation

// MARK: - Protocol for View Updates
protocol GolfCourseListProtocol: AnyObject {
    func getGolfCourseAPIFail(withMessage message: String)
    func getGolfCourseAPISuccess()
}

// MARK: - ViewModel for Golf Course List
class GolfCourseListViewModel: NSObject {
    
    // MARK: - Public Properties
    var arrGolfCourseList: [Course]? // Data source for the View
    var arrAllCourseList: [Course]? // for Local data source for the View

    // MARK: - Private Properties
    private var apiService: ApiServiceProtocol
    private weak var delegate: GolfCourseListProtocol?
    
    // MARK: - Initializer
    init(delegate: GolfCourseListProtocol, apiService: ApiServiceProtocol = ApiService()) {
        self.delegate = delegate
        self.apiService = apiService
    }
    
    func loadPrefrenceSearch() -> Void {
        arrAllCourseList = []
        // Check local storage before making api call
        let cachedCourses = LocalCacheService.getRecentResults()
        if !cachedCourses.isEmpty {
            self.arrAllCourseList = cachedCourses
        }
    
    }
    // MARK: - Public API Call Method
    func callGetGolfCourseListAPI(searchText:String) {

        // Show loader
        Loader.shared.showLoader()
        
        // Perform API call using service
        apiService.callGetGolfCourseList(searchText: searchText) { [weak self] result in
            guard let self = self else { return }
            Loader.shared.hideLoader()
            
            switch result {
            case .success(let response):
                // Handle error from API payload
                if let errorMessage = response.error {
                    self.delegate?.getGolfCourseAPIFail(withMessage: errorMessage)
                } else if let courses = response.courses {
                    
                    // Save to local cache & notify view on success
                    self.arrGolfCourseList = courses
                    LocalCacheService.saveRecentResults(courses)
                    self.delegate?.getGolfCourseAPISuccess()
                } else {
                    self.delegate?.getGolfCourseAPIFail(withMessage: "No courses found.")
                }
                
            case .failure(let error):
                //  Handle networking error
                self.delegate?.getGolfCourseAPIFail(withMessage: error.localizedDescription)
            }
        }
    }
}

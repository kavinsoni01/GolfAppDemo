//
//  ApiService.swift
//  GolfAppDemo
//
//  Created by Kavin's Macbook on 22/05/25.
//

import UIKit
import Network

// MARK: - Protocol to abstract API service
protocol ApiServiceProtocol: AnyObject {
    func callGetGolfCourseList(searchText: String, completion: @escaping (Result<GolfCourse, Error>) -> Void)
}

// MARK: - Concrete implementation of API Service
class ApiService: BaseAPIService, ApiServiceProtocol {
    
    override init() {
        super.init()
    }
    
    /// Calls the golf course list API with a search query
    /// - Parameters:
    ///   - searchText: Text used to search for golf courses
    ///   - completion: Result callback with GolfCourse or Error
    func callGetGolfCourseList(searchText: String, completion: @escaping (Result<GolfCourse, Error>) -> Void) {
        // Ensure query is properly percent encoded for safe URLs
        guard let encodedQuery = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid search query."])))
            return
        }

        // Construct full URL with query
        let urlString = "\(endpoint(EndPoint.golfCoursesList.rawValue))?search_query=\(encodedQuery)"
        
        // Perform GET request
        self.get(url: urlString, expectedModel: GolfCourse.self, completion: completion)
    }

    // MARK: - API Endpoint Enum
    private enum EndPoint: String {
        case golfCoursesList = "search" // endpoint for search
    }
}


// MARK: - Singleton for monitoring network connectivity
class NetworkMonitor {
    
    // Shared instance for global access
    static let shared = NetworkMonitor()
    
    // Private properties
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    // Publicly readable network status
    private(set) var isConnected: Bool = true
    
    // MARK: - Init
    private init() {
        startMonitoring()
    }

    /// Starts monitoring the network path
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}

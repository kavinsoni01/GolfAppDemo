//
//  GolfAppDemoUnitTests.swift
//  GolfAppDemoUnitTests
//
//  Created by Kavin's Macbook on 22/05/25.
//

import Testing

@testable import GolfAppDemo

struct GolfAppDemoUnitTests {

    @Test
    func testEndpointGeneration() throws {
        let service = BaseAPIService()
        let fullURL = service.endpoint("courses")
        
        #expect(fullURL == "https://api.golfcourseapi.com/v1/courses")
    }
}

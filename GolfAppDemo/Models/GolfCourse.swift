//
//  GolfCourse.swift
//  GolfAppDemo
//
//  Created by Kavin's Macbook on 21/05/25.
//

import UIKit

struct GolfCourse: Codable {
    let courses: [Course]?
    let error: String?
}

struct Course: Codable {
    let id: Int?
    let club_name: String?
    let course_name: String?
    let location: Location?
    let tees: Tees?
    let rating: Double? // its static and random number set for mock purpose
    
    enum CodingKeys: String, CodingKey {
           case id, club_name, course_name, location, tees
       }

       // Custom decoding to inject random rating
       init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           id = try container.decodeIfPresent(Int.self, forKey: .id)
           club_name = try container.decodeIfPresent(String.self, forKey: .club_name)
           course_name = try container.decodeIfPresent(String.self, forKey: .course_name)
           location = try container.decodeIfPresent(Location.self, forKey: .location)
           tees = try container.decodeIfPresent(Tees.self, forKey: .tees)
           
           // Generate static mock rating between 1.0 and 5.0
           rating = Double.random(in: 1.0...5.0)
       }
    
    
    struct Location: Codable {
        let address: String?
        let city: String?
        let state: String?
        let country: String?
        let latitude: Double?
        let longitude: Double?
    }
    
    struct Tees: Codable {
        let female: [TeeInfo]?
        let male: [TeeInfo]?
    }
    
    struct TeeInfo: Codable {
        let tee_name: String?
        let course_rating: Double?
        let slope_rating: Int?
        let bogey_rating: Double?
        let total_yards: Int?
        let total_meters: Int?
        let number_of_holes: Int?
        let par_total: Int?
        let front_course_rating: Double?
        let front_slope_rating: Int?
        let front_bogey_rating: Double?
        let back_course_rating: Double?
        let back_slope_rating: Int?
        let back_bogey_rating: Double?
        let holes: [Hole]?
    }
    
    struct Hole: Codable {
        let par: Int?
        let yardage: Int?
        let handicap: Int?
    }
}

class LocalCacheService {
    private static let goalCoursesKey = "goalCourses"

    static func saveRecentResults(_ newCourses: [Course]) {
        let defaults = UserDefaults.standard
           let key = goalCoursesKey

           // Retrieve existing courses
           var existingCourses: [Course] = []
           if let data = defaults.data(forKey: key),
              let decodedCourses = try? JSONDecoder().decode([Course].self, from: data) {
               existingCourses = decodedCourses
           }

           // Create a set of existing course IDs for quick lookup
           let existingCourseIDs = Set(existingCourses.compactMap { $0.id })

           // Filter new courses to include only those not already in existingCourses
           let uniqueNewCourses = newCourses.filter { course in
               guard let id = course.id else { return false }
               return !existingCourseIDs.contains(id)
           }

           // Append unique new courses
           existingCourses.append(contentsOf: uniqueNewCourses)

           // Save updated courses
           if let updatedData = try? JSONEncoder().encode(existingCourses) {
               defaults.set(updatedData, forKey: key)
           }
    }
    

    static func getRecentResults() -> [Course] {
        let defaults = UserDefaults.standard
        let key = goalCoursesKey

        if let data = defaults.data(forKey: key),
           let courses = try? JSONDecoder().decode([Course].self, from: data) {
            return courses
        }
        return []
    }
    
    static func clearRecentResults() {
        UserDefaults.standard.removeObject(forKey: goalCoursesKey)
    }
    
}

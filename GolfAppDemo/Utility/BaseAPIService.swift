//
//  BaseAPIService.swift
//  GolfAppDemo
//
//  Created by Kavin's Macbook on 22/05/25.
//

import UIKit
import Foundation

// MARK: - Custom Error Types for API Service
enum APIServiceError: Error {
    case invalidURL
    case blankResponse
}

// MARK: - Base API Service Handling Common API Logic
class BaseAPIService: NSObject {
    
    // MARK: - Constants
    private let baseURL: String = "https://api.golfcourseapi.com/"
    private let apiVersion: String = "v1"
    private let authKey: String = "Key R2MFBWXPIG2MOW6Q6KAWPSQNJQ"
    
    /// Combines base URL, version, and endpoint to return a full URL string
    func endpoint(_ endpoint: String) -> String {
        return "\(baseURL)\(apiVersion)/\(endpoint)"
    }
    
    /// Generic GET request handler
    /// - Parameters:
    ///   - url: Full URL string for the GET request
    ///   - expectedModel: Expected Codable model type
    ///   - completion: Completion handler with Result
    func get<T: Decodable>(url: String, expectedModel: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let url = URL(string: url) else {
            completion(.failure(APIServiceError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(authKey, forHTTPHeaderField: "Authorization")
        
        // Print cURL for debugging or testing in Postman/terminal
        print("cURL -- \(request.cURL())")
        
        let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        
        session.dataTask(with: request) { data, _, error in
            
            // Handle network error
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // Handle blank data response
            guard let data = data else {
                completion(.failure(APIServiceError.blankResponse))
                return
            }
            
            do {
                // Optional: print raw JSON dictionary for debugging
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print("Raw JSON Response: \(json)")
                }
                
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(expectedModel.self, from: data)
                completion(.success(decodedResponse))
                
            } catch let decodingError {
                print("Decoding Error: \(decodingError.localizedDescription)")
                completion(.failure(decodingError))
            }
        }.resume()
    }
}

// MARK: - SSL Pinning via URLSessionDelegate
extension BaseAPIService: URLSessionDelegate {
    
    /// Handles SSL trust for custom/trusted domains
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Add any trusted hosts for SSL pinning
        let trustedHostArray = ["api.golfcourseapi.com", "https://api.golfcourseapi.com"]
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if trustedHostArray.contains(challenge.protectionSpace.host),
               let serverTrust = challenge.protectionSpace.serverTrust {
                
                let credential = URLCredential(trust: serverTrust)
                challenge.sender?.use(credential, for: challenge)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

// MARK: - URLRequest Extension for cURL Generation
public extension URLRequest {
    
    /// Returns a cURL string representation of the request (for debugging)
    func cURL() -> String {
        let cURL = "curl -f"
        let method = "-X \(self.httpMethod ?? "GET")"
        let url = self.url.map { "--url '\($0.absoluteString)'" }
        
        let headers = self.allHTTPHeaderFields?
            .map { "-H '\($0): \($1)'" }
            .joined(separator: " ")
        
        let body: String?
        if let httpBody = self.httpBody, !httpBody.isEmpty {
            if let bodyString = String(data: httpBody, encoding: .utf8) {
                let escaped = bodyString.replacingOccurrences(of: "'", with: "'\\''")
                body = "--data '\(escaped)'"
            } else {
                let hexString = httpBody.map { String(format: "%02X", $0) }.joined()
                body = #"--data "$(echo '\#(hexString)' | xxd -p -r)""#
            }
        } else {
            body = nil
        }
        
        return [cURL, method, url, headers, body]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}

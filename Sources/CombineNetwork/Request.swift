//
//  Request.swift
//  Countries
//
//  Created by Dushant  Singh on 2021-09-30.
//

import Foundation

/// Defines when the time out occurs if service is down or slow.
fileprivate let requestTimeoutInterval: TimeInterval = 30

/// A typealias for better readability of headers
typealias HTTPHeaders = [String: String]

/// Defines all the HTTP method that are available
/// for network processing.
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum ContentType {
    case json, xml
    case other(code: String)
    
    var value: String {
        switch self {
        case .json: return "application/json"
        case .xml: return "application/xml"
        case .other(let code): return code
        }
    }
}

/// Defines the structure of a network request
struct Request {
    let scheme: URLScheme = .https
    let host: URLHost = .default
    let endpoint: Endpoint
    let method: HTTPMethod = .get
    let contentType: ContentType = .json
    let body: Data? = nil
    let headers: HTTPHeaders? = nil
    
    
    /// Creates a new URLRequest from the endpoint and other information
    /// stored in this request
    func urlRequest() throws -> URLRequest {
        let url = try endpoint.url(with: scheme, host: host)
        var urlRequest = URLRequest(
            url: url,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: requestTimeoutInterval
        )
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        urlRequest.allHTTPHeaderFields = headers
        return urlRequest
    }
}

//
//  File.swift
//  
//
//  Created by Dushant  Singh on 2021-10-04.
//

import Foundation

/// A typealias for better readability of headers
public typealias HTTPHeaders = [String: String]

/// Defines when the time out occurs if service is down or slow.
public let requestTimeoutInterval: TimeInterval = 30

/// Defines all the HTTP method that are available
/// for network processing.
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum ContentType {
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

public protocol RequestTask {
    var scheme: URLScheme { get }
    var host: URLHost { get }
    var endpoint: Endpoint { get }
    var method: HTTPMethod { get }
    var contentType: ContentType { get }
    var body: Data? { get }
    var headers: HTTPHeaders? { get }
}

extension RequestTask {
    
    /// Creates a new URLRequest from the endpoint and other information
    /// stored in this request
    /// - Parameters:
    ///  - cachePolicy: URLRequest.CachePolicy, defining the cache policy for HTTP requests. Default: ReturnCacheDataElseLoad
    ///  - timeout: TimeInterval defining how long it should take until a non-repsonse HTTP request should timeout. Default: 30s
    func urlRequest(
        cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad,
        timeout: TimeInterval = requestTimeoutInterval
    ) throws -> URLRequest {
        let url = try endpoint.url(with: scheme, host: host)
        var urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        urlRequest.allHTTPHeaderFields = headers
        return urlRequest
    }
}

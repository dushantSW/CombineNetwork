//
//  Endpoint.swift
//  Countries
//
//  Created by Dushant  Singh on 2021-09-30.
//

import Foundation

public struct Endpoint {
    let path: String
    let queryParameters: [URLQueryItem]
    
    public init(path: String, queryParameters: [URLQueryItem] = []) {
        self.path = path
        self.queryParameters = queryParameters
    }
}

// MARK: - Endpoint + URL
extension Endpoint {
    func url(with scheme: URLScheme, host: URLHost) throws -> URL {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = host.rawValue
        components.path = path
        
        if !queryParameters.isEmpty {
            components.queryItems = queryParameters
        }
        
        guard let url = components.url else {
            throw RequestError.invalidRequest
        }
        
        return url
    }
}

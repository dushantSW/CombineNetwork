//
//  Request.swift
//  Countries
//
//  Created by Dushant  Singh on 2021-09-30.
//

import Foundation

/// Defines the structure of a network request
struct Request: RequestTask {
    let scheme: URLScheme = .https
    let host: URLHost = .default
    let endpoint: Endpoint
    let method: HTTPMethod = .get
    let contentType: ContentType = .json
    let body: Data? = nil
    let headers: HTTPHeaders? = nil
}

//
//  File.swift
//  
//
//  Created by Dushant  Singh on 2021-10-04.
//

import Foundation
import CombineNetwork

typealias RequestHandlingBlock = (data: Data?, response: HTTPURLResponse?)

/// Mocking the URLProtocol by returning the required information
/// via requestHandler.
///
/// Note that protocol ignores the endpoint instead will return whatever data exists
/// in the requestHandler.
class MockURLProtocol: URLProtocol {
    
    /// Static property for defining the information that should be sent when mocking an endpoint.
    static var requestHandler: RequestHandlingBlock?

    // MARK: - Overriden functions
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let requestHandler = MockURLProtocol.requestHandler else {
            return assertionFailure("No request handling block was provided")
        }
        
        guard let client = self.client else {
            return assertionFailure("No client was found")
        }
        
        if let response = requestHandler.response {
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        } else {
            client.urlProtocol(self, didFailWithError: RequestError.invalidRequest)
        }
        
        if let data = requestHandler.data {
            client.urlProtocol(self, didLoad: data)
        }
        
        client.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

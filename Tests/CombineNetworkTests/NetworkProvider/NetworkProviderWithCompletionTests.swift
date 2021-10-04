//
//  File.swift
//  
//
//  Created by Dushant  Singh on 2021-10-04.
//

import Foundation
import XCTest
@testable import CombineNetwork

class NetworkProviderWithCompletionTests: XCTestCase {
    
    private var networkClient = NetworkClient.shared
    
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }()
    
    override func setUpWithError() throws {
        networkClient = NetworkClient(urlSession: urlSession)
    }
    
    func testThatRequestWithInvalidURLThrowsError() {
        let endpoint = Endpoint(path: "?=")
        let url = try? endpoint.url(with: .https, host: .default)
        XCTAssertNil(url)
    }
    
    func testThatRequestToNotFoundEndpointThrowsError() {
        // GIVEN
        let expectation = expectation(description: "Expecting a HTTP 404 error")
        let endpoint = Endpoint(path: "/not-found-endpoint")
        
        guard let url = try? endpoint.url(with: .https, host: .default) else {
            return XCTFail("Invalid endpoint")
        }
        
        let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)
        MockURLProtocol.requestHandler = (Data(invalidJSON.utf8), response)
        
        // WHEN
        var result: Result<TestDecodable, Error>?
        networkClient.performRequest(Request(host: .default, endpoint: endpoint)) { (completionResult: Result<TestDecodable, Error>) in
            result = completionResult
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // THEN
        XCTAssertNotNil(result)
        XCTAssertNotNil(result!.error)
        XCTAssertEqual(result!.error as! NetworkError, .notFound)
    }
    
    func testThatRequestReturnsDecodableError() {
        // GIVEN
        let expectation = expectation(description: "Expecting a decodable error")
        let endpoint = Endpoint(path: "/good-url-bad-json")
        
        guard let url = try? endpoint.url(with: .https, host: .default) else {
            return XCTFail("Invalid endpoint")
        }
        
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.requestHandler = (Data(invalidJSON.utf8), response)
        
        // WHEN
        var result: Result<TestDecodable, Error>?
        networkClient.performRequest(Request(host: .default, endpoint: endpoint)) { (completionResult: Result<TestDecodable, Error>) in
            result = completionResult
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // THEN
        XCTAssertNotNil(result)
        XCTAssertNotNil(result!.error)
        XCTAssertEqual(result!.error as! NetworkError, .decodingError)
    }
    
    func testThatRequestReturnsVoidSuccessfully() {
        // GIVEN
        let expectation = expectation(description: "Expecting a successful response")
        let endpoint = Endpoint(path: "/good-url")
        
        guard let url = try? endpoint.url(with: .https, host: .default) else { return XCTFail("Invalid endpoint") }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        MockURLProtocol.requestHandler = (Data(validJSON.utf8), response)
        
        // WHEN
        var result: Result<TestDecodable, Error>?
        networkClient.performRequest(Request(host: .default, endpoint: endpoint)) { (completionResult: Result<TestDecodable, Error>) in
            result = completionResult
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // THEN
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.isSuccess)
        
        let decodable = try? result?.get()
        XCTAssertNotNil(decodable)
        XCTAssertEqual(decodable!.firstName, "Dushant")
        XCTAssertEqual(decodable!.lastName, "Singh")
    }
}

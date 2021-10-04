//
//  File.swift
//  
//
//  Created by Dushant  Singh on 2021-10-04.
//

import Foundation
import XCTest
@testable import CombineNetwork

@available(OSX 12.0, iOS 15, tvOS 15.0, watchOS 8.0, *)
class NetworkProviderWithAsyncTests: XCTestCase {
    
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
    
    func testThatRequestToNotFoundEndpointThrowsError() async {
        // GIVEN
        let endpoint = Endpoint(path: "/not-found-endpoint")
        guard let url = try? endpoint.url(with: .https, host: .default) else { return XCTFail("Invalid endpoint") }
        let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)
        MockURLProtocol.requestHandler = (Data(invalidJSON.utf8), response)
        
        // WHEN
        let result: Result<TestDecodable, Error> = await networkClient.performRequest(Request(endpoint: endpoint))
        
        // THEN
        XCTAssertNotNil(result.error)
        XCTAssertEqual(result.error as! NetworkError, .notFound)
    }
    
    func testThatRequestReturnsDecodableError() async {
        // GIVEN
        let endpoint = Endpoint(path: "/good-url-bad-json")
        guard let url = try? endpoint.url(with: .https, host: .default) else { return XCTFail("Invalid endpoint") }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.requestHandler = (Data(invalidJSON.utf8), response)
        
        // WHEN
        let result: Result<TestDecodable, Error> = await networkClient.performRequest(Request(endpoint: endpoint))
        
        // THEN
        XCTAssertNotNil(result.error)
        XCTAssertEqual(result.error as! NetworkError, .decodingError)
    }
    
    func testThatRequestReturnsVoidSuccessfully() async throws {
        // GIVEN
        let endpoint = Endpoint(path: "/good-url-bad-json")
        guard let url = try? endpoint.url(with: .https, host: .default) else { return XCTFail("Invalid endpoint") }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.requestHandler = (Data(validJSON.utf8), response)
        
        // WHEN
        let request = Request(endpoint: endpoint)
        let result: Result<TestDecodable, Error> = await networkClient.performRequest(request)
        
        // THEN
        XCTAssertTrue(result.isSuccess)
        
        let decodable = try result.get()
        XCTAssertNotNil(decodable)
        XCTAssertEqual(decodable.firstName, "Dushant")
        XCTAssertEqual(decodable.lastName, "Singh")
    }
}

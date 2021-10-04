//
//  File.swift
//  
//
//  Created by Dushant  Singh on 2021-10-04.
//

import Foundation
import Combine
import XCTest
@testable import CombineNetwork

@available(OSX 10.15, iOS 13, tvOS 13.0, watchOS 6.0, *)
class NetworkProviderWithCombineTests: XCTestCase {
    
    private var networkClient = NetworkClient.shared
    private var subscribers: Set<AnyCancellable> = []
    
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
        networkClient.performRequest(Request(endpoint: endpoint))
            .map { testDecodable -> Result<TestDecodable, Error> in .success(testDecodable)}
            .catch { error -> AnyPublisher<Result<TestDecodable, Error>, Never> in .just(.failure(error)) }
            .sink { result = $0; expectation.fulfill() }
            .store(in: &subscribers)
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // THEN
        XCTAssertNotNil(result)
        XCTAssertNotNil(result!.error)
        XCTAssertEqual(result!.error as! RequestError, .notFound)
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
        networkClient.performRequest(Request(endpoint: endpoint))
            .map { testDecodable -> Result<TestDecodable, Error> in .success(testDecodable)}
            .catch { error -> AnyPublisher<Result<TestDecodable, Error>, Never> in .just(.failure(error)) }
            .sink { result = $0; expectation.fulfill() }
            .store(in: &subscribers)
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // THEN
        XCTAssertNotNil(result)
        XCTAssertNotNil(result!.error)
        XCTAssertEqual(result!.error as! RequestError, .decodingError)
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
        networkClient.performRequest(Request(endpoint: endpoint))
            .map { testDecodable -> Result<TestDecodable, Error> in .success(testDecodable)}
            .catch { error -> AnyPublisher<Result<TestDecodable, Error>, Never> in .just(.failure(error)) }
            .sink { result = $0; expectation.fulfill() }
            .store(in: &subscribers)
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

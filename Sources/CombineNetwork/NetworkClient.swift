//
//  NetworkClient.swift
//  Countries
//
//  Created by Dushant  Singh on 2021-09-30.
//

import Foundation
import Combine

/// Defines the public interface of the networking layer
protocol NetworkClientProvider {
    typealias ResultCompletion<Value> = (Result<Value, Error>) -> Void
    
    /// Performs the given network request,
    /// - Parameters:
    ///  - request: Defines a network request with all required information
    /// - Returns: A publisher with either Decodable Value or Error
    @available(OSX 10.15, iOS 13, tvOS 13.0, watchOS 6.0, *)
    func performRequest<Value: SelfDecodable>(_ request: Request) -> AnyPublisher<Value, Error>
    
    /// Performs the given network request
    /// - Parameters:
    ///  - request: Defines a network request with all required information
    ///  - completion: A completion block returning a Result with either Value or Error. All errors are parsed to NetworkError
    func performRequest<Value: SelfDecodable>(_ request: Request, completion: @escaping ResultCompletion<Value>)
}

class NetworkClient {
    /// Shared instance of the network client. Use this as default.
    static let shared = NetworkClient()
    
    /// Property to make network calls
    private let urlSession: URLSession
    
    /// Initializes a new instance of the client
    ///
    /// - Parameter urlSession: Uses default URLSession
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
}

extension NetworkClient: NetworkClientProvider {
    func performRequest<Value>(_ request: Request, completion: @escaping ResultCompletion<Value>) where Value : SelfDecodable {
        guard let request = try? request.urlRequest() else {
            return completion(.failure(RequestError.invalidRequest))
        }
        urlSession.dataTask(with: request) { data, response, error in
            guard error == nil else {
                return completion(.failure(RequestError.invalidRequest))
            }
            
            guard let response = response as? HTTPURLResponse, let data = data else {
                return completion(.failure(RequestError.unknownError))
            }
            
            guard 200..<300 ~= response.statusCode else {
                return completion(.failure(RequestError.httpError(response.statusCode)))
            }
            
            let decoder: JSONDecoder = Value.decoder ?? .default
            guard let value = try? decoder.decode(Value.self, from: data) else {
                return completion(.failure(RequestError.decodingError))
            }
            
            return completion(.success(value))
        }
    }
    
    @available(OSX 10.15, iOS 13, tvOS 13.0, watchOS 6.0, *)
    func performRequest<Value: SelfDecodable>(_ request: Request) -> AnyPublisher<Value, Error> {
        guard let networkRequest = try? request.urlRequest() else {
            return .fail(RequestError.invalidRequest)
        }
        
        return urlSession.dataTaskPublisher(for: networkRequest)
            .mapError { _ in RequestError.invalidRequest }
            .print()
            .flatMap { data, response -> AnyPublisher<Data, Error> in
                guard let response = response as? HTTPURLResponse else {
                    return .fail(RequestError.unknownError)
                }
                
                guard 200..<300 ~= response.statusCode else {
                    return .fail(RequestError.httpError(response.statusCode))
                }
                return .just(data)
            }
            .decode(type: Value.self, decoder: Value.decoder ?? .default)
            .mapError { RequestError.handleError($0) }
            .eraseToAnyPublisher()
    }
}

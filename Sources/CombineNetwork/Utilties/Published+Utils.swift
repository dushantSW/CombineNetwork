//
//  Published+Utils.swift
//  Countries
//
//  Created by Dushant  Singh on 2021-10-01.
//

import Foundation
import Combine

/// Extending the publisher class with some convience functions
@available(OSX 10.15, iOS 13, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    
    static func empty() -> AnyPublisher<Output, Failure> {
        return Empty().eraseToAnyPublisher()
    }

    static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
        return Just(output)
            .catch { _ in AnyPublisher<Output, Failure>.empty() }
            .eraseToAnyPublisher()
    }

    static func fail(_ error: Failure) -> AnyPublisher<Output, Failure> {
        return Fail(error: error).eraseToAnyPublisher()
    }
}

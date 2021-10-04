//
//  URLHost.swift
//  Countries
//
//  Created by Dushant  Singh on 2021-10-03.
//

import Foundation

public struct URLHost: RawRepresentable {
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

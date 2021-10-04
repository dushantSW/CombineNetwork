//
//  File.swift
//  
//
//  Created by Dushant  Singh on 2021-10-04.
//

import Foundation
import CombineNetwork

extension URLHost {
    static var `default`: Self {
        return URLHost(rawValue: "google.com")
    }
}

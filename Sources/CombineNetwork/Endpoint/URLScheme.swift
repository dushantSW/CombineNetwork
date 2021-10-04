//
//  File.swift
//  
//
//  Created by Dushant  Singh on 2021-10-04.
//

import Foundation

public enum URLScheme {
    case http, https
    case other(scheme: String)
    
    var rawValue: String {
        switch self {
        case .http: return "http"
        case .https: return "https"
        case .other(let scheme): return scheme
        }
    }
}

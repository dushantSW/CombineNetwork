//
//  File.swift
//  
//
//  Created by Dushant  Singh on 2021-10-04.
//

import Foundation
import CombineNetwork

public let validJSON = "{\"first_name\": \"Dushant\", \"last_name\": \"Singh\"}"
public let invalidJSON = "{}"

struct TestDecodable: SelfDecodable {
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    let firstName: String
    let lastName: String
}

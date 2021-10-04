//
//  File.swift
//  
//
//  Created by Dushant  Singh on 2021-10-04.
//

import Foundation

protocol SelfDecodable: Decodable {
    static var decoder: JSONDecoder? { get }
}

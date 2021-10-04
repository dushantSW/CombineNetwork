//
//  File.swift
//  
//
//  Created by Dushant  Singh on 2021-10-04.
//

import Foundation

extension Result {
    var isSuccess: Bool {
        return (try? self.get()) != nil
    }
    
    var error: Error? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
}

//
//  Scheduler.swift
//  Countries
//
//  Created by Dushant  Singh on 2021-10-01.
//

import Foundation
import Combine

final class Scheduler {
    
    static var background: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        operationQueue.qualityOfService = QualityOfService.userInitiated
        return operationQueue
    }()

    static let main = RunLoop.main
}

//
//  File.swift
//  
//
//  Created by Danny Sung on 04/28/2022.
//

import Foundation

#if false
class SerialTask {
    private let opQ: OperationQueue
    private let serialTaskOp: SerialTaskOp
    typealias AsyncBlock = () async -> Void

    init() {
        self.opQ = OperationQueue()
        self.opQ.maxConcurrentOperationCount = 1
        self.serialTaskOp = SerialTaskOp()
        self.opQ.addOperation(self.serialTaskOp)
    }

    func addTask(_ handler: @escaping AsyncBlock ) {
        serialTaskOp.addTask(handler)
    }

}

class SerialTaskOp: Operation {
    private var handlers: [SerialTask.AsyncBlock] = []
    private let syncQ: DispatchQueue
    private let semaphore: DispatchSemaphore

    override init() {
        self.syncQ = DispatchQueue(label: "SerialTaskQueue: handler sync queue")
        self.semaphore = DispatchSemaphore(value: 0)
        super.init()
    }


    override func main() {
        while( !self.isCancelled ) {
            self.semaphore.wait()

            self.syncQ.sync {
                let g = DispatchGroup()
                g.enter()
                _ = Task {
                    defer { g.leave() }

                    var numHandlersExecuted = 0
                    for handler in self.handlers {
                        if self.isCancelled {
                            break
                        }
                        await handler()
                        numHandlersExecuted += 1
                    }
                    self.handlers.removeFirst(numHandlersExecuted)
                }
                g.wait()
            }
        }
    }

    func addTask(_ handler: @escaping SerialTask.AsyncBlock ) {
        self.syncQ.async {
            self.handlers.append(handler)
            self.semaphore.signal()
        }
    }
}
#endif


//
//  AnyHandlerWrapper.swift
//  
//
//  Created by Danny Sung on 04/17/2022.
//

import Foundation

internal protocol AnyHandlerWrapper {
}

internal protocol HandlerWrapper: AnyHandlerWrapper {
    associatedtype SwiftPacketType

    var handler: (SwiftPacketType)->Void { get }

    init(_ handler: @escaping (SwiftPacketType)->Void)
}

internal struct DataHandlerWrapper: HandlerWrapper {
    let handler: (SwiftDataPacket)->Void

    init(_ handler: @escaping (SwiftDataPacket)->Void) {
        self.handler = handler
    }
}

internal struct StringHandlerWrapper: HandlerWrapper {
    let handler: (SwiftStringPacket)->Void

    init(_ handler: @escaping (SwiftStringPacket)->Void) {
        self.handler = handler
    }
}

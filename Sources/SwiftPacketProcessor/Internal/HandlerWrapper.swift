//
//  AnyHandlerWrapper.swift
//  
//
//  Created by Danny Sung on 04/17/2022.
//

import Foundation

internal protocol AnyHandlerWrapper {
    associatedtype SwiftPacketType

    var handler: (SwiftPacketType)->Void { get }

    init(_ handler: @escaping (SwiftPacketType)->Void)
}

internal struct DataHandlerWrapper: AnyHandlerWrapper {
    let handler: (SwiftDataPacket)->Void

    init(_ handler: @escaping (SwiftDataPacket)->Void) {
        self.handler = handler
    }
}

internal struct StringHandlerWrapper: AnyHandlerWrapper {
    let handler: (SwiftStringPacket)->Void

    init(_ handler: @escaping (SwiftStringPacket)->Void) {
        self.handler = handler
    }
}

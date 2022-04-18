//
//  File.swift
//  
//
//  Created by Danny Sung on 04/17/2022.
//

import Foundation

public protocol SPPAnyPacket {
    static var _packetTypeId: UUID { get }
}

public protocol SPPPacket: SPPAnyPacket {
    associatedtype CollectionType

    static func getPacket(context: SwiftPacketContext, data: CollectionType) -> (packet: Self, countInPacket: Int)?
}

public protocol SPPDataPacket: SPPPacket {
    static func getPacket(context: SwiftPacketContext, data: Data) -> (packet: Self, countInPacket: Int)?
}

public protocol SPPStringPacket: SPPPacket {
    static func getPacket(context: SwiftPacketContext, data: String) -> (packet: Self, countInPacket: Int)?
}

/*
extension SPPPacket {
    func _packetWrapped() -> SPPHandlerWrapper {
    }
}
 */

/*

internal protocol SPPHandlerWrapper {
    associatedtype SwiftPacketType

    var handler: (SwiftPacketType)->Void { get }

    init(_ handler: @escaping (SwiftPacketType)->Void)
}
 */

struct SPPHandlerWrapper {
    var handler: (SPPAnyPacket)->Void
    init(_ handler: @escaping (SPPAnyPacket)->Void) {
        self.handler = handler
    }
}


internal struct SPPPacketTypeWrapper: Hashable {
    static func == (lhs: SPPPacketTypeWrapper, rhs: SPPPacketTypeWrapper) -> Bool {
        lhs.packetType == rhs.packetType
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine("\(self.packetType)")
        hasher.combine(self.packetType._packetTypeId)
    }

    let packetType: SPPAnyPacket.Type
    init(_ packetType: SPPAnyPacket.Type) {
        self.packetType = packetType
    }
}

public class PacketProcessor<CollectionType: SwiftPacketCollectionType, PacketType: SPPPacket> where PacketType.CollectionType == CollectionType {

    private var unprocessedData: CollectionType
    private var handlers: [SPPPacketTypeWrapper:[SPPHandlerWrapper]]

    public init() {
        self.unprocessedData = .init()
        self.handlers = [:]
    }

    public func add<P: SPPPacket>(_ handler: @escaping (P)->Void) where P.CollectionType == CollectionType {

        let handlerWrapper = SPPHandlerWrapper { genericPacket in
            let packet = genericPacket as! P
            handler(packet)
        }
        let packetTypeWrapper = SPPPacketTypeWrapper(P.self)

        self.add(handler: handlerWrapper, for: packetTypeWrapper)

    }
    
    private func add(handler: SPPHandlerWrapper, for packetType: SPPPacketTypeWrapper) {
        if var handlerForPacket = self.handlers[packetType] {
            handlerForPacket.append(handler)
            self.handlers[packetType] = handlerForPacket
        } else {
            self.handlers[packetType] = [handler]
        }
    }

    private func pop(count: Int) {
        self.unprocessedData._packetRemoveFirst(count)
    }

    private func process() {
        for (packetTypeWrapper,handlerWrappers) in handlers {
            let packetType = packetTypeWrapper.packetType as! PacketType.Type

            guard let packetInfo = packetType.getPacket(context: SwiftPacketContext(), data: self.unprocessedData) else {
                continue
            }
            self.pop(count: packetInfo.countInPacket)

            for handlerWrapper in handlerWrappers {
                handlerWrapper.handler(packetInfo.packet)
            }

        }
    }

}

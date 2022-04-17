//
//  SwiftPacketProcessor.swift
//  
//
//  Created by Danny Sung on 04/16/2022.
//

import Foundation

/*
public protocol SwiftPacket {
    associatedtype CollectionType: SwiftPacketCollectionType

    static func getPacket(context: SwiftPacketContext, data: CollectionType) -> (packet: Self, countInPacket: Int)?
}

 */
/*
class SwiftPacketProcessor<CollectionType: SwiftPacketCollectionType> {
    private var unprocessedData: CollectionType

//    typealias SwiftDataPacket = SwiftPacket

//    private var handlers:
    struct HandlerWrapper {
        let handler: (SwiftAnyPacket)->Void

        init(_ handler: @escaping (SwiftAnyPacket)->Void) {
            self.handler = handler
        }
    }
    struct PacketTypeWrapper: Hashable {
        static func == (lhs: SwiftPacketProcessor.PacketTypeWrapper, rhs: SwiftPacketProcessor.PacketTypeWrapper) -> Bool {
            lhs.packetType.self == rhs.packetType.self
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine("\(self.packetType)")
            hasher.combine(self.packetType._packetTypeId)
        }

        let packetType: SwiftAnyPacket.Type
        init(_ packetType: SwiftAnyPacket.Type) {
            self.packetType = packetType
        }
    }
    private var handlers: [PacketTypeWrapper:[HandlerWrapper]]

    public init() {
        self.unprocessedData = CollectionType()
        self.handlers = [:]
    }

    public func add<P: SwiftAnyPacket>(_ type: P.Type, _ handler: @escaping(P)->Void) {
        assert(P.self == CollectionType.self, "Packet Collection Type must match that of Processor")

        let handlerWrapper = HandlerWrapper { genericPacket in
            let packet = genericPacket as! P
            handler(packet)
        }
        let packetTypeWrapper = PacketTypeWrapper(P.self)

        self.add(handler: handlerWrapper, for: packetTypeWrapper)
    }

    public func push(_ incomingData: CollectionType) {
        self.unprocessedData._packetAppend(incomingData)
        self.process()
    }

    private func pop(count: Int) {
        self.unprocessedData._packetRemoveFirst(count)
    }

    private func process() {
        for (packetTypeWrapper, handlerWrappers) in handlers {

            if let packetType = packetTypeWrapper.packetType as? SwiftDataPacket {

                let packetInfo = packetType.self.getPacket(context: SwiftPacketContext(), data: self.unprocessedData as! Data)

            } else if let packetType = packetTypeWrapper.packetType as? SwiftStringPacket {

            }
            /*
            guard
                let packetType = packetTypeWrapper.packetType
                let packetInfo = packetTypeWrapper.packetType.getPacket(context: SwiftPacketContext(), data: self.unprocessedData) else {
                continue
            }
            self.pop(count: packetInfo.countInPacket)

            for handlerWrapper in handlerWrappers {
                handlerWrapper.handler(packetInfo.packet)
            }
             */
        }
    }

    private func add(handler: HandlerWrapper, for packetType: PacketTypeWrapper) {
        if var handlerForPacket = self.handlers[packetType] {
            handlerForPacket.append(handler)
            self.handlers[packetType] = handlerForPacket
        } else {
            self.handlers[packetType] = [handler]
        }

    }
}

*/

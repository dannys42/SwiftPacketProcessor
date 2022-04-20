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

public protocol SPPDataPacket: SPPPacket where CollectionType == Data {
    static func getPacket(context: SwiftPacketContext, data: Data) -> (packet: Self, countInPacket: Int)?
}

public protocol SPPStringPacket: SPPPacket where CollectionType == String {
    static func getPacket(context: SwiftPacketContext, data: String) -> (packet: Self, countInPacket: Int)?
}



struct SPPHandlerWrapper {
    var handler: (SPPAnyPacket)->Void
    init(_ handler: @escaping (SPPAnyPacket)->Void) {
        self.handler = handler
    }
}


internal struct SPPPacketTypeWrapper<CollectionType: SwiftPacketCollectionType>: Hashable {
    static func == (lhs: SPPPacketTypeWrapper, rhs: SPPPacketTypeWrapper) -> Bool {
        lhs.packetType == rhs.packetType
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine("\(self.packetType)")
        hasher.combine(self.packetType._packetTypeId)
    }

    let packetType: SPPAnyPacket.Type
    let packetGenerator: (_ context: SwiftPacketContext, _ data: CollectionType)->(packet: SPPAnyPacket, count: Int)?
    init(_ packetType: SPPAnyPacket.Type, packetGenerator: @escaping (_ context: SwiftPacketContext, _ data: CollectionType)->(packet: SPPAnyPacket, count: Int)? ) {
        self.packetType = packetType
        self.packetGenerator = packetGenerator
    }


}

public class PacketProcessor<CollectionType: SwiftPacketCollectionType> {

    private var unprocessedData: CollectionType
    private var handlers: [SPPPacketTypeWrapper<CollectionType>:[SPPHandlerWrapper]]

    public init() {
        self.unprocessedData = CollectionType()
        self.handlers = [:]
    }

    public func add<P: SPPPacket>(_ packetType: P.Type, _ handler: @escaping (P)->Void) where P.CollectionType == CollectionType {

        let handlerWrapper = SPPHandlerWrapper { genericPacket in
            let packet = genericPacket as! P
            handler(packet)
        }
        let packetTypeWrapper = SPPPacketTypeWrapper<CollectionType>(P.self) { context, data in
            guard let (packet, count) = P.getPacket(context: context, data: data) else {
                return nil
            }

            return (packet as SPPAnyPacket, count)
        }


        self.add(handler: handlerWrapper, for: packetTypeWrapper)

    }
    
    private func add(handler: SPPHandlerWrapper, for packetType: SPPPacketTypeWrapper<CollectionType>) {
        if var handlerForPacket = self.handlers[packetType] {
            handlerForPacket.append(handler)
            self.handlers[packetType] = handlerForPacket
        } else {
            self.handlers[packetType] = [handler]
        }
    }

    public func push(_ data: CollectionType) {
        self.unprocessedData._packetAppend(data)
        self.process()
    }

    private func pop(count: Int) {
        self.unprocessedData._packetRemoveFirst(count)
        self.process()
    }

    private func process() {
        for (packetTypeWrapper,handlerWrappers) in handlers {
            guard let packetInfo = packetTypeWrapper.packetGenerator(SwiftPacketContext(), self.unprocessedData) else {
                continue
            }
            self.pop(count: packetInfo.count)

            for handlerWrapper in handlerWrappers {
                handlerWrapper.handler(packetInfo.packet)
            }

        }
    }

}

//
//  SwiftDataPacketProcessor.swift
//  
//
//  Created by Danny Sung on 04/15/2022.
//

import Foundation

public protocol SwiftDataPacket: SwiftAnyPacket {
    static func getPacket(context: SwiftPacketContext, data: Data) -> (packet: Self, countInPacket: Int)?
}

public class SwiftDataPacketProcessor {
    private var unprocessedData: Data

    struct PacketTypeWrapper: Hashable {
        static func == (lhs: SwiftDataPacketProcessor.PacketTypeWrapper, rhs: SwiftDataPacketProcessor.PacketTypeWrapper) -> Bool {
            lhs.packetType == rhs.packetType
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine("\(self.packetType)")
            hasher.combine(self.packetType._packetTypeId)
        }

        let packetType: SwiftDataPacket.Type
        init(_ packetType: SwiftDataPacket.Type) {
            self.packetType = packetType
        }
    }
    struct HandlerWrapper {
        let handler: (SwiftDataPacket)->Void

        init(_ handler: @escaping (SwiftDataPacket)->Void) {
            self.handler = handler
        }
    }
    private var handlers: [PacketTypeWrapper:[HandlerWrapper]]

    public init() {
        self.unprocessedData = Data()
        self.handlers = [:]
    }

    public func add<P: SwiftDataPacket>(_ handler: @escaping (P)->Void) {
        let handlerWrapper = HandlerWrapper { genericPacket in
            let packet = genericPacket as! P
            handler(packet)
        }
        let packetTypeWrapper = PacketTypeWrapper(P.self)

        self.add(handler: handlerWrapper, for: packetTypeWrapper)
    }

    private func add(handler: HandlerWrapper, for packetType: PacketTypeWrapper) {
        if var handlerForPacket = self.handlers[packetType] {
            handlerForPacket.append(handler)
            self.handlers[packetType] = handlerForPacket
        } else {
            self.handlers[packetType] = [handler]
        }

    }

    public func push(_ incomingData: Data) {
        self.unprocessedData.append(incomingData)
        self.process()
    }

    private func pop(count: Int) {
        self.unprocessedData.removeFirst(count)
    }

    private func process() {
        for (packetTypeWrapper,handlerWrappers) in handlers {
            guard let packetInfo = packetTypeWrapper.packetType.getPacket(context: SwiftPacketContext(), data: self.unprocessedData) else {
                continue
            }
            self.pop(count: packetInfo.countInPacket)

            for handlerWrapper in handlerWrappers {
                handlerWrapper.handler(packetInfo.packet)
            }
        }
    }

}


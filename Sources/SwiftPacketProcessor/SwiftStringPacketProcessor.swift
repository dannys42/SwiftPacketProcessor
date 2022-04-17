//
//  SwiftStringPacket.swift
//
//
//  Created by Danny Sung on 04/12/2022.
//

import Foundation

public protocol SwiftStringPacket {

    static var _packetTypeId: UUID { get }
    static func getPacket(context: SwiftPacketContext, data: String) -> (packet: Self, countInPacket: Int)?
}

public class SwiftStringPacketProcessor {
    private var unprocessedData: String

    struct PacketTypeWrapper: Hashable {
        static func == (lhs: SwiftStringPacketProcessor.PacketTypeWrapper, rhs: SwiftStringPacketProcessor.PacketTypeWrapper) -> Bool {
            lhs.packetType == rhs.packetType
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine("\(self.packetType)")
            hasher.combine(self.packetType._packetTypeId)
        }

        let packetType: SwiftStringPacket.Type
        init(_ packetType: SwiftStringPacket.Type) {
            self.packetType = packetType
        }
    }
    struct HandlerWrapper {
        let handler: (SwiftStringPacket)->Void

        init(_ handler: @escaping (SwiftStringPacket)->Void) {
            self.handler = handler
        }
    }
    private var handlers: [PacketTypeWrapper:[HandlerWrapper]]

    public init() {
        self.unprocessedData = ""
        self.handlers = [:]
    }

    public func add<P: SwiftStringPacket>(_ type: P.Type, _ handler: @escaping (P)->Void) {
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

    public func push(_ incomingData: String) {
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

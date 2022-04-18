//
//  SwiftStringPacket.swift
//
//
//  Created by Danny Sung on 04/12/2022.
//

import Foundation

public protocol SwiftStringPacket: SwiftAnyPacket {
    
    static func getPacket(context: SwiftPacketContext, data: String) -> (packet: Self, countInPacket: Int)?
}

public class SwiftStringPacketProcessor {
    private var unprocessedData: String

    private var handlers: [PacketTypeWrapper:[StringHandlerWrapper]]

    public init() {
        self.unprocessedData = ""
        self.handlers = [:]
    }

    public func add<P: SwiftStringPacket>(_ type: P.Type, _ handler: @escaping (P)->Void) {
        let handlerWrapper = StringHandlerWrapper { genericPacket in
            let packet = genericPacket as! P
            handler(packet)
        }
        let packetTypeWrapper = PacketTypeWrapper(P.self)

        self.add(handler: handlerWrapper, for: packetTypeWrapper)
    }

    private func add(handler: StringHandlerWrapper, for packetType: PacketTypeWrapper) {
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
            let packetType = packetTypeWrapper.packetType as! SwiftStringPacket.Type
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

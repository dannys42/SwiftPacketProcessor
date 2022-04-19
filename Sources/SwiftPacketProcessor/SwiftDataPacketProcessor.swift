//
//  SwiftDataPacketProcessor.swift
//  
//
//  Created by Danny Sung on 04/15/2022.
//

import Foundation

/*
public protocol SwiftDataPacket: SwiftPacket {
    
    static func getPacket(context: SwiftPacketContext, data: Data) -> (packet: Self, countInPacket: Int)?
}

public class SwiftDataPacketProcessor {
    private var unprocessedData: Data

    private var handlers: [PacketTypeWrapper:[DataHandlerWrapper]]

    public init() {
        self.unprocessedData = Data()
        self.handlers = [:]
    }

    public func add<P: SwiftDataPacket>(_ handler: @escaping (P)->Void) {
        let handlerWrapper = DataHandlerWrapper { genericPacket in
            let packet = genericPacket as! P
            handler(packet)
        }
        let packetTypeWrapper = PacketTypeWrapper(P.self)

        self.add(handler: handlerWrapper, for: packetTypeWrapper)
    }

    private func add(handler: DataHandlerWrapper, for packetType: PacketTypeWrapper) {
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
            let packetType = packetTypeWrapper.packetType as! SwiftDataPacket.Type

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

*/

//
//  PacketProcessor.swift
//  
//
//  Created by Danny Sung on 04/17/2022.
//

import Foundation


public class PacketProcessor<CollectionType: PacketCollectionType> {

    private var unprocessedData: CollectionType
    private var handlers: [PacketTypeWrapper<CollectionType>:[HandlerWrapper]]

    public init() {
        self.unprocessedData = CollectionType()
        self.handlers = [:]
    }

    public func add<P: Packet>(_ packetType: P.Type, _ handler: @escaping (P)->Void) where P.CollectionType == CollectionType {

        let handlerWrapper = HandlerWrapper { genericPacket in
            let packet = genericPacket as! P
            handler(packet)
        }
        let packetTypeWrapper = PacketTypeWrapper<CollectionType>(P.self) { context, data -> (AnyPacket, Int)? in
            guard let (packet, count) = P.getPacket(context: context, data: data) else {
                return nil
            }

            return (packet as AnyPacket, count)
        }


        self.add(handler: handlerWrapper, for: packetTypeWrapper)

    }
    
    private func add(handler: HandlerWrapper, for packetType: PacketTypeWrapper<CollectionType>) {
        if var handlerForPacket = self.handlers[packetType] {
            handlerForPacket.append(handler)
            self.handlers[packetType] = handlerForPacket
        } else {
            self.handlers[packetType] = [handler]
        }
    }

    public func push(_ data: CollectionType) {
        self.unprocessedData._packetProcessor_packetAppend(data)
        self.process()
    }

    private func pop(count: Int) {
        self.unprocessedData._packetProcessor_packetRemoveFirst(count)
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

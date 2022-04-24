/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Defines a new PacketProcessor to convert data streams to type-safe packets.
*/

//
//  PacketProcessor.swift
//  
//
//  Created by Danny Sung on 04/17/2022.
//

import Foundation


/// Provides a simple, type-safe way of handling structured packets given a data stream.
///
/// `PacketProcessor` handles the details of buffer management when reading a data stream.  Callers need only push newly received data to the `PacketProcessor`.  The correct handlers for the appropriately typed packet will be called when appropriate.
///
/// Packet definitions must include rules for validating the packet and returning the number of data elements consumed by the packet. See `DataPacket` and `StringPacket`.
///
/// Streams can have a base collection type of `String` or `Data` by initializing as `PacketProcessor<String>` or `PacketProcessor<Data>`.
///
public class PacketProcessor<CollectionType: PacketCollectionType> {

    private var unprocessedData: CollectionType
    private var handlers: [PacketTypeWrapper<CollectionType>:[HandlerWrapper]]

    public init() {
        self.unprocessedData = CollectionType()
        self.handlers = [:]
    }

    /// Add a packet handler for a specific packet type.
    ///
    /// - Parameters:
    ///   - packetType: The packet type to process.  (e.g. `MyPacket.self`)
    ///   - handler: a handler that will be called every time `packetType` is found.
    ///
    /// This is typically called like:
    ///  ```swift
    ///  add(MyPacketType.self) { packet in ...
    ///  }
    /// ```
    ///
    /// - Note: It is safe to register multiple handlers of the same type.  Each handler each handler will receive the packet.
    ///
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

    /// Call this when more data in the stream is received.
    /// - Parameter data: The new data received
    ///
    /// For `Data` types:
    /// ```swift
    ///     let packetProcessor = PacketProcessor<Data>()
    ///     let newData = Data([ ... ]) // incoming data stream
    ///     packetProcessor.push(newData)
    /// ```
    ///
    /// For `String` types:
    /// ```swift
    ///     let packetProcessor = PacketProcessor<String>()
    ///     let newData = "..." // incoming data stream
    ///     packetProcessor.push(newData)
    /// ```
    ///
    public func push(_ data: CollectionType) {
        self.unprocessedData._packetProcessor_packetAppend(data)
        self.process()
    }


    // MARK: - Private methods

    private func add(handler: HandlerWrapper, for packetType: PacketTypeWrapper<CollectionType>) {
        if var handlerForPacket = self.handlers[packetType] {
            handlerForPacket.append(handler)
            self.handlers[packetType] = handlerForPacket
        } else {
            self.handlers[packetType] = [handler]
        }
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

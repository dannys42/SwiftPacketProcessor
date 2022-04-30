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

public
class PacketSequenceIterator<P: AnyPacket>: AsyncSequence, AsyncIteratorProtocol {
    public typealias Element = P
    private var isCancelled = false
    actor Coordinator {
        private var isCancelled = false
        private var nextElement: P?

        func cancel() {
            self.isCancelled = true
        }

        func push(_ value: P) {
            self.nextElement = value
        }

        public func next() async throws -> Element? {
            return await withCheckedContinuation { continuation in
                if self.isCancelled {
                    continuation.resume(returning: nil)
                    return
                }

                let nextElement = self.nextElement
                self.nextElement = nil
                continuation.resume(returning: nextElement)
            }
        }
    }
    private var coordinator: Coordinator

    init(type: P.Type) {
        self.coordinator = Coordinator()
    }

    deinit {
        Task {
            await self.coordinator.cancel()
        }

    }

    func push(_ value: P) async {
        await self.coordinator.push(value)
    }

    public func next() async throws -> Element? {
        return try await self.coordinator.next()
    }

    nonisolated public func makeAsyncIterator() -> PacketSequenceIterator {
        self
    }

}

/// Provides a simple, type-safe way of handling structured packets given a data stream.
///
/// ``PacketProcessor`` handles the details of buffer management when reading a data stream.  Callers need only push newly received data to the ``PacketProcessor``.  The correct handlers for the appropriately typed packet will be called when appropriate.
///
/// Packet definitions must include rules for validating the packet and returning the number of data elements consumed by the packet. See ``DataPacket`` and ``StringPacket``.
///
/// Streams can have a base ``PacketCollectionType`` type of `String` or `Data` by initializing as `PacketProcessor<String>` or `PacketProcessor<Data>`.
///
public class PacketProcessor<CollectionType: PacketCollectionType> {

    private var unprocessedData: CollectionType
    private var handlers: [PacketTypeWrapper<CollectionType>:[HandlerWrapper]]
    private var isEnded = false

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
    ///  addHandler(MyPacketType.self) { packet in ...
    ///  }
    /// ```
    ///
    /// - Note: It is safe to register multiple handlers of the same type.  Each handler each handler will receive the packet.
    /// - Returns: An identifier that can be used to remove the handler
    @discardableResult
    public func addHandler<P: Packet>(_ packetType: P.Type, _ handler: @escaping (PacketHandlerIdentifier,P) ->Void) -> PacketHandlerIdentifier where P.CollectionType == CollectionType {

        let handlerWrapper = HandlerWrapper { handlerId, genericPacket in
            let packet = genericPacket as! P
            handler(handlerId, packet)
        }
        let packetTypeWrapper = PacketTypeWrapper<CollectionType>(P.self) { context, data -> (AnyPacket, Int)? in
            guard let searchResult = P.findFirstPacket(context: context, data: data) else {
                return nil
            }

            return (searchResult.packet as AnyPacket, searchResult.numberOfElementsConsumedByPacket)
        }

        self.add(handler: handlerWrapper, for: packetTypeWrapper)

        return handlerWrapper.id
    }

    /// Add a packet handler for a specific packet type.
    /// - Parameters:
    ///   - packetType: The packet type to process.  (e.g. `MyPacket.self`)
    ///   - handler: a handler that will be called every time `packetType` is found.
    /// - Returns: An identifier that can be used to remove the handler
    @discardableResult
    public func addHandler<P: Packet>(_ packetType: P.Type, _ handler: @escaping (P) ->Void) -> PacketHandlerIdentifier where P.CollectionType == CollectionType {

        return self.addHandler(packetType) { _, packet in
            handler(packet)
        }
    }

    public func handle<P: Packet>(_ packetType: P.Type) -> PacketSequenceIterator<P> where P.CollectionType == CollectionType {
        let iterator = PacketSequenceIterator(type: P.self)

        self.addHandler(P.self) { handlerId, packet in
            Task {
                await iterator.push(packet)
            }
        }

        return iterator
    }

    /// Call when more data in the stream is received.
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
    /// Note: Call ``end()`` when no more data is expected (e.g. when the input stream is closed).
    ///
    public func push(_ data: CollectionType) {
        assert(!self.isEnded, "Attempting to push() after callign end()")
        self.unprocessedData._packetProcessor_packetAppend(data)
        self.processAllPackets()
    }

    /// Remove a handler
    /// - Parameter handlerId: ``PacketHandlerIdentifier`` to remove.  This is returned when calling ``addHandler()``
    public func remove(handlerId: PacketHandlerIdentifier) {
        var newHandlers: [PacketTypeWrapper<CollectionType>:[HandlerWrapper]] = [:]
        for (packetType, handlerList) in self.handlers {

            let newHandlerList = handlerList.filter { $0.id != handlerId }
            if !newHandlerList.isEmpty {
                newHandlers[packetType] = newHandlerList
            }
        }
        self.handlers = newHandlers
    }

    /// Mark the end of input.  It is an error to call ``push(_:)`` after declaring end.
    ///
    /// This will give all packet handlers another chance to process the packet (with `isEnded = true` in the `PacketContext`.  It will also clear the `PacketProcessor`'s internal data buffers.
    public func end() {
        self.isEnded = true
        if self.unprocessedData.count > 0 {
            self.processAllPackets()
            self.unprocessedData = .init()
        }
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
    }

    private func processAllPackets() {
        var didPopBuffer: Bool
        repeat {
            didPopBuffer = self.processSinglePacket()
        } while didPopBuffer
    }

    private func processSinglePacket() -> Bool {
        guard self.unprocessedData.count > 0 else { return false }

        var didPopBuffer = false

        let context = PacketContext(isEnded: self.isEnded)
        for (packetTypeWrapper, handlerWrappers) in self.handlers {
            guard let packetInfo = packetTypeWrapper.packetGenerator(context, self.unprocessedData) else {
                continue
            }
            didPopBuffer = true
            self.pop(count: packetInfo.count)

            for handlerWrapper in handlerWrappers {
                handlerWrapper.handler(handlerWrapper.id, packetInfo.packet)
            }

        }

        return didPopBuffer
    }

}

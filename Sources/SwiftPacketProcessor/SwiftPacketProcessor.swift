//
//  SwiftPacketProcessor.swift
//
//
//  Created by Danny Sung on 04/12/2022.
//

import Foundation

public protocol SwiftDataPacket {

}

public class SwiftDataPacketProcessor {
    private var unprocessedData: Data


    public init() {
        self.unprocessedData = Data()
    }
    public func add<P: SwiftDataPacket>(_ handler: @escaping (P)->Void) {
    }
}

public protocol SwiftStringPacket {

//    static func getPacket(context: PPFrameContext, data: CollectionType) -> (packet: Self, countInPacket: Int)?

    static func getPacket(context: PPFrameContext, data: String) -> (packet: Self, countInPacket: Int)?
}

public class SwiftStringPacketProcessor {
    private var unprocessedData: String
//    private var handlers: [(SwiftStringPacket)->Void]
    private var handlers: [HandlerInfo]

    public init() {
        self.unprocessedData = ""
        self.handlers = []
    }

    class HandlerInfo {
        let handlerType: SwiftStringPacket.Type
        let handler: (SwiftStringPacket)->Void

        init(_ type: SwiftStringPacket.Type, _ handler: @escaping (SwiftStringPacket)->Void) {
            self.handlerType = type
            self.handler = handler
        }
    }

    public func add<P: SwiftStringPacket>(_ type: P.Type, _ handler: @escaping (P)->Void) {
        let info = HandlerInfo(type, { genericPacket in
            let packet = genericPacket as! P
            handler(packet)
        })
        self.handlers.append(info)
    }

    public func push(_ incomingData: String) {
        self.unprocessedData.append(incomingData)
        self.process()
    }

    private func process() {
        for handlerInfo in handlers {
            guard let packetInfo = handlerInfo.handlerType.getPacket(context: PPFrameContext(), data: self.unprocessedData) else {
                continue
            }
            handlerInfo.handler(packetInfo.packet)
        }
    }
}
/*

public class SwiftPacketProcessor<CollectionType: SwiftPacketCollectionType> {
    private var unprocessedData: CollectionType

    public init() {
        self.unprocessedData = CollectionType()
    }

//    public typealias PacketHandler = (SwiftPacket) async -> Void
//    private var packetHandlers: [(SwiftPacket.Type, PacketHandler)] = []
//    public typealias CodableArrayClosure<O: Codable> = (@escaping CodableArrayResultClosure<O>) -> Void

    public typealias PacketHandler<P: AnySwiftPacket> = (P) -> Void
    /*
    struct PacketType {
        let type: SwiftPacket.Type
    }
     */
//    struct PacketHandlerInfo {
//        let p: PacketHandler<packetType>
//    }
    class HandlerInfo<C: SwiftPacketCollectionType> {
//        let type: SwiftPacket.Type
        let handler: (AnySwiftPacket)->Void

        init(type: SwiftPacket.Type, handler: @escaping PacketHandler<AnySwiftPacket>) {
            self.type = type
            self.handler = handler as! (AnySwiftPacket) -> Void
        }
    }
    private var packetHandlers: [HandlerInfo<AnySwiftPacket, CollectionType>] = []

    /*
    struct PacketHandlerInfo<P: SwiftPacket> {
        let packetType: SwiftPacket.Type
        let handler: (P) async -> Void
    }
    private var packetHandlers: [PacketHandlerInfo<SwiftPacket>] = []
     */

    // MARK: Frame Registration
    public func add<P: SwiftPacket>(_ type: P.Type, _ handler: @escaping PacketHandler<P>) {
        let handlerInfo = HandlerInfo(type: P.self, handler: handler)
        self.packetHandlers.append(handlerInfo)
    }
    /*
    public func addPacketHandler<P: SwiftPacket>(_ handler: @escaping (P) async->Void) {
        let handler = PacketHandlerInfo(packetType: P.self, handler: handler)

        self.packetHandlers.append(info)
    }
     */

    // MARK: Input Methods
    public func push(_ data: CollectionType) {
        self.unprocessedData._packetAppend(data)
    }

    // MARK: Process

    private func process() {
        guard self.unprocessedData.count > 0 else { return }

        for handlerInfo in packetHandlers {
            guard let packetInfo = handlerInfo.type.getPacket(context: PPFrameContext(), data: self.unprocessedData) else { continue }
            handlerInfo.handler(packetInfo.packet)
            /*
            let type = handlerInfo.type
            guard let handler = handlerInfo.handler as? (type)->Void else {
                continue
            }
            handler.handler(self.unprocessedData)
             */
        }

//        for toplevelFrame in toplevelFrames {
//            let elements = toplevelFrame.getElements(context: .init(), data: self.unprocessedData)
//
//            print("elements: \(elements)")
//        }
    }
}
 */

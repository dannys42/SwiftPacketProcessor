//
//  SwiftPacketProcessor.swift
//
//
//  Created by Danny Sung on 04/12/2022.
//

import Foundation

public protocol SwiftStringPacket {

    static func getPacket(context: SwiftPacketContext, data: String) -> (packet: Self, countInPacket: Int)?
}

public class SwiftStringPacketProcessor {
    private var unprocessedData: String
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
            guard let packetInfo = handlerInfo.handlerType.getPacket(context: SwiftPacketContext(), data: self.unprocessedData) else {
                continue
            }
            handlerInfo.handler(packetInfo.packet)
        }
    }
}

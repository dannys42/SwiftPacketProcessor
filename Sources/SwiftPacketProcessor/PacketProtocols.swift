//
//  PacketProtocols.swift
//  
//
//  Created by Danny Sung on 04/20/2022.
//

import Foundation

public protocol AnyPacket {
    static var _packetTypeId: UUID { get }
}

public protocol Packet: AnyPacket {
    associatedtype CollectionType

    static func getPacket(context: SwiftPacketContext, data: CollectionType) -> (packet: Self, countInPacket: Int)?
}

public protocol DataPacket: Packet where CollectionType == Data {
    static func getPacket(context: SwiftPacketContext, data: Data) -> (packet: Self, countInPacket: Int)?
}

public protocol StringPacket: Packet where CollectionType == String {
    static func getPacket(context: SwiftPacketContext, data: String) -> (packet: Self, countInPacket: Int)?
}



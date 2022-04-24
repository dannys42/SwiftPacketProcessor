//
//  PacketProtocols.swift
//  
//
//  Created by Danny Sung on 04/20/2022.
//

import Foundation

/// A type-erased `Packet`.
/// - Note: Primarily used internally; most callers can ignore this.
public protocol AnyPacket {
    static var _packetTypeId: UUID { get }
}

/// A generic `Packet` type that allows the choice between different `CollectionType`s (either `Data` or `String`)
/// - Note: Primarily used internally; most callers can ignore this.
public protocol Packet: AnyPacket {
    associatedtype CollectionType

    static func getPacket(context: SwiftPacketContext, data: CollectionType) -> (packet: Self, countInPacket: Int)?
}


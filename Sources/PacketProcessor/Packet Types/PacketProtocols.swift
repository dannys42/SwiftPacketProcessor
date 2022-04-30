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

    /// Implement this method to find the first occurance of a valid packet within the data supplied.
    /// - Parameters:
    ///   - context: ``PacketHandlerContext/isEnded`` can be used to determine if the `data` passed is the last to be processed.  Useful for handling incomplete packets.
    ///   - data: The data to search.  The packet must start at the beginning of `data`.
    /// - Returns: ``PacketSearchResult`` if packet is found at the beginning of `data`.  Otherwise returns `nil`.
    static func findFirstPacket(context: PacketHandlerContext, data: CollectionType) -> PacketSearchResult<Self>?
}


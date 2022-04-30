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
///
/// ``Packet`` Implementations must also include the following lines:
/// ```swift
///    static var _packetTypeId = UUID()
/// ```
///
/// - Note: Primarily used internally; most callers can ignore this.
public protocol Packet: AnyPacket {
    /// Must be either `String` or `Data`.  You usually do not need to specify this as it will be inferred from your declaration of ``findFirstPacket(context:data:)``.
    associatedtype CollectionType

    /// Implement this method to find the first occurance of a valid packet within the data supplied.
    /// - Parameters:
    ///   - context: ``PacketHandlerContext/isEnded`` can be used to determine if the `data` passed is the last to be processed.  Useful for handling incomplete packets (such as due to end of file or close of socket).
    ///   - data: The data to search.  The packet must start at the beginning of `data`.  Either `String` or `Data` must be used in place of ``CollectionType``.
    /// - Returns: ``PacketSearchResult`` containing this ``Packet`` if a valid packet is found at the beginning of `data`.  Otherwise returns `nil`.
    static func findFirstPacket(context: PacketHandlerContext, data: CollectionType) -> PacketSearchResult<Self>?
}


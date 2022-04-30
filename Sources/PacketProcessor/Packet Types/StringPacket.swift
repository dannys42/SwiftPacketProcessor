//
//  StringPacket.swift
//  
//
//  Created by Danny Sung on 04/21/2022.
//

import Foundation

/// String-oriented packets should conform to `StringPacket`.
/// Examples include SMTP, IRC, XMPP.
///
/// See ``Packet`` for full conformance.
public protocol StringPacket: Packet where CollectionType == String {
    /// Implement this method to find the first occurance of a valid packet within the data supplied.
    /// - Parameters:
    ///   - context: ``PacketHandlerContext/isEnded`` can be used to determine if the `data` passed is the last to be processed.  Useful for handling incomplete packets (such as due to end of file or close of socket).
    ///   - data: The data to search.  The packet must start at the beginning of `data`.
    /// - Returns: ``PacketSearchResult`` containing this ``Packet`` if a valid packet is found at the beginning of `data`.  Otherwise returns `nil`.
    static func findFirstPacket(context: PacketHandlerContext, data: String) -> PacketSearchResult<Self>?
}

/// Declare `String` is a valid `PacketCollectionType`
extension String: PacketCollectionType {
    mutating public func _packetProcessor_packetAppend(_ other: String) {
        self.append(other)
    }
    mutating public func _packetProcessor_packetRemoveFirst(_ count: Int) {
        self.removeFirst(count)
    }
}

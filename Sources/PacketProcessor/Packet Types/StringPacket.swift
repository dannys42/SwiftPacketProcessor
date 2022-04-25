//
//  StringPacket.swift
//  
//
//  Created by Danny Sung on 04/21/2022.
//

import Foundation

/// String-oriented packets should conform to `StringPacket`.
/// Examples include SMTP, IRC, XMPP.
public protocol StringPacket: Packet where CollectionType == String {
    static func findFirstPacket(context: SwiftPacketContext, data: String) -> PacketSearchResult<Self>?
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

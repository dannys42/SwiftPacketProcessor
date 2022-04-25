//
//  DataPacket.swift
//  
//
//  Created by Danny Sung on 04/21/2022.
//

import Foundation

/// Byte-oriented packets should conform to `DataPacket`.
/// Examples of this include IP, TCP, and UDP.
public protocol DataPacket: Packet where CollectionType == Data {
    static func findFirstPacket(context: SwiftPacketContext, data: Data) -> PacketSearchResult<Self>?
}

/// Declare `Data` is a valid `PacketCollectionType`
extension Data: PacketCollectionType {

    mutating public func _packetProcessor_packetAppend(_ other: Self) {
        self.append(other)
    }
    mutating public func _packetProcessor_packetRemoveFirst(_ count: Int) {
        self.removeFirst(count)
    }
}

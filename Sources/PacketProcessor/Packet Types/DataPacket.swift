//
//  DataPacket.swift
//  
//
//  Created by Danny Sung on 04/21/2022.
//

import Foundation

/// Packets that are fundamentally byte-oriented should conform to `DataPacket`.
public protocol DataPacket: Packet where CollectionType == Data {
    static func getPacket(context: SwiftPacketContext, data: Data) -> (packet: Self, countInPacket: Int)?
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

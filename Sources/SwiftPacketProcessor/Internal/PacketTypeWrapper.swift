//
//  PacketTypeWrapper.swift
//  
//
//  Created by Danny Sung on 04/17/2022.
//

import Foundation

internal struct PacketTypeWrapper: Hashable {
    static func == (lhs: PacketTypeWrapper, rhs: PacketTypeWrapper) -> Bool {
        lhs.packetType == rhs.packetType
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine("\(self.packetType)")
        hasher.combine(self.packetType._packetTypeId)
    }

    let packetType: SwiftAnyPacket.Type
    init(_ packetType: SwiftAnyPacket.Type) {
        self.packetType = packetType
    }
}

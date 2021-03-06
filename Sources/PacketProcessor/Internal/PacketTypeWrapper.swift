//
//  PacketTypeWrapper.swift
//  
//
//  Created by Danny Sung on 04/20/2022.
//

import Foundation

internal struct PacketTypeWrapper<CollectionType: PacketCollectionType>: Hashable {
    static func == (lhs: PacketTypeWrapper, rhs: PacketTypeWrapper) -> Bool {
        lhs.packetType == rhs.packetType
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine("\(self.packetType)")
        hasher.combine(ObjectIdentifier(self.packetType))
    }

    let packetType: AnyPacket.Type
    let packetGenerator: (_ context: PacketHandlerContext, _ data: CollectionType)->(packet: AnyPacket, count: Int)?
    init(_ packetType: AnyPacket.Type, packetGenerator: @escaping (_ context: PacketHandlerContext, _ data: CollectionType)->(packet: AnyPacket, count: Int)? ) {
        self.packetType = packetType
        self.packetGenerator = packetGenerator
    }


}

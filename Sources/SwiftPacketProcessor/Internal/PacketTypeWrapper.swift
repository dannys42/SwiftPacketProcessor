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

    let packetType: SPPAnyPacket.Type
    init(_ packetType: SPPAnyPacket.Type) {
        self.packetType = packetType
    }

    /*
    func getPacketType<CollectionType: SwiftPacketCollectionType>(_ collectionType: CollectionType) -> SwiftDataPacket.Type where CollectionType == Data {
        return self.packetType as! SwiftDataPacket.Type
    }
     */
    /*
    func getPacketType<CollectionType: SwiftPacketCollectionType>() -> SwiftStringPacket.Type where CollectionType == String {
        return self.packetType as! SwiftStringPacket.Type
    }
     */

//    func getPacket<CollectionType: SwiftPacketCollectionType>(context: SwiftPacketContext, data: CollectionType) -> SPPDataPacket where CollectionType == SPPDataPacket.CollectionType {
//    func getPacket(context: SwiftPacketContext, data: Data) -> SPPDataPacket {
//
//    }

    /*
    guard let packetInfo = packetType.getPacket(context: SwiftPacketContext(), data: self.unprocessedData) else {
        continue
    }
     */


}

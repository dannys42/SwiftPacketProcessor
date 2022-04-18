//
//  SwiftAnyPacket.swift
//  
//
//  Created by Danny Sung on 04/17/2022.
//

import Foundation

public protocol SwiftAnyPacket {
    static var _packetTypeId: UUID { get }
}

public protocol SwiftPacket: SwiftAnyPacket {
//    associatedtype CollectionType
}

/*
public protocol SwiftPacket: SwiftAnyPacket {
    associatedtype CollectionType: SwiftPacketCollectionType

    static func getPacket(context: SwiftPacketContext, data: CollectionType) -> (packet: Self, countInPacket: Int)?

}

*/

//public protocol Packet: SwiftAnyPacket {
//    associatedtype CollectionType
//}
//
//struct StringPacket: Packet {
//    static var _packetTypeId = UUID(
//
//    typealias CollectionType = String
//
//}
//public protocol StringPacket: Packet where CollectionType == String {
//
//
//}
//
//public protocol DataPacket: Packet where CollectionType == Data {
//
//
//}

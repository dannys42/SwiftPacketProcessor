//
//  SwiftPacketCollectionType.swift
//  
//
//  Created by Danny Sung on 04/13/2022.
//

import Foundation

public protocol SwiftPacketCollectionType {
    init()
    var count: Int { get }
    mutating func _packetAppend(_ other: Self)
    mutating func _packetRemoveFirst(_ count: Int)

    associatedtype _packetType
//    mutating func _packetAppend(data: Data)
//    mutating func _packetAppend(string: String)

}

extension Data: SwiftPacketCollectionType {
    public typealias _packetType = SwiftDataPacket

    mutating public func _packetAppend(_ other: Self) {
//        let dataToAppend = other as! Data
//        self.append(dataToAppend)
        self.append(other)
    }
    mutating public func _packetRemoveFirst(_ count: Int) {
        self.removeFirst(count)
    }
/*
    mutating public func _packetAppend(data: Data) {
        self.append(data)
    }

    mutating public func _packetAppend(string: String) {
        self.append(string.data(using: .utf8)!)
    }
 */
}

extension String: SwiftPacketCollectionType {
    public typealias _packetType = SwiftStringPacket

    mutating public func _packetAppend(_ other: String) {
        self.append(other)
    }
    mutating public func _packetRemoveFirst(_ count: Int) {
        self.removeFirst(count)
    }

    /*
    mutating public func _packetAppend(data: Data) {
        self.append(String(data: data, encoding: .utf8)!)
    }

    mutating public func _packetAppend(string: String) {
        self.append(string)
    }
*/
}

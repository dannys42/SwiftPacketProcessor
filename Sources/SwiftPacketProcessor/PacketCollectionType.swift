//
//  PacketCollectionType.swift
//  
//
//  Created by Danny Sung on 04/13/2022.
//

import Foundation

public protocol PacketCollectionType {
    init()
    var count: Int { get }
    mutating func _packetProcessor_packetAppend(_ other: Self)
    mutating func _packetProcessor_packetRemoveFirst(_ count: Int)
}

extension Data: PacketCollectionType {

    mutating public func _packetProcessor_packetAppend(_ other: Self) {
        self.append(other)
    }
    mutating public func _packetProcessor_packetRemoveFirst(_ count: Int) {
        self.removeFirst(count)
    }
}

extension String: PacketCollectionType {
    mutating public func _packetProcessor_packetAppend(_ other: String) {
        self.append(other)
    }
    mutating public func _packetProcessor_packetRemoveFirst(_ count: Int) {
        self.removeFirst(count)
    }
}

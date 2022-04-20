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
}

extension Data: SwiftPacketCollectionType {

    mutating public func _packetAppend(_ other: Self) {
        self.append(other)
    }
    mutating public func _packetRemoveFirst(_ count: Int) {
        self.removeFirst(count)
    }
}

extension String: SwiftPacketCollectionType {
    mutating public func _packetAppend(_ other: String) {
        self.append(other)
    }
    mutating public func _packetRemoveFirst(_ count: Int) {
        self.removeFirst(count)
    }
}

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
    mutating func _packetAppend(data: Data)
    mutating func _packetAppend(string: String)

}

extension Data: SwiftPacketCollectionType {
    mutating public func _packetAppend(_ other: Data) {
        self.append(other)
    }

    mutating public func _packetAppend(data: Data) {
        self.append(data)
    }

    mutating public func _packetAppend(string: String) {
        self.append(string.data(using: .utf8)!)
    }
}

extension String: SwiftPacketCollectionType {
    mutating public func _packetAppend(_ other: String) {
        self.append(other)
    }

    mutating public func _packetAppend(data: Data) {
        self.append(String(data: data, encoding: .utf8)!)
    }

    mutating public func _packetAppend(string: String) {
        self.append(string)
    }
}

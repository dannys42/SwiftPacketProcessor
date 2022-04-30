//
//  PacketCollectionType.swift
//  
//
//  Created by Danny Sung on 04/13/2022.
//

import Foundation

/// Protocol used to declare data collection types that can be used by ``PacketProcessor``.
///
/// This is primarily used to initialize a ``PacketProcessor``.  You will do so by specifying either `PacketProcessor<String>` or `PacketProcessor<Data>`.
///
/// Most users can ignore this protocol.
public protocol PacketCollectionType {

    init()

    /// Number of elements in the collection.
    var count: Int { get }

    /// Called when adding more data to the buffer.
    /// - Parameter other: Additional data to add.
    mutating func _packetProcessor_packetAppend(_ other: Self)

    /// Called when removing data from the buffer.
    /// - Parameter count: Number of elements to remove.  (bytes for Data; characters for String)
    mutating func _packetProcessor_packetRemoveFirst(_ count: Int)
}

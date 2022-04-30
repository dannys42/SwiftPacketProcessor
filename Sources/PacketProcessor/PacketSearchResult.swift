//
//  PacketSearchResult.swift
//  
//
//  Created by Danny Sung on 04/24/2022.
//

import Foundation

public struct PacketSearchResult<P: AnyPacket> {
    /// The ``Packet`` found
    public let packet: P
    /// The number of data elements consumed (from ``Packet/findFirstPacket(context:data:)``) by the packet
    public let numberOfElementsConsumedByPacket: Int

    /// Declare a packet that has been found by ``Packet/findFirstPacket(context:data:)``
    /// - Parameters:
    ///   - packet: The ``Packet`` that was found.
    ///   - numberOfElementsConsumedByPacket: The number of elements of data (from ``Packet/findFirstPacket(context:data:)``) that was used to construct the ``Packet``.
    public init(packet: P, numberOfElementsConsumedByPacket: Int) {
        self.packet = packet
        self.numberOfElementsConsumedByPacket = numberOfElementsConsumedByPacket
    }
}

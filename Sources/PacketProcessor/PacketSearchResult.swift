//
//  PacketSearchResult.swift
//  
//
//  Created by Danny Sung on 04/24/2022.
//

import Foundation

public struct PacketSearchResult<P: AnyPacket> {
    public let packet: P
    public let numberOfElementsConsumedByPacket: Int

    public init(packet: P, numberOfElementsConsumedByPacket: Int) {
        self.packet = packet
        self.numberOfElementsConsumedByPacket = numberOfElementsConsumedByPacket
    }
}

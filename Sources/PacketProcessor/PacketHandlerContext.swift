//
//  PacketHandlerContext.swift
//  
//
//  Created by Danny Sung on 04/15/2022.
//

import Foundation

/// Used by packet handlers to get more details about the state of the data stream.  Typically used in ``Packet/findFirstPacket(context:data:)``.
public class PacketHandlerContext {
    /// `true` if input handling has ended on a ``PacketProcessor``.
    ///
    /// This is intended for ``Packet/findFirstPacket(context:data:)`` to determine how to handle potentially incomplete packets.
    public private(set) var isEnded: Bool

    internal init(isEnded: Bool = false) {
        self.isEnded = isEnded
    }
}

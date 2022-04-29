//
//  HandlerWrapper.swift
//  
//
//  Created by Danny Sung on 04/20/2022.
//

import Foundation

internal struct HandlerWrapper: Identifiable {
    var id: PacketHandlerIdentifier
    var handler: (PacketHandlerIdentifier, AnyPacket) async ->Void

    init(_ handler: @escaping (PacketHandlerIdentifier, AnyPacket) async ->Void) {
        self.id = UUID()
        self.handler = handler
    }
}


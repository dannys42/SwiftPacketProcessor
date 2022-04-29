//
//  SwiftPacketContext.swift
//  
//
//  Created by Danny Sung on 04/15/2022.
//

import Foundation

public class PacketContext {
    public private(set) var isEnded: Bool

    internal init(isEnded: Bool = false) {
        self.isEnded = isEnded
    }
}

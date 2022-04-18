//
//  SwiftAnyPacket.swift
//  
//
//  Created by Danny Sung on 04/17/2022.
//

import Foundation

public protocol SwiftAnyPacket {
    static var _packetTypeId: UUID { get }
}


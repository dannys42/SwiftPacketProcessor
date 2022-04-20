//
//  HandlerWrapper.swift
//  
//
//  Created by Danny Sung on 04/20/2022.
//

import Foundation

internal struct HandlerWrapper {
    var handler: (AnyPacket)->Void
    init(_ handler: @escaping (AnyPacket)->Void) {
        self.handler = handler
    }
}


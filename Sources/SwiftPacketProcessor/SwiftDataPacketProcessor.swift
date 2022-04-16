//
//  SwiftDataPacketProcessor.swift
//  
//
//  Created by Danny Sung on 04/15/2022.
//

import Foundation

public protocol SwiftDataPacket {

}

public class SwiftDataPacketProcessor {
    private var unprocessedData: Data


    public init() {
        self.unprocessedData = Data()
    }
    public func add<P: SwiftDataPacket>(_ handler: @escaping (P)->Void) {
    }
}


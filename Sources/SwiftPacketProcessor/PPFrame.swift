//
//  PPFrame.swift
//  
//
//  Created by Danny Sung on 04/12/2022.
//

import Foundation

public struct PPFrameContext {

}

public protocol PPFrame {
//    func isValidFrame(data: Data) -> Bool
    var payload: Data { get }

    static func getElements(context: PPFrameContext, data: Data) -> (elements: [PPElement], bytesInFrame: Int)?

}

/*
See LICENSE file for this sample’s licensing information.

Abstract:
A simple log file processor

Created by Danny Sung on 04/24/2022.
*/

import Foundation

print("Hello World!")

struct NewlinePacket: StringPacket {
    typealias CollectionType = String

    static var _packetTypeId = UUID()

    static func getPacket(context: SwiftPacketContext, data: String) -> (packet: NewlinePacket, countInPacket: Int)? {
        guard let newlineIndex = data.firstIndex(of: "\n") else {
            return nil
        }

        let payload = data.prefix(upTo: newlineIndex)
        let packet = NewlinePacket(payload: String(payload))
        return (packet, payload.count+1)
    }

    var payload: String
}

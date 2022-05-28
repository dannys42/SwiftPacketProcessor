/*
See LICENSE file for this sample’s licensing information.

Abstract:
A simple log file processor

Created by Danny Sung on 04/29/2022.
*/

import Foundation
import PacketProcessor

struct NewlinePacket: StringPacket {
    var text: String

    static func findFirstPacket(context: PacketContext, data: String) -> PacketSearchResult<Self>? {

        let endOfLineIndex: String.Index
        let newlineCount: Int

        if let newlineIndex = data.firstIndex(of: "\n") {
            endOfLineIndex = newlineIndex
            newlineCount = 1
        } else if context.isEnded {
            endOfLineIndex = data.endIndex
            newlineCount = 0
        } else {
            return nil
        }

        let payload = data.prefix(upTo: endOfLineIndex)
        let packet = NewlinePacket(text: String(payload))
        return PacketSearchResult(packet: packet, numberOfElementsConsumedByPacket: payload.count+newlineCount)
    }

}

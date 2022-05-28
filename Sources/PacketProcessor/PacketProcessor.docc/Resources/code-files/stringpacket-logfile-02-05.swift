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
        guard let newlineIndex = data.firstIndex(of: "\n") else {
            return nil
        }

        let payload = data.prefix(upTo: newlineIndex)
        let packet = NewlinePacket(text: String(payload))
        return PacketSearchResult(packet: packet, numberOfElementsConsumedByPacket: payload.count+1)
    }

}

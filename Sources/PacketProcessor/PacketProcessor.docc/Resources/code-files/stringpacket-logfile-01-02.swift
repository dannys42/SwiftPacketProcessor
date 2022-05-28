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
        // TBD
    }

}

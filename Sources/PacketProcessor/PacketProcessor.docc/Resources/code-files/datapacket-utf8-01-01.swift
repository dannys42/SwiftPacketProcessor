/*
See LICENSE file for this sample’s licensing information.

Abstract:
A simple UTF-8 decoder

Created by Danny Sung on 05/05/2022.
*/


import Foundation

struct UTF8ToString: DataPacket {
    var string: String

    static func findFirstPacket(context: PacketHandlerContext, data: Data) -> PacketSearchResult<UTF8ToString>? {
        // TBD
    }
}

/*
See LICENSE file for this sample’s licensing information.

Abstract:
A simple UTF-8 decoder

Created by Danny Sung on 05/05/2022.
*/


import Foundation

struct UTF8ToString: DataPacket {
    var string: String

    static var _packetTypeId = UUID()

    static func findFirstPacket(context: PacketHandlerContext, data: Data) -> PacketSearchResult<UTF8ToString>? {
        /// A buffer to append valid converted `String`s until we're ready to return
        var string = ""

        /// The last `Data.Index` that was converted to string
        var lastGoodIndex: Data.Index!

        /// Invalid bytes found will generate a UTF-8 Replacement character
        let invalidCharacter = "�"

        /// A container to keep track of a range of indexes into `Data`
        struct Range {
            let startIndex: Data.Index
            let endIndex: Data.Index

            init(startIndex: Data.Index, endIndex: Data.Index) {
                self.startIndex = startIndex
                self.endIndex = endIndex
            }

            init(index: Data.Index) {
                self.startIndex = index
                self.endIndex = index
            }

            func incrementEnd() -> Range {
                return Range(startIndex: self.startIndex, endIndex: self.endIndex+1)
            }
        }

        enum State {
            /// range keeps track of a run of "good" bytes that can be converted and appended to ``string``
            case good(range: Range)

            /// goodRange is the last "good" range that has not yet been appended to ``string``.
            /// partialRange keeps track of the start and current index of a multi-byte character
            case partial(goodRange: Range, partialRange: Range, count: Int)

            /// an exit condition if we were expecting more bytes in a multi-byte character, but ran out
            case incomplete(lastGoodIndex: Data.Index)

            /// an exit condition when everything has been properly converted
            case done(lastGoodIndex: Data.Index)
        }

        /// TBD
        return nil
    }
}

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
        var lastConsumedIndex: Data.Index!

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

        var state = State.good(range: .init(index: data.startIndex))
        var isDone = false

        while !isDone {
            let nextState: State
            switch state {
            case .good(range: let range):
                // The logic here is:
                // - Extend the range while we have valid bytes
                // - Handle invalid characters
                // - Move to the `partial` state when we detect a multi-byte character
                // - Convert validated bytes if we reach the end of the buffer
                guard range.endIndex < data.endIndex else {
                    if range.startIndex < range.endIndex {
                        let goodData = data[range.startIndex..<data.endIndex]
                        string.append(String(data: goodData, encoding: .utf8)!)
                    }
                    nextState = .done(lastGoodIndex: data.endIndex)
                    break
                }
                let byte = data[range.endIndex]
                let nextIndex = range.endIndex + 1
                if (byte & 0b1000_0000) == 0b0000_0000 {
                    nextState = .good(range: range.incrementEnd())
                } else if (byte & 0b1110_0000) == 0b1100_0000 {
                    nextState = .partial(goodRange: range, partialRange: .init(index: nextIndex), count: 1)
                } else if (byte & 0b1111_0000) == 0b1110_0000 {
                    nextState = .partial(goodRange: range, partialRange: .init(index: nextIndex), count: 2)
                } else if (byte & 0b1111_1000) == 0b1111_0000 {
                    nextState = .partial(goodRange: range, partialRange: .init(index: nextIndex), count: 3)
                } else if (byte & 0b1111_1100) == 0b1111_1000 {
                    nextState = .partial(goodRange: range, partialRange: .init(index: nextIndex), count: 4)
                } else if (byte & 0b1111_1110) == 0b1111_1100 {
                    nextState = .partial(goodRange: range, partialRange: .init(index: nextIndex), count: 5)
                } else {
                    let goodData = data[range.startIndex..<range.endIndex]
                    string.append(String(data: goodData, encoding: .utf8)!)
                    string.append(invalidCharacter)
                    nextState = .good(range: .init(index: nextIndex))
                }
            case .partial(goodRange: let goodRange, partialRange: let partialRange, count: let count):
                // The logic here is:
                // - Validate each byte in a multi-byte character
                // - Handle invalid characters
                // - Go to `incomplete` state if we have fewer bytes than expected
                // - Go to `good` state if we've validated all the bytes of the multi-byte character

                guard count > 0 else {
                    nextState = .good(range: Range(startIndex: goodRange.startIndex, endIndex: partialRange.endIndex))
                    break
                }
                guard partialRange.endIndex < data.endIndex else {
                    nextState = .incomplete(lastGoodIndex: partialRange.startIndex-1)
                    break
                }
                let byte = data[partialRange.endIndex]
                if (byte & 0b1100_0000) == 0b1000_0000 {
                    nextState = .partial(goodRange: goodRange, partialRange: partialRange.incrementEnd(), count: count-1)
                } else {
                    let goodData = data[goodRange.startIndex..<goodRange.endIndex]
                    string.append(String(data: goodData, encoding: .utf8)!)
                    string.append(invalidCharacter)
                    nextState = .good(range: .init(index: partialRange.endIndex+1))
                }
            case .incomplete(lastGoodIndex: let index):
                if context.isEnded {
                    string.append(invalidCharacter)
                    lastConsumedIndex = data.endIndex
                } else {
                    lastConsumedIndex = index
                }
                nextState = state
                isDone = true
            case .done(lastGoodIndex: let index):
                lastConsumedIndex = index
                nextState = state
                isDone = true
            }
            state = nextState
        }

        if string.count > 0 {
            let packet = UTF8ToString(string: string)
            let numberOfBytes = lastConsumedIndex - data.startIndex
            return PacketSearchResult(packet: packet,
                                      numberOfElementsConsumedByPacket: numberOfBytes)
        } else {
            return nil
        }
    }
}

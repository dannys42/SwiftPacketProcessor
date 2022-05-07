/*
See LICENSE file for this sample’s licensing information.

Abstract:
A JSON packet processor, supporting multiple types of JSON packets.

Created by Danny Sung on 05/07/2022.
*/

import Foundation

struct JSONPacket: StringPacket {
    var value: String

    static var _packetTypeId = UUID()
    static func findFirstPacket(context: PacketHandlerContext, data: String) -> PacketSearchResult<JSONPacketTests.JSONPacket>? {

        var objectLevel = 0
        enum State {
            case unquoted
            case quoted
            case quotedEscape
        }
        var state = State.unquoted
        var numberOfCharactersConsumed: Int?

        for (index,character) in data.enumerated() {
            if numberOfCharactersConsumed != nil {
                break
            }
            if character.isWhitespace { // ignore whitespace
                continue
            }
            var nextState: State
            switch state {
            case .unquoted:
                // Try to find out where the object boundary is
                switch character {
                case "{":
                    objectLevel += 1
                    nextState = state
                case "}":
                    objectLevel -= 1
                    if objectLevel == 0 {
                        numberOfCharactersConsumed = index + 1
                    }
                    nextState = state
                case "\"":
                    nextState = .quoted
                default:
                    nextState = state
                }
            case .quoted:
                // Once we're inside double-quotes, just keep going until we're no longer quoted, paying attention to escape characters.
                switch character {
                case "\"":
                    nextState = .unquoted
                case "\\":
                    nextState = .quotedEscape
                default:
                    nextState = state
                }
            case .quotedEscape:
                // It actually doesn't matter what this character is.  We'll simply go back to the quoted state.
                nextState = .quoted
            }
            state = nextState
        }

        if let numberOfCharactersConsumed = numberOfCharactersConsumed {
            let packet = JSONPacket(value: String(data.prefix(numberOfCharactersConsumed)))
            return PacketSearchResult(packet: packet, numberOfElementsConsumedByPacket: numberOfCharactersConsumed)
        }
        return nil
    }
}


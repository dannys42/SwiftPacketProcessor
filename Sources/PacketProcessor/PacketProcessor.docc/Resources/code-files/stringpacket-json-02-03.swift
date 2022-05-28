/*
See LICENSE file for this sample’s licensing information.

Abstract:
A JSON packet processor, supporting multiple types of JSON packets.

Created by Danny Sung on 05/07/2022.
*/

import Foundation

struct JSONPacket: StringPacket {
    var value: String

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

struct PlayerMove: Codable, DataPacket {
    let playerId: Int
    let move: Coordinates

    static func findFirstPacket(context: PacketHandlerContext, data: Data) -> PacketSearchResult<JSONPacketTests.PlayerMovePacket>? {

        let decoder = JSONDecoder()
        if let packet = try? decoder.decode(PlayerMovePacket.self, from: data) {
            return PacketSearchResult(packet: packet, numberOfElementsConsumedByPacket: data.count)
        }

        return nil
    }
}

struct PlayerAttack: Codable, DataPacket {
    let playerId: Int
    let attack: Coordinates
    let weapon: String

    static func findFirstPacket(context: PacketHandlerContext, data: Data) -> PacketSearchResult<JSONPacketTests.PlayerAttackPacket>? {

        let decoder = JSONDecoder()
        if let packet = try? decoder.decode(PlayerAttackPacket.self, from: data) {
            return PacketSearchResult(packet: packet, numberOfElementsConsumedByPacket: data.count)
        }

        return nil
    }
}


let jsonProcessor = PacketProcessor<String>()
let packetProcessor = PacketProcessor<Data>()

jsonProcessor.addHandler(JSONPacket.self) { packet in
    let packetData = packet.value.data(using: .utf8)!
    packetProcessor.push(packetData)
}

packetProcessor.addHandler(PlayerMove.self) { packet in
    // Handle move
}

packetProcessor.addHandler(PlayerAttack.self) { packet in
    // Handle attack
}

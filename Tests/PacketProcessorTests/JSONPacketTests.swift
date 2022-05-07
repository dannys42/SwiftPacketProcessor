//
//  JSONPacketTests.swift
//  
//
//  Created by Danny Sung on 05/07/2022.
//

import Foundation
import XCTest
@testable import PacketProcessor

class JSONPacketTests: XCTestCase {
    let inputString = """
        {
            \"playerId\": 1,
            \"move\": {
                \"x\" : 3,
                \"y\" : 2
            }
        }

        {
            \"playerId\": 1,
            \"attack\": {
                \"x\" : 7,
                \"y\" : 9
            },
            \"weapon\": "cannon"
        }

        """

    struct Coordinates: Codable {
        let x: Int
        let y: Int
    }

    struct PlayerMove: Codable {
        let playerId: Int
        let move: Coordinates
    }

    struct PlayerAttack: Codable {
        let playerId: Int
        let attack: Coordinates
        let weapon: String
    }

    struct PlayerMovePacket: Codable, DataPacket {
        let playerId: Int
        let move: Coordinates

        static var _packetTypeId = UUID()
        static func findFirstPacket(context: PacketHandlerContext, data: Data) -> PacketSearchResult<JSONPacketTests.PlayerMovePacket>? {

            let decoder = JSONDecoder()
            if let packet = try? decoder.decode(PlayerMovePacket.self, from: data) {
                return PacketSearchResult(packet: packet, numberOfElementsConsumedByPacket: data.count)
            }

            return nil
        }
    }

    struct PlayerAttackPacket: Codable, DataPacket {
        let playerId: Int
        let attack: Coordinates
        let weapon: String

        static var _packetTypeId = UUID()
        static func findFirstPacket(context: PacketHandlerContext, data: Data) -> PacketSearchResult<JSONPacketTests.PlayerAttackPacket>? {

            let decoder = JSONDecoder()
            if let packet = try? decoder.decode(PlayerAttackPacket.self, from: data) {
                return PacketSearchResult(packet: packet, numberOfElementsConsumedByPacket: data.count)
            }

            return nil
        }
    }


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

    override class func setUp() {

    }

    func testThat_JSONPacketsFound_WhilePushingSmallChunks() throws {
        let processor = PacketProcessor<String>()
        let expectedValue = 2
        var observedValue = 0

        processor.addHandler(JSONPacket.self) { packet in
            observedValue += 1
        }

        let chunkSize = (1..<17).randomElement()!
        let strings = inputString.split(by: chunkSize)

        for string in strings {
            processor.push(string)
        }

        XCTAssertEqual(expectedValue, observedValue)
    }

    func testThat_Packets_CanDecode() throws {
        let jsonProcessor = PacketProcessor<String>()
        let jsonDecoder = JSONDecoder()
        var playerMove: PlayerMove?
        var playerAttack: PlayerAttack?

        jsonProcessor.addHandler(JSONPacket.self) { packet in
            let packetData = packet.value.data(using: .utf8)!
            if let move = try? jsonDecoder.decode(PlayerMove.self, from: packetData) {
                playerMove = move
            } else if let attack = try? jsonDecoder.decode(PlayerAttack.self, from: packetData) {
                playerAttack = attack
            }
        }
        let chunkSize = (1..<17).randomElement()!
        let strings = inputString.split(by: chunkSize)

        for string in strings {
            jsonProcessor.push(string)
        }

        XCTAssertNotNil(playerMove)
        XCTAssertNotNil(playerAttack)
    }

    func testThat_TwoLevelPackets_CanDecode() throws {
        let jsonProcessor = PacketProcessor<String>()
        let packetProcessor = PacketProcessor<Data>()
        var playerMove: PlayerMovePacket?
        var playerAttack: PlayerAttackPacket?

        jsonProcessor.addHandler(JSONPacket.self) { packet in
            let packetData = packet.value.data(using: .utf8)!
            packetProcessor.push(packetData)
        }
        packetProcessor.addHandler(PlayerMovePacket.self) { packet in
            playerMove = packet
        }
        packetProcessor.addHandler(PlayerAttackPacket.self) { packet in
            playerAttack = packet
        }
        let chunkSize = (1..<17).randomElement()!
        let strings = inputString.split(by: chunkSize)

        for string in strings {
            jsonProcessor.push(string)
        }

        XCTAssertNotNil(playerMove)
        XCTAssertNotNil(playerAttack)
    }

}


// MARK: Some helper extensions

extension String {
    func split(by interval: Int) -> [String] {
        var count = 0
        var s = ""
        var returnValues: [String] = []

        for char in self {
            s.append(char)
            count += 1
            if( (count % interval) == 0 ) {
                returnValues.append(s)
                s = ""
            }
        }
        returnValues.append(s)
        return returnValues
    }
}

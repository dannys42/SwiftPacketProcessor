/*
See LICENSE file for this sample’s licensing information.

Abstract:
A JSON packet processor, supporting multiple types of JSON packets.

Created by Danny Sung on 05/07/2022.
*/

import Foundation

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

func handleNewData(packetData: Data) {
    if let playerMove = try? jsonDecoder.decode(PlayerMove.self, from: packetData) {
        // handle move
    } else if let playerAttack = try? jsonDecoder.decode(PlayerAttack.self, from: packetData) {
        // handle attack
    }
}

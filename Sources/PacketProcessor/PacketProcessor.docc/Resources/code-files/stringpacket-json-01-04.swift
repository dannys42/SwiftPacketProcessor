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

// Setup
let packetProcessor = PacketProcessor<Data>()

packetProcessor.addHandler(PlayerMovePacket.self) { packet in
    playerMove = packet
}
packetProcessor.addHandler(PlayerAttackPacket.self) { packet in
    playerAttack = packet
}

// Read new packets
let newData = ...
packetProcessor.push(newData)

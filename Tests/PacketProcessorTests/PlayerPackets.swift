//
//  PlayerPackets.swift
//  
//
//  Created by Danny Sung on 04/20/2022.
//

import Foundation
import PacketProcessor

/* The following packets follow this structure:

    1 byte MagicNumber
    1 byte Packettype
    2 byte Payload length (network byte order -- big endian)
    n bytes payload

 */

struct Packet {
    let type: Int
    let length: Int
    let payload: Data

    static let magicNumber = 0x3a

    init(type: Int, payload: Data) {
        self.type = type
        self.length = payload.count
        self.payload = payload
    }

    func toData() -> Data {
        var data = Data()
        data.append(contentsOf: [
            UInt8(Self.magicNumber),
            UInt8(self.type),
            UInt8( (self.length >> 8) & 0xff),
            UInt8( (self.length & 0xff)),
        ] + payload)
        return data
    }

    // Initialize any packet matching the format given
    init?(data: Data) {
        guard data.count >= 4,
              Int(data[0]) == Self.magicNumber
        else {
            return nil
        }
        self.type = Int(data[1])

        self.length = (Int(data[2]) << 8) | (Int(data[3]))

        let remainingBytes = data.count - 4
        guard remainingBytes == self.length else {
            return nil
        }

        self.payload = data.dropLast(data.count-4)
    }

    /// Only initialize if payloadType and payloadLength match the parameters given
    init?(packetType: Int, payloadLength: Int, payload: Data) {
        guard payload.count >= 4,
              Int(payload[0]) == Self.magicNumber
        else {
            return nil
        }
        self.type = Int(payload[1])
        guard self.type == packetType else {
            return nil
        }

        self.length = (Int(payload[2]) << 8) | (Int(payload[3]))
        guard payloadLength == self.length else {
            return nil
        }

        let remainingBytes = payload.count - 4
        guard self.length >= remainingBytes else {
            return nil
        }

        self.payload = payload.subdata(in: 4..<(payloadLength+4))
    }
}

enum PacketType: Int {
    case movement = 1
    case attack = 2
}

// Movement packets are:
// packetType = 0x01
// 1 byte playerId
// 1 byte direction
struct PlayerMovement: DataPacket, Equatable {
    enum Direction: Int {
        case North = 1
        case East  = 2
        case South = 3
        case West  = 4
    }
    let playerId: Int
    let direction: Direction

    static let MagicNumber = 0x01

    func toData() -> Data {
        var payload = Data()
        payload.append(contentsOf: [
            UInt8(self.playerId),
            UInt8(self.direction.rawValue),
        ])

        let packet = Packet(type: Self.MagicNumber, payload: payload)
        return packet.toData()
    }

    // DataPacket conformance

    static var _packetTypeId = UUID()

    static func getPacket(context: SwiftPacketContext, data: Data) -> (packet: PlayerMovement, countInPacket: Int)? {
        guard let packet = Packet(packetType: PacketType.movement.rawValue, payloadLength: 2, payload: data) else {
            return nil
        }
        let playerMovement = PlayerMovement(playerId: Int(packet.payload[0]),
                                            direction: Direction(rawValue: Int(packet.payload[1]))!)

        return (playerMovement, 2+4) // 4-byte header + 2-byte payload
    }
}

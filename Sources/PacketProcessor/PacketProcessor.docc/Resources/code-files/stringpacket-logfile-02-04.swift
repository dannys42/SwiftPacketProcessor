/*
See LICENSE file for this sample’s licensing information.

Abstract:
A simple log file processor

Created by Danny Sung on 04/29/2022.
*/


import Foundation
import PacketProcessor

let packetProcessor = PacketProcessor<String>()

packetProcessor.addHandler(NewlinePacket.self) { packet in
    print("Found a full line: \(packet.text)")
}

while let newText = getNewTextFromSomewhere() {
    self.packetProcessor.push(text)
}

self.packetProcessor.end()

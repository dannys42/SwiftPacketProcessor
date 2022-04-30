//
//  PartialStringPacketProcessorTests.swift
//  
//
//  Created by Danny Sung on 04/29/2022.
//

import XCTest
@testable import PacketProcessor

class PartialStringPacketProcessorTests: XCTestCase {

    struct NewlinePacket: StringPacket {
        var text: String

        static var _packetTypeId = UUID()

        static func findFirstPacket(context: PacketHandlerContext, data: String) -> PacketSearchResult<Self>? {
            let endOfLineIndex: String.Index
            let newlineCount: Int

            if let newlineIndex = data.firstIndex(of: "\n") {
                endOfLineIndex = newlineIndex
                newlineCount = 1
            } else if context.isEnded {
                endOfLineIndex = data.endIndex
                newlineCount = 0
            } else {
                return nil
            }

            let payload = data.prefix(upTo: endOfLineIndex)
            let packet = NewlinePacket(text: String(payload))
            return PacketSearchResult(packet: packet, numberOfElementsConsumedByPacket: payload.count+newlineCount)
        }

    }
    var stringProcessor = PacketProcessor<String>()

    override func setUpWithError() throws {
        self.stringProcessor = PacketProcessor<String>()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testThat_ThereIsNoPacket_WhenNoNewline_AndNoEnd() throws {
        let expectedValue = 0
        var count = 0

        stringProcessor.addHandler(NewlinePacket.self) { p in
            count += 1
        }
        stringProcessor.push("Hello")
        stringProcessor.push(" world!")

        let observedValue = count
        XCTAssertEqual(expectedValue, observedValue)
    }

    func testThat_ThereIsOnePacket_WhenNoNewline() throws {
        let expectedValue = 1
        var count = 0

        stringProcessor.addHandler(NewlinePacket.self) { p in
            count += 1
        }
        stringProcessor.push("Hello")
        stringProcessor.push(" world!")
        stringProcessor.end()

        let observedValue = count
        XCTAssertEqual(expectedValue, observedValue)
    }

}

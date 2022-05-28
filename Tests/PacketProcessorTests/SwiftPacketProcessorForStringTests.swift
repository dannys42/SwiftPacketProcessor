//
//  SwiftPacketProcessorForStringTests.swift
//  
//
//  Created by Danny Sung on 04/16/2022.
//

import Foundation
import XCTest
@testable import PacketProcessor

/*
class SwiftPacketProcessorForStringTests: XCTestCase {
    struct NewlinePacket: SwiftStringPacket {
        static func findFirstPacket(context: PacketHandlerContext, data: String) -> (packet: NewlinePacket, countInPacket: Int)? {
            guard let newlineIndex = data.firstIndex(of: "\n") else {
                return nil
            }

            let payload = data.prefix(upTo: newlineIndex)
            let packet = NewlinePacket(payload: String(payload))
            return (packet, payload.count+1)
        }

        var payload: String
    }
    var stringProcessor = SwiftPacketProcessor<String>()

    override func setUpWithError() throws {
        self.stringProcessor = SwiftPacketProcessor<String>()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testThat_ThereIsOnePacket_WhenNewline() throws {
        let expectation = self.expectation(description: "Find a newline.")
        let expectedValue = "Hello world!"
        var observedValue: String?

        stringProcessor.addHandler(NewlinePacket.self) { p in
            observedValue = p.payload
            expectation.fulfill()
        }
        stringProcessor.push("Hello")
        stringProcessor.push(" world!\n")

        self.wait(for: [expectation], timeout: Timeouts.successTimeout.rawValue)
        XCTAssertEqual(observedValue, expectedValue)
    }

}

*/

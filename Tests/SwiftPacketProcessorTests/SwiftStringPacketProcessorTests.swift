//
//  SwiftStringPacketProcessorTests.swift
//  
//
//  Created by Danny Sung on 04/15/2022.
//

import XCTest
@testable import SwiftPacketProcessor

class SwiftStringPacketProcessorTests: XCTestCase {
    enum Timeouts: TimeInterval {
        case successTimeout = 2
        case failureTimeout = 1
    }


    struct NewlinePacket: SPPStringPacket {
        typealias CollectionType = String

        static var _packetTypeId = UUID()

        static func getPacket(context: SwiftPacketContext, data: String) -> (packet: NewlinePacket, countInPacket: Int)? {
            guard let newlineIndex = data.firstIndex(of: "\n") else {
                return nil
            }

            let payload = data.prefix(upTo: newlineIndex)
            let packet = NewlinePacket(payload: String(payload))
            return (packet, payload.count+1)
        }

        var payload: String
    }
    var stringProcessor = PacketProcessor<String>()

    override func setUpWithError() throws {
        self.stringProcessor = PacketProcessor<String>()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testThat_ThereIsNoPacket_WhenNoNewline() throws {
        let g = DispatchGroup()

        g.enter()
        stringProcessor.add(NewlinePacket.self) { p in
            g.leave()
        }
        stringProcessor.push("Hello")
        stringProcessor.push(" world!")

        let result = g.wait(timeout: .now() + Timeouts.failureTimeout.rawValue)
        XCTAssertEqual(result, .timedOut)
    }

    func testThat_ThereIsOnePacket_WhenNewline() throws {
        let expectation = self.expectation(description: "Find a newline.")
        let expectedValue = "Hello world!"
        var observedValue: String?

        stringProcessor.add(NewlinePacket.self) { p in
            observedValue = p.payload
            expectation.fulfill()
        }
        stringProcessor.push("Hello")
        stringProcessor.push(" world!\n")

        self.wait(for: [expectation], timeout: Timeouts.successTimeout.rawValue)
        XCTAssertEqual(observedValue, expectedValue)
    }

    func testThat_MultipleObserversOfSamePacket_WillGetPacket() throws {
        let expectation = self.expectation(description: "Find a newline.")
        let expectedValue = ["1. Hello world!", "2. Hello world!"]
        var observedValue: [String] = []
        let g = DispatchGroup()

        g.enter()
        stringProcessor.add(NewlinePacket.self) { p in
            defer { g.leave() }

            observedValue.append("1. " + p.payload)
        }

        g.enter()
        stringProcessor.add(NewlinePacket.self) { p in
            defer { g.leave() }

            observedValue.append("2. " + p.payload)
        }
        stringProcessor.push("Hello")
        stringProcessor.push(" world!\n")

        g.notify(queue: .global()) {
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: Timeouts.successTimeout.rawValue)
        XCTAssertEqual(observedValue, expectedValue)
    }

    func testThat_SuccessiveNewlines_WillGetPackets() throws {
        let expectation = self.expectation(description: "Find a newline.")
        let expectedValue = ["0. Hello world!", "1. Goodbye, world."]
        var observedValue: [String] = []
        var count = 0
        let g = DispatchGroup()

        stringProcessor.add(NewlinePacket.self) { p in
            defer { g.leave() }

            observedValue.append("\(count). " + p.payload)
            count += 1
        }

        g.enter()
        stringProcessor.push("Hello world!\n")
        g.enter()
        stringProcessor.push("Goodbye, world.\n")

        g.notify(queue: .global()) {
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: Timeouts.successTimeout.rawValue)
        XCTAssertEqual(observedValue, expectedValue)
    }
}

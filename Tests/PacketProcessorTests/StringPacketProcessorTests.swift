//
//  StringPacketProcessorTests.swift
//  
//
//  Created by Danny Sung on 04/15/2022.
//

import XCTest
@testable import PacketProcessor

class StringPacketProcessorTests: XCTestCase {
    enum Timeouts: TimeInterval {
        case successTimeout = 2
        case failureTimeout = 1
    }


    struct NewlinePacket: StringPacket {
        var text: String

        static var _packetTypeId = UUID()

        static func findFirstPacket(context: PacketContext, data: String) -> PacketSearchResult<Self>? {
            guard let newlineIndex = data.firstIndex(of: "\n") else {
                return nil
            }

            let payload = data.prefix(upTo: newlineIndex)
            let packet = NewlinePacket(text: String(payload))
            return PacketSearchResult(packet: packet, numberOfElementsConsumedByPacket: payload.count+1)
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

    func testThat_ThereIsNoPacket_WhenNoNewline() throws {
        let g = DispatchGroup()

        g.enter()
        stringProcessor.addHandler(NewlinePacket.self) { p in
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

        stringProcessor.addHandler(NewlinePacket.self) { p in
            observedValue = p.text
            expectation.fulfill()
        }
        stringProcessor.push("Hello")
        stringProcessor.push(" world!\n")

        self.wait(for: [expectation], timeout: Timeouts.successTimeout.rawValue)
        XCTAssertEqual(observedValue, expectedValue)
    }

    func testThat_MultipleObserversOfSamePacket_WillGetPacket() async throws {
        let expectation = self.expectation(description: "Find a newline.")
        let expectedValue = Set(["1. Hello world!", "2. Hello world!"])
        class Observed {
            var value = Set<String>()

            func add(_ value: String) {
                self.value.insert(value)
            }
        }
        let observed = Observed()
        let waitGroup = DispatchGroup()

        waitGroup.enter()
        stringProcessor.addHandler(NewlinePacket.self) { packet in
            defer { waitGroup.leave() }

            observed.add("1. " + packet.text)
            print("  handler 1 done")
        }

        waitGroup.enter()
        stringProcessor.addHandler(NewlinePacket.self) { packet in
            defer { waitGroup.leave() }

            observed.add("2. " + packet.text)
            print("  handler 2 done")
        }
        stringProcessor.push("Hello")
        stringProcessor.push(" world!\n")

        waitGroup.notify(queue: .global()) {
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: Timeouts.successTimeout.rawValue)
        let observedValue = observed.value
        XCTAssertEqual(expectedValue, observedValue)
    }

    func testThat_SuccessiveNewlines_WillGetPackets() async throws {
        let expectation = self.expectation(description: "Find a newline.")
        let expectedValue = ["0. Hello world!", "1. Goodbye, world."]

        let g = DispatchGroup()
        class State {
            let q = DispatchQueue(label: "synchronize test state")
            var count: Int
            var strings: [String]

            init() {
                self.count = 0
                self.strings = []
            }

            func addString(_ string: String) {
                q.sync {
                    self.strings.append("\(self.count). " + string)
                    self.count += 1
                }
            }

            func getStrings() -> [String] {
                return self.strings
            }
        }
        let state = State()

        stringProcessor.addHandler(NewlinePacket.self) { p in
            defer { g.leave() }
            state.addString(p.text)
        }

        g.enter()
        stringProcessor.push("Hello world!\n")
        g.enter()
        stringProcessor.push("Goodbye, world.\n")

        g.notify(queue: .global()) {
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: Timeouts.successTimeout.rawValue)
        let observedValue = state.getStrings()
        XCTAssertEqual(observedValue, expectedValue)
    }
}

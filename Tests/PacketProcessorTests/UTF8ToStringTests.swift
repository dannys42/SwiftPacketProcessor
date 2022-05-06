//
//  UTF8ToStringTests.swift
//  
//
//  Created by Danny Sung on 04/30/2022.
//

import Foundation
import XCTest
import PacketProcessor

class UTF8ToStringTests: XCTestCase {
    var packetProcessor = PacketProcessor<Data>()

    struct UTF8ToString: DataPacket {
        var string: String
        static var _packetTypeId = UUID()
        static func findFirstPacket(context: PacketHandlerContext, data: Data) -> PacketSearchResult<UTF8ToString>? {
            var string = ""
            var lastGoodIndex: Data.Index!

            struct Range {
                let startIndex: Data.Index
                let endIndex: Data.Index

                init(startIndex: Data.Index, endIndex: Data.Index) {
                    self.startIndex = startIndex
                    self.endIndex = endIndex
                }

                init(index: Data.Index) {
                    self.startIndex = index
                    self.endIndex = index
                }

                func incrementEnd() -> Range {
                    return Range(startIndex: self.startIndex, endIndex: self.endIndex+1)
                }
            }
            enum State {
                case good(range: Range)
                case partial(goodRange: Range, partialRange: Range, count: Int)
                case incomplete(lastGoodIndex: Data.Index)
                case done(lastGoodIndex: Data.Index)
            }

            var state = State.good(range: .init(index: data.startIndex))
            let invalidCharacter = "�"
            var isDone = false

            while !isDone {
                let nextState: State
                switch state {
                case .good(range: let range):
                    guard range.endIndex < data.endIndex else {
                        if range.startIndex < range.endIndex {
                            let goodData = data[range.startIndex..<data.endIndex]
                            string.append(String(data: goodData, encoding: .utf8)!)
                        }
                        nextState = .done(lastGoodIndex: data.endIndex)
                        break
                    }
                    let byte = data[range.endIndex]
                    let nextIndex = range.endIndex + 1
                    if (byte & 0b1000_0000) == 0b0000_0000 {
                        nextState = .good(range: range.incrementEnd())
                    } else if (byte & 0b1110_0000) == 0b1100_0000 {
                        nextState = .partial(goodRange: range, partialRange: .init(index: nextIndex), count: 1)
                    } else if (byte & 0b1111_0000) == 0b1110_0000 {
                        nextState = .partial(goodRange: range, partialRange: .init(index: nextIndex), count: 2)
                    } else if (byte & 0b1111_1000) == 0b1111_0000 {
                        nextState = .partial(goodRange: range, partialRange: .init(index: nextIndex), count: 3)
                    } else {
                        let goodData = data[range.startIndex..<range.endIndex]
                        string.append(String(data: goodData, encoding: .utf8)!)
                        string.append(invalidCharacter)
                        nextState = .good(range: .init(index: nextIndex))
                    }
                case .partial(goodRange: let goodRange, partialRange: let partialRange, count: let count):
                    guard count > 0 else {
                        nextState = .good(range: Range(startIndex: goodRange.startIndex, endIndex: partialRange.endIndex))
                        break
                    }
                    guard partialRange.endIndex < data.endIndex else {
                        nextState = .incomplete(lastGoodIndex: partialRange.startIndex-1)
                        break
                    }
                    let byte = data[partialRange.endIndex]
                    if (byte & 0b1100_0000) == 0b1000_0000 {
                        nextState = .partial(goodRange: goodRange, partialRange: partialRange.incrementEnd(), count: count-1)
                    } else {
                        let goodData = data[goodRange.startIndex..<goodRange.endIndex]
                        string.append(String(data: goodData, encoding: .utf8)!)
                        string.append(invalidCharacter)
                        nextState = .good(range: .init(index: partialRange.endIndex+1))
                    }
                case .incomplete(lastGoodIndex: let index):
                    lastGoodIndex = index
                    nextState = state
                    isDone = true
                case .done(lastGoodIndex: let index):
                    lastGoodIndex = index
                    nextState = state
                    isDone = true
                }
                state = nextState
            }

            if string.count > 0 {
                let packet = UTF8ToString(string: string)
                let numberOfBytes = lastGoodIndex - data.startIndex
                return PacketSearchResult(packet: packet,
                                          numberOfElementsConsumedByPacket: numberOfBytes)
            } else {
                return nil
            }
        }
    }

    override func setUp() async throws {
        self.packetProcessor = PacketProcessor<Data>()
    }

    override func tearDown() async throws {
    }

    func testThat_LowerAsciiConverts_ToString() {
        let inputValue = Data([0x48, 0x65, 0x6c, 0x6c, 0x6f])
        let expectedValue = "Hello"
        var observedValue: String?

        self.packetProcessor.addHandler(UTF8ToString.self) { packet in
            let oldValue = observedValue ?? ""
            observedValue = oldValue.appending(packet.string)
        }
        self.packetProcessor.push(inputValue)

        XCTAssertEqual(expectedValue, observedValue)
    }

    func testThat_InvalidUTF8_OnByte0_AddsError() {
        let inputValue = Data([0x48, 0x65, 0x6c, 0x6c, 0x6f, 0xff])
        let expectedValue: String = "Hello�"
        var observedValue: String?

        self.packetProcessor.addHandler(UTF8ToString.self) { packet in
            let oldValue = observedValue ?? ""
            observedValue = oldValue.appending(packet.string)
        }
        self.packetProcessor.push(inputValue)

        XCTAssertEqual(expectedValue, observedValue)
    }

    func testThat_InvalidUTF8_OnByte1_AddsError() {
        let inputValue = Data([0x48, 0x65, 0x6c, 0x6c, 0x6f, 0b1101_1111, 0xff])
        let expectedValue: String = "Hello�"
        var observedValue: String?

        self.packetProcessor.addHandler(UTF8ToString.self) { packet in
            let oldValue = observedValue ?? ""
            observedValue = oldValue.appending(packet.string)
        }
        self.packetProcessor.push(inputValue)

        XCTAssertEqual(expectedValue, observedValue)
    }

    func testThat_4byte_UTF8_Converts() {
        let inputValue = Data([0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0xf0, 0x9f, 0x8c, 0x8e])
        let expectedValue: String = "Hello 🌎"
        var observedValue: String?

        self.packetProcessor.addHandler(UTF8ToString.self) { packet in
            let oldValue = observedValue ?? ""
            observedValue = oldValue.appending(packet.string)
        }
        self.packetProcessor.push(inputValue)

        XCTAssertEqual(expectedValue, observedValue)
    }

    func testThat_2byte_UTF8_Converts() {
        let inputValue = Data([0xc2, 0xa9])
        let expectedValue: String = "©"
        var observedValue: String?

        self.packetProcessor.addHandler(UTF8ToString.self) { packet in
            let oldValue = observedValue ?? ""
            observedValue = oldValue.appending(packet.string)
        }
        self.packetProcessor.push(inputValue)

        XCTAssertEqual(expectedValue, observedValue)
    }

    func testThat_3byte_UTF8_Converts() {
        let inputValue = Data([0xe2, 0x86, 0x92])
        let expectedValue: String = "→"
        var observedValue: String?

        self.packetProcessor.addHandler(UTF8ToString.self) { packet in
            let oldValue = observedValue ?? ""
            observedValue = oldValue.appending(packet.string)
        }
        self.packetProcessor.push(inputValue)

        XCTAssertEqual(expectedValue, observedValue)
    }

    func testThat_Consecutive_4_3_2_1byte_UTF8_Converts() {
        let inputValue = Data([
            0xf0, 0x9f, 0x8c, 0x8e, // 🌎
            0xe2, 0x86, 0x92,       // →
            0xc2, 0xa9,             // ©
            0x2e,                   // .
        ])
        let expectedValue: String = "🌎→©."
        var observedValue: String?

        self.packetProcessor.addHandler(UTF8ToString.self) { packet in
            let oldValue = observedValue ?? ""
            observedValue = oldValue.appending(packet.string)
        }
        self.packetProcessor.push(inputValue)

        XCTAssertEqual(expectedValue, observedValue)
    }

    func testThat_Consecutive_3_4_1_2byte_UTF8_Converts() {
        let inputValue = Data([
            0xe2, 0x86, 0x92,       // →
            0xf0, 0x9f, 0x8c, 0x8e, // 🌎
            0x2e,                   // .
            0xc2, 0xa9,             // ©
        ])
        let expectedValue: String = "→🌎.©"
        var observedValue: String?

        self.packetProcessor.addHandler(UTF8ToString.self) { packet in
            let oldValue = observedValue ?? ""
            observedValue = oldValue.appending(packet.string)
        }
        self.packetProcessor.push(inputValue)

        XCTAssertEqual(expectedValue, observedValue)
    }

}

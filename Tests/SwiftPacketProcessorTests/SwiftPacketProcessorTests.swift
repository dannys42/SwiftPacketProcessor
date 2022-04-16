import Foundation
import XCTest
@testable import SwiftPacketProcessor

final class SwiftPacketProcessorTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        /*
        let dataProcessor = SwiftDataPacketProcessor()
        dataProcessor.add { p in
//           print("")
        }
         */
        let expectation = self.expectation(description: "Find a newline.")
        var returnString: String?

        struct NewlinePacket: SwiftStringPacket {
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
        let stringProcessor = SwiftStringPacketProcessor()
        stringProcessor.add(NewlinePacket.self) { p in
            returnString = "Found a packet: " + p.payload
            expectation.fulfill()
        }
        stringProcessor.push("Hello")
        stringProcessor.push(" world!\n")

        self.wait(for: [expectation], timeout: 2)

        XCTAssertEqual(returnString, "Found a packet: Hello world!")


        struct NewlineFrame: SwiftPacket {
            typealias CollectionType = String

            static func getPacket(context: SwiftPacketContext, data: String) -> (packet: NewlineFrame, countInPacket: Int)? {

//                let indexOfNewline = data.indexOf(character: "\n")
                return nil
            }

            var payload: String

        }
        /*
        struct NewlineFrame: PPFrame {
            var payload: Data

            static func getElements(context: PPFrameContext, data: Data) -> (elements: [PPElement], bytesInFrame: Int)? {
                guard let index = data.indexOf(character: "\n") else {
                    return nil
                }
                print("index: \(index)")
                let payloadData = data.prefix(index)
                print("payload len: \(payloadData.count)")
                return (elements: [.payload(data)], index+1)
            }

        }
         */
        /*
        let packetProcessor = SwiftPacketProcessor<String>()
        var returnString: String?

        packetProcessor.add(NewlineFrame.self) { packet in
            returnString = "Found a packet: \(packet.payload)"
            expectation.fulfill()
        }
         */
        /*
        packetProcessor.addPacketHandler({ packet in
            returnString = "Found a packet: \(packet)"
            expectation.fulfill()
        })
         */

        /*
        packetProcessor.push("Hello")
        packetProcessor.push(" world!\n")

        self.wait(for: [expectation], timeout: 2)

        XCTAssertEqual(returnString, "Found a packet: Find a newline.")
         */
//        XCTAssertEqual(SwiftPacketProcessor().text, "Hello, World!")
    }
}

fileprivate extension Data {
    func indexOf(character: String) -> Int? {
        return self.firstIndex(of: Character("\n").asciiValue!)
    }
}

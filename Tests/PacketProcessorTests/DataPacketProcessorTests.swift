import Foundation
import XCTest
@testable import PacketProcessor

final class DataPacketProcessorTests: XCTestCase {
    var dataProcessor = PacketProcessor<Data>()

    // A test of "typical" network byte protocols
    override func setUpWithError() throws {
        self.dataProcessor = PacketProcessor<Data>()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testThat_DifferentPacketTypes_Have_DiffernetPacketIDs() throws {
        XCTAssertNotEqual(PlayerMovement._packetTypeId, PlayerAttack._packetTypeId)
    }

    func testThat_PacketId_Is_Static() throws {
        let packetId1 = PlayerMovement._packetTypeId
        let packetId2 = PlayerMovement._packetTypeId

        XCTAssertEqual(packetId1, packetId2)
    }

    func testThat_GeneratedMovement_isEqualTo_ParsedMovement() throws {
        let inputValue = PlayerMovement(playerId: 0x23, direction: .East)
        let expectedValue = inputValue

        let packetData = inputValue.toData()
        guard let processedMovement = PlayerMovement.findFirstPacket(context: SwiftPacketContext(), data: packetData) else {
            XCTFail("Did not find a valid packet!")
            return
        }
        let observedValue = processedMovement.packet

        XCTAssertEqual(expectedValue, observedValue)
    }

    func testExample() throws {
        self.dataProcessor.add(PlayerMovement.self) { packet in
            print("got movement packet: \(packet)")
        }
    }
}

fileprivate extension Data {
    func indexOf(character: String) -> Int? {
        return self.firstIndex(of: Character("\n").asciiValue!)
    }
}

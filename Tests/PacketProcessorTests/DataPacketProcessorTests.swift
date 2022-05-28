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

    func testThat_DifferentPacketTypes_Are_Different() throws {
        let movementId = ObjectIdentifier(PlayerMovement.self)
        let attackid = ObjectIdentifier(PlayerAttack.self)
        XCTAssertNotEqual(movementId, attackid)
    }

    func testThat_PacketId_Is_Static() throws {
        let packetId1 = ObjectIdentifier(PlayerMovement.self)
        let packetId2 = ObjectIdentifier(PlayerMovement.self)

        XCTAssertEqual(packetId1, packetId2)
    }

    func testThat_DifferentPacketsWithSameName_Are_Different() throws {
        class Container {
            struct PlayerMovement: DataPacket {
                static func findFirstPacket(context: PacketHandlerContext, data: Data) -> PacketSearchResult<Container.PlayerMovement>? {
                    return nil
                }
            }
        }

        let packetId1 = ObjectIdentifier(PlayerMovement.self)
        let packetId2 = ObjectIdentifier(Container.PlayerMovement.self)

        XCTAssertNotEqual(packetId1, packetId2)
    }

    func testThat_GeneratedMovement_isEqualTo_ParsedMovement() throws {
        let inputValue = PlayerMovement(playerId: 0x23, direction: .East)
        let expectedValue = inputValue

        let packetData = inputValue.toData()
        guard let processedMovement = PlayerMovement.findFirstPacket(context: PacketHandlerContext(), data: packetData) else {
            XCTFail("Did not find a valid packet!")
            return
        }
        let observedValue = processedMovement.packet

        XCTAssertEqual(expectedValue, observedValue)
    }

    func testExample() throws {
        self.dataProcessor.addHandler(PlayerMovement.self) { packet in
            print("got movement packet: \(packet)")
        }
    }
}

fileprivate extension Data {
    func indexOf(character: String) -> Int? {
        return self.firstIndex(of: Character("\n").asciiValue!)
    }
}

//
//  SyslogFilePacketProcessorTests.swift
//  
//
//  Created by Danny Sung on 04/25/2022.
//

import Foundation
import XCTest
import PacketProcessor

// RFC5424 - syslog format

class SyslogFilePacketProcessorTests: XCTestCase {
    let logConents = """
    Mar  1 03:37:35 myserver rsyslogd: [origin software="rsyslogd" swVersion="5.8.10" x-pid="14251" x-info="http://www.rsyslog.com"] rsyslogd was HUPed
    Mar  7 12:51:09 myserver yum[29215]: Updated: libX11-common-1.6.4-4.el6_10.noarch
    Mar  7 12:51:09 myserver yum[29215]: Updated: libX11-1.6.4-4.el6_10.x86_64
    Mar  7 12:52:05 myserver yum[29307]: Updated: kernel-firmware-2.6.32-754.35.1.el6.noarch
    Mar  7 12:52:10 myserver yum[29307]: Installed: kernel-2.6.32-754.35.1.el6.x86_64
    Mar  7 12:52:11 myserver yum[29307]: Updated: kernel-headers-2.6.32-754.35.1.el6.x86_64
    Mar 29 07:01:01 myserver auditd[941]: Audit daemon rotating log files
    Apr 25 16:54:12 myserver sshd[7191]: Accepted publickey for root from 93.184.216.34 port 42157 ssh2
    Apr 25 16:54:12 myserver sshd[7191]: pam_unix(sshd:session): session opened for user root by (uid=0)

    """

    var packetProcessor = PacketProcessor<String>()

    struct SyslogPacket: StringPacket, Equatable {
        let date: Date
        let server: String
        let component: String
        let message: String

        static func findFirstPacket(context: SwiftPacketContext, data: String) -> PacketSearchResult<SyslogFilePacketProcessorTests.SyslogPacket>? {

            // We can ignore packets that do not have a newline as they are incomplete
            guard let newlineIndex = data.range(of: "\n") else { return nil }
            let line = data[data.startIndex..<newlineIndex.lowerBound]

            // If there is no separator, the packet is also incomplete
            guard let separatorIndex = line.range(of: ": ") else { return nil }

            // Require that we have exactly 5 space-separated components
            let columns = line[..<separatorIndex.lowerBound].split(separator: " ")
            guard columns.count == 5 else { return nil }

            let month = columns[0]
            let day = columns[1]
            let time = columns[2]
            let timeFields = time.split(separator: ":")
            guard timeFields.count == 3 else { return nil }

            let host = String(columns[3])
            let component = String(columns[4])
            let message = String(line[separatorIndex.upperBound...])

            let monthMap = [
                "Jan" : 0,
                "Feb" : 1,
                "Mar" : 2,
                "Apr" : 3,
                "May" : 4,
                "Jun" : 5,
                "Jul" : 6,
                "Aug" : 7,
                "Sep" : 8,
                "Oct" : 9,
                "Nov" :10,
                "Dec" :11
            ]

            var dateComponents = DateComponents()
            dateComponents.month = monthMap[String(month)]
            dateComponents.day = Int(day)
            dateComponents.year = Calendar.current.component(.year, from: Date())
            dateComponents.hour = Int(timeFields[0])
            dateComponents.minute = Int(timeFields[1])
            dateComponents.second = Int(timeFields[2])

            guard let date = Calendar.current.date(from: dateComponents) else { return nil }

            let packet = SyslogPacket(date: date, server: host, component: component, message: message)

            return PacketSearchResult(packet: packet,
                                      numberOfElementsConsumedByPacket: line.count+1)
        }
        static var _packetTypeId = UUID()
    }

    override func setUp() async throws {
        self.packetProcessor = PacketProcessor<String>()
    }

    override func tearDown() async throws {
    }

    func feedPacketProcessor() {
        let bufferSize = Int( (1...100).randomElement()! )
        print("Feeding packet processor with buffer size: \(bufferSize) elements")
        var inputBuffer = self.logConents
        while inputBuffer.count > 0 {
            let firstBlock = String(inputBuffer.prefix(bufferSize))
            print("read a block (\(firstBlock.count)): \(firstBlock.replacingOccurrences(of: "\n", with: "\\n"))")

            self.packetProcessor.push(firstBlock)
            inputBuffer.removeFirst(firstBlock.count)
        }
    }

    func testThat_FirstLine_MatchesExpectation() throws {
        self.packetProcessor.addHandler(SyslogPacket.self) { packet in
            print("found: \(packet)")
        }

        self.feedPacketProcessor()

//        Mar  1 03:37:35 myserver rsyslogd: [origin software="rsyslogd" swVersion="5.8.10" x-pid="14251" x-info="http://www.rsyslog.com"] rsyslogd was HUPed

    }

    class PacketObserver<ReturnValue: Any>: Operation {
        public private(set) var value: ReturnValue!
        var error: Error?
        let packetProcessor: PacketProcessor<String>
        let block: () async throws -> ReturnValue

        init(packetProcessor: PacketProcessor<String>, block: @escaping () async throws -> ReturnValue) {
            self.packetProcessor = packetProcessor
            self.block = block
        }

        override func main() {
            Task {
                do {
                    self.value = try await self.block()
                } catch {
                    self.error = error
                }
            }

        }
    }

    func testThat_FirstLine_MatchesExpectation_WithAsyncSequence() async throws {
//        class Observed: Operation {
//            var value: SyslogPacket?
//            var error: Error?
//            let packetProcessor: PacketProcessor<String>
//
//            init(packetProcessor: PacketProcessor<String>) {
//                self.packetProcessor = packetProcessor
//            }
//
//            override func main() {
//                Task {
//                    do {
//                        for try await packet in self.packetProcessor.handle(SyslogPacket.self) {
//                            self.value = packet
//                            break
//                        }
//                    } catch {
//                        self.error = error
//                    }
//                }
//
//            }
//        }
        var expectedDateComponents = DateComponents()
        expectedDateComponents.month = 2 // Mar
        expectedDateComponents.day = 1
        expectedDateComponents.year = Date().year
        expectedDateComponents.hour = 3
        expectedDateComponents.minute = 37
        expectedDateComponents.second = 35
        let expectedDate = Calendar.current.date(from: expectedDateComponents)!

        // Expected Line: Mar  1 03:37:35 myserver rsyslogd: [origin software="rsyslogd" swVersion="5.8.10" x-pid="14251" x-info="http://www.rsyslog.com"] rsyslogd was HUPed
        let expectedValue = SyslogPacket(date: expectedDate, server: "myserver", component: "rsyslogd", message: "[origin software=\"rsyslogd\" swVersion=\"5.8.10\" x-pid=\"14251\" x-info=\"http://www.rsyslog.com\"] rsyslogd was HUPed")
//        let observed = Observed(packetProcessor: self.packetProcessor)

        // Place observer in it's own operation queue because we're going to feed into the packet processor after the handler is setup
        let opQ = OperationQueue()
        let observer = PacketObserver<SyslogPacket?>(packetProcessor: self.packetProcessor) {
            for try await packet in self.packetProcessor.handle(SyslogPacket.self) {
                return packet
            }
            return nil
        }
        opQ.addOperation(observer)

        self.feedPacketProcessor()

        opQ.waitUntilAllOperationsAreFinished()

        XCTAssertEqual(expectedValue, observer.value!)
    }

    func testThat_NumberOfPackets_IsCorrect() {
        let expectedValue = 9
        let observedValue: Int

        let lines = self.logConents.split(separator: "\n")
        print("line count: \(lines.count)")

        let opQ = OperationQueue()
        let observer = PacketObserver<Int>(packetProcessor: self.packetProcessor) {
            var count = 0
            for try await _ in self.packetProcessor.handle(SyslogPacket.self) {
                count += 1
            }
            return count
        }
        opQ.addOperation(observer)
        self.feedPacketProcessor()

        opQ.waitUntilAllOperationsAreFinished()
        observedValue = observer.value

        XCTAssertEqual(expectedValue, observedValue)
    }
    
}



fileprivate extension Date {
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
}

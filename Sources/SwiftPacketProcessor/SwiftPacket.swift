import Foundation

public protocol AnySwiftPacket {

}

public protocol SwiftPacket: AnySwiftPacket {
//    associatedtype CollectionType: RangeReplaceableCollection //RandomAccessCollection & MutableCollection
    associatedtype CollectionType: SwiftPacketCollectionType

    static func getPacket(context: SwiftPacketContext, data: CollectionType) -> (packet: Self, countInPacket: Int)?
//    static func getPacket<CollectionType: SwiftPacketCollectionType>(context: PPFrameContext, data: CollectionType) -> (packet: SwiftPacket, countInPacket: Int)?

//    var _packetType: Self { get }
}
extension SwiftPacket {

}

/*
func f() {
var d = Data()
var s = ""

    d.append(contentsOf: [])
    s.append(contentsOf: "")

}

*/

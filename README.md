<p align="center">
<a href="https://swiftpackageindex.com/dannys42/SwiftPacketProcessor"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdannys42%2FSwiftPacketProcessor%2Fbadge%3Ftype%3Dswift-versions"></a>
<a href="https://swiftpackageindex.com/dannys42/SwiftPacketProcessor"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdannys42%2FSwiftPacketProcessor%2Fbadge%3Ftype%3Dplatforms"></a>
<a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache2-blue.svg?style=flat" alt="Apache 2"></a>
</p>

# PacketProcessor

The Swift `PacketProcessor` provides a simple, type-safe way of handling structured packets given a data stream.

`PacketProcessor` handles the details of buffer management when reading a data stream.  Callers need only push newly received data to the `PacketProcessor`.  The correct handlers for the appropriately typed packet will be called when appropriate.

Packet definitions must include rules for validating the packet and returning the number of data elements consumed by the packet. See `DataPacket` and `StringPacket`.

Streams can have a base collection type of `String` or `Data` by initializing as `PacketProcessor<String>` or `PacketProcessor<Data>`.


## Installation

### Swift Package Manager
Add the `PacketProcessor ` package to the dependencies within your application's `Package.swift` file.  Substitute "x.y.z" with the [latest PacketProcessor release](https://github.com/dannys42/PacketProcessor/releases).

```swift
.package(url: "https://github.com/dannys42/SwiftPacketProcessor", from: "x.y.z")
```

Add `PacketProcessor` to your target's dependencies:

```swift
.target(name: "example", dependencies: ["PacketProcessor"]),
```

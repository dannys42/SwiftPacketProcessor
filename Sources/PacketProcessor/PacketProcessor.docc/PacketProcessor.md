# ``PacketProcessor``

## Overview

``PacketProcessor`` takes care of buffer management when processing packetized data within streams. 

## Intro

where am i?

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:/Tutorials/Tutorial-TOC>
<!--- <doc:/Tutorials/DataPacket>-->
<!--- ``PacketProcessor``-->

### Initializing a Packet Processor

- ``PacketProcessor/PacketProcessor``

### Defining Packets
- ``DataPacket``
- ``StringPacket``
- ``PacketContext``

### Internals

- ``AnyPacket``
- ``Packet``
- ``PacketCollectionType``

Say something smart here!

// - Example
//
//  ```swift
//     struct MyPacket: DataPacket {
//         // Packet implementation here
//     }
//     let packetProcessor = PacketProcessor<Data>()
//     packetProcessor.add(MyPacket.self) { packet in
//         // Handle packet of type `MyPacket` here.
//     }
//  ```
//

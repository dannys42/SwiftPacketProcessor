# ``PacketProcessor``

``PacketProcessor`` takes care of buffer management when processing packetized data within streams. 

## Intro

``PacketProcessor`` allows you to process any type of packet (whether variable or fixed length, binary, or string) by writing simple definitions for your ``PacketProcessor/Packet``s.

In addition, ``PacketProcessor`` is able to aid you in handling any packet type when reading chunked data, e.g. from a very large file to be more memory efficient or from a network socket where there may be latency between chunks.


## Topics

### Essentials

- <doc:GettingStarted>
- <doc:/tutorials/Tutorial-TOC>
<!--- <doc:/tutorials/DataPacket>-->
<!--- ``PacketProcessor``-->

### Initializing a Packet Processor

- ``PacketProcessor/PacketProcessor``

### Defining & Handling Packets
- ``DataPacket``
- ``StringPacket``
- ``PacketHandlerContext``

### Internals

- ``AnyPacket``
- ``Packet``
- ``PacketCollectionType``


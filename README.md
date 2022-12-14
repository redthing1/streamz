
# streamz

a stream IO library for D based on freck-streams abandoned source code.

## MemoryStream

Simple in-memory stream.

```D
import std.stdio;
import streamz.face;
import streamz.memorystream;

auto stream = MemoryStream.fromBytes(cast(ubyte[])"Hello", ["Roses": "Are red"]);

stream.seek(0, Seek.end);
stream.write(cast(ubyte[])" World!");

writeln("Roses: ", stream.getMetadata("Roses"));
writeln("Stream content: ", cast(string)stream.getContents);
```

## FileStream

Simple file stream built on top of `std.stdio.File`.

```D
import std.stdio;
import streamz.face;
import streamz.filestream;

auto stream = new FileStream("stream.txt", "w+b", ["Roses": "Are red"]);

stream.write(cast(ubyte[])"Hello World!");
stream.seek(0, Seek.set);

writeln("Roses: ", stream.getMetadata("Roses"));
//.read(1024) Reads 1024 bytes or the whole stream to the end, if it is smaller.
writeln("Stream content: ", cast(string)stream.read(1024));
```

## AppendStream

Reads from multiple streams, one after the other.

```D
import std.stdio;
import streamz.face;
import streamz.memorystream;
import streamz.appendstream;

auto stream1 = MemoryStream.fromBytes(cast(ubyte[])"Hello ");
auto stream2 = MemoryStream.fromBytes(cast(ubyte[])"World");
auto stream3 = MemoryStream.fromBytes(cast(ubyte[])"!");

auto allTogether = new AppendStream([
  stream1,
  stream2,
  stream3,
]);

writeln("Stream content: ", cast(string)allTogether.getContents);
```

## Endianness

Each stream has an endianness attribute with default value `Endian.platform`. This attribute affects on reading/writing scalar types from/to the stream.

```D
import std.stdio;
import streamz.face;
import streamz.memorystream;
import streamz.util: readScalar;

auto stream = MemoryStream.fromBytes(cast(ubyte[])[1, 2, 3, 4]);

stream.setEndian(Endian.little);
stream.seek(0);
auto ret1 = stream.readScalar!uint;
writefln("Returns: %.8x", ret1); //04030201

stream.setEndian(Endian.big);
stream.seek(0);
auto ret2 = stream.readScalar!uint;
writefln("Returns: %.8x", ret2); //01020304
```

module streamz.streams.memorystream;

import streamz.stream;

///Memory i/o stream
class MemoryStream : Stream
{
	import streamz.exception;
	import streamz.util.misc: writeRaw;

protected:
	ubyte[] buf;
	size_t ptr;

	this(ubyte[] buf, string[string] metadata = null, Endian e = Endian.platform)
	{
		super(metadata, e);

		this.buf = buf;
		this.ptr = 0;
	}

public:

	/***********************************
	 * Creates an empty memory stream
	 *
	 * Params:
	 *  e = Endianness (default: platform)
	 */
	static MemoryStream fromScratch(string[string] metadata = null, Endian e = Endian.platform)
	{
		return new MemoryStream([], metadata, e);
	}

	/***********************************
	 * Creates a memory stream initialized with an array of unsigned bytes
	 *
	 * Params:
	 *  buf = Initial array
	 *  e = Endianness (default: platform)
	 */
	static MemoryStream fromBytes(ubyte[] buf, string[string] metadata = null, Endian e = Endian.platform)
	{
		return new MemoryStream(buf, metadata, e);
	}

	/***********************************
	 * Creates a memory stream initialized with content of a file
	 *
	 * Params:
	 *  fileName = File name
	 *  e = Endianness (default: platform)
	 */
	static MemoryStream fromFile(in string fileName, string[string] metadata = null, Endian e = Endian.platform)
	{
		import std.stdio: File;

		auto f = File(fileName, "rb");
		auto buffer = new ubyte[cast(uint)(f.size())];
		f.rawRead(buffer);

		return new MemoryStream(buffer, metadata, e);
	}


	override @property ssize_t length()
	{
		return this.buf.length;
	}

	override ssize_t tell()
	{
		return this.ptr;
	}

	override @property bool isEmpty()
	{
		return (this.ptr == (this.length));
	}

	override bool isSeekable()
	{
		return true;
	}

	override ssize_t seek(in sdiff_t pos, in Seek origin = Seek.set)
	{
		with (Seek) final switch (origin) {
			case set:
				this.ptr = cast(size_t)(pos);
				break;
			case cur:
				this.ptr = cast(size_t)(this.ptr + pos);
				break;
			case end:
				this.ptr = cast(size_t)(this.buf.length - pos);
				break;
		}

		if (this.ptr > this.buf.length) this.ptr = this.buf.length;

		return this.ptr;
	}

	override bool isWritable()
	{
		return true;
	}

	override void write(in ubyte b)
	{
		if (this.ptr == this.buf.length) {
			this.buf ~= b;
			this.ptr++;
		} else {
			this.buf[this.ptr++] = b;
		}
	}

	override void write(in ubyte[] b)
	{
		if (this.ptr == this.buf.length) {
			this.buf ~= b;
			this.ptr = this.buf.length;
		} else if (this.ptr+b.length < this.buf.length) {
			this.buf[this.ptr .. (this.ptr + b.length)] = b;
		} else {
			this.buf.length = this.ptr;
			this.buf ~= b;
			this.ptr = this.buf.length;
		}
	}

	override bool isReadable()
	{
		return true;
	}

	override ubyte read()
	{
		if ((this.ptr + ubyte.sizeof) > this.length) {
			throw new StreamsException(boundsError);
		}

		return this.buf[this.ptr++];
	}

	override ubyte[] read(in size_t n)
	{
		auto a = this.ptr;
		this.ptr += ((this.ptr + n) > this.length) ? (this.length - this.ptr) : n;
		return this.buf[a .. this.ptr];
	}

	override ubyte[] getContents()
	{
		return this.buf;
	}

}

unittest
{
	import std.stdio: stdout, write, writeln;
	import streamz.tests;

	write("Running MemoryStream simple tests:"); stdout.flush;
	assertSimpleReads(MemoryStream.fromScratch());
	assertSimpleWrites(MemoryStream.fromScratch());
	writeln(" OK");

	write("Running MemoryStream raw i/o tests:"); stdout.flush;
	assertRawWrite(MemoryStream.fromScratch());
	assertRawRead(MemoryStream.fromScratch());
	writeln(" OK");
}
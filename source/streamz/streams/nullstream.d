module streamz.streams.nullstream;

import streamz.stream;

///Implementation of an empty stream.
class EmptyStream : Stream
{
	import streamz.exception;
public:
	this(string[string] metadata = null, Endian e = Endian.platform)
	{
		super(metadata, e);
	}

	override @property ssize_t length()
	{
		return 0;
	}

	override ssize_t tell()
	{
		return 0;
	}

	override @property bool isEmpty()
	{
		return true;
	}

	override bool isSeekable()
	{
		return false;
	}

	override ssize_t seek(in sdiff_t pos, in Seek origin = Seek.set)
	{
		throw new StreamsException(nonSeekable);
	}

	override bool isWritable()
	{
		return false;
	}

	override void write(in ubyte b)
	{
		throw new StreamsException(writeToNonwritable);
	}

	override void write(in ubyte[] b)
	{
		throw new StreamsException(writeToNonwritable);
	}

	override bool isReadable()
	{
		return false;
	}

	override ubyte read()
	{
		throw new StreamsException(readFromNoreadable);
	}

	override ubyte[] read(in size_t n)
	{
		throw new StreamsException(readFromNoreadable);
	}

	override ubyte[] getContents()
	{
		return [];
	}
}

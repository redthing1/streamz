module streamz.murmur3;

import streamz.face;
import streamz.util.misc: readScalar;

/+@nogc+/
private pure nothrow uint rotl32(uint x, uint r) {
	return (x << r) | (x >> (32 - r));
}

/+@nogc+/
private pure nothrow uint fmix32(uint h) {
	h ^= h >> 16;
	h *= 0x85ebca6b;
	h ^= h >> 13;
	h *= 0xc2b2ae35;
	h ^= h >> 16;

	return h;
}

/***********************************
 * Returns: The 32 bit murmur3 hash computed from a stream
 *
 * Params:
 *  s = The stream
 *  seed = An optional seed
 */
@property uint murmur3(IStream s, uint seed = 0)
{
	import streamz.stream;

	immutable auto length = s.length;
	immutable auto nblocks = length >> 2;

	enum c1 = 0xcc9e2d51;
	enum c2 = 0x1b873593;

	auto h1 = seed;

	immutable auto seekSave = s.tell();
	s.seek(0);

	foreach (_; 0 .. nblocks) {
		auto k1 = s.readScalar!uint;//s.readUint();

		k1 *= c1;
		k1 = rotl32(k1, 15);
		k1 *= c2;

		h1 ^= k1;
		h1 = rotl32(h1, 13);
		h1 = h1 * 5 + 0xe6546b64;
	}

	uint k1 = 0;
	const ubyte[] tail = s.read(cast(size_t)(length - (nblocks << 2)));
	final switch (length & 3) {
	case 3:
		k1 ^= tail[2] << 16;
		goto case 2;
	case 2:
		k1 ^= tail[1] << 8;
		goto case 1;
	case 1:
		k1 ^= tail[0];
		k1 *= c1;
		k1 = rotl32(k1, 15);
		k1 *= c2;
		h1 ^= k1;
		goto case 0;
	case 0:
		break;
	}

	h1 ^= length;

	s.seek(seekSave);

	return fmix32(h1);
}

///
unittest
{
	import std.stdio: stdout, write, writeln;
	import streamz.memorystream: MemoryStream;

	write("Running MurMur3 tests:"); stdout.flush;

	foreach (str, result; [
		"Hello, teenage America": 0xbe3880f1,
		"The quick brown fox jumps over the lazy dog": 0x2e4ff723,
		"hash me!": 0x7adaaf4e
	]) {
		auto stream = MemoryStream.fromBytes(cast(ubyte[])(str));
		assert(stream.murmur3 == result);
	}

	writeln(" OK");
}


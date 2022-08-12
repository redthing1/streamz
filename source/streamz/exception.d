module streamz.exception;

package static immutable boundsError = "Attempted to read outside the bounds of the stream";
package static immutable appendNonreadableStream = "Each stream of AppendStream must be readable";
package static immutable cantOpenFile = "Can't open file ";
package static immutable cantGetFilestat = "Can't get filestat ";
package static immutable invalidMode = "Invalid file open mode";
package static immutable nonSeekable = "This stream is not seekable";
package static immutable onlySetOrigin = "This stream can only seek with Seek.set";
package static immutable writeToNonwritable = "This stream is non-writable";
package static immutable readFromNoreadable = "This stream is non-readable";

///Package default exception
class StreamsException : Exception {
	///constructor
	this(string s, string fn = __FILE__, size_t ln = __LINE__) @safe pure nothrow
	{
		super(s, fn, ln);
	}
}

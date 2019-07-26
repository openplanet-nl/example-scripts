#name "Network example"
#author "Miss"

/* This plugin will open a TCP socket on port 80 to icanhazip.com, sends a
 * GET request to the server, and waits for a response to print to log.
 *
 * This is all done in an asynchronous manner - the connecting, the sending,
 * and the receiving of the response. This is accomplished by yielding.
 */

// Main() is our entry point. Note that when this function returns, the plugin
// will be inactive. See also the Plugin_YieldTest example.
void Main()
{
	// Create a new socket.
	auto sock = Net::Socket();

	// Try to initiate a socket to icanhazip.com on port 80.
	if (!sock.Connect("icanhazip.com", 80)) {
		// If it failed, there was some socket error. (This is not necessarily
		// a connection error!)
		print("Couldn't initiate socket connection.");
		return;
	}

	print(Time::Now + " Connecting to host...");

	// Wait until we are connected. This is indicated by whether we can write
	// to the socket.
	while (!sock.CanWrite()) {
		yield();
	}

	print(Time::Now + " Connected! Sending request...");

	// Send raw data (as a string) to the server.
	if (!sock.WriteRaw(
		"GET / HTTP/1.1\r\n" +
		"Host: icanhazip.com\r\n" +
		"User-agent: Openplanet NetworkTest Plugin\r\n" +
		"Connection: close\r\n" +
		"\r\n"
	)) {
		// If this fails, the socket might not be open. Something is wrong!
		print("Couldn't send data.");
		return;
	}

	print(Time::Now + " Waiting for headers...");

	// We are now ready to wait for the response. We'll need to note down
	// the content length from the response headers as well.
	int contentLength = 0;

	while (true) {
		// If there is no data available yet, yield and wait.
		while (sock.Available() == 0) {
			yield();
		}

		// There's buffered data! Try to get a line from the buffer.
		string line;
		if (!sock.ReadLine(line)) {
			// We couldn't get a line at this point in time, so we'll wait a
			// bit longer.
			yield();
			continue;
		}

		// We got a line! Trim it, since ReadLine() returns the line including
		// the newline characters.
		line = line.Trim();

		// Parse the header line.
		auto parse = line.Split(":");
		if (parse.get_Length() == 2 && parse[0].ToLower() == "content-length") {
			// If this is the content length, remember it.
			contentLength = Text::ParseInt(parse[1].Trim());
		}

		// If the line is empty, we are done reading all headers.
		if (line == "") {
			break;
		}

		// Print the header line.
		print(Time::Now + " \"" + line + "\"");
	}

	print(Time::Now + " Waiting for response...");

	// At this point, we've parsed all the headers. We can now wait for the
	// actual response body.
	string response = "";

	// While there is content to read from the body...
	while (contentLength > 0) {
		// Try to read up to contentLength.
		string chunk = sock.ReadRaw(contentLength);

		// Add the chunk to the response.
		response += chunk;

		// Subtract what we've read from the content length.
		contentLength -= chunk.Length();

		// If there's more to read, yield until the next frame. (Not necessary,
		// we could also only yield if there's no data available, but in this
		// example we don't care too much.)
		if (contentLength > 0) {
			yield();
		}
	}

	// We're all done!
	print(Time::Now + " All done!");
	print(Time::Now + " Response: \"" + response + "\"");

	// Close the socket.
	sock.Close();
}

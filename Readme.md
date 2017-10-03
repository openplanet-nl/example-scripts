# Example Scripts

These are example scripts for Openplanet. All examples are fully commented to explain what's going on in the code.

If you have a script you want to contribute to this repository, please don't hesitate [submitting a pull request](/openplanet-nl/example-scripts/compare).

## [`NetworkTest.as`](NetworkTest.as)

This plugin will open a TCP socket on port 80 to icanhazip.com, sends a GET request to the server, and waits for a response to print to log.

This is all done in an asynchronous manner - the connecting, the sending, and the receiving of the response. This is accomplished by yielding.

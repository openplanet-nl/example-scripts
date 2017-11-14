# Example Scripts

These are example scripts for Openplanet. All examples are fully commented to explain what's going on in the code.

If you have a script you want to contribute to this repository, please don't hesitate [submitting a pull request](/openplanet-nl/example-scripts/compare).

## [`Plugin_NetworkTest.as`](Plugin_NetworkTest.as)

This plugin will open a TCP socket on port 80 to icanhazip.com, sends a GET request to the server, and waits for a response to print to log.

This is all done in an asynchronous manner - the connecting, the sending, and the receiving of the response. This is accomplished by yielding.

## [`Plugin_YieldTest.as`](Plugin_YieldTest.as)

This plugin demonstrates how a script loop works. Openplanet will execute the `Main()` function in our plugin every game/server frame.

We can then call `yield()` to suspend script execution and return execution back to Openplanet & Maniaplanet, or we can call `sleep()` with a milliseconds parameter to yield for a specific amount of time.

In this example, we will increase a variable by 2 on the first frame, decrease it by 1 the second frame, then wait 1 second and do it again.

## License

All scripts in this repository are MIT licensed. You can use them however you wish.

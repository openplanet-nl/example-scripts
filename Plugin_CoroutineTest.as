#name "Coroutine example"
#author "Miss"
#category "Examples"

/* This plugin demonstrates how coroutines work and how they can be
 * created and managed.
 *
 * Coroutines can be looked at in a similar way as threads, except that
 * they are single-threaded. Whenever a routine yields or returns (also
 * see Plugin_YieldTest.as) it will give the script engine a chance to
 * run other coroutines from the plugin, as well as routines from other
 * plugins.
 *
 * Coroutines are not guaranteed to run at the same frequency, they are
 * however guaranteed to be executed parallel within the same thread.
 */

// This is our Main function. In itself, it is also a coroutine.
void Main()
{
	// We will start a new coroutine here, with a function defined below.
	startnew(MyCoroutine);

	// Next, we put this routine into an infinite loop.
	while (true) {
		print("Hello from Main()");
		sleep(1000);
	}
}

// This is the function for the coroutine we created in Main().
void MyCoroutine()
{
	// We are allowed to yield within this function, as it is a coroutine.
	// Now, let's start another infinite loop on a different frequency as
	// the loop in Main(). This will demonstrate that they are in fact
	// running in parallel.
	while (true) {
		print("MyCoroutine() here");
		sleep(250);
	}
}

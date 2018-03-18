#name "Yield example"
#author "Miss"

/* This plugin demonstrates how a script loop works. Openplanet will
 * execute the Main() function in our plugin every game/server frame.
 *
 * We can then call `yield()` to suspend script execution and return
 * execution back to Openplanet & Maniaplanet, or we can call `sleep()`
 * with a milliseconds parameter to yield for a specific amount of time.
 *
 * In this example, we will increase a variable by 2 on the first frame,
 * decrease it by 1 the second frame, then wait 1 second and do it again.
 */

// This is the variable we will be modifying in our script loop.
int g_num = 0;

// Main() is our entry point function for our script loop.
void Main()
{
	// This will be our script loop.
	while (true) {
		// Add 2.
		g_num += 2;
		print(Time::Now + " Num = " + g_num);

		// Suspend script execution.
		yield();

		// When script execution is resumed in the next frame, we continue
		// from here. So let's subtract 1 in this frame.
		g_num -= 1;
		print(Time::Now + " Num = " + g_num);

		// Let's suspend the script for 1 second.
		sleep(1000);
	}

	// The plugin lifetime is over when the end of this function is reached.
}

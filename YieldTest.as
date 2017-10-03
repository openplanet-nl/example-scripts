/* YieldTest by Miss
 *
 * This plugin demonstrates how a script fiber works. Openplanet will
 * execute the Fiber() function in our plugin every game/server frame.
 *
 * We can then call `yield()` to suspend script execution and return
 * execution back to Openplanet & Maniaplanet, or we can call `sleep()`
 * with a milliseconds parameter to yield for a specific amount of time.
 *
 * In this example, we will increase a variable by 2 on the first frame,
 * decrease it by 1 the second frame, then wait 1 second and do it again.
 */

[Plugin]
class YieldTest
{
	// This is the variable we will be modifying in our script fiber.
	int m_num = 0;

	// Fiber() is our entry point function for our script fiber.
	void Fiber()
	{
		// This will be our fiber loop.
		while (true) {
			// Add 2.
			m_num += 2;
			print(Time::now + " Num = " + m_num);

			// Suspend script execution.
			yield();

			// When script execution is resumed in the next frame, we continue
			// from here. So let's subtract 1 in this frame.
			m_num -= 1;
			print(Time::now + " Num = " + m_num);

			// Let's suspend the script for 1 second.
			sleep(1000);
		}
	}
}

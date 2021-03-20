#name "Draw example"
#author "Miss"
#category "Examples"

/* This plugin is a simple demo of the drawing API. It draws a circle
 * and a rounded square on the screen, with a line in between, and the
 * text "Hello, world!" next to it.
 *
 * It moves this continously across the screen.
 */

// These are just some states we have to remember for our movement.
uint64 g_fromTime;
uint64 g_toTime;
vec2 g_fromPoint;
vec2 g_toPoint;
float g_fromCircleRadius;
float g_toCircleRadius;

int g_interval = 500;

// Easing function.
float easeQuad(float x)
{
	if ((x /= 0.5) < 1) return 0.5 * x * x;
	return -0.5 * ((--x) * (x - 2) - 1);
}

// Our Main function, which merely updates our states when needed.
void Main()
{
	// Draw::GetWidth() gets the width of the screen. If this returns -1,
	// the rendering isn't ready yet and you can't use the Draw API, so
	// we have to wait for that to be a valid value.
	while (Draw::GetWidth() == -1) {
		yield();
	}

	g_toPoint = vec2(
		Draw::GetWidth() / 2.0f,
		Draw::GetHeight() / 2.0f
	);

	while (true) {
		g_fromPoint = g_toPoint;

		vec2 newPoint;
		do {
			float newAngle = Math::Rand(0.0f, Math::PI * 2.0f);
			newPoint = g_fromPoint + vec2(Math::Cos(newAngle), Math::Sin(newAngle)) * 300.0f;
		} while (newPoint.x < 0 || newPoint.y < 0 || newPoint.x > Draw::GetWidth() || newPoint.y > Draw::GetHeight());

		g_toPoint = newPoint;
		g_fromTime = Time::Now;
		g_toTime = g_fromTime + g_interval;

		g_fromCircleRadius = g_toCircleRadius;
		g_toCircleRadius = g_fromCircleRadius + 0.4f;

		// We sleep a bit to wait for the next needed change.
		sleep(g_interval);
	}
}

void Render()
{
	float timeFactor = Math::InvLerp(g_fromTime, g_toTime, Time::Now);

	vec4 colFill = vec4(1, 0.9f, 0.7f, 1);
	vec4 colBorder = vec4(1, 1, 1, 1);

	vec2 point = Math::Lerp(g_fromPoint, g_toPoint, easeQuad(timeFactor));
	float circleRadius = Math::Lerp(g_fromCircleRadius, g_toCircleRadius, timeFactor);
	vec2 circlePos = point + vec2(Math::Cos(circleRadius), Math::Sin(circleRadius)) * 75.0f;

	// Draws a line.
	Draw::DrawLine(point, circlePos, colBorder, 2.0f);

	// Draws a filled rectangle with a border rounding of 8px, followed
	// by a border of 2px width and 8px border rounding.
	Draw::FillRect(vec4(point.x - 16, point.y - 16, 32, 32), colFill, 8.0f);
	Draw::DrawRect(vec4(point.x - 16, point.y - 16, 32, 32), colBorder, 8.0f, 2.0f);

	// Draws a filled circle, followed by a border of 2px width.
	Draw::FillCircle(circlePos, 16.0f, colFill);
	Draw::DrawCircle(circlePos, 16.0f, colBorder, 2.0f);

	// Draws the string "Hello, world!" below the square position.
	Draw::DrawString(point + vec2(0, 24), colBorder, "Hello, world!");
}

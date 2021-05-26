#name "Settings example"
#author "Miss"
#category "Examples"

/* This plugin demonstrates how persistent settings can be created and
 * automatically stored in Openplanet's Settings.ini file.
 *
 * Settings must be one of the following data types: 
 *  - bool
 *  - int, float
 *  - string
 *  - enum
 *  - vec2, vec3, vec4
 * More will be added in the future if they are deemed necessary.
 */

// Each setting can have a name and description, which will be displayed
// in the plugin's settings panel.
[Setting name="Print foo" description="Prints foo every second."]
bool Foo = false;

// If a setting also sets its initial value, it will be its default value.
// Settings that have its default value will not be written to the config
// file, meaning that if left unchanged, modifying them within the script
// will always be applied.
[Setting]
int FooNumber = 10;

// Integer settings can also have optional range values. If set, the settings
// dialog will show a slider that travels between the specified range. Note
// that the value can still go outside the range either by manually modifying
// Settings.ini, or by Control-clicking the slider.
[Setting min=-50 max=50]
int FooNumberLimited;

// Settings don't necessarily need to have a default value. In this case,
// the default value is simply 0.0f.
[Setting]
float SomeFloat;

// Float settings can also have range values.
[Setting min=-2.5 max=2.5]
float SomeFloatLimited;

// This is a regular string setting.
[Setting]
string FooText = "Foo!";

// String settings can have a maximum length value. If set, the string can
// not be made longer than the given amount of characters, unless changed
// manually in Settings.ini.
[Setting max=30]
string FooTextLimited = "Foo..?";

// If a string setting is marked as multiline, it will appear as a multiline
// editor field in the settings dialog.
[Setting multiline]
string FooTextMultiline = "Foo!\nThere's multiple lines here.";

// For strings that represent passwords or other sensitive information, you
// can mark it as a password field. This will mask the characters in the
// settings dialog as asterisks.
[Setting password]
string FooTextPassword = "hunter2";

// Enum settings will appear as a drop-down selector in the settings dialog,
// listing each defined enum value.
[Setting]
MyEnum FooEnum = MyEnum::Foo;

// For vec3 and vec4 settings, the 'color' tag may be added. In the settings
// dialog, a color selector will be shown for these values.
[Setting color]
vec4 FooColor = vec4(0, 0, 0, 0.7f);

// All settings support the optional 'category' tag. If provided, settings
// will be organized under tabs, for each category. If all settings are in
// the same category, the tab bar will be hidden. If some settings have a
// category and other do not (such as in this script), the settings without
// a defined category will appear under the 'Uncategorized' tab. Tabs will
// appear in the order that they are first encountered.
[Setting category="Misc"]
int FooCategorizedValue = 25;

enum MyEnum
{
	Foo,
	Bar,
	Baz
}

// Our main routine
void Main()
{
	while (true) {
		// We print some stuff based on our settings here. Note that they can
		// be changed on-the-fly, and changes made in the settings dialog are
		// immediately changed within the script.
		if (Foo) {
			print(FooText + " " + FooNumber);
		}
		sleep(1000);
	}
}

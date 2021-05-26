#name "Settings advanced example"
#author "Phlarx"
#category "Examples"

/* This plugin demonstrates some techniques for storing
 * data with the Settings interface, when the data types
 * are not supported by the Setting annotation.
 * 
 * In this demonstration, we will be storing vec3 objects.
 * This data type is supported by the Settings interface,
 * natively, but they will serve as a simple example that
 * can be extended to more complex use cases, and in fact,
 * these techniques are most useful when applied to objects
 * that are more expensive to construct.
 * 
 * These examples are not intended to be the bible for
 * achieving these effects, but instead a set of ideas and
 * inspirations that you can apply to your use case. The
 * strategies used here can be mixed and matched, and built
 * upon.
 * 
 * Finally, larger data structures may benefit more from
 * being stored separately in their own data file, instead
 * of being shoehorned into the Settings ini file. Take note
 * of this when deciding which strategy is best for your
 * specific application.
 */

/* Our goal for each vec3 is to approximate the following
 * code:
 * 
 *     [Setting]
 *     vec3 Data;
 * 
 * Remember, the above code is valid, but this file will
 * show techniques that are applicable to unsupported data
 * types.
 * 
 * Each example has:
 * - a declaration, which defines the objects that we want
 *   to store.
 * - getters and setters which are able to store the object
 *   into the settings interface, and retrieve it again.
 * - accessors and mutators which are the script's normal
 *   interactions with the objects.
 *
 * In addition, the third example, called Qux, has a
 * separate pair of functions for data conversion. The other
 * two examples do their data conversion at the same place as
 * one or more of the parts listed above.
 */

/* [[FooColor declaration]]
 * The first vec3, Foo, will be stored by creating separate
 * entries for each component. This allows the user to set
 * these values within the Settings dialog. Since the Setting
 * annotation doesn't provide the facilities to automatically
 * synchonize the vec3 directly, we'll need to use both
 * OnSettingsChanged and OnSettingsLoad to get the updates
 * via the Settings interface, as well as manually change the
 * component values when the vec3 is updated.
 * 
 * Here, we see each float component declared individually,
 * with a Setting annotation for each, followed by the vec3
 * declaration.
 */
[Setting min=0.f max=1.f]
float FooR = 1.f;
[Setting min=0.f max=1.f]
float FooG = 0.f;
[Setting min=0.f max=1.f]
float FooB = 0.f;
vec3 FooColor = vec3(FooR, FooG, FooB);

/* [[BarColor declaration]]
 * The second vec3, Bar, does not use separated component values,
 * and as such, it will not appear in the Settings dialog. As a
 * result, we need to only declare the actual vec3 object.
 */
vec3 BarColor = vec3(0.f, 1.f, 0.f);

/* [[QuxColor declaration]]
 * The third vec3 is Qux, and like Bar, is does not appear in the
 * Settings dialog, and therefore we only need to declare the vec3.
 */
vec3 QuxColor = vec3(0.f, 0.f, 1.f);

/* OnSettingsChanged is called whenever an update occurs within the
 * Settings dialog.
 */
void OnSettingsChanged()
{
  /* [[FooColor get value from components]]
   * Since Foo is the only strategy which exposes the component
   * values to the Settings dialog, it is the only one which needs
   * to respond to that event. As the vec3 case is rather simple,
   * we can just immediately update the component values.
   */
  FooColor.x = FooR;
  FooColor.y = FooG;
  FooColor.z = FooB;
}

/* OnSettingsSave is called when stopping a plugin, which may be
 * caused by, for example, reloading the plugin or exiting the
 * game.
 * 
 * Note that the settings data is only written to the disk when
 * exiting the game, and is cached otherwise.
 */
void OnSettingsSave(Settings::Section& section)
{
  /* [[BarColor set value to Settings]]
   * Here, we manually set the component values for Bar to its
   * component values. In the Settings ini file, this will look
   * almost identical to the approach for Foo, but by using this
   * route, the components do not appear within the settings menu,
   * and we don't need to worry about keeping the values
   * synchonized.
   * 
   * As a side effect of doing this ourselves, values identical to
   * the default are not omitted from the ini, in contrast to Foo.
   */
  section.SetFloat("BarR", BarColor.x);
  section.SetFloat("BarG", BarColor.y);
  section.SetFloat("BarB", BarColor.z);
  
  /* [[QuxColor set value to Settings]]
   * For Qux, we use a similar approach to Bar by setting the
   * Settings ini values directly, but in this case we've used a
   * conversion method to convert the value of Qux to some data
   * type matively handled by the settings interface. In this case,
   * we are using a string holding JSON data. The definition of
   * writeQux is found near the bottom of this file.
   */
  section.SetString("Qux", writeQux(QuxColor));
}

/* OnSettingsLoad is called when starting a plugin, which may be
 * caused by, for example, reloading the plugin or launching the
 * game.
 * 
 * Note that the settings data is only read from the disk when
 * launching the game, and is cached otherwise.
 */
void OnSettingsLoad(Settings::Section& section)
{
  /* [[FooColor get value from components]]
   * Since OnSettingsChanged is not triggered at plugin startup,
   * we replicate the actions for Foo here.
   */
  FooColor.x = FooR;
  FooColor.y = FooG;
  FooColor.z = FooB;
  
  /* [[BarColor get value from Settings]]
   * When loading the values from the settings interface, we are
   * simply performing the inverse of what we had done in
   * OnSettingsSave. Additionally, we can provide default values
   * to use for each component, if that component is found to be
   * missing.
   */
  BarColor.x = section.GetFloat("BarR", 0.f);
  BarColor.y = section.GetFloat("BarG", 1.f);
  BarColor.z = section.GetFloat("BarB", 0.f);
  
  /* [[QuxColor get value from Settings]]
   * In the case of Qux, the default value is the full json
   * description of the object, and the result of the Settings
   * load is passed through a converter to create the actual
   * object that we want. The definition of parseQux is found
   * near the bottom of this file.
   */
  QuxColor = parseQux(section.GetString("Qux", "{'r':0,'g':0,'b':1}"));
}

void RenderInterface()
{
  UI::Begin("Settings Advanced", UI::WindowFlags::AlwaysAutoResize);
  
  /* [[FooColor accesses and mutations]]
   * Our strategy for Foo shows real-time updates in the Settings
   * dialog, so we need to manually update the individual
   * components whenever Foo is updated.
   */
  FooColor = UI::InputColor3("Foo Color", FooColor);
  FooR = FooColor.x;
  FooG = FooColor.y;
  FooB = FooColor.z;
  
  /* [[BarColor accesses and mutations]]
   * Since our strategy for Bar does not require updating the stored
   * values for use in the Settings dialog, we can use both direct
   * accesses and mutations.
   */
  BarColor = UI::InputColor3("Bar Color", BarColor);
  
  /* [[QuxColor accesses and mutations]]
   * Like Bar, for Qux we can use both direct accesses and mutations.
   */
  QuxColor = UI::InputColor3("Qux Color", QuxColor);
  
  UI::End();
}

/* [[QuxColor datatype conversion]]
 * Where the component decomposition of Foo and Bar are scattered
 * in several placed throughout the source, the breakdown for Qux
 * is restricted to just the two conversion functions, parseQux and
 * writeQux.
 * 
 * This particular implementation makes use of the Json group within
 * the Openplanet API, but a similar effect can be achieved with XML,
 * a bespoke serialization format, a unique identifier, or any of a
 * number of other things.
 
 * We need both directions for this conversion, and so writeQux is
 * the inverse operation of parseQux. To say it another way,
 * color == parseQux(writeQux(color)).
 */
vec3 parseQux(string json)
{
  Json::Value obj = Json::Parse(json);
  vec3 color;
  color.x = obj.Get("r", 0.f);
  color.y = obj.Get("g", 0.f);
  color.z = obj.Get("b", 1.f);
  return color;
}

string writeQux(vec3 color)
{
  Json::Value obj = Json::Object();
  obj["r"] = Json::Value(color.x);
  obj["g"] = Json::Value(color.y);
  obj["b"] = Json::Value(color.z);
  return Json::Write(obj);
}

#name "Class Method Coroutine example"
#author "XertroV"
#category "Examples"

/* This plugin demonstrates how class methods can be used as coroutines.
 * Unlike other coroutines, a delegate object must be used instead of
 * the method itself.
 *
 * You should read Plugin_CoroutineTest.as before this file.
 *
 * AngelScript docs for function handles and delegates:
 * https://www.angelcode.com/angelscript/sdk/docs/manual/doc_datatypes_funcptr.html
 */

void Main() {
    // We need to instantiate the class. The class itself is defined below.
    // The class starts a class method coroutine in its constructor.
    CoroExampleCls@ myInstance = CoroExampleCls("abcd");

    // Let's confirm that the coroutine really is bound to `myInstance`.
    sleep(500);
    print("changing myInstance.name to 1234\n");
    myInstance.name = "1234";

    // stop the coroutines after 1500 ms avoid polluting the log.
    sleep(1500);
    myInstance.stop = true;
    print("coroutines stopped.");
}

// Example class with coroutines
class CoroExampleCls {
    // A property that we'll modify later to show that we really are
    // running class methods as coroutines.
    string name;

    // Used to terminate the coroutines
    bool stop = false;

    // A basic constructor
    CoroExampleCls(string name) {
        this.name = name;

        // To run a class method as a coroutine, we construct a *delegate*
        // using the `CoroutineFunc` funcdef (provided by OpenPlanet).
        startnew(CoroutineFunc(this.AClassCoroutine));
        sleep(111);

        // This also works (no explicit `this.`). Note: there will be two
        // instances of this coroutine running, now.
        startnew(CoroutineFunc(AClassCoroutine));
        sleep(111);

        // We can also start a coroutine that takes an argument.

        // This will be our argument. It'll be automatically cast to `ref@`.
        Meta::Plugin@ thisPlugin = Meta::ExecutingPlugin();

        // We should use `CoroutineFuncUserdata` as the funcdef, this time.
        startnew(CoroutineFuncUserdata(AClassCoroWithArg), thisPlugin);
    }

    // A class method that is a coroutine with an infinite loop.
    void AClassCoroutine() {
        while (!stop) {
            print("AClassCoroutine() here with name=" + this.name);
            sleep(333);
        }
    }

    // A class method that is a coroutine with an infinite loop which takes an argument.
    void AClassCoroWithArg(ref@ _arg) {
        // We need to know the datatype here -- be careful that you don't pass in an argument of the wrong type.
        auto arg = cast<Meta::Plugin@>(_arg);
        while (!stop) {
            print("AClassCoroWithArg() here with name=" + this.name + " -- run from plugin: " + arg.Name);
            sleep(333);
        }
    }
}

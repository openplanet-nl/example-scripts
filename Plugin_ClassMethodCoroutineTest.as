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

// We need to declare a function signature for the function handle.
// This must match the signature of the class method.
funcdef void SUB_DELEGATE_F();

void Main() {
    // We need to instantiate the class first. The class itself is defined below.
    CoroExampleCls@ myInstance = CoroExampleCls("abc");

    // Next, we declare a function handle (f) and set it to the delegate of the class method.
    SUB_DELEGATE_F @f = SUB_DELEGATE_F(myInstance.AClassCoroutine);

    // Now we can use this delegate with `startnew`.
    startnew(f);

    // Let's confirm that the coroutine really is bound to `myInstance`.
    sleep(500);
    print("changing myInstance.name to 222");
    myInstance.name = "222";

    // We can also call the delegate directly.
    f();
}

// Example class with a coroutine
class CoroExampleCls {
    string name;

    // A basic constructor
    CoroExampleCls(string name) {
        this.name = name;
    }

    // A class method that is a coroutine with an infinite loop.
    void AClassCoroutine() {
        while (true) {
            print("AClassCoroutine() here with name=" + this.name);
            sleep(333);
        }
    }
}

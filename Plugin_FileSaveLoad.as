#name "Files: Saving and Loading"
#author "XertroV"
#category "Examples"

/*
  This example script covers saving and loading files in a plugin-specific directory.
*/

// These are some constants that we'll write to and read from a file:
const string Line1 = "[Plugin Dev]: Hello World!";
const string Line2 = "[Spirit of Openplanet]: +:opwave:";
const string Line3 = "Line3";

void Main() {
    /* Before we can store data in files, we need the path to those files.
       The easiest way to do this is `IO::FromStorageFolder`. This will return
    */
    string rootFilePath = IO::FromStorageFolder("rootFile.txt");
    IO::CreateFolder(IO::FromStorageFolder("jsonFiles/"), true);
    string jsonFilePath = IO::FromStorageFolder("jsonFiles/file2.json");
    print("rootFilePath: " + rootFilePath);
    print("jsonFilePath: " + jsonFilePath);

    // Let's write some basic data to the first file.
    // First, we'll declare the file handler in Write mode, which will delete everything
    // in the file, giving us a fresh, empty file to work with.
    IO::File rootFile(rootFilePath, IO::FileMode::Write);
    // Let's write some lines to this file:
    rootFile.WriteLine(Line1);
    rootFile.WriteLine(Line2);
    // Now, let's close the file so that we can open it in Read mode:
    rootFile.Close();

    // We need to declare a new file handler so that we can read the data back.
    // Watch out: you can't re-use variable names for file handlers in the same scope.
    IO::File rootFile2(rootFilePath, IO::FileMode::Read);
    // Let's read our string back.
    string tmp = rootFile2.ReadLine();
    if (Line1 != tmp) {
        throw("Expected '" + Line1 + "' but read back: '" + tmp + "'");
    }
    tmp = rootFile2.ReadLine();
    if (Line2 != tmp) {
        throw("Expected '" + Line2 + "' but read back: '" + tmp + "'");
    }
    // we're at the end of the file now, if we try to read everything else, we'll get an empty string.
    tmp = rootFile2.ReadToEnd();
    if ("" != tmp) {
        throw("Expected '' but read back: '" + tmp + "'");
    }
    // since we're done reading the file, we should close it
    rootFile2.Close();

    // We can add more data to an existing file using the Append mode
    // If we use the Write mode here, then we'd delete any data that was already in the file.
    IO::File rootFile3(rootFilePath, IO::FileMode::Append);
    rootFile3.WriteLine(Line3);
    rootFile3.Close();

    // Let's read the data back to be sure:
    IO::File rootFile4(rootFilePath, IO::FileMode::Read);
    print("Skipping line: " + rootFile4.ReadLine());
    print("Skipping line: " + rootFile4.ReadLine());
    tmp = rootFile4.ReadLine();
    if (Line3 != tmp) {
        throw("Expected '" + Line3 + "' but read back: '" + tmp + "'");
    }
    rootFile4.Close();

    // JSON data, by comparison, is much easier to read and write.
    // Let's create a sample JSON object to see how this works.
    Json::Value jData = Json::Object();
    jData['isJson'] = true;
    jData['0-to-5'] = Json::Array();
    for (uint i = 0; i <= 5; i++) {
        jData['0-to-5'].Add(i);
    }

    // It's easy to write JSON data to a file
    Json::ToFile(jsonFilePath, jData);
    // And easy to read it back again, too
    auto jData2 = Json::FromFile(jsonFilePath);

    // You might want to turn a JSON value into a string for debugging. That's easy too using `Json::Write`.
    // Note: the keys of a JSON object can appear in any order when that object is serialized,
    // so you shouldn't rely on the serialized version for things like equality tests.
    print("original jData: " + Json::Write(jData));
    print("JSON from file: " + Json::Write(jData2));
}

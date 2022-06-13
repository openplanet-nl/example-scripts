#name "Files: Saving and Loading"
#author "XertroV"
#category "Examples"

/*
  There are a few ways to save and load files depending on what you're saving/loading.

  First, we'll look at file paths and how you should choose them, where the best place
  is to save files, creating the directories, etc.

  Next, we'll save and load some basic JSON data.

  Finally some arbitrary data.

  Relevant docs pages for APIs used in this example:
  - https://openplanet.dev/docs/api/IO
  - https://openplanet.dev/docs/api/IO/File
  - https://openplanet.dev/docs/api/Json
  - https://openplanet.dev/docs/api/Meta

*/

void Main() {
    /* Here, we'll call functions that correspond to each of the topics we'll cover.
       We'll yield between them because anything involving files might take a long
       time, and we don't want to hit the 1000ms script timeout.
    */

    // 1. Where to save files and making directories
    InitializeFilePaths();
    yield();

    // 2. Basic JSON
    ExampleBasicJson();
    yield();

    // 3. Arbitrary Data
    ExampleArbitraryData();
    yield();
}

/*
  # File Paths

  When your plugin needs to save data, the best place for it is in the user folder.
  We'll write a function to generate this path for us and call it from
  `InitializeFilePaths()`.

  (Note: this script is public domain so you may copy paste this and other utility
  functions if they're suitable for you.)

  We'll also need to create the directory if it doesn't exist, so let's do this in
  the same function for convenience.
*/

void InitializeFilePaths() {
    // Here, we get the storage folder path. GetPluginStorageDir does all the work
    // for us (like creating the directories), but we might want to create more
    // folders here and cache the paths for later use, etc.
    const string storageFolderPath = GetPluginStorageDir("init-folders");
    print("InitializeFilePaths got storage folder: " + storageFolderPath);
}

/* Returns a user-data folder path for this plugin.
   `GetPluginStorageDir("lap-times") == "C:\Users\Username\OpenplanetNext/Plugin_FileSaveLoad/main/lap-times"`
   (Don't worry that the path has both forward slashes and back slashes -- it works fine.)

   Preferably you should cache the output of this function to avoid calling
   IO:FolderExists more often than necessary.
*/
const string GetPluginStorageDir(const string &in dirName) {
    // the primary storage folder for this plugin will have the same ID as the plugin.
    // e.g., this plugin's ID is Plugin_FileSaveLoad (the filename without an extension).
    string mainFolderName = Meta::ExecutingPlugin().ID;

    // let's add a subfolder here, too, which we'll change via compiler flags.
    string subFolder = GetStorageSubfolder();

    // We use `IO::FromDataFolder` to get the absolute path to this folder within
    // Openplanet's user-data directory. We'll set up our plugin storage folders inside
    // a main `Storage/` folder in the Openplanet data folder to keep that folder clean.
    // (Imagine if 100 plugins all had their own folders without a main `Storage/` folder.)
    string absPath = IO::FromDataFolder("Storage/" + mainFolderName + "/" + subFolder + "/" + dirName);

    // If the directory does not exist, let's create it.
    if (!IO::FolderExists(absPath)) {
        // We include `true` so that we create these folders recursively. That way we don't
        // care how many folders we're creating, they're all guaranteed to be there.
        IO::CreateFolder(absPath, true);
    }

    // return the absolute path
    return absPath;
}

/* Return a subfolder name depending on compiler flags. This is useful for having
   separate folders during development and the release version of the plugin.
*/
const string GetStorageSubfolder() {
#if DEV
    // set `defines = ["DEV"]` in your plugin's info.toml for this code to run
    return "dev";
#elif UNIT_TEST
    // set `defines = ["UNIT_TEST"]` in your plugin's info.toml for this code to run
    return "unit-test";
#else
    // if neither DEV nor UNIT_TEST is defined, assume that we are running a release version
    return "main";
#endif
}


/*
    # Saving and Loading JSON data

    There are some convenience functions available to us for saving and loading JSON
    data specifically. They are `Json::ToFile` and `Json::FromFile`.

    Let's generate some JSON data, save it to file, load it back, and make sure that
    the data matches.
*/

void ExampleBasicJson() {
    // first, we need some JSON data to save.
    // note: it's common to typically declare these variables using `auto` instead of the explicit type.
    Json::Value origData = GenerateJsonData();

    // Next, we want to save the data, but where? Let's get a storage directory and
    // create a path to a file.
    const string storageDir = GetPluginStorageDir("basic-json");
    const string jsonFile = storageDir + "/generated.json";

    // Let's save the data.
    Json::ToFile(jsonFile, origData);

    // Let's load the data into a new JSON value
    auto loadedData = Json::FromFile(jsonFile);

    // Now let's check that all of the values are the same. We'll throw an error if there's a problem,
    // but you might want to do something more sophisticated depending on your use-case.

    // Check lengths match
    if (origData.Length != loadedData.Length) {
        throw("ExampleBasicJson Failure: data lengths differ.");
    }

    // Check values match
    for (uint i = 0; i < origData.Length; i++) {
        // we need to cast data we get out of a JSON object/array to the expected types.
        // otherwise they're treated as `Json::Value`s and we cant compare them or add them
        // to strings, etc.
        uint origVal = origData[i];
        uint loadedVal = loadedData[i];
        if (origVal != loadedVal) {
            throw("ExampleBasicJson Failure: mismatching values: " + origVal + " vs " + loadedVal);
        }
    }

    // All good!
    print("ExampleBasicJson: original data and loaded data match.");
    print("You can find generated.json here: " + jsonFile);
}

/* Generate a json array of length 100 (default) filled with random integers.
   Tip: passing around `Json::Value`s can be expensive as the objects are copied.
*/
Json::Value GenerateJsonData(uint length = 100) {
    // create a fresh json array
    auto j = Json::Array();
    // keep a string to track the numbers that we generate so we can print them later.
    string msg = "Generated Array: [";
    // a loop with an iteration for each value we'll insert
    for (uint i = 0; i < length; i++) {
        // Pick a random integer between -400k and 400k.
        // Warning: serializing JSON integers beyond +/- 500k will save them in scientific notation.
        // You can confirm this by increasing the magnitude of the limits.
        int randInt = Math::Rand(-400000, 400000);
        // we can append to a JSON array using `.Add` (similar to `MwFastBuffer`).
        j.Add(randInt);
        // add the generated integer to our output msg
        msg += tostring(randInt);
        // add a comma if we're not last
        if (i + 1< length) msg += ", ";
    }
    // print out the generated numbers so we know what they are
    print(msg);
    // return our generated JSON data.
    return j;
}


/*
    # Saving and loading arbitrary data.

    We'll need to create `IO::File` handlers directly. However, we can create
    these handlers in one of Read, Write, and Append modes. This example will
    include all three modes.

    We'll write a few lines to a CSV file in different modes, and then go through
    a few ways to read the data from a file.
*/

void ExampleArbitraryData() {
    // The file we'll read/write to
    const string storageDir = GetPluginStorageDir("arb-data");
    const string csvFilePath = storageDir + "/data.csv";

    // We might often want to set up a file before we use it in a regular way.
    // Let's check if the file exists, and if not it will initialize it.
    if (!IO::FileExists(csvFilePath)) {
        // first, open a handle to this file.
        // We could use ::Write or ::Append mode here (they're equivalent since the file doesn't exist).
        // But if you use ::Write on a file that *already* exists then you risk deleting all the data in it!
        // todo: will it always delete the data or can you .Seek to only write certain bytes at certain offsets?
        IO::File csvFileInit(csvFilePath, IO::FileMode::Write);
        // We might want to populate the first few rows with headings or some constant data.
        string headings = string::Join({"col1", "col2", "col3", "total"}, ",");
        // We call `.WriteLine(str)` to write a string to a file and then add a line-break (`\n`) after.
        csvFileInit.WriteLine(headings);
        // Let's write an example row, too
        csvFileInit.WriteLine(string::Join({"1", "1", "1", "3"}, ","));
        // Since we're done initializing the file, let's close the handler.
        // We won't be able to use `csvFileInit` after this.
        csvFileInit.Close();
    }

    // We need to declare a new file handler in ::Read mode to access the data.
    IO::File csvFileRead(csvFilePath, IO::FileMode::Read);
    // The first line is just headings, so we can skip that and discard the result.
    // `.ReadLine()` will tell us the *next* line in the file, excluding the line-break.
    // Here, we use it just to skip the first line.
    csvFileRead.ReadLine();
    // The next row line will be the 2nd row we wrote in the initialization section.
    const string row2Str = csvFileRead.ReadLine();
    print("ExampleArbitraryData | Expected: 1,1,1,3 and Read: " + row2Str + ".");
    // Let's check that it's what we expect.
    if (row2Str != "1,1,1,3") {
        throw("ExampleArbitraryData failure! (see above line for details)");
    }
    // Let's close the file handler so we can write to it later.
    csvFileRead.Close();

    // Now that we're done setting up the csv file, let's call the regular
    // business-logic that will handle using the file most of the time.
    // Let's run it a few times to see what it does.
    for (uint i = 0; i < 15; i++) {
        UpdateCsvFile(csvFilePath);
        sleep(1000);
    }
}

/* Updates the csv file each time it's run.
   This will load the last row of the CSV file as input and then append a new row.
*/
void UpdateCsvFile(const string &in csvFilePath) {
    // let's make sure it exists. We could handle the case if we want but we'll
    // just throw for now.
    if (!IO::FileExists(csvFilePath)) {
        throw("UpdateCsvFile was run for a non-initialized CSV!");
    }

    /*
      Part 1: let's open the file and read the last line.
    */

    // Open the file.
    IO::File csvFile(csvFilePath, IO::FileMode::Read);
    // Declare a temporary variable for the line.
    string line;

    // Instead of parsing the whole file, let's just keep reading lines until there are no more.
    // We can check if there's more to read using `.EOF()` (which stands for "end of file").
    while (!csvFile.EOF()) {
        line = csvFile.ReadLine();
    }
    print("UpdateCsvFile loaded last line: " + line);
    // since we're done, close the file.
    csvFile.Close();

    /*
    Part 2: let's parse the data and calculate the next row
    */

    // Split the line into values
    string[] vs = line.Split(",");
    int v0 = Text::ParseInt(vs[0]);
    float v1 = Text::ParseFloat(vs[1]);
    float v2 = Text::ParseFloat(vs[2]);
    float vTotal = Text::ParseFloat(vs[3]);

    // calculate new values
    v0 += 1;  // row number
    v1 = float(v0) * v1 / v2;  // next v1 value
    v2 = Math::Sqrt(v1);  // next v2 value
    vTotal = float(v0 + v1) + v2;  // next vTotal value

    // Now, let's open the file in ::Append mode so that we keep all the existing data.
    // Note, we can't reuse the variable name `csvFile` from before since it's already declared.
    IO::File csvFile_(csvFilePath, IO::FileMode::Append);

    // Let's calculate the string we'll write to the file.
    string lineToWrite = "" + v0 + "," + v1 + "," + v2 + "," + vTotal;
    // And write it.
    // Note: we'll use `.Write` this time, instead of `.WriteLine` and include the line-break explicitly.
    csvFile_.Write(lineToWrite + "\n");

    // There are many ways to write data to files, so you should read
    // https://openplanet.dev/docs/api/IO/File if you are interested.

    // Print out what we expect to have written. The extra spaces help almost align the values in
    // this log output with those in the prior output for easy visual comparison.
    print("UpdateCsvFile wrote this line:   " + lineToWrite);
}

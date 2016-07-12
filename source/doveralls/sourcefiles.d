module doveralls.sourcefiles;

import std.json;

// Get an array of all source files and their coverage.
JSONValue[] getSourceFiles(string path)
{
    import std.algorithm, std.array, std.conv, std.file, std.path, std.stdio, std.string;

    JSONValue[] files;
    auto coverage = appender!(JSONValue[])();
    auto source = appender!(char[])();

    foreach (string lstPath; dirEntries(path, "*.lst", SpanMode.breadth, true))
    {
        if (lstPath.baseName.startsWith(".."))
            continue;

        string relPath;
        foreach (line; File(lstPath).byLine(KeepTerminator.no))
        {
            auto parts = line.findSplit("|");
            if (parts[1].length)
            {
                parts[0] = parts[0].strip();
                coverage.put(parts[0].length ? JSONValue(parts[0].to!uint) : JSONValue(null));
                source.put(parts[2]); source.put("\n"); // use UNIX LF
            }
            else
            {
                relPath = line.findSplitBefore(" ")[0].idup; // last line "filename is x% covered"
                break;
            }
        }
        if (relPath.empty) // module w/o code, see druntime#1393
            relPath = baseName(lstPath).split("-").buildPath.setExtension(".d");

        JSONValue[string] file;
        file["name"] = relPath;
        file["coverage"] = coverage.data.dup;
        file["source"] = source.data.idup;
        files ~= JSONValue(file);
        coverage.clear();
        source.clear();
    }

    return files;
}

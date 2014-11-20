module doveralls.sourcefiles;

import std.json;

// Get an array of all source files and their coverage.
JSONValue[] getSourceFiles(string path)
{
    import std.algorithm, std.array, std.conv, std.file, std.path, std.stdio, std.string;

    JSONValue[] files;
    auto coverage = appender!(JSONValue[])();
    auto source = appender!(char[])();

    foreach (de; dirEntries(path, "*.d", SpanMode.breadth, true))
    {
        // relative path
        string relPath = de.name.relativePath(path);
        string lstPath = relPath.replace("/", "-").replace("\\", "-")
            .setExtension(".lst").absolutePath(path);

        if (!lstPath.exists)
            continue;

        foreach (line; File(lstPath).byLine(KeepTerminator.no))
        {
            auto parts = line.findSplit("|");
            // Ignore the "filename is x% covered" lines.
            if (!parts[1].length) continue;

            parts[0] = parts[0].strip();
            coverage.put(parts[0].length ? JSONValue(parts[0].to!uint) : JSONValue(null));
            source.put(parts[2]); source.put("\n"); // use UNIX LF
        }

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

module doveralls.sourcefiles;
import doveralls.args;

import std.file, std.conv, std.stdio, std.string, std.array, std.typecons,
       std.algorithm, std.path;

// Get an array of all source files and their coverage.
auto getSourceFiles( string path )
{
    CoverallsArgs.SourceFile[] files;

    // Find each source file.
    foreach( immutable dirEntry; dirEntries( path, "*.d", SpanMode.breadth, true ) )
    {
        // The name of the D source file.
        string fileName = dirEntry.name.relativePath( path )
                                       .chompPrefix( "./" );
        // The name of the corresponding .lst file.
        string lstName = fileName.replace( "/", "-" )
                                 .replace( "\\", "-" )
                                 .replace( ".d", ".lst" )
                                 .absolutePath( path );

        // If we don't have coverage info, skip the file.
        if( !lstName.exists() )
        {
            continue;
        }

        CoverallsArgs.SourceFile file;
        file.name = fileName;

        // Get the coverage for each line.
        foreach( line; File( lstName ).byLine( KeepTerminator.no ) )
        {
            // Ignore the "filename is x% covered" lines.
            if( line.countUntil( "|" ) == -1 )
            {
                continue;
            }

            // Get the numbers.
            auto split = line.split( "|" );
            file.source ~= split[ 1..$ ].join( "|" ) ~ "\n";
            auto hitCountStr = split[ 0 ].strip();

            Nullable!uint hit;
            if( hitCountStr.length )
                hit = hitCountStr.to!uint;
            else
                hit.nullify();

            file.coverage ~= hit;
        }

        files ~= file;
    }

    return files;
}

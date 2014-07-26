module doveralls.sourcefiles;
import doveralls.args;

import std.file, std.conv, std.stdio, std.string, std.array, std.typecons,
       std.algorithm, std.path;

auto getSourceFiles( string path )
{
    CoverallsArgs.SourceFile[] files;

    foreach( immutable dirEntry; dirEntries( path, "*.d", SpanMode.breadth, true ) )
    {
        string fileName = dirEntry.name.relativePath( path )
                                       .chompPrefix( "./" );
        string lstName = fileName.replace( "/", "-" )
                                 .replace( "\\", "-" )
                                 .replace( ".d", ".lst" )
                                 .absolutePath( path );

        if( !lstName.exists() )
        {
            writeln( "Not found: ", lstName );
            continue;
        }

        CoverallsArgs.SourceFile file;
        file.name = fileName;

        foreach( line; File( lstName ).byLine( KeepTerminator.no ) )
        {
            // Ignore the "filename is x% covered" lines.
            if( line.countUntil( "|" ) == -1 )
            {
                continue;
            }

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

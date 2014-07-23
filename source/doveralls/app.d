module doveralls.app;
import doveralls.coverallsargs;

import yajl.encoder;
import std.getopt, std.stdio;

int main( string[] args )
{
    if( args.length == 1 )
    {
        printHelp();
        return 1;
    }

    Encoder.Option option;
    option.beautify = true;
    option.indentString = "    ";
    Encoder encoder = Encoder( option );
    writeln( encoder.encode( CoverallsArgs() ) );

    return 0;
}

void printHelp()
{

}

module doveralls.app;
import doveralls.coverallsargs;

import std.getopt, std.stdio;

int main( string[] args )
{
    if( args.length == 1 )
    {
        printHelp();
        return 1;
    }



    return 0;
}

void printHelp()
{

}

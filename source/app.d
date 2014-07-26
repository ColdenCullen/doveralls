module app;
import doveralls.doveralls, doveralls.config;

import std.getopt;

int main( string[] args )
{
    args.getopt( config.passThrough,
        "p|path", &Doveralls.repoPath,
        "t|token", &Doveralls.repoToken );

    return execute();
}

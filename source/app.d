module app;
import doveralls.doveralls, doveralls.config;

import std.getopt, std.process, std.conv;

int main( string[] args )
{
    // If job id is specified, default to "travis-ci", unless it's already been set.
    void jobId( string key, string job )
    {
        if( Doveralls.ciServiceName is null || Doveralls.ciServiceName.length == 0 )
            Doveralls.ciServiceName = "travis-ci";

        Doveralls.ciServiceJobId = job;
    }
    // If pro mode specified, force service name to "travis-pro."
    void travisPro( string key, string value )
    {
        Doveralls.ciServiceName = "travis-pro";
    }

    args.getopt( config.passThrough,
        "p|path", &Doveralls.repoPath,
        "t|token", &Doveralls.repoToken,
        "j|job", &jobId,
        "travis-pro", &travisPro );

    return execute();
}

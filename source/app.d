module app;
import doveralls.doveralls, doveralls.config;

import std.getopt, std.process, std.conv;

int main( string[] args )
{
    bool jobIdSet = false;
    void jobId( string key, string job )
    {
        if( Doveralls.ciServiceName is null || Doveralls.ciServiceName.length == 0 )
            Doveralls.ciServiceName = "travis-ci";

        Doveralls.ciServiceJobId = job;
        jobIdSet = true;
    }
    void travisPro( string key, string value )
    {
        Doveralls.ciServiceName = "travis-pro";
    }

    args.getopt( config.passThrough,
        "p|path", &Doveralls.repoPath,
        "t|token", &Doveralls.repoToken,
        "j|job", &jobId,
        "p|travis-pro", &travisPro );

    // If travis, default to travis-ci (travis-pro override required), and get job.
    if( auto travis = environment.get( "TRAVIS" ) )
    {
        import std.stdio;

        if( !jobIdSet && travis.to!bool )
        {
            Doveralls.ciServiceName = "travis-ci";
            Doveralls.ciServiceJobId = environment.get( "TRAVIS_JOB_ID" );

            if( Doveralls.ciServiceJobId.length == 0 )
            {
                Doveralls.ciServiceJobId = environment.get( "TRAVIS_BUILD_ID" );
            }

            writeln( "Job ID: ", Doveralls.ciServiceJobId );
        }
        else
        {
            writeln( "$TRAVIS set to ", travis, "Job ID: ", Doveralls.ciServiceJobId );
        }
    }

    return execute();
}

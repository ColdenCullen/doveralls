module doveralls.doveralls;
import doveralls.args, doveralls.config, doveralls.sourcefiles, doveralls.git,
       doveralls.request;

import std.getopt, std.string, std.conv, std.stdio, std.datetime, std.json,
       std.process;

// Upload data
int execute()
{
    // If travis, default to travis-ci (travis-pro override required), and get job.
    if( auto travis = environment.get( "TRAVIS" ) )
    {
        if( travis.to!bool )
        {
            Doveralls.ciServiceName = "travis-ci";
            Doveralls.ciServiceJobId = environment.get( "TRAVIS_JOB_ID", "" );
        }
    }

    CoverallsArgs args;

    // Get repo information
    if( Doveralls.repoToken )
    {
        args.repo_token = Doveralls.repoToken;
    }
    else if( Doveralls.ciServiceName )
    {
        args.service_name = Doveralls.ciServiceName;
        args.service_job_id = Doveralls.ciServiceJobId;
    }
    else
    {
        writeln( "Please specify ciServiceName and ciServiceJobId or repoToken." );
        return 1;
    }

    // Calculate coverage information
    args.source_files = getSourceFiles( Doveralls.repoPath );

    // Get git information
    args.git = getGitEntry( Doveralls.repoPath );

    // Get time info
    args.run_at = Clock.currTime.toSimpleString().split( "." )[ 0 ];

    // Encode json
    auto root = args.toJson().toJSONValue();
    string json = toJSON( &root, false );

    return sendData( json );
}

module doveralls.doveralls;
import doveralls.args, doveralls.config, doveralls.sourcefiles, doveralls.git,
       doveralls.request;

import std.getopt, std.string, std.conv, std.stdio, std.process;

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

            if( Doveralls.ciServiceJobId.length == 0 )
            {
                Doveralls.ciServiceJobId = environment.get( "TRAVIS_BUILD_ID", "" );
            }

            writeln( "Job ID: ", Doveralls.ciServiceJobId );
        }
        else
        {
            writeln( "$TRAVIS set to ", travis );
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
    args.run_at = getCurrentTime();

    // Encode json
    return sendData( args.toJson() );
}

string getCurrentTime()
{
    // Target: 2013-02-18 00:52:48 -0800
    import std.array, std.datetime, std.format, std.conv;
    auto now = Clock.currTime;

    auto writer = appender!string();
    writer.formattedWrite(
        "%d-%d-%d %02d:%02d:%02d %0" ~ (now.utcOffset.hours < 0 ? 3 : 2).to!string ~ "d00",
        now.year, now.month, now.day,
        now.hour, now.minute, now.second,
        now.utcOffset.hours );

    return writer.data;
}

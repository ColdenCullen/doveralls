module app;
import doveralls.doveralls, doveralls.config;

import std.getopt, std.process, std.conv, std.file;

enum usage = q"USAGE
Usage:
  doveralls [options]

  -p|--path     repo path, default is current dir
  -t|--token    set the repo_token, required to run locally
  -j|--job      set the Travis-CI job id
  --travis-pro  use travis-pro service
USAGE";

int main( string[] args )
{
    // Default to cwd
    Doveralls.repoPath = getcwd();

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

    bool help;
    args.getopt(config.passThrough, "h|help", &help);

    if( help || args.length == 1 )
    {
        import std.stdio;
        writeln( usage );
        return 0;
    }

    args.getopt( config.passThrough,
        "p|path", &Doveralls.repoPath,
        "t|token", &Doveralls.repoToken,
        "j|job", &jobId,
        "travis-pro", &travisPro );

    return execute();
}

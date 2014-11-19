module doveralls.doveralls;
import doveralls.args, doveralls.sourcefiles, doveralls.git,
       doveralls.request;

int execute(string path, string token, string service)
{
    import std.stdio, std.process : env=environment;

    string jobID;
    if (env.get("TRAVIS"))
    {
        if (!service.length) service = "travis-ci"; // could be travis-pro
        jobID = env["TRAVIS_JOB_ID"];
    }
    else if (env.get("CIRCLECI"))
    {
        service = "circleci";
        jobID = env["CIRCLE_BUILD_NUM"];
    }
    else if (env.get("SEMAPHORE"))
    {
        service = "semaphore";
        jobID = env["SEMAPHORE_BUILD_NUMBER"];
    }
    else if (env.get("JENKINS_URL"))
    {
        service = "jenkins";
        jobID = env["BUILD_NUMBER"];
    }
    else if (env.get("CI_NAME"))
    {
        service = env["CI_NAME"];
        jobID = env["CI_BUILD_NUMBER"];
        version (none) // TODO
        {
            build_url = env["CI_BUILD_URL"];
            branch = env["CI_BRANCH"];
            pull_request = env["CI_PULL_REQUEST"];
        }
    }
    else
    {
        service = "coveralls-ruby";
        token = env.get("COVERALLS_REPO_TOKEN", token);
        if (!token.length)
        {
            stderr.writeln("A repo_token is required when running locally.");
            stderr.writeln("Either pass one as argument or set the COVERALLS_REPO_TOKEN env variable.");
            return 1;
        }
    }

    auto args = CoverallsArgs(
        token, service, jobID, getSourceFiles(path), getGitEntry(path), getCurrentTime());

    return sendData(args.toJson());
}

// Get a string representation of the current time.
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

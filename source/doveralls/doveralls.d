module doveralls.doveralls;
import doveralls.sourcefiles, doveralls.git, doveralls.request;

int execute(string path, string token, string service)
{
    import std.stdio, std.process : env=environment;
    import std.json;

    JSONValue[string] data;
    JSONValue[string] ext;
    if (env.get("TRAVIS"))
    {
        data["service_job_id"] = env["TRAVIS_JOB_ID"];
        data["service_name"] = service.length ? service : "travis-ci"; // could be travis-pro
        ext["travis_job_id"] = env["TRAVIS_JOB_ID"];
        ext["travis_pull_request"] = env["TRAVIS_PULL_REQUEST"];
    }
    else if (env.get("CIRCLECI"))
    {
        data["service_name"] = "circleci";
        data["service_number"] = env["CIRCLE_BUILD_NUM"];
        ext["circleci_build_num"] = env["CIRCLE_BUILD_NUM"];
        ext["branch"] = env["CIRCLE_BRANCH"];
        ext["commit_sha"] = env["CIRCLE_SHA1"];
    }
    else if (env.get("SEMAPHORE"))
    {
        data["service_name"] = "semaphore";
        data["service_number"] = env["SEMAPHORE_BUILD_NUMBER"];
    }
    else if (env.get("JENKINS_URL"))
    {
        data["service_name"] = "jenkins";
        data["service_number"] = env["BUILD_NUMBER"];
        ext["jenkins_build_num"] = env["BUILD_NUMBER"];
        ext["jenkins_build_url"] = env["BUILD_URL"];
        ext["branch"] = env["GIT_BRANCH"];
        ext["commit_sha"] = env["GIT_COMMIT"];
    }
    else if (env.get("CI_NAME"))
    {
        data["service_name"] = env["CI_NAME"];
        data["service_number"] = env["CI_BUILD_NUMBER"];
        data["service_build_url"] = env["CI_BUILD_URL"];
        data["service_branch"] = env["CI_BRANCH"];
        data["service_pull_request"] = env["CI_PULL_REQUEST"];
    }
    else
    {
        data["service_name"] = "coveralls-ruby";
        data["repo_token"] = token = env.get("COVERALLS_REPO_TOKEN", token);
        if (!token.length)
        {
            stderr.writeln("A repo_token is required when running locally.");
            stderr.writeln("Either pass one as argument or set the COVERALLS_REPO_TOKEN env variable.");
            return 1;
        }
    }

    import std.datetime : Clock, UTC;

    if (ext.length) data["environment"] = JSONValue(ext);
    data["source_files"] = getSourceFiles(path);
    data["git"] = getGitEntry(path);
    data["run_at"] = Clock.currTime(UTC()).toISOExtString();

    return sendData(JSONValue(data));
}

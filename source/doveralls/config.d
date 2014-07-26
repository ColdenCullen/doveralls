module doveralls.config;

final abstract shared class Doveralls
{
public static:
    /// The path to the git repo. Usually aquired by `pwd`
    string repoPath = ".";

    /// Token on doveralls page.
    string repoToken;

    /// Name of CI server (travis-ci, travis-pro, or coveralls-ruby).
    string ciServiceName;
    /// A unique identifier of the job on the service specified by service_name.
    string ciServiceJobId;
}

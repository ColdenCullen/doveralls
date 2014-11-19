module app;
import doveralls.doveralls;

enum usage = q"USAGE
Usage:
  doveralls [options]

  -p|--path     repo path, default is current dir
  -t|--token    set the repo_token, required to run locally
  --travis-pro  required when using Travis Pro
USAGE";

int main(string[] args)
{
    import std.getopt, std.process : getcwd;

    bool help;
    args.getopt(config.passThrough, "h|help", &help);

    if (help)
    {
        import std.stdio;
        writeln(usage);
        return 0;
    }

    string path = getcwd(), token, service;
    args.getopt( config.passThrough,
        "p|path", &path,
        "t|token", &token,
        "travis-pro", (string k, string v) { service = "travis-pro"; });

    return execute(path, token, service);
}

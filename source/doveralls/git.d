module doveralls.git;
import doveralls.args;

auto getGitEntry( string repoPath )
{
    import git;
    import std.file, std.string;

    CoverallsArgs.GitEntry info;
    auto repo = openRepository( repoPath );
    auto head = repo.lookupCommit( repo.head.target );

    info.head.id = head.id.toHex();
    info.head.author_name = head.author.name;
    info.head.author_email = head.author.email;
    info.head.committer_name = head.committer.name;
    info.head.committer_email = head.committer.email;
    info.head.message = head.message().strip();

    repo.iterateBranches( GitBranchType.local, ( branch, type )
    {
        if( branch.isHead )
        {
            info.branch = branch.name;
        }
        return branch.isHead ? ContinueWalk.no : ContinueWalk.yes;
    } );

    foreach( remoteName; repo.listRemotes() )
    {
        auto remote = repo.loadRemote( remoteName );
        info.remotes ~= CoverallsArgs.GitEntry.Remote( remote.name, remote.url );
    }

    return info;
}

module doveralls.git;
import std.json;

JSONValue getGitEntry(string repoPath)
{
    version(Have_dlibgit)
    {
        import git;
        import std.range;

        auto repo = openRepository(repoPath);
        auto head = repo.lookupCommit(repo.head.target);

        auto info = [
            "head": JSONValue(
            [
                "id": head.id.toHex(),
                "author_name": head.author.name,
                "author_email": head.author.email,
                "committer_name": head.committer.name,
                "committer_email": head.committer.email,
                "message": head.message()
            ])
        ];

        repo.iterateBranches(GitBranchType.local, (branch, type)
        {
            if (!branch.isHead) return ContinueWalk.yes;
            info["branch"] = branch.name;
            return ContinueWalk.no;
        });

        info["remotes"] = repo.listRemotes.map!(n => loadRemote(repo, n))
            .map!(r => JSONValue(["name": r.name, "url": r.url])).array();

        return JSONValue(info);
    }
}

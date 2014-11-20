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
    else
    {
        import std.algorithm, std.process, std.range, std.string;

        auto res = execute(["git", "-C", repoPath, "log", "-1", "--pretty=format:%H\n%aN\n%ae\n%cN\n%ce\n%s"]);
        if (res.status)
            return JSONValue(null);
        string[6] parts;
        res.output.splitter('\n').takeExactly(parts.length).copy(parts[]);

        auto info = [
            "head": JSONValue(
            [
                "id": parts[0],
                "author_name": parts[1],
                "author_email": parts[2],
                "comitter_name": parts[3],
                "comitter_email": parts[4],
                "message": res.output[&parts[5][0] - &res.output[0] .. $],
            ])
        ];

        res = execute(["git", "-C", repoPath, "rev-parse", "--abbrev-ref", "HEAD"]);
        if (res.status)
            return JSONValue(info);
        info["branch"] = res.output.stripRight();

        res = execute(["git", "-C", repoPath, "remote", "-v"]);
        if (res.status)
            return JSONValue(info);

        JSONValue[] remotes;
        foreach (line; res.output.splitter('\n'))
        {
            if (!line.endsWith("(fetch)")) continue;
            line.splitter().takeExactly(2).copy(parts[0 .. 2]);
            remotes ~= JSONValue(["name": parts[0], "url": parts[1]]);
        }
        info["remotes"] = remotes;
        return JSONValue(info);
    }
}

/**
 * Defines everything required to interact with the Coveralls.io API.
 */
module doveralls.args;

import std.typecons, std.array;

/**
 * A hash representing the coverage data from a single run of a test suite.
 *
 * You must specify either repo_token or a service name and job id.
 */
struct CoverallsArgs
{
public:
    /**
     * REQUIRED
     * The secret token for your repository, found at the bottom of your
     * repository's page on Coveralls.
     */
    string repo_token;

    /**
     * REQUIRED
     * The CI service or other environment in which the test suite was run.
     * This can be anything, but certain services have special features
     * (travis-ci, travis-pro, or coveralls-ruby).
     */
    string service_name;

    /**
     * OPTIONAL
     * A unique identifier of the job on the service specified by service_name.
     */
    string service_job_id;

    /**
     * REQUIRED
     * An array of source files, including their coverage data.
     */
    SourceFile[] source_files;

    /**
     * OPTIONAL
     * A hash of Git data that can be used to display more information to users.
     *
     * Example:
     * ---
     * "git": {
     *   "head": {
     *     "id": "b31f08d07ae564b08237e5a336e478b24ccc4a65",
     *     "author_name": "Nick Merwin",
     *     "author_email": "...",
     *     "committer_name": "Nick Merwin",
     *     "committer_email": "...",
     *     "message": "version bump"
     *   },
     *   "branch": "master",
     *   "remotes": [
     *     {
     *       "name": "origin",
     *       "url": "git@github.com:lemurheavy/coveralls-ruby.git"
     *     }
     *   ]
     * }
     * ---
     */
    GitEntry git;

    /**
     * OPTIONAL
     * A timestamp of when the job ran. Must be parsable by Ruby.
     *
     * Example:
     * ---
     * "run_at": "2013-02-18 00:52:48 -0800"
     * ---
     */
    string run_at;

    /// Converts the instance to json
    auto toJson()
    {
        import medea;
        import std.algorithm, std.array;

        ObjectValue root = new ObjectValue;

        mixin( stringValue!q{repo_token} );
        mixin( stringValue!q{service_name} );
        mixin( stringValue!q{service_job_id} );
        root[ "source_files" ] = new ArrayValue( cast(Value[])source_files.map!( file => file.toJson() ).array() );
        root[ "git" ] = git.toJson();
        mixin( stringValue!q{run_at} );

        return root;
    }

static: // Struct definitions
    struct SourceFile
    {
    public:
        /**
         * REQUIRED
         * Represents the file path of this source file. Must be unique in the
         * job. Can include slashes. The file type for syntax highlighting will
         * be determined from the file extension in this parameter.
         */
        string name;

        /**
         * REQUIRED
         * The full source code of this file. Newlines should use UNIX-style
         * line endings (\n).
         */
        string source;

        /**
         * REQUIRED
         * The coverage data for this file for the file's job.
         *
         * The item at index 0 represents the coverage for line 1 of the source
         * code.
         *
         * Acceptable values in the array:
         *     A positive integer if the line is covered, representing the
         *         number of times the line is hit during the test suite.
         *     0 if the line is not covered by the test suite.
         *     null to indicate the line is not relevant to code coverage
         *         (it may be whitespace or a comment).
         *
         * Example:
         *     [null, 1, 0, null, 4, 15, null]
         */
        Nullable!uint[] coverage;

        /// Converts instance to json.
        auto toJson()
        {
            import medea;

            Value[] coverageValues;
            foreach( val; coverage )
            {
                if( val.isNull )
                    coverageValues ~= new NullValue;
                else
                    coverageValues ~= new UIntegerValue( val );
            }

            return new ObjectValue( [
                "name": cast(Value) new StringValue( name ),
                "source": cast(Value) new StringValue( source ),
                "coverage": cast(Value) new ArrayValue( coverageValues )
            ] );
        }
    }

    struct GitEntry
    {
    public: // Member definitions
        Commit head;
        string branch;
        Remote[] remotes;

        auto toJson()
        {
            import medea;
            import std.algorithm, std.array;
            ObjectValue root = new ObjectValue;

            root[ "head" ] = head.toJson();
            mixin( stringValue!q{branch} );
            root[ "remotes" ] = new ArrayValue( cast(Value[])remotes.map!( remote => remote.toJson() ).array() );

            return root;
        }

    static: // Struct definitions
        struct Commit
        {
        public:
            string id;
            string author_name;
            string author_email;
            string committer_name;
            string committer_email;
            string message;

            mixin( stringOnlyToJson!q{Commit} );
        }

        struct Remote
        {
            string name;
            string url;

            mixin( stringOnlyToJson!q{Remote} );
        }
    }
}

private enum stringOnlyToJson( string struckt ) = q{
    auto toJson()
    {
        import medea;
        ObjectValue root = new ObjectValue;

        foreach( memberName; __traits(allMembers, $struckt) )
        {
            static if( is( typeof(__traits(getMember, this, memberName )) == string ) )
            {
                mixin( stringValue!memberName );
            }
        }

        return root;
    }
}.replace( "$struckt", struckt );

private enum stringValue( string name ) = q{
    if( $name && $name.length )
    {
        //root[ "$name" ] = new StringValue( args.$name );
        root[ "$name" ] = new StringValue( $name );
    }
}.replace( "$name", name );

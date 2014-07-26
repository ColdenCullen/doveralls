module doveralls.request;

import std.conv;

int sendData( string json )
{
    /*

    import vibe.d;
    requestHTTP( "https://coveralls.io/api/v1/jobs",
        ( scope req )
        {
            import std.stdio;
            req.method = HTTPMethod.POST;
            req.headers[ "Content-Disposition" ] = "form-data; name=\"json_file\"";
            req.headers[ "Content-Type" ] = "application/octet-stream";

            req.writeBody( cast(ubyte[])json );

            writeln( "Request: ", req.toString() );
        },
        ( scope res )
        {
            import std.stdio;
            writeln( "status: ", res.statusCode, ": ", res.statusPhrase );
            writeln( "response: ", res.bodyReader.readAllUTF8() );
        } );

    /*/

    import std.process, std.file;

    write( "doveralls.json", json );

    auto result = executeShell( "curl -F \"json_file=@doveralls.json\" https://coveralls.io/api/v1/jobs" );
    if( result.status == 0 )
    {
        import std.stdio;
        writeln( result.output );
    }

    //*/

    return result.status;
}

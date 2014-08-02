module doveralls.request;

import medea;
import std.json, std.conv, std.process, std.file;

// Send the json arguments to Coveralls.io.
int sendData( Value jsonObject )
{
    auto root = jsonObject.toJSONValue();
    string json = toJSON( &root, false );

    write( "doveralls.json", json );

    auto result = executeShell( "curl -F \"json_file=@doveralls.json\" https://coveralls.io/api/v1/jobs" );
    if( result.status == 0 )
    {
        import std.stdio;
        writeln( result.output );
    }

    return result.status;
}

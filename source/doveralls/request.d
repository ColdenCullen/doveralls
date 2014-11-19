module doveralls.request;

import std.json, std.conv, std.process, std.file;

// Send the json arguments to Coveralls.io.
int sendData(JSONValue data)
{
    string json = toJSON(&data, false);
    write("doveralls.json", json);

    auto result = executeShell( "curl -F \"json_file=@doveralls.json\" https://coveralls.io/api/v1/jobs" );
    if( result.status == 0 )
    {
        import std.stdio;
        writeln( result.output );
    }

    return result.status;
}

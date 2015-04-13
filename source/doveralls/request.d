module doveralls.request;

import std.json, std.net.curl, etc.c.curl;

// Send the json arguments to Coveralls.io.
int sendData(JSONValue data)
{
    auto json = toJSON(&data, false);

    curl_httppost* formpost, lastptr;
    curl_formadd(&formpost, &lastptr,
                 CurlForm.copyname, "json_file".ptr,
                 CurlForm.buffer, "doveralls.json".ptr,
                 CurlForm.bufferptr, json.ptr,
                 CurlForm.bufferlength, json.length,
                 CurlForm.contenttype, "application/json".ptr,
                 CurlForm.end);

    // don't wait for 100-continue response
    curl_slist *headerlist;
    headerlist = curl_slist_append(headerlist, cast(char*)"Expect:".ptr);

    Curl curl;
    curl.initialize();
    import std.process : env=environment;
    auto host = env.get("COVERALLS_ENDPOINT", "https://coveralls.io");
    curl.set(CurlOption.url, host ~ "/api/v1/jobs");
    curl.set(CurlOption.httpheader, headerlist);
    curl.set(CurlOption.httppost, formpost);
    curl.set(CurlOption.useragent, "doveralls ("~HTTP.defaultUserAgent~")");
    if (auto res = curl.perform(ThrowOnError.no))
    {
        import std.stdio, core.stdc.string;
        auto msg = curl_easy_strerror(res);
        stderr.writeln("Failed to upload data: ", msg[0 .. strlen(msg)]);
        return 1;
    }
    return 0;
}

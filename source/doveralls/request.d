module doveralls.request;

import std.json, std.net.curl, std.stdio, etc.c.curl;

// Send the json arguments to Coveralls.io.
int sendData(JSONValue data)
{
    static if (__VERSION__ >= 2072)
        auto json = toJSON(data, false);
    else
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
    static extern(C) size_t append(void *buffer, size_t size, size_t nmemb, void *userp)
    {
        *cast(string*)userp ~= (cast(char*)buffer)[0 .. size * nmemb];
        return size * nmemb;
    }
    string response;
    curl.set(CurlOption.writefunction, &append);
    alias CURLOPTION_WRITEDATA = CurlOption.file; // alias is missing in std.net.curl
    curl.set(CURLOPTION_WRITEDATA, &response);
    static if (__VERSION__ >= 2067)
        enum dontThrowOnError = ThrowOnError.no;
    else
        enum dontThrowOnError = false;
    if (auto res = curl.perform(dontThrowOnError))
    {
        import core.stdc.string : strlen;
        auto msg = curl_easy_strerror(res);
        stderr.writeln("Failed to upload data: ", msg[0 .. strlen(msg)]);
        return 1;
    }

    auto jsonResponse = parseJSON(response);
    if (jsonResponse.type != JSON_TYPE.OBJECT || "url" !in jsonResponse.object)
    {
        stderr.writeln("Unexpected upload response: ", jsonResponse.toPrettyString);
        return 1;
    }
    writeln("Uploaded data to: ", jsonResponse["url"].str);
    return 0;
}

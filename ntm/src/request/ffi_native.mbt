///|
extern "C" fn curl_get(url : String) -> String = "zig_http_get"

///|
extern "C" fn download_file(url : String, file : String) -> Bool = "zig_download_file"

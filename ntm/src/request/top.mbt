///|
pub fn get(url : String) -> String {
  curl_get(url)
}

///|
pub fn download(url : String, file : String) -> Bool {
  download_file(url, file)
}

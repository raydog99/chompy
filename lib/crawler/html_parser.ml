open Soup

class html_parser =
  object (self)
    val mutable html = ""
    val session = Nethttp_client.https_client ()

    method private get_html url =
      let headers =
        [ "User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36"
        ; "User-Agent", "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.3"
        ]
      in
      let h = Random.int 2 in
      try
        let response = session#get ~headers:(Nethttp_headers.header_list_of_list [headers.(h)]) url in
        let html = response#response_body#value in
        html
      with _ -> ""
  end
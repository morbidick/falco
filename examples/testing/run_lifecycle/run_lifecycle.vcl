backend httpbin_org {
  .connect_timeout = 1s;
  .dynamic = true;
  .port = "443";
  .host = "httpbin.org";
  .first_byte_timeout = 20s;
  .max_connections = 500;
  .between_bytes_timeout = 20s;
  .share_key = "xei5lohleex3Joh5ie5uy7du";
  .ssl = true;
  .ssl_sni_hostname = "httpbin.org";
  .ssl_cert_hostname = "httpbin.org";
  .ssl_check_cert = always;
  .min_tls_version = "1.2";
  .max_tls_version = "1.2";
  .bypass_local_route_table = false;
  .probe = {
    .request = "GET /status/200 HTTP/1.1" "Host: httpbin.org" "Connection: close";
    .dummy = true;
    .threshold = 1;
    .window = 2;
    .timeout = 5s;
    .initial = 1;
    .expected_response = 200;
    .interval = 10s;
  }
}

sub vcl_recv {

  #Fastly recv
  set req.backend = httpbin_org;
  set req.http.Foo = "bar";
  if (req.url.path == "/error") {
    error 500 "forced";
  }
  if (req.url.path == "/pass") {
    return (pass);
  }
  if (req.url.path == "/miss") {
    set req.hash_always_miss = true;
  } else {
    set req.hash_always_miss = false;
  }
  return (lookup);
}

sub vcl_hash {

  #Fastly hash
  set req.http.Hash-Visited = "1";
  return (hash);
}

sub vcl_hit {

  #Fastly hit
  set req.http.Hit-Visited = "1";
  return (deliver);
}

sub vcl_miss {

  #Fastly miss
  set req.http.Miss-Visited = "1";
  return (fetch);
}

sub vcl_pass {

  #Fastly pass
  set req.http.Pass-Visited = "1";
  return (pass);
}

sub vcl_fetch {

  #Fastly fetch
  return(deliver);
}

sub vcl_deliver {

  #Fastly deliver
  set resp.http.X-Custom-Header = "Custom Header";
  return (deliver);
}

sub vcl_error {

  #Fastly error
  set obj.status = 500;
  set obj.response = "forced";
  return (deliver);
}

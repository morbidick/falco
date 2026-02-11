// @scope: recv
// @suite: full lifecycle populates response headers
sub test_full_lifecycle {
  set req.url = "/";
  testing.run_lifecycle();
  assert.equal(req.http.Hash-Visited, "1");
  assert.contains(resp.http.X-Custom-Header, "Custom Header");
  assert.equal(testing.state, "LOG");
}

// @scope: recv
// @suite: recv routes to miss or pass based on input
sub test_recv_miss_or_deliver {
  set req.url = "/miss";
  testing.run_lifecycle();
  assert.equal(req.http.Hash-Visited, "1");
  assert.equal(req.http.Miss-Visited, "1");

  unset req.http.Miss-Visited;
  set req.url = "/pass";
  testing.run_lifecycle();
  assert.equal(req.http.Hash-Visited, "1");
  assert.equal(req.http.Pass-Visited, "1");
  assert.contains(resp.http.X-Custom-Header, "Custom Header");
}

// @scope: recv
// @suite: recv routes to pass
sub test_recv_pass {
  set req.url = "/pass";
  testing.run_lifecycle();
  assert.equal(req.http.Hash-Visited, "1");
  assert.equal(req.http.Pass-Visited, "1");
  assert.contains(resp.http.X-Custom-Header, "Custom Header");
}

// @scope: recv
// @suite: recv routes to error
sub test_recv_error {
  set req.url = "/error";
  testing.run_lifecycle();
  assert.error(500, "forced");
  assert.equal(testing.state, "ERROR");
}

// @scope: recv
// @suite: recv routes to hit after cache fill
sub test_recv_hit {
  set req.url = "/hit";
  testing.run_lifecycle();

  set req.url = "/hit";
  testing.run_lifecycle();
  assert.equal(req.http.Hash-Visited, "1");
  assert.equal(req.http.Hit-Visited, "1");
}

local cjson = require "cjson"

local body = {
  ["request_path"] = ngx.var.request_uri,
  ["request_method"] = ngx.var.request_method,
  ["request_headers"] = ngx.req.get_headers()
}

local res = ngx.location.capture(
  '/darkvisitors-proxy', { 
    method = ngx.HTTP_POST, 
    body = cjson.encode(body)
});

if res.status ~= ngx.HTTP_OK then
  ngx.log(ngx.ERR, res.status)
  ngx.log(ngx.ERR, res.body)
end
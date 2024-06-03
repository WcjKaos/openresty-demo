local m, err = ngx.re.match("hello, 9527", "[0-9]+")
if m then
  ngx.say(m[0])
else
  if err then
    ngx.log(ngx.ERR, "error: ", err)
    return
  end
  ngx.say("match not found")
end

local m, err = ngx.re.match("hello, 9527", "([0-9])[0-9]+")
ngx.say(m[0])
ngx.say(m[1])
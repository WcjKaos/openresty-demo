-- http://localhost:8080/encode?userId=1&a=2&c=3
--未经解码的请求uri  
local request_uri = ngx.var.request_uri;  
ngx.say("request_uri : ", request_uri); 

--编码
local escape_uri = ngx.escape_uri(request_uri)
ngx.say("escape_uri : ", escape_uri); 

--解码  
ngx.say("decode request_uri : ", ngx.unescape_uri(escape_uri));

--参数编码
local request_uri = ngx.var.request_uri;
local question_pos, _ = string.find(request_uri, '?')
if question_pos>0 then
  local uri = string.sub(request_uri, 1, question_pos-1)
  ngx.say("uri sub=",string.sub(request_uri, question_pos+1));
  
  --对字符串进行解码
  local args = ngx.decode_args(string.sub(request_uri, question_pos+1))
  
  for k,v in pairs(args) do
    ngx.say("k=",k,",v=", v);
  end
  
  if args and args.userId then
    args.userId = args.userId + 10000
    ngx.say("args+10000 : ", uri .. '?' .. ngx.encode_args(args));
  end
end
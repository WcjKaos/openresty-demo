--获取请求头
ngx.header.content_type = "text/plain; charset=utf-8"
local headers = ngx.req.get_headers()  
ngx.say("============headers begin===============")  
ngx.say("Host : ", headers["Host"])  
ngx.say("headers['user-agent'] : ", headers["user-agent"])  
ngx.say("headers.user_agent : ", headers.user_agent ) 
ngx.say("-------------遍历headers-----------") 
for k,v in pairs(headers) do  
    if type(v) == "table" then  
        ngx.say(k, " : ", table.concat(v, ","))  
    else  
        ngx.say(k, " : ", v)  
    end  
end  
ngx.say("===========headers end============")  
ngx.say()  

--get请求uri参数  
ngx.say("===========uri get args begin==================")  
local uri_args = ngx.req.get_uri_args()  
for k, v in pairs(uri_args) do  
    if type(v) == "table" then  
        ngx.say(k, " : ", table.concat(v, ", "))  
    else  
        ngx.say(k, ": ", v)  
    end  
end  
ngx.say("===========uri get args end==================") 
  
--post请求参数  
-- ngx.req.get_post_args：获取post请求内容体，其用法和get_headers类似，但是必须提前调用ngx.req.read_body()来读取body体
ngx.req.read_body()  
ngx.say("=================post args begin====================")  
local post_args = ngx.req.get_post_args()  
for k, v in pairs(post_args) do  
    if type(v) == "table" then  
        ngx.say(k, " : ", table.concat(v, ", "))  
    else  
        ngx.say(k, ": ", v)  
    end  
end  
ngx.say("================post args end=====================")  

--请求的http协议版本  
ngx.say("ngx.req.http_version : ", ngx.req.http_version())  
--请求方法  
ngx.say("ngx.req.get_method : ", ngx.req.get_method())  
--原始的请求头内容  
ngx.say("ngx.req.raw_header : ",  ngx.req.raw_header())  
--请求的body内容体  
ngx.say("ngx.req.get_body_data() : ", ngx.req.get_body_data())  
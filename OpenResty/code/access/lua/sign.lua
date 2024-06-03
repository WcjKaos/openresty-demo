--判断table是否为空
local function isTableEmpty(t)
    return t == nil or next(t) == nil
end

--两个table合并
local function union(table1, table2)
    for k, v in pairs(table2) do
        table1[k] = v
    end
    return table1
end

--检验请求的sign签名是否正确
--params:传入的参数值组成的table
--secret:项目secret，根据key找到secret
local function signcheck(params, secret)
    --判断参数是否为空，为空报异常
    if isTableEmpty(params) then
        local mess = "参数为空"
        ngx.log(ngx.ERR, mess)
        return false, mess
    end

    if secret == nil then
        local mess = "私钥为空"
        ngx.log(ngx.ERR, mess)
        return false, mess
    end

    local key = params["key"]; --平台分配给某客户端类型的keyID
    if key == nil then
        local mess = "key值为空"
        ngx.log(ngx.ERR, mess)
        return false, mess
    end

    --判断是否有签名参数
    local sign = params["sign"]
    if sign == nil then
        local mess = "签名参数为空"
        ngx.log(ngx.ERR, mess)
        return false, mess
    end

    --是否存在时间戳的参数
    local timestamp = params["time"]
    if timestamp == nil then
        local mess = "时间戳参数为空"
        ngx.log(ngx.ERR, mess)
        return false, mess
    end

    --时间戳有没有过期，10秒过期
    local now_mill = ngx.now() * 1000 --毫秒级
    if now_mill - timestamp > 10000 then
        local mess = "链接过期"
        ngx.log(ngx.ERR, mess)
        return false, mess
    end

    local keys, tmp = {}, {}

    --提出所有的键名并按字符顺序排序
    for k, _ in pairs(params) do
        if k ~= "sign" then --去除掉
            keys[#keys + 1] = k
        end
    end
    table.sort(keys)
    --根据排序好的键名依次读取值并拼接字符串成key=value&key=value
    for _, k in pairs(keys) do
        if type(params[k]) == "string" or type(params[k]) == "number" then
            tmp[#tmp + 1] = k .. "=" .. tostring(params[k])
        end
    end

    --将salt添加到最后，计算正确的签名sign值并与传入的sign签名对比，
    local signchar = table.concat(tmp, "&") .. "&" .. secret
    local rightsign = ngx.md5(signchar);
    if sign ~= rightsign then
        --如果签名错误返回错误信息并记录日志，
        local mess = "sign error: sign," .. sign .. " right sign:" .. rightsign .. " sign_char:" .. signchar
        ngx.log(ngx.ERR, mess)
        return false, mess
    end
    return true
end

local params = {}

local get_args = ngx.req.get_uri_args();
ngx.req.read_body()
local post_args = ngx.req.get_post_args();

union(params, get_args)

union(params, post_args)

local secret = "123456" --根据keyID到后台服务获取secret

local checkResult, mess = signcheck(params, secret)

if not checkResult then
    ngx.say(mess);
    return ngx.exit(ngx.HTTP_FORBIDDEN) --直接返回403
end

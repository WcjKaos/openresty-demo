local function close_redis(red)
    if not red then
        return
    end
    -- Release the connection (connection pool implementation)
    local pool_max_idle_time = 10000 -- milliseconds
    local pool_size = 100 -- connection pool size
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)
    if not ok then
        ngx.log(ngx.ERR, "set keepalive error: ", err)
    end
end

local function errlog(...)
    ngx.log(ngx.ERR, "redis: ", ...)
end

local redis = require "resty.redis" -- Import the redis module
local red = redis:new() -- Create a new redis object

-- Set constants
local pool_max_idle_time = 10000 -- milliseconds
local pool_size = 100 -- connection pool size
local timeout = 1000 -- milliseconds

-- Set Redis connection parameters
local redis_config = {
    host = "192.168.71.127",
    port = 6379,
    password = "123456",
}

-- Set the timeout
red:set_timeout(timeout)

-- Connect to Redis
local ok, err = red:connect(redis_config.host, redis_config.port)
if not ok then
    close_redis(red)
    errlog("Cannot connect")
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

-- Check reused times
local times, err = red:get_reused_times()
ngx.log(ngx.ERR, "reused times: ", times)
if times == 0 then
    local ok, err = red:auth("default", redis_config.password)
    ngx.log(ngx.ERR, "auth: ", ok, " ", err)
    if not ok then
        ngx.log(ngx.ERR, "Failed to authenticate: ", err)
        close_redis(red)
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
elseif err then
    ngx.log(ngx.ERR, "Failed to get reused times: ", err)
end

-- Set the key
local key = "limit:frequency:login:" .. ngx.var.remote_addr
ngx.log(ngx.ERR, "key: ", key)

-- Get the frequency for this client IP
local resp, err = red:get(key)
ngx.log(ngx.ERR, "resp: ", resp)
if not resp then
    close_redis(red)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR) -- Redis failed to get the value
end
if resp == ngx.null then
    red:set(key, 1) -- First access within the time unit
    red:expire(key, 10000) -- 10 seconds expiration
    ngx.log(ngx.ERR, "Key set successfully")
end

if type(resp) == "string" then
    if tonumber(resp) > 10 then -- Exceeded 10 times
        close_redis(red)
        return ngx.exit(ngx.HTTP_FORBIDDEN) -- Return 403 directly
    end
end

-- Call the API to set the key
ok, err = red:incr(key)
if not ok then
    close_redis(red)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR) -- Redis error
end

close_redis(red)

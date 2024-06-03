local redis = require "resty.redis"

-- Create a Redis instance
local red = redis:new()

-- Close redis connect
local function close_redis(red)
    if not red then
        return
    end
    -- put it into the connection pool of size 100,
    -- with 10 seconds max idle time
    local ok, err = red:set_keepalive(10000, 100)
    if not ok then
        ngx.log(ngx.ERR, "Failed to set keepalive: ", err)
        return
    end
end

-- Set the Redis server address and port
local redis_host = "192.168.71.110";
local redis_port = 6379;
local redis_password = [[123123]];

-- Connect to the Redis server
local ok, err = red:connect(redis_host, redis_port)
if not ok then
    ngx.log(ngx.ERR, "Failed to connect to Redis: ", err)
    return
end

local times, err = red:get_reused_times()
if times == 0 then
    local ok, err = red:auth("default",redis_password)
    if not ok then
        ngx.log(ngx.ERR, "Failed to authenticate: ", err)
        return
    end
elseif err then
    ngx.say("Failed to get reused times: ", err)
end

-- Set a key-value pair in Redis
local key = "mykey"
local value = "myvalue"
local res, err = red:set(key, value)
if not res then
    ngx.log(ngx.ERR, "Failed to set key-value pair in Redis: ", err)
    return close_redis(red)
end
ngx.say("Set key-value pair in Redis: ", res)

-- Get the value of a key from Redis
local res, err = red:get(key)
if not res then
    ngx.log(ngx.ERR, "Failed to get value from Redis: ", err);
    close_redis(red)
    return
end

-- Print the value
ngx.say("Value from Redis: ", res)

-- Close the Redis connection
close_redis(red)

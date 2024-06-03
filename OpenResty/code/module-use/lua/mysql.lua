local mysql = require("resty.mysql")

-- Create a MySQL connection
local db, err = mysql:new()
if not db then
    ngx.log(ngx.ERR, "Failed to create MySQL object: ", err)
    return
end

-- Set the MySQL server address, port, and credentials
db:set_timeout(1000)  -- 1 second timeout
local ok, err, errno, sqlstate = db:connect{
    host = "192.168.71.110",
    port = 15003,
    database = "openresty",
    user = "root",
    password = "root",
    charset = "utf8mb4",
    max_packet_size = 1024 * 1024,
}

if not ok then
    ngx.log(ngx.ERR, "Failed to connect to MySQL: ", err, ": ", errno, " ", sqlstate)
    return
end
-- Get the current request URL and time
local request_url = ngx.var.http_host .. ngx.var.request_uri
local request_time = ngx.time()

-- Example: Insert a new record with current request URL and time
local quote_sql_str = ngx.quote_sql_str
local request_url_escaped = quote_sql_str(request_url)
local request_time_escaped = quote_sql_str(tostring(request_time))

local res, err, errno, sqlstate = db:query("INSERT INTO openresty_request (request_url, request_time) VALUES (" .. request_url_escaped .. ", FROM_UNIXTIME(" .. request_time_escaped .. "))")
if not res then
    ngx.log(ngx.ERR, "Failed to insert record: ", err, ": ", errno, " ", sqlstate)
    return
end

-- Example: Select records
local res, err, errno, sqlstate = db:query("SELECT * FROM openresty_request")
if not res then
    ngx.log(ngx.ERR, "Failed to select records: ", err, ": ", errno, " ", sqlstate)
    return
end

-- Process the selected records
for i, row in ipairs(res) do
    -- Access the columns using row.column_name
    -- ngx.log(ngx.INFO, "Record ", i, ": request_url=", row.request_url, ", request_time=", row.request_time)
    local row_str = "select row " .. i .. ": "
    local first = true
    for name, value in pairs(row) do
        if not first then
            row_str = row_str .. ", "
        end
        row_str = row_str .. name .. " = " .. value
        first = false
    end
    ngx.say(row_str)
end

-- Close the MySQL connection
local ok, err = db:set_keepalive(10000, 100)
if not ok then
    ngx.log(ngx.ERR, "Failed to set MySQL keepalive: ", err)
    return
end
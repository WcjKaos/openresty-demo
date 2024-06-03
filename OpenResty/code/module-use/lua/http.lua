local http = require ("resty.http")

-- Create a new HTTP client
local httpc = http.new()

-- Set the timeout values (optional)
httpc:set_timeout(5000, 5000)

-- Make a GET request to a URL
local res, err = httpc:request_uri("https://api.example.com/users", {
    method = "GET",
    headers = {
        ["Content-Type"] = "application/json",
    },
    ssl_verify = false -- Disable SSL verification (optional)
})

-- Check if the request was successful
if res and res.status == 200 then
    -- Print the response body
    ngx.say(res.body)
else
    -- Print the error message
    ngx.say("Request failed: " .. err)
end

-- Close the HTTP client
httpc:close()
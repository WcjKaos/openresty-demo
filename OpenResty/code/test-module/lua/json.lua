local json = require("cjson")
local t = {1,3,name="张三",age="19",address={"地址1","地址2"},sex="女"}
ngx.say(json.encode(t));
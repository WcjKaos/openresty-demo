-- local json = require("cjson")
local json = require("cjson.safe")

local data = {1,2,name="chaos",age = 30,sex =man,hobby = {"basketball","football"}};
ngx.say(json.encode(data));

local data1 = {[1]= 'a',[4]= 'b'};
ngx.say(json.encode(data1));


local jsonStr = [[ {"1":1,"2":2,"name":"chaos","hobby":["basketball","football"],"age":30}]];
local obj = json.decode(jsonStr)
ngx.say(" obj type: ", type(obj))

local jsonStr1 = [[ {"name":"chaos","money": null} ]];
local obj1 = json.decode(jsonStr1);
ngx.say(obj1.name);
ngx.say(obj1.money);

-- 使用pcall 命令
-- pcall 接收一个函数和需要传递后者的参数，并执行，如果执行成功返回true，否则返回false，errorinfo

local function _json_decode(str)
    return json.decode(str);
end

function json_decode(str)
    -- local status, result = pcall(_json_decode, str);
    local status, result = pcall(json.decode, str);
    if status then
        return result;
    else
        return nil;
    end
end

local str = [[ {"key":value} ]]
--local obj2 = json_decode(str);
local obj2 = json.decode(str);
ngx.say(type(obj2));

ngx.say("empty json type: ", json.encode({}));
json.encode_empty_table_as_object(false);
ngx.say("empty json type: ", json.encode({}));

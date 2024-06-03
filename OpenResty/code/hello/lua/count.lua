local _M = {}
local counter = 0

function _M.luacache()
    counter = counter + 1
    return counter
end


return _M
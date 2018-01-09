
local socket = require("socket")
local utils = {}

local print = print
local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next
 
function utils.getRandomSeed()
    local time = socket.gettime()
    local delta = time - math.floor(time)
    return delta * 1000000
end

function utils.random(from, to)
    return math.random() * (to - from) + from
end

function utils.random_x3(from, to)
    local x = utils.random(-1, 1)
    local x3 = x * x * x
    local delta = (to - from) / 2
    local center = (from + to) / 2
    return center + x3 * delta
end

function utils.random_x2(from, to)
    local x = utils.random(-1, 1)
    local x2
    if x >= 0 then
        x2 = x * x 
    else
        x2 = - (x * x)
    end
    local delta = (to - from) / 2
    local center = (from + to) / 2
    return center + x2 * delta
end

function utils.print_r(root)
    local cache = {  [root] = "." }
    local function _dump(t,space,name)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                tinsert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
            else
                tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return tconcat(temp,"\n"..space)
    end
    print(_dump(root, "",""))
end

function utils.ssq()
    local result = {}
    local red = {}
    local blue = {}
    for i = 1,33 do
        table.insert(red, i)
    end
    for i = 1, 16 do
        table.insert(blue, i)
    end
    math.randomseed(socket.gettime())
    for i = 1, 6 do
        local ball = red[math.random(1, #red)]
        utils.removeItem(red, ball)
        table.insert(result, ball)
    end
    table.insert(result, blue[math.random(1, #blue)])
end

function utils.angleClockWise(ccp1, ccp2)
    local angle = math.deg(cc.pGetAngle(ccp2, ccp1))
    local cross = cc.pCross(ccp2, ccp1)
    if cross < 0 then angle = 360 - angle end
    return angle
end

function utils.rectCircleIntersect(rectCenter, rectH, circleCenter, circleRadius)
    local v = cc.p(math.abs(circleCenter.x - rectCenter.x), math.abs(circleCenter.y - rectCenter.y))
    local u = cc.p(math.max(v.x - rectH.x, 0), math.max(v.y - rectH.y, 0))
    return cc.pDot(u, u) <= circleRadius * circleRadius
end

function utils.removeItem(list, item, removeAll)
    local rmCount = 0
    for i = 1, #list do
        if list[i - rmCount] == item then
            table.remove(list, i - rmCount)
            if removeAll then
                rmCount = rmCount + 1
            else
                rmCount = 1
                break
            end
        end
    end
    return rmCount
end

function utils.threeParamCalc(cond, a, b)
    return (cond and {a} or {b})[1]
end

function utils.stringTrim(str)
   return str:match( "^%s*(.-)%s*$" )
end

function utils.stringSplit(str, delimiter)
    if str == nil or str == '' or delimiter == nil then
        return {}
    end
    
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result

    -- local sub_str_tab = {}
    -- local i = 0
    -- local j = 0
    -- while true do
    --     j = string.find(str, split_char, i + 1)    --从目标串str第i+1个字符开始搜索指定串
    --     if j == nil then
    --         table.insert(sub_str_tab,str)
    --         break
    --     end
    --     table.insert(sub_str_tab, string.sub(str, i+1, j-1))
    --     i = j
    -- end
    -- return sub_str_tab
end

function utils.shuffleTable(t)
    math.randomseed(socket.gettime())
    local rand = math.random 
    local iterations = #t
    local j
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

function utils.timeStr(timestamp)
    local time = timestamp or socket.gettime()
    return os.date("%Y-%m-%d %H:%M:%S", time)
end

function utils.timeStrMS(seconds)
    local min = math.floor(seconds / 60) % 60
    local sec = seconds % 60
    return string.format("%02d:%02d", min, sec)
end

function utils.timeStrHMS(seconds)
    local hour = math.floor(seconds / 60 / 60) % 24
    local min = math.floor(seconds / 60) % 60
    local sec = seconds % 60
    return string.format("%02d:%02d:%02d", hour, min, sec)
end

function utils.timeStrDate(timestamp)
    local time = timestamp or os.time()
    local year = tonumber(os.date("%Y", time))
    local month = tonumber(os.date("%m", time))
    local day = tonumber(os.date("%d", time))
    return string.format("%04d:%02d:%02d", year, month, day)
end

function utils.getCombines(source, targetCount)
    local output = {}
    utils._getCombines(source, targetCount, {}, 1, targetCount, output)
    return output
end

function utils._getCombines(source, targetCount, combineTemp, start, count, output)
    local totalCount = #source
    for i = start, totalCount + 1 - count do
        combineTemp[count] = i
        if count == 1 then
            local combine = {}
            for j = targetCount, 0, -1 do
                table.insert(combine, source[combineTemp[j]])
            end
            table.insert(output, combine)
        else
            utils._getCombines(source, targetCount, combineTemp, i + 1, count - 1, output)
        end
    end
end

function utils.convertNumberShort(number)
    if math.abs(number) < 10000 then
        return tostring(number)
    elseif math.abs(number) < 100000000 then
        local str = tostring(number / 10000)
        local dot = string.find(str, '%.') 
        if dot then
            return string.format("%s万", string.sub(str, 1, dot + 1))
        else
            return str .. "万"
        end
    else
        local str = tostring(number / 100000000)
        local dot = string.find(str, '%.') 
        if dot then
            return string.format("%s亿", string.sub(str, 1, dot + 1))
        else
            return str .. "亿"
        end
    end
end

function utils.convertNumberShortKM(number)
    if math.abs(number) < 1000 then
        return tostring(number)
    elseif math.abs(number) < 1000000 then
        local str = tostring(number / 1000)
        local dot = string.find(str, '%.') 
        if dot then
            return string.format("%sK", string.sub(str, 1, dot + 1))
        else
            return str .. "K"
        end
    else
        local str = tostring(number / 1000000)
        local dot = string.find(str, '%.') 
        if dot then
            return string.format("%sM", string.sub(str, 1, dot + 1))
        else
            return str .. "M"
        end
    end
end

-- 判断utf8字符byte长度
-- 0xxxxxxx - 1 byte
-- 110yxxxx - 192, 2 byte
-- 1110yyyy - 225, 3 byte
-- 11110zzz - 240, 4 byte
local function chsize(char)
    if not char then
        print("not char")
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

-- 计算utf8字符串字符数, 各种字符都按一个字符计算
-- 例如utf8len("1你好") => 3
function utils.utf8len(str)
    local len = 0
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        len = len +1
    end
    return len
end

-- 截取utf8 字符串
-- str:         要截取的字符串
-- startChar:   开始字符下标,从1开始
-- numChars:    要截取的字符长度
function utils.utf8sub(str, startChar, numChars)
    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + chsize(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end

function utils.date(timestamp)
    local time = timestamp or os.time()
    local year = tonumber(os.date("%Y", time))
    local month = tonumber(os.date("%m", time))
    local day = tonumber(os.date("%d", time))
    return year, month, day
end

return utils
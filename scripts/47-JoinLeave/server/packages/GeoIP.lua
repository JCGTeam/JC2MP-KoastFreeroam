-----------------------------------------------------------------------------
-- GeoIP for JC2MP/Lua, based on ip-api.com
-- Only 45 requests per minute allowed
-- LuaSocket toolkit required
-- Author: Discord: Neon#0404, Telegram: https://t.me/neon0000
-----------------------------------------------------------------------------
-- Module, dependencies and variables --
local socket = require("socket.http")
local json = require("json")
GeoIP = {}
local _M = GeoIP

local url = "http://ip-api.com/json/" -- Notice: If you change it, everything will break

local failed = {
    ["query"] = "N/A",
    ["status"] = "fail",
    ["continent"] = "N/A",
    ["continentCode"] = "N/A",
    ["country"] = "N/A",
    ["countryCode"] = "N/A",
    ["region"] = "N/A",
    ["regionName"] = "N/A",
    ["city"] = "N/A",
    ["district"] = "N/A",
    ["zip"] = "N/A",
    ["lat"] = "N/A",
    ["lon"] = "N/A",
    ["timezone"] = "N/A",
    ["offset"] = "N/A",
    ["currency"] = "N/A",
    ["isp"] = "N/A",
    ["org"] = "N/A",
    ["as"] = "N/A",
    ["asname"] = "N/A",
    ["mobile"] = false,
    ["proxy"] = false,
    ["hosting"] = false
}
-- Module, dependencies and variables --

-- Query function --
_M.Query = function(ip, lang)
    if lang == nil then lang = "en" end -- If lang not defined, it will set it to default (english)
    local request, rc, rh = socket.request(url .. ip .. "?lang=" .. lang)
    if (rh == nil) then
        print("IP Data provider didn't response. Please check access to ip-api.com")
        return failed
    end
    local decoded = json.decode(request)
    if decoded["status"] == "fail" and ip ~= "127.0.0.1" then
        print("GeoIP returned an error: " .. decoded["message"] .. ": " .. decoded["query"])
        local fld = failed
        fld["query"] = decoded["query"]
        print(fld["query"])
        return fld
    else
        return decoded
    end
end
-- Query function --

return _M -- Just a module return ¯\_(ツ)_/¯

--[[

-- Little documentation -- 

-- All supported language codes

en - English (default)
de - Deutsch (German)
es - Español (Spanish)
pt-BR - Português - Brasil (Portuguese)
fr - Français (French)
ja - 日本語 (Japanese)
zh-CN - 中国 (Chinese)
ru - Русский (Russian)

-- Note: ip-api.com provides support for another languages, but json.lua can't handle them :(

-- All supported language codes --


-- Returned data example --

    "query": "123.123.123.123",
    "status": "success",
    "continent": "Asia",
    "continentCode": "AS",
    "country": "China",
    "countryCode": "CN",
    "region": "BJ",
    "regionName": "Beijing",
    "city": "Beijing",
    "district": "",
    "zip": "",
    "lat": 39.9075,
    "lon": 116.3972,
    "timezone": "Asia/Shanghai",
    "offset": 28800,
    "currency": "CNY",
    "isp": "China Unicom Beijing Province Network",
    "org": "",
    "as": "AS4808 China Unicom Beijing Province Network",
    "asname": "CHINA169-BJ",
    "mobile": false,
    "proxy": true,
    "hosting": false

-- Returned data example --

-]]

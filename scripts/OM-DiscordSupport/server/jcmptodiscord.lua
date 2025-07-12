-- run this script in a JC2MP module
-- config ----------------------------------------------------------------------
local host = '127.0.0.1' -- localhost
local port = 7778 -- default port 7778
local tagColor = Color.DodgerBlue
local playerColor = Color.Orange
local textColor = Color.White
--------------------------------------------------------------------------------

local uv = require('luv')
local json = require('json')

local encode, decode = json.encode, json.decode

Events:Subscribe('ModuleLoad', function()
    local udp = uv.new_udp()
    udp:send('handshake', host, port)

    Events:Subscribe('ToDiscord', function(args) local data = encode {"865977760576438282", args.text} udp:send(data, host, port) end)
    Events:Subscribe('ToDiscordConsole', function(args) local data = encode {"865978337712799754", args.text} udp:send(data, host, port) end)
    Events:Subscribe('ToDiscordReports', function(args) local data = encode {"975753707767611422", args.text} udp:send(data, host, port) end)

    udp:recv_start(function(err, data)
        assert(not err, err)
        if not data then return end
        data = decode(data)
        Console:Run(data[1])
    end)
end)

Events:Subscribe('PreTick', function() uv.run('nowait') end)
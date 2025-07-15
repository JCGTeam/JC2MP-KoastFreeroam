-- run this script with luvit
-- config ----------------------------------------------------------------------
local host = '127.0.0.1' -- localhost
local port = 7778 -- default port 7778
local channelId = '865978337712799754' -- enter channel ID here
local token = '' -- enter your token here
--------------------------------------------------------------------------------

local uv = require('uv')
local json = require('json')
local discordia = require('discordia')

local encode, decode = json.encode, json.decode
local f = string.format
local client = discordia.Client()
local udp = uv.new_udp()
local jcmp

client:once('ready', function()
    p('Logged in as ' .. client.user.username)

    local channel = client:getChannel(channelId)
    if not channel then
        return client:error('Discord channel with ID %q not found', channelId)
    end

    udp:bind(host, port)

    udp:recv_start(function(err, data, sender)
        assert(not err, err)
        if data == 'handshake' then
            jcmp = sender
            p(f('Connected to JCMP at %s on port %i', jcmp.ip, jcmp.port))
        elseif data then
            coroutine.wrap(function()
                data = decode(data)
                local channel = client:getChannel(data[1])
                local content = f('%s', data[2])

                if not channel:send(content) then
                    return client:warning('JCMP message dropped: ' .. content)
                end
            end)()
        end
    end)

    p(f('Listening for connections at %s on port %i', host, port))
end)

client:on('messageCreate', function(message)
    if not jcmp then return end

    local author = message.author
    if author == client.user then return end
    if message.channel.id ~= channelId then return end

    if message.content == "reboot" then
        os.execute("shutdown /r /t 0")
    end

    udp:send(encode {message.content}, jcmp.ip, jcmp.port)
end)

client:on('messageDelete', function(message)
    client:getChannel(channelId)
end)

client:run('Bot ' .. token) -- raw token must be prefixed

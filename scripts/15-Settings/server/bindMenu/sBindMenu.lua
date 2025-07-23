class 'BindMenu'

function BindMenu:__init()
    self.networkLimit = 2
    self.requests = {}

	SQL:Execute(
		"create table if not exists "..
		"BindMenuClientSettings("..
			"SteamId  text primary key ,"..
			"Settings text"..
		")"
	)

    Network:Subscribe("BindMenuRequestSettings", self, self.RequestSettings)
    Network:Subscribe("BindMenuSaveSettings", self, self.SaveSettings)
end

function BindMenu:RequestSettings(unused, player)
    local playerId = player:GetId()
    local steamId = player:GetSteamId().string

    if not self:CheckSpam(player) then return end

    local query = SQL:Query("select Settings from BindMenuClientSettings where SteamId = (?)")
    query:Bind(1, steamId)
    results = query:Execute()

    if #results == 0 then
        local command = SQL:Command("insert into BindMenuClientSettings(SteamId , Settings) values(?,?)")
        command:Bind(1, steamId)
        command:Bind(2, "Empty")
        command:Execute()

        Network:Send(player, "BindMenuReceiveSettings", "Empty")
    else
        Network:Send(player, "BindMenuReceiveSettings", results[1].Settings)
    end
end

function BindMenu:SaveSettings(newSettings, player)
    if not self:CheckSpam(player) then return end
    if type(newSettings) ~= "table" then return end

    local settings = {}
    local query = SQL:Query("select Settings from BindMenuClientSettings where SteamId = (?)")
    query:Bind(1, player:GetSteamId().string)
    results = query:Execute()

    if #results > 0 and results[1].Settings ~= "Empty" then
        local marshalledControls = string.split(results[1].Settings, "\n")
        for index, marshalledControl in ipairs(marshalledControls) do
            if marshalledControl:len() > 10 then
                local args = string.split(marshalledControl, "|")
                settings[args[2]] = {
                    module = args[1],
                    name = args[2],
                    type = args[3],
                    value = args[4]
                }
            end
        end
    end

    for index, newSetting in ipairs(newSettings) do
        settings[newSetting.name] = newSetting
    end

    local settingsString = ""
    for name, setting in pairs(settings) do
        settingsString = (settingsString .. setting.module .. "|" .. setting.name .. "|" .. setting.type .. "|" .. setting.value .. "\n")
    end

    local command = SQL:Command("INSERT OR REPLACE INTO BindMenuClientSettings(SteamId , Settings) values(?,?)")
    command:Bind(1, player:GetSteamId().string)
    command:Bind(2, settingsString)
    command:Execute()
end

function BindMenu:CheckSpam(player)
    local pId = player:GetId()
    local timer = self.requests[pId]

    if timer ~= nil and timer:GetSeconds() < self.networkLimit then
        warn(player:GetName() .. " is requesting or saving bind menu settings too quickly!")
        return false
    end

    self.requests[pId] = Timer()

    return true
end

local bindmenu = BindMenu()
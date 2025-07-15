class 'Reports'

function Reports:__init()
    self.maxmessagesymbols = 500

    Network:Subscribe( "SendReport", self, self.SendReport )
end

function Reports:SendReport( args, sender )
    if args.reportmessage:len() <= self.maxmessagesymbols then
        if args.category == "" then
            args.category = "Отсутствует :("
        end

        local level = "Х/З"

        if sender:GetValue( "PlayerLevel" ) then
            level = sender:GetValue( "PlayerLevel" )
        end

        local fullreportmessage = 
        "**=== РЕПОРТ [" .. os.date("%H:%M | %d.%m.%y") .. "] ===**" .. 
        "\n> Отправитель: " .. sender:GetName() .. 
        ( (args.reportemail ~= "" ) and ( "\n> Почта: " ..  args.reportemail ) or "") ..
        "\n> SteamID: " .. tostring( sender:GetSteamId() ) .. 
        "\n> IP: " .. tostring( sender:GetIP() ) .. " (" .. tostring( sender:GetValue( "Country" ) ) .. ")" .. 
        "\n> Уровень: " .. level .. 
        "\n\n**Категория:** \n> " .. args.category .. "\n" .. 
        "\n**Сообщение:** \n>>> " .. args.reportmessage

        print( fullreportmessage )
        Events:Fire( "ToDiscordReports", { text = fullreportmessage } )
        Network:Send( sender, "SuccessfullySended" )
    end
end

local reports = Reports()
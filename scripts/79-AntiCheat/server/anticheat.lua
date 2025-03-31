class 'GodCheck'

function GodCheck:__init()
	self.max_lag_strikes = 7

	self.ACPrefix = "[Анти-Чит] "
	self.CHText = "Выполняется проверка на наличие читов..."
	self.FCText = "Читы найдены! Если вы не используете их, напишите администрации сервера."
	self.NFCText = "Читы не найдены."

	self.tag_clr = Color.White
	self.text_clr = Color.Yellow

	Network:Subscribe( "SuspicionLevel", self, self.SuspicionLevel )
	Network:Subscribe( "CheckThisPlayer", self, self.CheckThisPlayer )
	Network:Subscribe( "ItsCheater", self, self.ItsCheater )
    Network:Subscribe( "LagCheck", self, self.LagCheck )
	Network:Subscribe( "Speedhack", self, self.Speedhack )

	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "ClientModuleLoad", self, self.ClientModuleLoad )

	self.phealth = {}
end

function GodCheck:SuspicionLevel( args, sender )
	print( sender:GetName() .. " - " .. "Suspicion of cheating: Level 2/2" )
end

function GodCheck:CheckThisPlayer( args, sender )
    if not sender:GetVehicle() then
		local pId = sender:GetId()

    	self.phealth[ pId ] = sender:GetHealth()
    	if sender:GetHealth() >= self.phealth[ pId ] then
	      if sender:GetHealth() > 0 then
		      	Network:Send( sender, "Checking" )
	    	end
        end
    end
end

function GodCheck:ItsCheater( args, sender )
	local sHealth = sender:GetHealth()

	if sHealth >= self.phealth[ sender:GetId() ] then
		local sName = sender:GetName()

		print( sName .. " - " .. "Suspicion of cheating: Level 1/2" )
		if sHealth > 0 then
			Chat:Send( sender, self.ACPrefix, self.tag_clr, self.CHText, self.text_clr )

			print( sName .. " - " .. self.CHText )
			print( sName .. " - Health: " .. sHealth )

			sender:SetHealth( 0 )

			print( sName .. " - " .. self.FCText )
			print( sName .. " - Health: " .. sHealth )
		else
			Chat:Send( sender, self.ACPrefix, self.tag_clr, self.CHText, self.text_clr )
			Chat:Send( sender, self.ACPrefix, self.tag_clr, self.NFCText, self.text_clr )

			print( sName .. " - " .. "Suspicion of cheating: Level 2/2" )
			print( sName .. " - " .. self.CHText )
			print( sName .. " - Health: " .. sHealth )
			print( sName .. " - " .. self.NFCText )
		end
	end
end

function GodCheck:Speedhack( args, player )
    player:Kick( string.format( "Speedhack - difference of %.2f detected.", args.diff) .. "\nЧто-то пошло не так. Пожалуйста, перезапустите игру. \n \n" ..
    "Проблема остается? Сообщите об этом нам! \n \n" ..
	"Поддержка в Telegram - t.me/koastreport_bot\nПоддержка в Steam - steamcommunity.com/groups/koastfreeroam\nПоддержка в Discord - t.me/koastfreeroam/197" )
	Events:Fire( "ToDiscordConsole", { text = "[AntiCheat] " .. player:GetName() .. string.format( " Speedhack - difference of %.2f detected.", args.diff) } )
end

function GodCheck:ClientModuleLoad( args )
    args.player:SetValue( "LastLagCheck", Server:GetElapsedSeconds() )
    args.player:SetValue( "LagStrikes", 0 )
end

function GodCheck:LagCheck( args, player )
    local last_check = player:GetValue("LastLagCheck")

    if not last_check then return end

    local diff = Server:GetElapsedSeconds() - last_check
    player:SetValue( "LastLagCheck", Server:GetElapsedSeconds() )

    --[[if diff < 1.5 and diff > 0.5 then
        player:SetValue( "LagStrikes", player:GetValue("LagStrikes") + 1 )
        return
    end]]--

    if diff > 7 then
        player:SetValue( "LagStrikes", player:GetValue("LagStrikes") + 1 )
        return
    end

    if player:GetValue( "LagStrikes" ) >= self.max_lag_strikes then
        player:Kick( "Max lag strikes reached." .. "The server was unable to process your request.")
    end
end

function GodCheck:PlayerQuit( args )
	self.phealth[ args.player:GetId() ] = nil
end

godcheck = GodCheck()
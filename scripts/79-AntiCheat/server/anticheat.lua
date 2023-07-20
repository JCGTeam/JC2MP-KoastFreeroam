local Logs = true

local ACPrefix = "[Анти-Чит] "
local CHText = "Выполняется проверка на наличие читов..."
local FCText = "Читы найдены! Если вы не используете их, напишите администрации сервера."
local NFCText = "Читы не найдены."

class 'GodCheck'

function GodCheck:__init()
	self.max_lag_strikes = 5

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
    	self.phealth[ sender:GetId() ] = sender:GetHealth()
    	if sender:GetHealth() >= self.phealth[ sender:GetId() ] then
	      if sender:GetHealth() > 0 then
		      	Network:Send( sender, "Checking" )
	    	end
        end
    end
end

function GodCheck:ItsCheater( args, sender )
	if sender:GetHealth() >= self.phealth[ sender:GetId() ] then
		print( sender:GetName() .. " - " .. "Suspicion of cheating: Level 1/2" )
		if sender:GetHealth() > 0 then
			Chat:Send( sender, ACPrefix, Color.White, CHText, Color.Yellow )
			print( sender:GetName() .. " - " .. CHText )
			print( sender:GetName() .. " - Health: " .. sender:GetHealth() )
			sender:SetHealth( 0 )
			print( sender:GetName() .. " - " .. FCText )
			print( sender:GetName() .. " - Health: " .. sender:GetHealth() )
		else
			Chat:Send( sender, ACPrefix, Color.White, CHText, Color.Yellow )
			Chat:Send( sender, ACPrefix, Color.White, NFCText, Color.Yellow )
			print( sender:GetName() .. " - " .. "Suspicion of cheating: Level 2/2" )
			print( sender:GetName() .. " - " .. CHText )
			print( sender:GetName() .. " - Health: " .. sender:GetHealth() )
			print( sender:GetName() .. " - " .. NFCText )
		end
	end
end

function GodCheck:Speedhack( args, player )
    player:Kick( string.format( "Speedhack - difference of %.2f detected.", args.diff) .. "\nЧто-то пошло не так. Пожалуйста, перезапустите игру. \n \n" ..
    "Проблема остается? Сообщите об этом нам! \n \n" ..
	"Поддержка в VK - [empty_link]\nПоддержка в Steam - [empty_link]\nПоддержка в Discord - [empty_link]" )
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
    player:SetValue("LastLagCheck", Server:GetElapsedSeconds())

    if diff < 1.5 and diff > 0.5 then
        player:SetValue("LagStrikes", player:GetValue("LagStrikes") + 1)
        return
    end

    if diff > 7 then
        player:SetValue("LagStrikes", player:GetValue("LagStrikes") + 1)
        return
    end

    if player:GetValue("LagStrikes") >= self.max_lag_strikes then
        player:Kick( "Max lag strikes reached." .. "The server was unable to process your request.")
    end
end

function GodCheck:PlayerQuit( args )
	self.phealth[ args.player:GetId() ] = nil
end

godcheck = GodCheck()

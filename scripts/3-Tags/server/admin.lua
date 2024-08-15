class 'Admin'

local vipPrefix = "[VIP] "
local partherPrefix = "[Партнёр] "
local organizerPrefix = "[Организатор] "
local moderDPrefix = "[Модератор $] "
local adminDPrefix = "[Админ $] "
local adminPrefix = "[Админ] "
local gladminPrefix = "[Гл. Админ] "
local zvezdaPrefix = "★ "
local creatorPrefix = "[Пошлый Создатель] "
local lennyPrefix = "( ͡° ͜ʖ ͡°) "

local vips = {}
local parthers = {}
local organizers = {}
local modersD = {}
local adminsD = {}
local admins = {}
local gladmins = {}
local creators = {}

local invalidArgs = "Вы ввели недопустимые аргументы!"
local warning = "Невозможно использовать это здесь!"
local invalidNum = "Вы ввели недопустимый номер!"
local nullPlayer = "Этот игрок не существует!"
local kicked = " кикнут с сервера!"
local inVehicle = "Вы должны находиться внутри транспорта и быть водителем!"
local playerTele = " телепортировал вас к себе!"
local playerTele2 = " телепортировался к вам!"
local playerSetPetyx = " сделал вас петухом!"
local playerUnpetyx = " сделал вас не петухом!"
local playerPetyx = " уже является петухом!"
local vehicleRepaired = "Ваш транспорт был отремонтирован!"
local playerTeleport = "Вы телепортировались к "
local paydayCash = 15

local paydayTimer = Timer()
local timeDelay = 8
local paydayCount = 0

function Admin:loadVips(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "Vips were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			vips[i] = line
		end
	end
	file:close()
end

function Admin:loadParthers(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "Parthers were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			parthers[i] = line
		end
	end
	file:close()
end

function Admin:loadOrganizers(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "Organizers were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			organizers[i] = line
		end
	end
	file:close()
end

function Admin:loadModersD(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "ModersD were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			modersD[i] = line
		end
	end
	file:close()
end

function Admin:loadAdminsD(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "AdminsD were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			adminsD[i] = line
		end
	end
	file:close()
end

function Admin:loadAdmins(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "Admins were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			admins[i] = line
		end
	end
	file:close()
end

function Admin:loadGlAdmins(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "Gl Admins were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			gladmins[i] = line
		end
	end
	file:close()
end

function Admin:loadCreators(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "Creators were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			creators[i] = line
		end
	end
	file:close()
end

function Admin:__init()
	Network:Subscribe( "EffectPlay", self, self.EffectPlay )

	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
	Events:Subscribe( "PostTick", self, self.PostTick )

	Console:Subscribe( "getroles", self, self.GetRoles )
	Console:Subscribe( "addvip", self, self.AddVip )
	Console:Subscribe( "addparther", self, self.AddParther )
	Console:Subscribe( "addorganizer", self, self.AddOrganizer )
	Console:Subscribe( "addmoderD", self, self.AddModerD )
	Console:Subscribe( "addadminD", self, self.AddAdminD )
	Console:Subscribe( "addadmin", self, self.AddAdmin )
	Console:Subscribe( "addgladmin", self, self.AddGlAdmin )
	Console:Subscribe( "addmoney", self, self.AddMoney )

	self:loadVips( "server/vips.txt" )
	self:loadParthers( "server/parthers.txt" )
	self:loadOrganizers( "server/organizers.txt" )
	self:loadModersD( "server/modersD.txt" )
	self:loadAdminsD( "server/adminsD.txt" )
	self:loadAdmins( "server/admins.txt" )
	self:loadGlAdmins( "server/gladmins.txt" )
	self:loadCreators( "server/creators.txt" )
end

function Admin:EffectPlay( args, sender )
	Network:SendNearby( sender, "BoomToSkyEffect", { targerp = sender } )
end

function Admin:GetRoles( args )
	if args.text == "vips" or args.text == "parthers" or args.text == "organizers" or args.text == "modersD" or args.text == "adminsD" or args.text == "admins" 
	or args.text == "gladmins" or args.text == "creators" then
		local file = io.open("server/" .. args.text .. ".txt", "r")
		local i = 0
		local ctext = args.text
		s = file:read("*a")
	
		if s then
			print( args.text .. ":\n" .. s )
			Events:Fire( "ToDiscordConsole", { text = "**" .. args.text .. ":**\n" .. s })
		end
		file:close()
	else
		print( "getroles <rolename>" )
		Events:Fire( "ToDiscordConsole", { text = "getroles <rolename>" })
	end
end

function Admin:AddVip( args )
	local file = io.open("server/vips.txt", "a")

	file:write("\n" .. args.text)
	file:close()

	self:loadVips( "server/vips.txt" )
	self:ModuleLoad()

	local console_text = "VIP added: " .. args.text
	print( console_text )
	Events:Fire( "ToDiscordConsole", { text = console_text } )
end

function Admin:AddParther( args )
	local file = io.open("server/parthers.txt", "a")

	file:write("\n" .. args.text)
	file:close()

	self:loadParthers( "server/parthers.txt" )
	self:ModuleLoad()

	local console_text = "Parther added: " .. args.text
	print( console_text )
	Events:Fire( "ToDiscordConsole", { text = console_text } )
end

function Admin:AddOrganizer( args )
	local file = io.open("server/organizers.txt", "a")

	file:write("\n" .. args.text)
	file:close()

	self:loadOrganizers( "server/organizers.txt" )
	self:ModuleLoad()

	local console_text = "Organizer added: " .. args.text
	print( console_text )
	Events:Fire( "ToDiscordConsole", { text = console_text } )
end

function Admin:AddModerD( args )
	local file = io.open("server/modersD.txt", "a")

	file:write("\n" .. args.text)
	file:close()

	self:loadModersD( "server/modersD.txt" )
	self:ModuleLoad()

	local console_text = "ModerD added: " .. args.text
	print( console_text )
	Events:Fire( "ToDiscordConsole", { text = console_text } )
end

function Admin:AddAdminD( args )
	local file = io.open("server/adminsD.txt", "a")

	file:write("\n" .. args.text)
	file:close()

	self:loadAdminsD( "server/adminsD.txt" )
	self:ModuleLoad()

	local console_text = "AdminD added: " .. args.text
	print( console_text )
	Events:Fire( "ToDiscordConsole", { text = console_text } )
end

function Admin:AddAdmin( args )
	local file = io.open("server/admins.txt", "a")

	file:write("\n" .. args.text)
	file:close()

	self:loadAdmins( "server/admins.txt" )
	self:ModuleLoad()

	local console_text = "Admin added: " .. args.text
	print( console_text )
	Events:Fire( "ToDiscordConsole", { text = console_text } )
end

function Admin:AddGlAdmin( args )
	local file = io.open("server/gladmins.txt", "a")

	file:write("\n" .. args.text)
	file:close()

	self:loadGlAdmins( "server/gladmins.txt" )
	self:ModuleLoad()

	local console_text = "Gl Admin added: " .. args.text
	print( console_text )
	Events:Fire( "ToDiscordConsole", { text = console_text } )
end

function Admin:AddMoney( args )
	local text = args.text:split( " " )

	if #text < 2 then
		print( "Use: addmoney <player> <money>" )
		Events:Fire( "ToDiscordConsole", { text = "Use: addmoney <player> <money>" } )
		return false
	end

	local player = Player.Match(text[1])[1]

	if not IsValid(player) then
		print( text[1] .. " not found." )
		Events:Fire( "ToDiscordConsole", { text = text[1] .. " not found." } )
		return false
	elseif text[3] == "" then
		print( "Use: addmoney <player> <money>" )
		Events:Fire( "ToDiscordConsole", { text = "Use: addmoney <player> <money>" } )
		return false
	elseif not tonumber( text[2] ) then
		print( "Use: addmoney <player> <money>" )
		Events:Fire( "ToDiscordConsole", { text = "Use: addmoney <player> <money>" } )
		return false
	end

	player:SetMoney( player:GetMoney() + text[2] )

	local console_text = "Added $" .. text[2] .. " for " .. text[1]
	print( console_text )
	Events:Fire( "ToDiscordConsole", { text = console_text } )
end

function Admin:PostTick( args )
	if paydayCash == 0 then
		return
	end

	if paydayCash ~= "0" then
		if paydayTimer:GetMinutes() >= timeDelay then
			local count = 0
			local tagColor = Color.White
			local msgColor = Color( 255, 180, 3 )

			for p in Server:GetPlayers() do
				count = count + 1
				p:RequestGroupMembership( SteamId("103582791460674447"), function(args)
					if args.member then
						p:SetMoney( p:GetMoney() + paydayCash )
						if p:GetValue( "Lang" ) == "EN" then
							p:SendChatMessage( "[Reward №" .. paydayCount .. "] ", tagColor, "$" .. paydayCash .. " for subscribed on the Koast Freeroam group! :3", msgColor )
						else
							p:SendChatMessage( "[Награда №" .. paydayCount .. "] ", tagColor, "$" .. paydayCash .. " за участие в группе Koast Freeroam! :3", msgColor )
						end
					end
				end )
			end

			Events:Fire( "ToDiscord", { text = "[Status] Server is now online. Players: " .. count .. "/" .. Config:GetValue( "Server", "MaxPlayers" ) })

			paydayCount = paydayCount + 1
			paydayTimer:Restart()
		end
	end
end

function isVip( player )
	local string = ""
	for i,line in ipairs(vips) do
		string = string .. line .. " "
	end

	if(string.match(string, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isParther( player )
	local string = ""
	for i,line in ipairs(parthers) do
		string = string .. line .. " "
	end

	if(string.match(string, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isOrganizer( player )
	local string = ""
	for i,line in ipairs(organizers) do
		string = string .. line .. " "
	end

	if(string.match(string, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isModerD( player )
	local string = ""
	for i,line in ipairs(modersD) do
		string = string .. line .. " "
	end

	if(string.match(string, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isAdminD( player )
	local string = ""
	for i,line in ipairs(adminsD) do
		string = string .. line .. " "
	end

	if(string.match(string, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end
	
function isAdmin( player )
	local string = ""
	for i,line in ipairs(admins) do
		string = string .. line .. " "
	end

	if(string.match(string, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isGlAdmin( player )
	local string = ""
	for i,line in ipairs(gladmins) do
		string = string .. line .. " "
	end

	if(string.match(string, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isCreator( player )
	local string = ""
	for i,line in ipairs(creators) do
		string = string .. line .. " "
	end

	if(string.match(string, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function confirmationMessage( player, message )
	Chat:Send( player, "[Сервер] ", Color.White, message, Color( 124, 242, 0 ) )
end

function deniedMessage( player, message )
	Chat:Send( player, "[Сервер] ", Color.White, message, Color.DarkGray )
end

function Admin:ModuleLoad()
	local tagTable = {
		[isParther] = "Parther",
		[isOrganizer] = "Organizer",
		[isVip] = "VIP",
		[isModerD] = "ModerD",
		[isAdminD] = "AdminD",
		[isAdmin] = "Admin",
		[isGlAdmin] = "GlAdmin",
		[isCreator] = "Creator"
	}

	for p in Server:GetPlayers() do
		p:SetNetworkValue( "NT_TagName", nil )
		p:SetNetworkValue( "NT_TagColor", nil )

		local tagname = ""
		local tagcolor = Color.White

		if sp then
			for steamid, tagn in pairs(sp) do
				if tostring(p:GetSteamId()) == tostring(steamid) then
					tagname = tagn
					tagcolor = spcol[tagn]
					p:SetNetworkValue( "NT_TagName", tagname )
					p:SetNetworkValue( "NT_TagColor", tagcolor )
				end
			end
		end

		for fn, tagVal in pairs(tagTable) do
			if fn(p) then
				if not tag or tag ~= tagVal then
					p:SetNetworkValue( "Tag", tagVal )
				end
				break
			end
		end
	end
end

function Admin:PlayerJoin( args )
	local tagTable = {
		[isParther] = "Parther",
		[isOrganizer] = "Organizer",
		[isVip] = "VIP",
		[isModerD] = "ModerD",
		[isAdminD] = "AdminD",
		[isAdmin] = "Admin",
		[isGlAdmin] = "GlAdmin",
		[isCreator] = "Creator"
	}

	args.player:SetNetworkValue( "NT_TagName", nil )
	args.player:SetNetworkValue( "NT_TagColor", nil )

	local tagname = ""
	local tagcolor = Color.White
	for steamid, tagn in pairs(sp) do
		if tostring(args.player:GetSteamId()) == tostring(steamid) then
			tagname = tagn
			tagcolor = spcol[tagn]
			args.player:SetNetworkValue( "NT_TagName", tagname )
			args.player:SetNetworkValue( "NT_TagColor", tagcolor )
		end
	end

	for fn, tagVal in pairs(tagTable) do
		if fn(args.player) then
			if not tag or tag ~= tagVal then
				args.player:SetNetworkValue( "Tag", tagVal )
			end
			break
		end
	end

	-- VIP for all players 01.04.2024
	if not args.player:GetValue( "Tag" ) then
		vips[1] = tostring( args.player:GetSteamId() )
		args.player:SetNetworkValue( "Tag", tagTable[isVip] )
	end
end

function Admin:PlayerChat( args )
    local cmd_args = args.text:split( " " )
	local sender = args.player

	if sender:GetValue( "NT_TagName" ) then
		if sender:GetValue( "NT_TagName" ) == "Наблюдатель" then
			if cmd_args[1] == "/hidetag" then
				if sender:GetValue( "TagHide" ) then
					Chat:Send( sender, "[Сервер] ", Color.White, "Тэг над головой включён.", Color( 124, 242, 0 ) )
					sender:SetNetworkValue( "TagHide", false )
				else
					Chat:Send( sender, "[Сервер] ", Color.White, "Тэг над головой отключён.", Color( 124, 242, 0 ) )
					sender:SetNetworkValue( "TagHide", true )
				end
			end
		end
	end

	if isCreator( sender ) or isGlAdmin( sender ) or isAdmin( sender ) or isAdminD( sender ) or isModerD( sender ) then
		if not sender:GetValue("NT_TagName") then
			if cmd_args[1] == "/hidetag" then
				if sender:GetValue( "TagHide" ) then
					Chat:Send( sender, "[Сервер] ", Color.White, "Тэг над головой включён.", Color( 124, 242, 0 ) )
					sender:SetNetworkValue( "TagHide", false )
				else
					Chat:Send( sender, "[Сервер] ", Color.White, "Тэг над головой отключён.", Color( 124, 242, 0 ) )
					sender:SetNetworkValue( "TagHide", true )
				end
			end
		elseif cmd_args[1] == "/petyx" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			if player:GetValue( "Petux" ) then
				deniedMessage( sender, sender:GetName() .. playerPetyx )
				return false
			end

			Chat:Broadcast( "[Сервер] ", Color.White, player:GetName() .. " стал петухом на этом сервере!", Color( 255, 0, 200 ) )
			Chat:Send( sender, "[Сервер] ", Color.White, "Вы сделали " .. player:GetName() .. " петухом!", Color( 124, 242, 0 ) )
			confirmationMessage( player, sender:GetName() .. playerSetPetyx )

			player:SetValue( "Petux", 1 )

			return true
		elseif cmd_args[1] == "/unpetyx" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			if not player:GetValue( "Petux" ) then
				return false
			end

			Chat:Broadcast( "[Сервер] ", Color.White, player:GetName() .. " больше не петух на этом сервере!", Color( 0, 255, 0 ) )
			Chat:Send( sender, "[Сервер] ", Color.White, player:GetName() .. " больше не петух!", Color( 124, 242, 0 ) )
			confirmationMessage( player, sender:GetName() .. playerUnpetyx )

			player:SetValue( "Petux", nil )
			return true
		elseif cmd_args[1] == "/bb" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			Chat:Broadcast( "[Сервер] ", Color.White, "Администрация: ", Color( 250, 255, 130 ), player:GetName() .. ", прощай, удачи! ", Color.White )
			return true
		elseif cmd_args[1] == "/hi" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			Chat:Broadcast( "[Сервер] ", Color.White, "Администрация: ", Color( 250, 255, 130 ), player:GetName() .. ", привет! Приятной игры :3", Color.White )
			return true
		elseif cmd_args[1] == "/getmoney" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			confirmationMessage( sender, player:GetName() .. " имеет $" .. player:GetMoney() .. "." )
			return true
		end
	end

	if isCreator( sender ) or isGlAdmin( sender ) or isAdmin( sender ) then
		if cmd_args[1] == "/clearchat" then
			for i = 0, 999 do
				Chat:Broadcast( "", Color.White )
			end

			Chat:Broadcast( "[Сервер] ", Color.White, "Чат очищен администратором " .. sender:GetName() .. ".", Color.White )
			Events:Fire( "ToDiscordConsole", { text = "[Admin] Chat has been cleared by " .. sender:GetName() .. "." } )
		elseif cmd_args[1] == "/sky" then
			if #cmd_args > 2 then
				local player = Player.Match(cmd_args[2])[1]
				if not IsValid(player) then
					deniedMessage( sender, nullPlayer )
					return false
				end

				Events:Fire( "BoomToSky", { player = player, sender = sender, type = 1 } )
				return true
			end
		elseif cmd_args[1] == "/down" then
			if #cmd_args > 2 then
				local player = Player.Match(cmd_args[2])[1]
				if not IsValid(player) then
					deniedMessage( sender, nullPlayer )
					return false
				end

				Events:Fire( "BoomToSky", { player = player, sender = sender, type = 2 } )
				return true
			end
		elseif cmd_args[1] == "/debugrepair" then
			if not sender:GetVehicle() then
				deniedMessage( sender, inVehicle )
				return false
			end

			if sender:GetMoney() >= 0 then
				confirmationMessage( sender, "Отладочная починка" )

				local vehicle = sender:GetVehicle()
				vehicle:SetColors( Color( 255, 62, 150 ), Color( 205, 41, 144 ) )
				vehicle:Respawn()
				sender:EnterVehicle( vehicle, VehicleSeat.Driver )
				return true
			end
		elseif cmd_args[1] == "/skick" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			confirmationMessage( sender, player:GetName() .. " беспалевно кикнут по причине " .. args.text:sub(7) )
			player:Kick( "\nВы были бесшумно выгнаны по причине:\n" .. args.text:sub(7) )
			Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " has invisibly kicked by " .. sender:GetName() .. " Reason: " .. args.text:sub(7) } )
			return true
		elseif cmd_args[1] == "/ptphere" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			if isCreator( sender ) then
				if cmd_args[2] == "all*" then
					local sPos = sender:GetPosition()
					local sAngle = sender:GetAngle()
					local sName = sender:GetName()

					for p in Server:GetPlayers() do
						p:Teleport( sPos, sAngle )
						confirmationMessage( p, sName .. " телепортировал всех игроков к себе." )
					end
					confirmationMessage( sender, "Все игроки были телепортированы к вам." )
					Events:Fire( "ToDiscordConsole", { text = sName .. " warp all players to yourself." } )
					return true
				end
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			player:Teleport( sender:GetPosition(), sender:GetAngle() )
			confirmationMessage( player, sender:GetName() .. playerTele )
			confirmationMessage( sender, player:GetName() .. playerTele2 )
			return true
		end
	end

	if isCreator( sender ) or isGlAdmin( sender ) then
		if cmd_args[1] == "/remveh" then
			for v in Server:GetVehicles() do
				v:Remove()
			end

			confirmationMessage( sender, "Все транспортные средства на сервере были удалены." )
			return true
		elseif cmd_args[1] == "/ban" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			Chat:Broadcast( "[Сервер] ", Color.White, player:GetName() .. " был внесён в черный список сервера.", Color( 255, 0, 0 ) )
			Events:Fire( "ToDiscordConsole", { text = "[Admin] " .. player:GetName() .. " has been banned from the server by " .. sender:GetName() } )
			Server:AddBan(player:GetSteamId())
			player:Kick( "You have been banned from the server." )
			return true
		elseif cmd_args[1] == "/addmoney" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local amount = cmd_args[3]
			if tonumber( amount ) == nil then
				deniedMessage( sender, invalidNum )
				return false
			end

			if cmd_args[2] == "all*" then
				for p in Server:GetPlayers() do
					p:SetMoney( p:GetMoney() + tonumber( amount ) )
				end
				Chat:Broadcast( "[Сервер] ", Color.White, "У всех теперь есть дополнительные $" .. tonumber( amount ) .. "! Любезно предоставлено " .. sender:GetName() .. ".", Color( 0, 255, 45 ) )
				Events:Fire( "ToDiscordConsole", { text = "[Admin] " .. "У всех теперь есть дополнительные $" .. tonumber( amount ) .. "! Любезно предоставлено " .. sender:GetName() .. "." } )
				return true
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			player:SetMoney( player:GetMoney() + tonumber( cmd_args[3] ) )
			confirmationMessage( sender, "Вы добавили $" .. cmd_args[3] .. " игроку " .. player:GetName() .. "!" )
			confirmationMessage( player, sender:GetName() .. " добавил вам $" .. cmd_args[3] .. "!" )
			return true
		elseif cmd_args[1] == "/setgm" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			confirmationMessage( sender, "Установлен режим: " .. cmd_args[3] .. " для " .. player:GetName() )
			player:SetNetworkValue( "GameMode", cmd_args[3] )
			return true
		elseif cmd_args[1] == "/setlang" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			if cmd_args[3]:len() > 5 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			confirmationMessage( sender, "Установлен язык: " .. cmd_args[3] .. " для " .. player:GetName() )
			player:SetNetworkValue( "Lang", cmd_args[3] )
			return true
		elseif cmd_args[1] == "/setlevel" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			if not tonumber( cmd_args[3] ) then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			confirmationMessage( sender, "Установлен уровень: " .. cmd_args[3] .. " для " .. player:GetName() )
			player:SetNetworkValue( "PlayerLevel", tonumber( cmd_args[3] ) )
			return true
		end
	end

	if isCreator( sender ) or isGlAdmin( sender ) or isAdmin( sender ) or isOrganizer( sender ) then
		if cmd_args[1] == "/notice" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local stringname = args.text:sub( 9, 256 )

			Network:Broadcast( "Notice", { text = stringname } )

			local console_text = sender:GetName() .. " made notice: " .. stringname
			print( console_text )
			Events:Fire( "ToDiscordConsole", { text = "[Admin] " .. console_text } )
		elseif cmd_args[1] == "/joinnotice" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local stringname = args.text:sub( 13, 256 )

			Events:Fire( "SetJoinNotice", stringname )

			confirmationMessage( sender, "Сообщение при входе успешно задано: " .. stringname )

			local console_text = sender:GetName() .. " made join notice: " .. stringname
			print( console_text )
			Events:Fire( "ToDiscordConsole", { text = "[Admin] " .. console_text } )
		elseif cmd_args[1] == "/clearjoinnotice" then
			Events:Fire( "SetJoinNotice", nil )

			confirmationMessage( sender, "Сообщение при входе успешно удалено." )

			local console_text = sender:GetName() .. " cleared join notice"
			print( console_text )
			Events:Fire( "ToDiscordConsole", { text = "[Admin] " .. console_text } )
		elseif cmd_args[1] == "/addcustomtp" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			if cmd_args[2] == "" then
				deniedMessage( sender, invalidArgs )
				return false
			end

			Events:Fire( "AddCustomTeleport", { name = cmd_args[2], pos = sender:GetPosition() } )
			confirmationMessage( sender, "Точка для телепортации /tp " .. cmd_args[2] .. " успешно создана." )

			local console_text = sender:GetName() .. " added custom teleport: /tp " .. cmd_args[2]
			print( console_text )
			Events:Fire( "ToDiscordConsole", { text = "[Admin] " .. console_text } )
		elseif cmd_args[1] == "/clearallcustomtp" then
			Events:Fire( "ClearCustomTeleports" )
			confirmationMessage( sender, "Созданные точки для телепортации очищены." )

			local console_text = sender:GetName() .. " cleared all custom teleports"
			print( console_text )
			Events:Fire( "ToDiscordConsole", { text = "[Admin] " .. console_text } )
		elseif cmd_args[1] == "/boton" then
			if not self.boton then
				Chat:Send( sender, "[Админ-система] ", Color.White, "НА РАБОТУ! ГОВНО ЧИСТИТЬ!", Color.Brown )
				Events:Fire( "ToDiscordConsole", { text = "[Admin] Bot Enabled!" } )
				print( sender, " - Bot Enabled" )
				Events:Fire( "EnableWF" )
				self.boton = true
			else
				Chat:Send( sender, "[Админ-система] ", Color.White, "ЧИСТИ-ЧИСТИ", Color.Brown )
			end
		elseif cmd_args[1] == "/botoff" then
			if self.boton then
				Chat:Send( sender, "[Админ-система] ", Color.White, "Нихуя не можешь сделать, пошол нахой отсюда!", Color.Brown )
				print( sender, " - Bot Disabled" )
				Events:Fire( "ToDiscordConsole", { text = "[Admin] Bot Disabled!" } )
				Events:Fire( "DisableWF" )
				self.boton = false
			end
		end
	end

	if cmd_args[1] == "/pos" or cmd_args[1] == "/coords" then
		local pos = sender:GetPosition()
		Chat:Send( sender, sender:GetValue( "Lang" ) == "EN" and "Your coordinates: " or "Ваши координаты: ", Color.White, tostring( pos.x .. ", " .. pos.y .. ", " .. pos.z ), Color.DarkGray )
		print( "Coordinates: (" .. tostring( pos.x .. ", " .. pos.y .. ", " .. pos.z ) .. ")" )
	elseif cmd_args[1] == "/angle" then
		Chat:Send( sender, sender:GetValue( "Lang" ) == "EN" and "Your angle: " or "Ваш угол: ", Color.White, tostring( sender:GetAngle() ), Color.DarkGray )
		print( "Angle: (" .. tostring( sender:GetAngle() ) .. ")" )
	elseif cmd_args[1] == "/mass" then
		if sender:GetWorld() ~= DefaultWorld then
			deniedMessage( sender, warning )
			return
		end

		if #cmd_args < 2 then
			deniedMessage( sender, invalidArgs )
			return false
		end

		if not tonumber( cmd_args[2] ) then
			deniedMessage( sender, invalidArgs )
			return false
		end

		local vehicle = sender:GetVehicle()

		if not vehicle then
			deniedMessage( sender, inVehicle )
			return false
		end

		if cmd_args[2] == "0" or cmd_args[2] == "-0" or cmd_args[2] == "+0" then
			deniedMessage( sender, invalidArgs )
			return false
		end

		if vehicle:GetDriver() and sender:GetState() == PlayerState.InVehicle then
			local limit1 = 1000000000000000000000000000000000000
			local limit2 = -1000000000000000000000000000000000000
			local value = tonumber( cmd_args[2] )

			if value >= 0 then value = math.min( value, limit1 ) else value = math.max( value, limit2 ) end

			vehicle:SetMass( value )

			confirmationMessage( sender, "Масса транспорта установлена ​​на " .. value )
		else
			deniedMessage( sender, inVehicle )
		end
		return true
	elseif cmd_args[1] == "/down" then
		if sender:GetValue( "PVPMode" ) then
			deniedMessage( sender, "Вы не можете использовать это во время боя!" )
			return
		end
		if sender:GetWorld() ~= DefaultWorld then
			deniedMessage( sender, warning )
			return
		end

		local vehicle = sender:GetVehicle()

		if not vehicle or vehicle and vehicle:GetDriver() == sender then
			Network:Send( sender, "BoomToSky", { boomvelocity = Vector3( 0, -100, 0 ) } )
		else
			deniedMessage( sender, inVehicle )
		end
	end

	if not sender:GetValue( "Mute" ) then
		if string.sub( args.text, 1, 1 ) ~= "/" then
			if sender:GetValue( "NT_TagName" ) then
				if sender:GetValue( "ChatMode" ) == 3 then
					Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), "[" .. sender:GetValue("NT_TagName") .. "] ", sender:GetValue( "NT_TagColor" ), sender:GetName(), sender:GetColor(), ": " .. args.text, Color.White )

					local console_text = "[" .. tostring( sender:GetValue( "Country" ) ) .. "] " .. "[" .. sender:GetValue( "NT_TagName")  .. "] " .. sender:GetName() .. ": ".. args.text
					print( "(" .. sender:GetId() .. ") " .. console_text )
					Events:Fire( "ToDiscordConsole", { text = console_text } )
				end
				return false
			else
				if sender:GetValue( "ChatMode" ) == 3 then
					if isVip( sender ) then
						Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), vipPrefix, Color( 255, 100, 232 ), sender:GetName(), sender:GetColor(), ": " .. args.text, Color.White )

						local console_text = "[" .. tostring( sender:GetValue( "Country" ) ) .. "] " .. vipPrefix .. sender:GetName() .. ": " .. args.text
						print( "(" .. sender:GetId() .. ") " .. console_text )
						Events:Fire( "ToDiscordConsole", { text = console_text } )
					elseif isParther( sender ) then
						Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 255 ), partherPrefix, Color( 135, 206, 250 ), sender:GetName(), sender:GetColor(), ": " .. args.text, Color.White )

						local console_text = "[" .. tostring( sender:GetValue( "Country" ) ) .. "] " .. partherPrefix .. sender:GetName() .. ": " .. args.text
						print( "(" .. sender:GetId() .. ") " .. console_text )
						Events:Fire( "ToDiscordConsole", { text = console_text } )
					elseif isOrganizer( sender ) then
						Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 255 ), organizerPrefix, Color( 255, 190, 125 ), sender:GetName(), sender:GetColor(), ": " .. args.text, Color.White )

						local console_text = "[" .. tostring( sender:GetValue( "Country" ) ) .. "] " .. organizerPrefix .. sender:GetName() .. ": " .. args.text
						print( "(" .. sender:GetId() .. ") " .. console_text )
						Events:Fire( "ToDiscordConsole", { text = console_text } )
					elseif isModerD( sender ) then
						Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), moderDPrefix, Color( 255, 148, 48 ), sender:GetName(), sender:GetColor(), ": " .. args.text, Color.White )

						local console_text = "[" .. tostring( sender:GetValue( "Country" ) ) .. "] " .. moderDPrefix .. sender:GetName() .. ": " .. args.text
						print( "(" .. sender:GetId() .. ") " .. console_text )
						Events:Fire( "ToDiscordConsole", { text = console_text } )
					elseif isAdminD( sender ) then
						Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), adminDPrefix, Color( 255, 48, 48 ), sender:GetName(), sender:GetColor(), ": " .. args.text, Color.White )

						local console_text = "[" .. tostring( sender:GetValue( "Country" ) ) .. "] " .. adminDPrefix .. sender:GetName() .. ": " .. args.text
						print( "(" .. sender:GetId() .. ") " .. console_text )
						Events:Fire( "ToDiscordConsole", { text = console_text } )
					elseif isAdmin( sender ) then
						Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), adminPrefix, Color( 255, 48, 48 ), sender:GetName(), sender:GetColor(), ": " .. args.text, Color.White )

						local console_text = "[" .. tostring( sender:GetValue( "Country" ) ) .. "] " .. adminPrefix .. sender:GetName() .. ": " .. args.text
						print( "(" .. sender:GetId() .. ") " .. console_text )
						Events:Fire( "ToDiscordConsole", { text = console_text } )
					elseif isGlAdmin( sender ) then
						Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), gladminPrefix, Color( 255, 48, 48 ), sender:GetName(), sender:GetColor(), ": " .. args.text, Color.White )

						local console_text = "[" .. tostring( sender:GetValue( "Country" ) ) .. "] " .. gladminPrefix ..  sender:GetName() .. ": " .. args.text
						print( "(" .. sender:GetId() .. ") " .. console_text )
						Events:Fire( "ToDiscordConsole", { text = console_text } )
					elseif isCreator( sender ) then
						Chat:Broadcast( lennyPrefix, Color( 255, 255, 50 ), creatorPrefix, Color( 63, 153, 255 ), sender:GetName(), sender:GetColor(), ": " .. args.text, Color.White )

						local console_text = "[" .. tostring( sender:GetValue( "Country" ) ) .. "] " .. creatorPrefix .. sender:GetName() .. ": ".. args.text
						print( "(" .. sender:GetId() .. ") " .. console_text )
						Events:Fire( "ToDiscordConsole", { text = console_text } )
					end
					return false
				end
			end
		end
	end
end

function Admin:ModuleUnload()
	if self.boton then
		print( "Server - Bot Disabled" )
		Events:Fire( "DisableWF" )
	end

	for p in Server:GetPlayers() do
		if p:GetValue( "Tag" ) ~= nil then
			p:SetNetworkValue( "Tag", nil )
		end
	end
end

admin = Admin()
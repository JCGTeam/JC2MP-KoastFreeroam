class 'Admin'

local vipPrefix = "[VIP] "
local youtuberPrefix = "[YouTube Деятель] "
local moderDPrefix = "[Модератор $] "
local adminDPrefix = "[Админ $] "
local adminPrefix = "[Админ] "
local gladminPrefix = "[Гл. Админ] "
local zvezdaPrefix = "★ "
local creatorPrefix = "[Пошлый Создатель] "
local lennyPrefix = "( ͡° ͜ʖ ͡°) "

local vips = {}
local youtubers = {}
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

function Admin:loadYouTubers(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "YouTubers were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			youtubers[i] = line
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
	Console:Subscribe( "addyoutuber", self, self.AddYouTuber )
	Console:Subscribe( "addmoderD", self, self.AddModerD )
	Console:Subscribe( "addadminD", self, self.AddAdminD )
	Console:Subscribe( "addadmin", self, self.AddAdmin )
	Console:Subscribe( "addgladmin", self, self.AddGlAdmin )
	Console:Subscribe( "addmoney", self, self.AddMoney )

	self:loadVips( "server/vips.txt" )
	self:loadYouTubers( "server/youtubers.txt" )
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
	if args.text == "vips" or args.text == "youtubers" or args.text == "modersD" or args.text == "adminsD" or args.text == "admins" 
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
	local text = args.text

	file:write("\n" .. text)
	file:close()

	self:loadVips( "server/vips.txt" )
	self:ModuleLoad()

	print( "Vip added: " .. args.text )
	Events:Fire( "ToDiscordConsole", { text = "Vip added: " .. args.text })
end

function Admin:AddYouTuber( args )
	local file = io.open("server/youtubers.txt", "a")
	local text = args.text

	file:write("\n" .. text)
	file:close()

	self:loadYouTubers( "server/youtubers.txt" )
	self:ModuleLoad()

	print( "YouTuber added: " .. args.text )
	Events:Fire( "ToDiscordConsole", { text = "YouTuber added: " .. args.text })
end

function Admin:AddModerD( args )
	local file = io.open("server/modersD.txt", "a")
	local text = args.text

	file:write("\n" .. text)
	file:close()

	self:loadModersD( "server/modersD.txt" )
	self:ModuleLoad()

	print( "ModerD added: " .. args.text )
	Events:Fire( "ToDiscordConsole", { text = "ModerD added: " .. args.text })
end

function Admin:AddAdminD( args )
	local file = io.open("server/adminsD.txt", "a")
	local text = args.text

	file:write("\n" .. text)
	file:close()

	self:loadAdminsD( "server/adminsD.txt" )
	self:ModuleLoad()

	print( "AdminD added: " .. args.text )
	Events:Fire( "ToDiscordConsole", { text = "AdminD added: " .. args.text })
end

function Admin:AddAdmin( args )
	local file = io.open("server/admins.txt", "a")
	local text = args.text

	file:write("\n" .. text)
	file:close()

	self:loadAdmins( "server/admins.txt" )
	self:ModuleLoad()

	print( "Admin added: " .. args.text )
	Events:Fire( "ToDiscordConsole", { text = "Admin added: " .. args.text })
end

function Admin:AddGlAdmin( args )
	local file = io.open("server/gladmins.txt", "a")
	local text = args.text

	file:write("\n" .. text)
	file:close()

	self:loadGlAdmins( "server/gladmins.txt" )
	self:ModuleLoad()

	print( "Gl Admin added: " .. args.text )
	Events:Fire( "ToDiscordConsole", { text = "Gl Admin added: " .. args.text })
end

function Admin:AddMoney( args )
	local text = args.text:split( " " )

	if #text < 2 then
		print( "Use: addmoney <player> <money>" )
		Events:Fire( "ToDiscordConsole", { text = "Use: addmoney <player> <money>" })
		return false
	end

	local player = Player.Match(text[1])[1]

	if not IsValid(player) then
		print( (text[1]) .. " not found." )
		Events:Fire( "ToDiscordConsole", { text = (text[1]) .. " not found." })
		return false
	elseif text[3] == "" then
		print( "Use: addmoney <player> <money>" )
		Events:Fire( "ToDiscordConsole", { text = "Use: addmoney <player> <money>" })
		return false
	elseif not tonumber(text[2]) then
		print( "Use: addmoney <player> <money>" )
		Events:Fire( "ToDiscordConsole", { text = "Use: addmoney <player> <money>" })
		return false
	end

	player:SetMoney( player:GetMoney() + (text[2]) )
	self:loadModersD( "server/modersD.txt" )
	self:ModuleLoad()

	print( "Added $" .. (text[2]) .. " for " .. (text[1]) )
	Events:Fire( "ToDiscordConsole", { text = "Added $" .. (text[2]) .. " for " .. (text[1]) })
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
						p:SetMoney(p:GetMoney() + paydayCash)
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
	local vipsstring = ""
	for i,line in ipairs(vips) do
		vipsstring = vipsstring .. line .. " "
	end

	if(string.match(vipsstring, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isYouTuber( player )
	local youtubersstring = ""
	for i,line in ipairs(youtubers) do
		youtubersstring = youtubersstring .. line .. " "
	end

	if(string.match(youtubersstring, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isModerD( player )
	local modersDstring = ""
	for i,line in ipairs(modersD) do
		modersDstring = modersDstring .. line .. " "
	end

	if(string.match(modersDstring, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isAdminD( player )
	local adminsDstring = ""
	for i,line in ipairs(adminsD) do
		adminsDstring = adminsDstring .. line .. " "
	end

	if(string.match(adminsDstring, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end
	
function isAdmin( player )
	local adminstring = ""
	for i,line in ipairs(admins) do
		adminstring = adminstring .. line .. " "
	end

	if(string.match(adminstring, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isGlAdmin( player )
	local gladminstring = ""
	for i,line in ipairs(gladmins) do
		gladminstring = gladminstring .. line .. " "
	end

	if(string.match(gladminstring, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isCreator( player )
	local creatorstring = ""
	for i,line in ipairs(creators) do
		creatorstring = creatorstring .. line .. " "
	end

	if(string.match(creatorstring, tostring(player:GetSteamId()))) then
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
		[isYouTuber] = "YouTuber",
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
		[isYouTuber] = "YouTuber",
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
	sender = args.player

	if args.player:GetValue("NT_TagName") then
		if args.player:GetValue("NT_TagName") == "Наблюдатель" then
			if (cmd_args[1]) == "/hidetag" then
				if args.player:GetValue( "TagHide" ) then
					Chat:Send( args.player, "[Сервер] ", Color.White, "Тэг над головой включён.", Color( 124, 242, 0 ) )
					args.player:SetNetworkValue( "TagHide", false )
				else
					Chat:Send( args.player, "[Сервер] ", Color.White, "Тэг над головой отключён.", Color( 124, 242, 0 ) )
					args.player:SetNetworkValue( "TagHide", true )
				end
			end
		end
	end

	if (isCreator(args.player)) or (isAdmin(args.player)) then
		if (cmd_args[1]) == "/sky" then
			if #cmd_args > 2 then
				local player = Player.Match(cmd_args[2])[1]
				if not IsValid(player) then
					deniedMessage( sender, nullPlayer )
					return false
				end

				Events:Fire( "BoomToSky", { player = player, sender = sender, type = 1 } )
				return true
			end
		end

		if (cmd_args[1]) == "/down" then
			if #cmd_args > 2 then
				local player = Player.Match(cmd_args[2])[1]
				if not IsValid(player) then
					deniedMessage( sender, nullPlayer )
					return false
				end

				Events:Fire( "BoomToSky", { player = player, sender = sender, type = 2 } )
				return true
			end
		end
	end

	if (isCreator(args.player)) or (isGlAdmin(args.player)) or (isAdmin(args.player)) or (isAdminD(args.player)) or (isModerD(args.player)) then
		if not args.player:GetValue("NT_TagName") then
			if (cmd_args[1]) == "/hidetag" then
				if args.player:GetValue( "TagHide" ) then
					Chat:Send( args.player, "[Сервер] ", Color.White, "Тэг над головой включён.", Color( 124, 242, 0 ) )
					args.player:SetNetworkValue( "TagHide", false )
				else
					Chat:Send( args.player, "[Сервер] ", Color.White, "Тэг над головой отключён.", Color( 124, 242, 0 ) )
					args.player:SetNetworkValue( "TagHide", true )
				end
			end
		end

		if (cmd_args[1]) == "/petyx" then
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

			Chat:Broadcast( "[Сервер] ", Color.White,player:GetName() .. " стал петухом на этом сервере!", Color( 255, 0, 200 ) )
			Chat:Send( args.player, "[Сервер] ", Color.White, "Вы сделали " .. player:GetName() .. " петухом!", Color( 124, 242, 0 ) )
			confirmationMessage( player, args.player:GetName() .. playerSetPetyx )

			player:SetValue( "Petux", 1 )

			return true
		end

		if (cmd_args[1]) == "/unpetyx" then
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
			Chat:Send( args.player, "[Сервер] ", Color.White, player:GetName() .. " больше не петух!", Color( 124, 242, 0 ) )
			confirmationMessage( player, args.player:GetName() .. playerUnpetyx )

			player:SetValue( "Petux", nil )
			return true
		end

		if (cmd_args[1]) == "/bb" then
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
		end

		if (cmd_args[1]) == "/hi" then
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
		end

		if (cmd_args[1]) == "/getmoney" then
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

	if (isCreator(args.player)) or (isGlAdmin(args.player)) or (isAdmin(args.player)) then
		if (cmd_args[1]) == "/debugrepair" then
			if not sender:GetVehicle() then
				deniedMessage( sender, inVehicle )
				return false
			end

			if sender:GetMoney() >= 0 then
				confirmationMessage( sender, "Отладочная починка" )

				veh = sender:GetVehicle()
				veh:SetColors( Color( 255, 62, 150 ), Color( 205, 41, 144 ) )
				veh:Respawn()
				sender:EnterVehicle( veh, VehicleSeat.Driver )
				return true
			end
		end

		if (cmd_args[1]) == "/skick" then
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
		end

		if (cmd_args[1]) == "/ptphere" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			if (isCreator(args.player)) then
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

			player:Teleport( args.player:GetPosition(), args.player:GetAngle() )
			confirmationMessage( player, args.player:GetName() .. playerTele )
			confirmationMessage( sender, player:GetName() .. playerTele2 )
			return true
		end

		if (cmd_args[1]) == "/boton" then
			if not self.boton then
				Chat:Send( args.player, "[Админ-система] ", Color.White, "НА РАБОТУ! ГОВНО ЧИСТИТЬ!", Color.Brown )
				Events:Fire( "ToDiscordConsole", { text = "[Admin] Bot Enabled!" } )
				print( args.player, " - Bot Enabled" )
				Events:Fire( "EnableWF" )
				self.boton = true
			else
				Chat:Send( args.player, "[Админ-система] ", Color.White, "ЧИСТИ-ЧИСТИ", Color.Brown )
			end
		end

		if (cmd_args[1]) == "/botoff" then
			if self.boton then
				Chat:Send( args.player, "[Админ-система] ", Color.White, "Нихуя не можешь сделать, пошол нахой отсюда!", Color.Brown )
				print( args.player, " - Bot Disabled" )
				Events:Fire( "ToDiscordConsole", { text = "[Admin] Bot Disabled!" } )
				Events:Fire( "DisableWF" )
				self.boton = false
			end
		end
	end

	if (isCreator(args.player)) or (isGlAdmin(args.player)) then
		if (cmd_args[1]) == "/clearchat" then
			for i = 0, 999 do
				Chat:Broadcast( "", Color.White )
			end

			Chat:Broadcast( "[Сервер] ", Color.White, "Чат очищен администратором " .. args.player:GetName() .. ".", Color.White )
			Events:Fire( "ToDiscordConsole", { text = "[Admin] Chat has been cleared by " .. args.player:GetName() .. "." } )
		end

		if (cmd_args[1]) == "/remveh" then
			for veh in Server:GetVehicles() do
				veh:Remove()
			end

			confirmationMessage( sender, "Все транспортные средства на сервере были удалены." )
			return true
		end

		if (cmd_args[1]) == "/ban" then
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
		end

		if (cmd_args[1]) == "/notice" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local stringname = args.text:sub(9, 256)

			Network:Broadcast( "Notice", { text = stringname } )
		end

		if (cmd_args[1]) == "/addmoney" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			amount = cmd_args[3]
			if(tonumber(amount) == nil) then
				deniedMessage( sender, invalidNum )
				return false
			end

			if cmd_args[2] == "all*" then
				for p in Server:GetPlayers() do
					p:SetMoney(p:GetMoney() + tonumber(cmd_args[3]))
				end
				Chat:Broadcast( "[Сервер] ", Color.White, "У всех теперь есть дополнительные $" .. tonumber(cmd_args[3]) .. "! Любезно предоставлено " .. args.player:GetName() .. ".", Color( 0, 255, 45 ) )
				Events:Fire( "ToDiscordConsole", { text = "[Admin] " .. "У всех теперь есть дополнительные $" .. tonumber(cmd_args[3]) .. "! Любезно предоставлено " .. args.player:GetName() .. "." } )
				return true
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			player:SetMoney(player:GetMoney() + tonumber(cmd_args[3]))
			confirmationMessage( sender, "Вы добавили $" .. cmd_args[3] .. " игроку " .. player:GetName() .. "!" )
			confirmationMessage( player, sender:GetName() .. " добавил вам $" .. cmd_args[3] .. "!" )
			return true
		end

		if (cmd_args[1]) == "/setgm" then
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
		end

		if (cmd_args[1]) == "/setlang" then
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
		end

		if (cmd_args[1]) == "/setlevel" then
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

	if (cmd_args[1]) == "/pos" or (cmd_args[1]) == "/coords" then
		local pos = args.player:GetPosition()
		Chat:Send( args.player, args.player:GetValue( "Lang" ) == "EN" and "Your coordinates: " or "Ваши координаты: ", Color.White, tostring( pos.x .. ", " .. pos.y .. ", " .. pos.z ), Color.DarkGray )
		print( "Coordinates: (" .. tostring( pos.x .. ", " .. pos.y .. ", " .. pos.z ) .. ")" )
	end

	if (cmd_args[1]) == "/angle" then
		Chat:Send( args.player, args.player:GetValue( "Lang" ) == "EN" and "Your angle: " or "Ваш угол: ", Color.White, tostring( args.player:GetAngle() ), Color.DarkGray )
		print( "Angle: (" .. tostring( args.player:GetAngle() ) .. ")" )
	end

	if (cmd_args[1]) == "/mass" then
		if args.player:GetWorld() ~= DefaultWorld then
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
	end

	if (cmd_args[1]) == "/down" then
		if args.player:GetValue( "PVPMode" ) then
			deniedMessage( sender, "Вы не можете использовать это во время боя!" )
			return
		end
		if args.player:GetWorld() ~= DefaultWorld then
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

	if not args.player:GetValue( "Mute" ) then
		local text = args.text
		if string.sub(text, 1, 1) ~= "/" then
			if args.player:GetValue("NT_TagName") then
				if args.player:GetValue( "ChatMode" ) == 3 then
					Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), "[" .. args.player:GetValue("NT_TagName") .. "] ", args.player:GetValue("NT_TagColor"), args.player:GetName(), args.player:GetColor(), ": " .. args.text, Color.White )

					local console_text = "[" .. tostring( args.player:GetValue( "Country" ) ) .. "] " .. "[" .. args.player:GetValue("NT_TagName") .. "] " .. args.player:GetName() .. ": ".. args.text
					print( "(" .. args.player:GetId() .. ") " .. console_text )
					Events:Fire( "ToDiscordConsole", { text = console_text } )
				end
				return false
			else
				if args.player:GetValue( "ChatMode" ) == 3 then
					local text = args.text
					if args.player:GetValue( "ChatMode" ) == 3 then
						if (isVip(args.player)) then
							Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), vipPrefix, Color( 255, 100, 232 ), args.player:GetName(), args.player:GetColor(), ": " .. text, Color.White )

							local console_text = "[" .. tostring( args.player:GetValue( "Country" ) ) .. "] " .. vipPrefix .. args.player:GetName() .. ": " .. args.text
							print( "(" .. args.player:GetId() .. ") " .. console_text )
							Events:Fire( "ToDiscordConsole", { text = console_text } )
						elseif (isYouTuber(args.player)) then
							Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), youtuberPrefix, Color( 255, 0, 50 ), args.player:GetName(), args.player:GetColor(), ": " .. text, Color.White )

							local console_text = "[" .. tostring( args.player:GetValue( "Country" ) ) .. "] " .. youtuberPrefix .. args.player:GetName() .. ": " .. args.text
							print( "(" .. args.player:GetId() .. ") " .. console_text )
							Events:Fire( "ToDiscordConsole", { text = console_text } )
						elseif (isModerD(args.player)) then
							Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), moderDPrefix, Color( 255, 148, 48 ), args.player:GetName(), args.player:GetColor(), ": " .. text, Color.White )

							local console_text = "[" .. tostring( args.player:GetValue( "Country" ) ) .. "] " .. moderDPrefix .. args.player:GetName() .. ": " .. args.text
							print( "(" .. args.player:GetId() .. ") " .. console_text )
							Events:Fire( "ToDiscordConsole", { text = console_text } )
						elseif (isAdminD(args.player)) then
							Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), adminDPrefix, Color( 255, 48, 48 ), args.player:GetName(), args.player:GetColor(), ": " .. text, Color.White )

							local console_text = "[" .. tostring( args.player:GetValue( "Country" ) ) .. "] " .. adminDPrefix .. args.player:GetName() .. ": " .. args.text
							print( "(" .. args.player:GetId() .. ") " .. console_text )
							Events:Fire( "ToDiscordConsole", { text = console_text } )
						elseif (isAdmin(args.player)) then
							Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), adminPrefix, Color( 255, 48, 48 ), args.player:GetName(), args.player:GetColor(), ": " .. text, Color.White )

							local console_text = "[" .. tostring( args.player:GetValue( "Country" ) ) .. "] " .. adminPrefix .. args.player:GetName() .. ": " .. args.text
							print( "(" .. args.player:GetId() .. ") " .. console_text )
							Events:Fire( "ToDiscordConsole", { text = console_text } )
						elseif (isGlAdmin(args.player)) then
							Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), gladminPrefix, Color( 255, 48, 48 ), args.player:GetName(), args.player:GetColor(), ": " .. text, Color.White )

							local console_text = "[" .. tostring( args.player:GetValue( "Country" ) ) .. "] " .. gladminPrefix ..  args.player:GetName() .. ": " .. args.text
							print( "(" .. args.player:GetId() .. ") " .. console_text )
							Events:Fire( "ToDiscordConsole", { text = console_text } )
						elseif (isCreator(args.player)) then
							Chat:Broadcast( lennyPrefix, Color( 255, 255, 50 ), creatorPrefix, Color( 63, 153, 255 ), args.player:GetName(), args.player:GetColor(), ": " .. args.text, Color.White )

							local console_text = "[" .. tostring( args.player:GetValue( "Country" ) ) .. "] " .. creatorPrefix .. args.player:GetName() .. ": ".. args.text
							print( "(" .. args.player:GetId() .. ") " .. console_text )
							Events:Fire( "ToDiscordConsole", { text = console_text } )
						end
						return false
					end
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
class "Admin"

local ChatTag = "[Сервер] "
local noonline = "Игрок не в сети."

local firstAdmin = "STEAM_0:0:90087002"
local msgColors =
	{
		[ "err" ] = Color ( 255, 0, 0 ),
		[ "info" ] = Color ( 0, 255, 0 ),
		[ "gray" ] = Color.DarkGray
	}

function Admin:__init()
	self.permissions =
		{
			"player.kick",
			"player.warn",
			"player.ban",
			"player.mute",
			"player.kill",
			"player.warp",
			"player.spectate",
			"player.setmodel",
			"player.sethealth",
			"player.setmoney",
			"player.giveweapon",
			"player.warpto",
			"player.freeze",
			"player.giveadmin",
			"player.takeadmin",
			"player.givemoney",
			"player.givevehicle",
			"player.repairvehicle",
			"player.destroyvehicle",
			"player.setvehiclecolour",
			"player.shout",
			"general.adminpanel",
			"general.tab_players",
			"general.tab_acl",
			"general.tab_bans",
			"general.tab_modules",
			"general.tab_server",
			"general.tab_adminchat",
			"general.settime",
			"general.settimestep",
			"general.setweather",
			"ban.add",
			"ban.remove",
			"module.load",
			"module.unload",
			"acl.creategroup",
			"acl.removegroup",
			"acl.modifypermission",
			"acl.addobject",
			"acl.removeobject",
			"adminchat.clearmessages"
		}
	self.weaponNames =
		{
			[ 2 ] = "Пистолет",
			[ 4 ] = "Револьвер",
			[ 5 ] = "СМГ",
			[ 6 ] = "Пилотный Дробовик",
			[ 11 ] = "Штурмовая Винтовка",
			[ 13 ] = "Дробовик",
			[ 14 ] = "Снайперская Винтовка",
			[ 16 ] = "Ракетная Установка",
			[ 17 ] = "Гранатомет",
			[ 28 ] = "Пулемет",
			[ 43 ] = "Пузырьковая Пушка",
			[ 66 ] = "СУПЕР Ракетная Установка",
			[ 100 ] = "(DLC) Штурмовая винтовка 'В яблочко",
			[ 101 ] = "(DLC) Воздушное силовое ружье",
			[ 102 ] = "(DLC) Кластерный бомбомет",
			[ 103 ] = "(DLC) Личное оружие Рико",
			[ 104 ] = "(DLC) Счетвернный гранатомет",
			[ 105 ] = "(DLC) Залповая ракетная установка",
			[ 31 ] = "ПВО",
			[ 116 ] = "Ракеты",
			[ 26 ] = "Миниган",
			[ 129 ] = "СУПЕР Пулемет",
			[ 32 ] = "Параша"
		}
	self.validModels =
		{
			[ 90 ] = true,
			[ 63 ] = true,
			[ 8 ] = true,
			[ 12 ] = true,
			[ 58 ] = true,
			[ 38 ] = true,
			[ 87 ] = true,
			[ 22 ] = true,
			[ 27 ] = true,
			[ 103 ] = true,
			[ 70 ] = true,
			[ 11 ] = true,
			[ 84 ] = true,
			[ 19 ] = true,
			[ 36 ] = true,
			[ 78 ] = true,
			[ 71 ] = true,
			[ 79 ] = true,
			[ 96 ] = true,
			[ 80 ] = true,
			[ 95 ] = true,
			[ 60 ] = true,
			[ 15 ] = true,
			[ 17 ] = true,
			[ 86 ] = true,
			[ 16 ] = true,
			[ 18 ] = true,
			[ 64 ] = true,
			[ 40 ] = true,
			[ 1 ] = true,
			[ 39 ] = true,
			[ 61 ] = true,
			[ 26 ] = true,
			[ 21 ] = true,
			[ 2 ] = true,
			[ 5 ] = true,
			[ 32 ] = true,
			[ 85 ] = true,
			[ 59 ] = true,
			[ 9 ] = true,
			[ 65 ] = true,
			[ 25 ] = true,
			[ 30 ] = true,
			[ 34 ] = true,
			[ 100 ] = true,
			[ 83 ] = true,
			[ 51 ] = true,
			[ 74 ] = true,
			[ 67 ] = true,
			[ 101 ] = true,
			[ 3 ] = true,
			[ 98 ] = true,
			[ 42 ] = true,
			[ 44 ] = true,
			[ 23 ] = true,
			[ 52 ] = true,
			[ 66 ] = true
		}
	self.serverInfo =
		{
			name = Config:GetValue( "Server", "Name" ),
			maxPlayers = Config:GetValue( "Server", "MaxPlayers" ),
			timeout = Config:GetValue( "Server", "Timeout" ),
			spawnPosition = Config:GetValue( "Player", "SpawnPosition" ),
			announce = Config:GetValue( "Server", "Announce" )
		}
	self.vehicles = {}
	self.canChat = {}
	self.moduleLog = {}

	json = require "JSON"

	-- Creates the first group "Admin" and adds the content of "firstAdmin" variable as member of it.
	local permissions = {}
	for _, perm in ipairs ( self.permissions ) do
		permissions [ perm ] = true
	end
	ACL:createGroup ( "Глава", permissions, false, "Глава", { 255, 0, 0 } )
	if ( firstAdmin and firstAdmin ~= "Your Steam ID Here" ) then
		ACL:groupAddObject ( "Глава", firstAdmin )
	end

	for group, data in pairs ( ACL:groupList( true ) ) do
		local perms = data.permissions
		for _, perm in ipairs ( self.permissions ) do
			if ( perms [ perm ] == nil ) then
				ACL:updateGroupPermission( group, perm, false )
			end
		end
	end

	-- Adds the players with the permission to use the admin chat to a table.
	for player in Server:GetPlayers() do
		local steamID = tostring ( player:GetSteamId() )
		if ACL:hasObjectPermissionTo ( steamID, "general.tab_adminchat" ) then
			self.canChat [ steamID ] = player
		end
	end

	-- Network events
	Network:Subscribe( "admin.requestPermissions", self, self.requestPermissions )
	Network:Subscribe( "admin.requestInformation", self, self.requestInformation )
	Network:Subscribe( "admin.getServerInfo", self, self.getServerInfo )
	Network:Subscribe( "admin.isAdmin", self, self.checkIfIsAdmin )
	Network:Subscribe( "admin.updateACL", self, self.checkIfIsACL )
	Network:Subscribe( "admin.executeAction", self, self.executeAction )
	Network:Subscribe( "admin.getBans", self, self.getBans )
	Network:Subscribe( "admin.getModules", self, self.getModules )
	Network:Subscribe( "admin.getChat", self, self.getChat )
	Network:Subscribe( "admin.savemessages", self, self.saveMessages )
	Network:Subscribe( "admin.getSpectatorVictim", self, self.getSpectatorVictim )
	-- Normal events
	Events:Subscribe( "ModuleUnload", self, self.onModuleUnload )
	Events:Subscribe( "PlayerJoin", self, self.onPlayerJoin )
	Events:Subscribe( "PlayerQuit", self, self.onPlayerQuit )
end

function Admin:saveMessages( args )
	self.savetext = args.gettext
end

function Admin:onModuleUnload()
	for k, v in pairs( self.vehicles ) do
		if IsValid(v) then
			v:Remove()
		end
	end
end

function Admin:onPlayerJoin( args )
	local steamID = tostring ( args.player:GetSteamId() )
	if ACL:hasObjectPermissionTo ( steamID, "general.tab_adminchat" ) then
		self.canChat [ steamID ] = args.player
	end
end

function Admin:onPlayerQuit( args )
	self.canChat [ tostring ( args.player:GetSteamId() ) ] = nil

	local pId = args.player:GetId()
	if self.vehicles [ pId ] and IsValid( self.vehicles [ pId ] ) then
		self.vehicles [ pId ]:Remove()
		self.vehicles [ pId ] = nil
	end
end

function Admin:requestPermissions( _, player )
	local perms = {}
	for _, perm in ipairs ( self.permissions ) do
		perms [ perm ] = ACL:hasObjectPermissionTo( tostring ( player:GetSteamId() ), perm )
	end
	Network:Send( player, "admin.returnPermissions", { perms, self.permissions } )
end

function Admin:checkIfIsAdmin ( _, player )
	if IsValid ( player, false ) then
		if ACL:hasObjectPermissionTo( tostring ( player:GetSteamId() ), "general.adminpanel" ) then
			Network:Send( player, "admin.showPanel", { bans = banSystem:getBans(), modules = { Server:GetModules(), self.moduleLog } } )
		end
	end
end

function Admin:checkIfIsACL ( _, player )
	if IsValid ( player, false ) then
		if ACL:hasObjectPermissionTo( tostring ( player:GetSteamId() ), "general.adminpanel" ) then
			Network:Send( player, "admin.updateACL", { acl = ACL:groupList() } )
		end
	end
end

function Admin:getServerInfo ( _, player )
	if IsValid ( player, false ) then
		self.serverInfo.time = os.time()
		self.serverInfo.serverTime = os.date ( "%X" )
		self.serverInfo.weatherSeverity = DefaultWorld:GetWeatherSeverity()
		self.serverInfo.timeStep = DefaultWorld:GetTimeStep()
		Network:Send( player, "admin.displayServerInfo", self.serverInfo )
	end
end

function Admin:requestInformation ( player, admin )
	if IsValid ( player, false ) then
		local x, y, z = table.unpack ( tostring ( player:GetPosition() ):split ( "," ) )
		local ax, ay, az = table.unpack ( tostring ( player:GetAngle() ):split ( "," ) )
		local weapon = player:GetEquippedWeapon()
		local vehicle = player:GetVehicle()
		local steamID = tostring ( player:GetSteamId() )
		local groups = ACL:getObjectGroups ( steamID )
		if ( type ( groups ) ~= "table" ) then
			groups = { "None" }
		end
		local data =
			{
				name = player:GetName(),
				ip = player:GetIP() .. ( player:GetValue( "Country" ) and " (" .. player:GetValue( "Country" ) .. ")" or "" ),
				steamID = steamID,
				ping = player:GetPing(),
				health = math.floor ( ( player:GetHealth ( ) * 100 ) ) .."%",
				money = convertNumber "$" .. ( player:GetMoney() ),
				position = math.round ( x, 3 ) ..", ".. math.round ( y, 3 ) ..", ".. math.round ( z, 3 ),
				angle = math.round ( ax, 3 ) ..", ".. math.round ( ay, 3 ) ..", ".. math.round ( az, 3 ),
				vehicle = ( player:InVehicle() and vehicle:GetName ( ) .." ( ID: ".. vehicle:GetModelId ( ) .." ) " or "Пешком" ),
				vehicleHealth = ( player:InVehicle() and math.floor ( player:GetVehicle():GetHealth() * 100 ) or 0 ) .."%",
				model = player:GetModelId(),
				weapon = ( self.weaponNames [ weapon.id ] or "Неизвестно" ) .. " ( ID: ".. weapon.id .." )",
				weaponAmmo = ( weapon.ammo_clip + weapon.ammo_reserve ),
				world = player:GetWorld():GetId(),
				groups = table.concat ( groups, ", " ),
				muted = mute:isPlayerMuted ( player ),
				frozen = isPlayerFrozen ( player ),
				isAdmin = ACL:isObjectInGroup ( steamID, "Глава" )
			}
		Network:Send( admin, "admin.displayInformation", data )
	end
end

function Admin:executeAction ( args, player )
	if IsValid ( player, false ) then
		if ACL:hasObjectPermissionTo ( tostring ( player:GetSteamId() ), args [ 1 ] ) then
			if ( args [ 1 ] == "player.ban" ) then
				if IsValid ( args [ 2 ], false ) then
					local banArgs =
					{
						steamID = tostring ( args [ 2 ]:GetSteamId() ),
						name = args [ 2 ]:GetName(),
						reason = ( args [ 3 ] or "Не определена причина" ),
						duration = tonumber ( args [ 4 ] ) or 1,
						responsible = player:GetName(),
						responsibleSteamID = tostring ( player:GetSteamId() )
					}
					if ( not banSystem:addBan ( banArgs ) ) then
						player:Message ( "Не удалось добавить бан.", "err" )
					end
				else
					player:Message ( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.kick" ) then
				if IsValid ( args [ 2 ], false ) then
					local reason = tostring ( args [ 3 ] or "No reason defined" )
					Chat:Broadcast( ChatTag, Color.White, args [ 2 ]:GetName() .." был кикнут ".. player:GetName() .." ( ".. reason .." )", Color ( 255, 0, 0 ) )
					print( args [ 2 ]:GetName() .." was kicked ".. player:GetName() .. " ( ".. reason .." )" )
					Events:Fire( "ToDiscordConsole", { text = args [ 2 ]:GetName() .. " was kicked ".. player:GetName() .." ( ".. reason .." )" } )
--					for _, thePlayer in pairs ( self.canChat ) do
--						Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." кикнул " .. args [ 2 ]:GetName() .. " | Причина: " .. reason } )
--					end
					args [ 2 ]:Kick ( reason )
				else
					player:Message ( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.warn" ) then
				if IsValid ( args [ 2 ], false ) then
					local reason = tostring ( args [ 3 ] or "No reason defined" )
					Chat:Broadcast( ChatTag, Color.White, args [ 2 ]:GetName() .." получил предупреждение! ( ".. reason .." )", Color ( 255, 0, 0 ) )
					print( args [ 2 ]:GetName() .." has been warned by ".. player:GetName() .. " ( ".. reason .." )" )
					Events:Fire( "ToDiscordConsole", { text = args [ 2 ]:GetName() .. " has been warned by ".. player:GetName() .." ( ".. reason .." )" } )
--					for _, thePlayer in pairs ( self.canChat ) do
--						Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." выдал предупреждение " .. args [ 2 ]:GetName() .. " | Причина: " .. reason } )
--					end
				else
					player:Message ( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.mute" ) then
				if IsValid ( args [ 2 ], false ) then
					if mute:isPlayerMuted ( args [ 2 ] ) then
						if mute:setPlayerMuted ( { steamID = tostring ( args [ 2 ]:GetSteamId() ), player = args [ 2 ] }, false ) then
							Chat:Broadcast( ChatTag, Color.White, args [ 2 ]:GetName() .." научился разговаривать благодаря ".. player:GetName(), Color ( 0, 255, 0 ) )
							print( args [ 2 ]:GetName() .. " was unmuted by " .. player:GetName() )
							Events:Fire( "ToDiscordConsole", { text = args [ 2 ]:GetName() .. " was unmuted by " .. player:GetName() } )
--							for _, thePlayer in pairs ( self.canChat ) do
--								Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." убрал мут " .. args [ 2 ]:GetName() } )
--							end
							self:requestInformation ( args [ 2 ], player )
						else
							player:Message ( "Невозможно открыть рот игрока!", "err" )
						end
					else
						local muteArgs =
						{
							player = args [ 2 ],
							steamID = tostring ( args [ 2 ]:GetSteamId() ),
							name = args [ 2 ]:GetName ( ),
							reason = ( args [ 3 ] or "Не определена причина" ),
							duration = tonumber ( args [ 4 ] ) or 1,
							responsible = player:GetName ( ),
							responsibleSteamID = tostring ( player:GetSteamId ( ) )
						}
						if mute:setPlayerMuted ( muteArgs, true ) then
							Chat:Broadcast( ChatTag, Color.White, args [ 2 ]:GetName() .." получил бан чата от ".. player:GetName() .." на ".. tostring ( muteArgs.duration / 60 ) .." минут ( ".. tostring ( muteArgs.reason ) .." )", Color ( 255, 0, 0 ) )
--							for _, thePlayer in pairs ( self.canChat ) do
--								Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." выдал мут " .. args [ 2 ]:GetName() .. " | Причина: " .. tostring ( muteArgs.reason ) } )
--							end
							print( args [ 2 ]:GetName() .. " was muted by " .. player:GetName() .. " for ".. tostring ( muteArgs.duration / 60 ) .." minutes ( ".. tostring ( muteArgs.reason ) .." )" )
							Events:Fire( "ToDiscordConsole", { text = args [ 2 ]:GetName() .. " was muted by " .. player:GetName() .. " for ".. tostring ( muteArgs.duration / 60 ) .." minutes ( ".. tostring ( muteArgs.reason ) .." )" } )
							self:requestInformation ( args [ 2 ], player )
						else
							player:Message( "Невозможно дать кляп игроку!", "err" )
						end
					end
				else
					player:Message ( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.freeze" ) then
				if IsValid ( args [ 2 ], false ) then
					if isPlayerFrozen ( args [ 2 ] ) then
						setPlayerFrozen ( args [ 2 ], false )
						player:Message( "Вы отморозили ".. args [ 2 ]:GetName(), "info" )
						args [ 2 ]:Message( "Вы были отморожены ".. player:GetName(), "info" )
--						for _, thePlayer in pairs ( self.canChat ) do
--							Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." отморозил " .. tostring ( args [ 2 ] ) } )
--						end
						print( player:GetName() .. " unfreeze " .. args [ 2 ]:GetName() )
						Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " unfreeze ".. args [ 2 ]:GetName() } )
					else
						setPlayerFrozen ( args [ 2 ], true )
						player:Message( "Вы заморозили ".. args [ 2 ]:GetName(), "err" )
						args [ 2 ]:Message( "Вы были заморожены ".. player:GetName(), "err" )
--						for _, thePlayer in pairs ( self.canChat ) do
--							Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." заморозили " .. tostring ( args [ 2 ] ) } )
--						end
						print( player:GetName() .. " freeze ".. args [ 2 ]:GetName() )
						Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " freeze ".. args [ 2 ]:GetName() } )
					end
					self:requestInformation ( args [ 2 ], player )
				else
					player:Message ( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.kill" ) then
				if IsValid ( args [ 2 ], false ) then
					args [ 2 ]:SetHealth ( 0 )
					player:Message( "Вы убили ".. args [ 2 ]:GetName(), "err" )
					args [ 2 ]:Message( "Вы были убиты ".. player:GetName(), "err" )
--					for _, thePlayer in pairs ( self.canChat ) do
--						Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." убил " .. args [ 2 ]:GetName() } )
--					end
					print( player:GetName() .. " killed ".. args [ 2 ]:GetName() )
					Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " killed ".. args [ 2 ]:GetName() } )
				else
					player:Message ( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.sethealth" ) then
				if IsValid ( args [ 2 ], false ) then
					local value = ( tonumber ( args [ 3 ] ) or 100 )
					args [ 2 ]:SetHealth ( value / 100 )
					player:Message( "Вы установили ".. args [ 2 ]:GetName ( ) .." здоровье на ".. tostring ( value ) .."%", "info" )
					args [ 2 ]:Message( player:GetName() .." поставил ваше здоровье на ".. tostring ( value ) .."%", "info" )
--					for _, thePlayer in pairs ( self.canChat ) do
--						Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." установил здоровье на " .. tostring ( value ) .. " для " .. args [ 2 ]:GetName() } )
--					end
					print( player:GetName() .. " set health " .. args [ 2 ]:GetName() .. " by " .. tostring ( value ) .. "%" )
					Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " set health ".. args [ 2 ]:GetName() .. " by " .. tostring ( value ) .."%" } )
				else
					player:Message ( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.setmodel" ) then
				if IsValid ( args [ 2 ], false ) then
					if ( self.validModels [ args [ 3 ] ] ) then
						args [ 2 ]:SetModelId ( args [ 3 ] )
						player:Message( "Вы установили ".. args [ 2 ]:GetName() .." персонажа на ".. tostring ( args [ 3 ] ), "info" )
						args [ 2 ]:Message( player:GetName() .." установил вам персонажа на ".. tostring ( args [ 3 ] ), "info" )
--						for _, thePlayer in pairs ( self.canChat ) do
--							Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." установил персонажа на " .. tostring ( args [ 3 ] ) .. " для " .. args [ 2 ]:GetName() } )
--						end
						print( player:GetName() .. " set model ".. args [ 2 ]:GetName() .. " by " .. tostring ( args [ 3 ] ) )
						Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " set model ".. args [ 2 ]:GetName() .. " by " .. tostring ( args [ 3 ] ) } )
					else
						player:Message ( "Неверный ID модели.", "err" )
					end
				else
					player:Message ( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.setmoney" ) then
				if IsValid ( args [ 2 ], false ) then
					if tonumber ( args [ 3 ] ) then
						args [ 2 ]:SetMoney ( tonumber ( args [ 3 ] ) )
						player:Message( "Вы установили баланс ".. args [ 2 ]:GetName() .." на $".. tostring ( convertNumber ( args [ 3 ] ) ), "info" )
						args [ 2 ]:Message( player:GetName() .." установил ваш баланс на $".. tostring ( convertNumber ( args [ 3 ] ) ), "info" )
--						for _, thePlayer in pairs ( self.canChat ) do
--							Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." установил опыт на " .. tostring ( convertNumber ( args [ 3 ] ) ) .. " для " .. args [ 2 ]:GetName() } )
--						end
						print( player:GetName() .. " set money ".. args [ 2 ]:GetName() .. " by $" .. tostring ( convertNumber ( args [ 3 ] ) ) )
						Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " set money ".. args [ 2 ]:GetName() .. " by $" .. tostring ( convertNumber ( args [ 3 ] ) ) } )
					else
						player:Message ( "Неверное значение.", "err" )
					end
				else
					player:Message ( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.givemoney" ) then
				if IsValid ( args [ 2 ], false ) then
					if tonumber ( args [ 3 ] ) then
						args [ 2 ]:SetMoney ( tonumber ( args [ 3 ] ) + args [ 2 ]:GetMoney ( ) )
						player:Message( "Вы дали ".. args [ 2 ]:GetName ( ) .. " $" .. tostring ( convertNumber ( args [ 3 ] ) ), "info" )
						args [ 2 ]:Message( player:GetName ( ) .." дал вам $".. tostring ( convertNumber ( args [ 3 ] ) ), "info" )
--						for _, thePlayer in pairs ( self.canChat ) do
--							Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." добавил " .. tostring ( convertNumber ( args [ 3 ] ) ) .. " ОП для " .. args [ 2 ]:GetName() } )
--						end
						print( player:GetName() .. " give money ".. args [ 2 ]:GetName() .. " by $" .. tostring ( convertNumber ( args [ 3 ] ) ) )
						Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " give money ".. args [ 2 ]:GetName() .. " by $" .. tostring ( convertNumber ( args [ 3 ] ) ) } )
					else
						player:Message ( "Неверное значение.", "err" )
					end
				else
					player:Message ( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.warp" ) then
				if IsValid ( args [ 2 ], false ) then
					if player:GetWorld() ~= args [ 2 ]:GetWorld() then
						player:Message ( "Игрок в другом мире!", "err" )
						return
					end
					local playerPos = args [ 2 ]:GetPosition()
--					player:SetWorld( args [ 2 ]:GetWorld() )
					player:SetPosition ( playerPos + Vector3 ( 2, 0, 0 ) )
					player:Message( "Вы телепортировались к ".. args [ 2 ]:GetName(), "info" )
--					for _, thePlayer in pairs ( self.canChat ) do
--						Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." телепортировался к " .. args [ 2 ]:GetName() } )
--					end
					print( player:GetName() .. " warped to " .. args [ 2 ]:GetName() )
					Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " warped to " .. args [ 2 ]:GetName() } )
				else
					player:Message ( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.warpto" ) then
				if IsValid ( args [ 2 ], false ) then
					if IsValid ( args [ 3 ], false ) then
						if args [ 2 ]:GetWorld() ~= args [ 3 ]:GetWorld() then
							player:Message ( "Игроки в разных мирах!", "err" )
							return
						end
						local playerPos = args [ 2 ]:GetPosition()
--						args [ 3 ]:SetWorld( args [ 2 ]:GetWorld() )
						args [ 3 ]:SetPosition ( playerPos + Vector3 ( 2, 0, 0 ) )
--						for _, thePlayer in pairs ( self.canChat ) do
--							Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." телепортировал " .. args [ 3 ]:GetName() .. " к " .. args [ 2 ]:GetName() } )
--						end
						args [ 3 ]:Message( player:GetName() .. " телепортировал ".. args [ 3 ]:GetName() .." к ".. args [ 2 ]:GetName(), "info" )
					else
						player:Message( "Один из игроков не в сети.", "err" )
					end
				else
					player:Message( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.givevehicle" ) then
				if IsValid ( args [ 2 ], false ) then
					if ( args [ 3 ] and Vehicle.GetNameByModelId ( args [ 3 ] ) ) then
						if args [ 2 ]:InVehicle() then
							local veh = args [ 2 ]:GetVehicle()
							if ( veh ) then
								veh:Remove()
								self.vehicles [ veh ] = nil
							end
						end
						local template = args [ 4 ]
						if ( template ~= "Default" ) then
							if ( not vehicleTemplates [ args [ 3 ] ] ) then
								template = ""
							else
								local found = false
								for _, temp in ipairs ( vehicleTemplates [ args [ 3 ] ] ) do
									if ( args [ 4 ] == temp ) then
										found = true
										break
									end
								end
								if ( not found ) then
									template = ""
								end
							end
						else
							template = ""
						end
						if self.vehicles [ args [ 2 ]:GetId() ] then
							self.vehicles [ args [ 2 ]:GetId() ]:Remove()
							self.vehicles [ args [ 2 ]:GetId() ] = nil
						end
						local vehicle = Vehicle.Create (
							{
								model_id = args [ 3 ],
								position = args [ 2 ]:GetPosition (),
								angle = args [ 2 ]:GetAngle (),
								template = template
							}
						)
						if ( vehicle ) then
							vehicle:SetUnoccupiedRespawnTime( 15 )
							vehicle:SetDeathRemove( true )
							vehicle:SetUnoccupiedRemove( true )
							--vehicle:SetWorld( args [ 2 ]:GetWorld() )
							args [ 2 ]:EnterVehicle ( vehicle, VehicleSeat.Driver )
							self.vehicles [ args [ 2 ]:GetId() ] = vehicle
							player:Message( "Вы дали ".. args [ 2 ]:GetName() .." транспорт ".. tostring ( Vehicle.GetNameByModelId ( args [ 3 ] ) ), "info" )
							print( player:GetName() .. " give ".. args [ 2 ]:GetName() .. " vehicle ".. tostring ( Vehicle.GetNameByModelId ( args [ 3 ] ) ) )
							Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " give ".. args [ 2 ]:GetName() .. " vehicle ".. tostring ( Vehicle.GetNameByModelId ( args [ 3 ] ) ) } )
							args [ 2 ]:Message( player:GetName() .." дал тебе ".. tostring ( Vehicle.GetNameByModelId ( args [ 3 ] ) ), "info" )
--							for _, thePlayer in pairs ( self.canChat ) do
--								Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." выдал тс " .. tostring ( Vehicle.GetNameByModelId ( args [ 3 ] ) ) .. " для " .. args [ 2 ]:GetName() } )
--							end
						else
							player:Message( "Не удалось предоставить ".. args [ 2 ]:GetName ( ) .."!", "err" )
						end
					else
						player:Message( "Неверный ID модели транспорта.", "err" )
					end
				else
					player:Message( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.repairvehicle" ) then
				if IsValid ( args [ 2 ], false ) then
					if args [ 2 ]:InVehicle() then
						args [ 2 ]:GetVehicle():SetHealth( 1 )
						player:Message( "Вы отремонтировали ".. args [ 2 ]:GetName() .." транспорт.", "info" )
						print( player:GetName() .. " repaired vehicle " .. args [ 2 ]:GetName() )
						Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " repaired vehicle ".. args [ 2 ]:GetName() } )
						args [ 2 ]:Message( player:GetName() .. " отремонтировал ваш транспорт.", "info" )
--						for _, thePlayer in pairs ( self.canChat ) do
--							Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." отремонтировал тс " .. args [ 2 ]:GetName() } )
--						end
					else
						player:Message( args [ 2 ]:GetName() .." не находится в транспорте.", "err" )
					end
				else
					player:Message ( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.destroyvehicle" ) then
				if IsValid ( args [ 2 ], false ) then
					if args [ 2 ]:InVehicle() then
						local veh = args [ 2 ]:GetVehicle()
						if ( veh ) then
							veh:Remove()
							self.vehicles [ veh ] = nil
--							for _, thePlayer in pairs ( self.canChat ) do
--								Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." удалил тс " .. args [ 2 ]:GetName() } )
--							end
						end
					else
						player:Message( args [ 2 ]:GetName() .." не находится в транспорте.", "err" )
					end
				else
					player:Message( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.setvehiclecolour" ) then
				if IsValid ( args [ 2 ], false ) then
					if args [ 2 ]:InVehicle ( ) then
						local veh = args [ 2 ]:GetVehicle()
						if ( veh ) then
							local color1, color2 = veh:GetColors()
							if ( args [ 3 ] == "tone1" ) then
								veh:SetColors ( args [ 4 ], color2 )
							elseif ( args [ 3 ] == "tone2" ) then
								veh:SetColors ( color1, args [ 4 ] )
							end
							player:Message( "Вы изменили ".. args [ 2 ]:GetName() .." цвет транспорта!", "info" )
							print( player:GetName() .. " change color vehicle " .. args [ 2 ]:GetName() )
							Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " change color vehicle " .. args [ 2 ]:GetName() } )
--							for _, thePlayer in pairs ( self.canChat ) do
--								Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." изменил цвет тс для " .. args [ 2 ]:GetName() } )
--							end
							player:Message( player:GetName() .." изменил цвет вашего транспорта!", "info" )
						end
					else
						player:Message( args [ 2 ]:GetName() .." не находится в транспорте.", "err" )
					end
				else
					player:Message( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.giveweapon" ) then
				if IsValid ( args [ 2 ], false ) then
					args [ 2 ]:GiveWeapon( WeaponSlot [ args [ 4 ] ], Weapon ( args [ 3 ], 30, 70 ) )
					player:Message( "Вы дали ".. args [ 2 ]:GetName() .." оружие: ".. tostring ( getWeaponNameFromID ( args [ 3 ] ) ) ..", боеприпасы: 30 патронов, 70 запас.", "info" )
					args [ 2 ]:Message( player:GetName() .." дал вам оружие: ".. tostring ( getWeaponNameFromID ( args [ 3 ] ) ) ..", боеприпасы: 30 патронов, 70 запас.", "info" )
--					for _, thePlayer in pairs ( self.canChat ) do
--						Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." выдал оружие " .. tostring ( getWeaponNameFromID ( args [ 3 ] ) ) .. " для " .. args [ 2 ]:GetName() } )
--					end
				else
					player:Message( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.giveadmin" ) then
				if IsValid ( args [ 2 ], false ) then
					if ACL:groupAddObject( "Глава", tostring ( args [ 2 ]:GetSteamId() ) ) then
						player:Message( "Вы дали доступ к панели ".. args [ 2 ]:GetName() .."!", "info" )
						print( player:GetName() .. " give access to admin panel " .. args [ 2 ]:GetName() .."!" )
						Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " give access to admin panel " .. args [ 2 ]:GetName() .."!" } )
--						for _, thePlayer in pairs ( self.canChat ) do
--							Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." дал доступ к админ панели " .. args [ 2 ]:GetName() } )
--						end
						args [ 2 ]:Message( player:GetName() .." дал вам доступ к админ панели!", "info" )
						self:requestInformation( args [ 2 ], player )
					else
						player:Message( "Не удалось предоставить доступ к панели ".. args [ 2 ]:GetName() .."!", "err" )
					end
				else
					player:Message( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.takeadmin" ) then
				if IsValid ( args [ 2 ], false ) then
					if ACL:groupRemoveObject( "Глава", tostring ( args [ 2 ]:GetSteamId() ) ) then
						player:Message( "Вы запретили доступ ".. args [ 2 ]:GetName() .." к панели!", "err" )
						print( player:GetName() .. " block access to admin panel " .. args [ 2 ]:GetName() .."!" )
						Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " block access to admin panel " .. args [ 2 ]:GetName() .."!" } )
--						for _, thePlayer in pairs ( self.canChat ) do
--							Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .. " запретил доступ к админ панели " .. args [ 2 ]:GetName() } )
--						end
						args [ 2 ]:Message( player:GetName() .." запретил вам доступ к панели!", "err" )
						self:requestInformation ( args [ 2 ], player )
					else
						player:Message( "Не удалось запретить доступ к панели ".. args [ 2 ]:GetName() .."!", "err" )
					end
				else
					player:Message( noonline, "err" )
				end
			elseif ( args [ 1 ] == "player.shout" ) then
				if IsValid ( args [ 2 ], false ) then
					Network:Send( args [ 2 ], "admin.shout", { name = "(".. player:GetName() ..")", msg = tostring ( args [ 3 ] or "" ) } )
					player:Message( "Вы отправили сообщение '".. args [ 3 ] .."' игроку " .. args [ 2 ]:GetName(), "info" )
					print( player:GetName() .." send screen message to " .. args [ 2 ]:GetName() .. ". ( Message: " .. args[ 3 ] .. " )" )
					Events:Fire( "ToDiscordConsole", { text = player:GetName() .." send screen message to " .. args [ 2 ]:GetName() .. ". ( Message: " .. args[ 3 ] .. " )" } )
--					for _, thePlayer in pairs ( self.canChat ) do
--						Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." вывел сообщение на экран игрока " .. args [ 2 ]:GetName() } )
--					end
				else
					player:Message( noonline, "err" )
				end
			elseif ( args [ 1 ] == "ban.add" ) then
				if ( args [ 2 ] ) then
					local banArgs =
					{
						steamID = args [ 2 ],
						name = "Неизвестно",
						reason = args [ 3 ],
						duration = args [ 4 ],
						responsible = player:GetName(),
						responsibleSteamID = tostring ( player:GetSteamId() )
					}
					if ( not banSystem:addBan ( banArgs ) ) then
						player:Message( "Не удалось добавить бан.", "err" )
					else
						player:Message( "Вы успешно забанили ".. tostring ( args [ 2 ] ) .."!", "info" )
						self:getBans ( _, player )
					end
				else
					player:Message( "No steam ID given.", "err" )
				end
			elseif ( args [ 1 ] == "ban.remove" ) then
				if ( args [ 2 ] ) then
					if banSystem:removeBan ( args [ 2 ] ) then
						player:Message( "Вы успешно разбанили ".. tostring ( args [ 2 ] ) .."!", "info" )
						self:getBans( _, player )
						Events:Fire( "ToDiscordConsole", { text = tostring ( args [ 2 ] ) .." was unbanned by ".. player:GetName() } )
						print( tostring ( args [ 2 ] ) .." was unbanned by ".. player:GetName() )
					else
						player:Message( "Не удалось удалить бан!", "err" )
					end
				else
					player:Message( "No steam ID given.", "err" )
				end
			elseif ( args [ 1 ] == "general.settime" ) then
				if tonumber ( args [ 2 ] ) then
					DefaultWorld:SetTime( tonumber ( args [ 2 ] ) )
					player:Message( "Время игры успешно изменилось.", "info" )
--					for _, thePlayer in pairs ( self.canChat ) do
--						Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .. " изменил время на " .. tostring ( args [ 2 ] ) } )
--					end
					print( player:GetName() .. " change game time." )
					Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " change game time." } )
				else
					player:Message( "Неверное значение.", "err" )
				end
			elseif ( args [ 1 ] == "general.settimestep" ) then
				if tonumber ( args [ 2 ] ) then
					player:Message( "Скорость игрового времени успешно изменилась.", "info" )
--					for _, thePlayer in pairs ( self.canChat ) do
--						Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." изменил скорость игрового времени на " .. tostring ( args [ 2 ] ) } )
--					end
					print( player:GetName() .. " changed the speed of the game time." )
					Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " changed the speed of the game time." } )
					DefaultWorld:SetTimeStep( tonumber ( args [ 2 ] ) )
				else
					player:Message( "Неверное значение.", "err" )
				end
			elseif ( args [ 1 ] == "general.setweather" ) then
				if tonumber ( args [ 2 ] ) then
					DefaultWorld:SetWeatherSeverity( tonumber ( args [ 2 ] ) )
					player:Message( "Погода в игре успешно изменилась.", "info" )
--					for _, thePlayer in pairs ( self.canChat ) do
--						Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .." изменил погоду на " .. tostring ( args [ 2 ] ) } )
--					end
					print( player:GetName() .. " changed weather." )
					Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " changed weather." } )
				else
					player:Message( "Неверное значение.", "err" )
				end
			elseif ( args [ 1 ] == "general.tab_adminchat" ) then
				for _, thePlayer in pairs ( self.canChat ) do
					Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() ..": ".. args [ 2 ] } )
					thePlayer:SendChatMessage( "[Админ-чат] ", Color.White, player:GetName(), player:GetColor(), ": ".. args [ 2 ], Color.Yellow )
				end
				print( "[Admin Chat] " .. player:GetName() .. ": ".. args [ 2 ] )
				Events:Fire( "ToDiscordConsole", { text = "[Admin Chat] " .. player:GetName() .. ": ".. args [ 2 ] } )
			elseif ( args [ 1 ] == "acl.modifypermission" ) then
				if ( args [ 2 ] ) then
					if ( args [ 3 ] and args [ 4 ] ) then
						if ACL:updateGroupPermission ( args [ 2 ], args [ 3 ], toboolean ( args [ 4 ] ) ) then
							player:Message( "Успешно изменено разрешение.", "info" )
							self:getACL( nil, player )
						else
							player:Message( "Не удалось обновить разрешение! Вы точно выбрали группу?", "err" )
						end
					end
				else
					player:Message( "Нет группы.", "err" )
				end
			elseif ( args [ 1 ] == "acl.creategroup" ) then
				if ( args [ 2 ] ) then
					if ( type ( args [ 3 ] ) == "table" ) then
						if ACL:createGroup ( args [ 2 ], args [ 3 ], player:GetName ( ) .."(".. tostring ( player:GetSteamId ( ) ) ..")" ) then
							player:Message( "Успешно созданная группа ACL ".. tostring ( args [ 2 ] ) .."!", "info" )
							self:getACL ( nil, player )
						else
							player:Message( "Не удалось создать группу ACL!", "err" )
						end
					else
						player:Message( "Недопустимая таблица разрешений.", "err" )
					end
				else
					player:Message( "Имя группы не указано.", "err" )
				end
			elseif ( args [ 1 ] == "acl.removegroup" ) then
				if ( args [ 2 ] ) then
					if ACL:destroyGroup ( args [ 2 ] ) then
						player:Message( "Вы успешно удалили группу ACL ".. tostring ( args [ 2 ] ) .."!", "err" )
						self:getACL ( nil, player )
					else
						player:Message( "Не удалось удалить группу ACL!", "err" )
					end
				else
					player:Message( "Имя группы не указано.", "err" )
				end
			elseif ( args [ 1 ] == "acl.addobject" ) then
				if ( args [ 2 ] ) then
					if ( args [ 3 ] ) then
						if ACL:groupAddObject ( args [ 2 ], args [ 3 ] ) then
							player:Message( "Вы успешно добавили объект ".. tostring ( args [ 3 ] ) .." группе ACL ".. tostring ( args [ 2 ] ) .."!", "info" )
							self:getACL ( nil, player )
						else
							player:Message( "Не удалось добавить объект! Вы точно выбрали группу?", "err" )
						end
					else
						player:Message( "Steam ID не был указан.", "err" )
					end
				else
					player:Message( "Имя группы не указано.", "err" )
				end
			elseif ( args [ 1 ] == "acl.removeobject" ) then
				if ( args [ 2 ] ) then
					if ( args [ 3 ] ) then
						if ACL:groupRemoveObject ( args [ 2 ], args [ 3 ] ) then
							player:Message( "Вы успешно удалили объект ".. tostring ( args [ 3 ] ) .." из группы ACL ".. tostring ( args [ 2 ] ) .."!", "err" )
							self:getACL ( nil, player )
						else
							player:Message( "Не удалось удалить объект! Вы точно выбрали группу?", "err" )
						end
					else
						player:Message( "Steam ID не был указан.", "err" )
					end
				else
					player:Message( "Имя группы не указано.", "err" )
				end
			elseif ( args [ 1 ] == "module.load" ) then
				if ( args [ 2 ] == "module.reload" ) then
					if self:moduleExists ( tostring ( args [ 3 ] ) ) then
						Console:Run ( "reload ".. tostring ( args [ 3 ] ) )
						player:Message ( "Вы успешно перезапустили модуль ".. tostring ( args [ 3 ] ) ..".", "info" )
--						for _, thePlayer in pairs ( self.canChat ) do
--							Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .. " перезапустил модуль " .. tostring ( args [ 3 ] ) } )
--						end
						self:updateModuleLog ( args [ 3 ], player, "reloaded" )
						self:getModules ( nil, player )
					else
						player:Message ( "Модуль с таким названием не найден.", "err" )
					end
				else
					if self:moduleExists ( tostring ( args [ 2 ] ) ) then
						Console:Run ( "load ".. tostring ( args [ 2 ] ) )
						player:Message ( "Вы успешно запустили модуль ".. tostring ( args [ 2 ] ) ..".", "info" )
--						for _, thePlayer in pairs ( self.canChat ) do
--							Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .. " запустил модуль " .. tostring ( args [ 2 ] ) } )
--						end
						self:updateModuleLog ( args [ 2 ], player, "loaded" )
						self:getModules ( nil, player )
					else
						player:Message ( "Модуль с таким названием не найден.", "err" )
					end
				end
			elseif ( args [ 1 ] == "module.unload" ) then
				if self:moduleExists ( tostring ( args [ 2 ] ) ) then
					Console:Run ( "unload ".. tostring ( args [ 2 ] ) )
					player:Message ( "Вы успешно отключили модуль ".. tostring ( args [ 2 ] ) ..".", "err" )
--					for _, thePlayer in pairs ( self.canChat ) do
--						Network:Send( thePlayer, "admin.addChatMessage", { msg = os.date ( "[%X] " ) .. player:GetName() .. " отключил модуль " .. tostring ( args [ 2 ] ) } )
--					end
					self:updateModuleLog ( args [ 2 ], player, "unloaded" )
					self:getModules ( nil, player )
				else
					player:Message ( "Модуль с таким названием не найден.", "err" )
				end
			end
		end
	end
end

function Admin:getBans( _, player )
	if IsValid ( player, false ) then
		Network:Send( player, "admin.displayBans", banSystem:getBans() )
	end
end

function Admin:getACL( _, player )
	if IsValid ( player, false ) then
		Network:Send( player, "admin.displayACL", ACL:groupList() )
	end
end

function Admin:getModules ( _, player )
	if IsValid ( player, false ) then
		Network:Send ( player, "admin.displayModules", { Server:GetModules ( ), self.moduleLog } )
	end
end

function Admin:getChat( _, player )
	if IsValid ( player, false ) then
		if self.savetext then
			Network:Send( player, "admin.addChatMessage", { msg = "" } )
			Network:Send( player, "admin.addChatMessage", { msg = self.savetext } )
		end
	end
end

function Admin:getSpectatorVictim( args, sender )
	if IsValid ( args.victim, false ) then
		Network:Send( sender, "admin.setSpectatorVictim", { victimPos = args.victim:GetPosition(), victimAng = args.victim:GetAngle() } )

		if ACL:hasObjectPermissionTo( tostring ( args.victim:GetSteamId() ), "general.adminpanel" ) then
			if args.spectating then
				args.victim:Message( sender:GetName() .. " начал наблюдать за вами. 0_0", "info" )
			else
				args.victim:Message( sender:GetName() .. " кончил наблюдать за вами.", "info" )
			end
		end
	end
end

function Admin:updateModuleLog ( module, player, action )
	if IsValid ( player, false ) then
		table.insert ( self.moduleLog, os.date ( "%X" ) ..": ".. player:GetName ( ) .."(".. tostring ( player:GetSteamId ( ) ) ..") ".. tostring ( action ) .." the module ".. tostring ( module ) )
	end
end

function Admin:moduleExists ( module )
	local modules = Server:GetModules ( )
	if ( modules [ module ] ~= nil ) then
		return true
	else
		return false
	end
end

function Player:Message( msg, color )
	self:SendChatMessage( ChatTag, Color.White, msg, msgColors [ color ] )
end

Events:Subscribe( "ModuleLoad",
	function()
		Admin = Admin()
	end
)
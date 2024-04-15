class 'FreeCamManager'

function FreeCamManager:__init()
	Network:Subscribe("FreeCamTP", self, self.TeleportPlayer)
	Network:Subscribe("ToggleFreecam", self, self.ToggleFreecam)

	-- Set default permissions from whitelist
	Events:Subscribe("ModuleLoad", self, self.SendPermissionAll)
	Events:Subscribe("ModulesLoad", self, self.SendPermissionAll)
	Events:Subscribe("PlayerJoin", self, self.SendPermission)

	-- Notice other modules on serverside when cam has changed
	Network:Subscribe("FreeCamChange", function(args, client)
			if args.active == nil then return end
			args.player = client
			Events:Fire("FreeCamChange", args)
		end)

	-- Forward permissions to FreeCam client
	Events:Subscribe("FreeCam", function(args)
			if args.player == nil then return end
			local perm = args.perm
			if args.restore then
				perm = FreeCamManager.CheckWhiteList(args.player)
			end
			Network:Send(args.player, "FreeCam",
								{["perm"] = perm,
								 ["active"] = args.active})
		end)
end


function FreeCamManager:TeleportPlayer(args, client)
	if not Config.teleport or args.pos == nil then return end
	if client:InVehicle() then
		local vehicle = client:GetVehicle()

		vehicle:SetPosition(args.pos)
		vehicle:SetAngle(args.angle)
	else
		client:SetPosition(args.pos)
		client:SetAngle(args.angle)
	end
end

function FreeCamManager:SendPermissionAll(args)
	for player in Server:GetPlayers() do

		if FreeCamManager.CheckWhiteList(player) then
			Network:Send(player, "FreeCam", {["perm"] = true})
		end
	end
end

function FreeCamManager:SendPermission(args)
	local player = args.player

	if FreeCamManager.CheckWhiteList(player) then
		Network:Send(player, "FreeCam", {["perm"] = true})
	end
end

function FreeCamManager:ToggleFreecam( args, sender )
	sender:SetNetworkValue( "FreecamEnabled", args.enabled )
end

function FreeCamManager.CheckWhiteList(player)
	local perm1 = table.find(WhiteList, player:GetSteamId().id)
	local perm2 = table.find(WhiteList, player:GetSteamId().string)
	if perm1 ~= nil or perm2 ~= nil then
		return true
	else
		return false
	end
end

freeCamManager = FreeCamManager()
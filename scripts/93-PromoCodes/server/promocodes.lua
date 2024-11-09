class 'PromoCodes'

function PromoCodes:__init()
	self.globalPromocodes = {}
	self.invitationsPromocodes = {}

	self.invalidArguments_txt = "Invalid arguments"

	SQL:Execute( "CREATE TABLE IF NOT EXISTS promocodes_global (name INTEGER UNIQUE, bonus INTEGER, count INTEGER)" )
    SQL:Execute( "CREATE TABLE IF NOT EXISTS promocodes_invitations (steamid VARCHAR UNIQUE, name INTEGER, bonus1 INTEGER, bonus2 INTEGER, uses INTEGER, activations INTEGER, rewards INTEGER, creationdate INTEGER)" )
	SQL:Execute( "CREATE TABLE IF NOT EXISTS promocodes_activeplayers (steamid VARCHAR, name INTEGER, bonus INTEGER)" )

    self:LoadGlobalPromocodes()
	self:LoadInvitationsPromocodes()

    Events:Subscribe( "ClientModuleLoad", self, self.ClientModuleLoad )
    Events:Subscribe( "AddGlobalPromocode", self, self.AddGlobalPromocode )
	Events:Subscribe( "AddInvitationPromocode", self, self.AddInvitationPromocode )
	Events:Subscribe( "UpdateInvitationPromocodesInfo", self, self.UpdateInvitationPromocodesInfo )
	Events:Subscribe( "InvitationPromocodeActivated", self, self.InvitationPromocodeActivated )
	Events:Subscribe( "GetInvitationPromocodesReward", self, self.GetInvitationPromocodesReward )

    Network:Subscribe( "GlobalPromocodeUses", self, self.GlobalPromocodeUses )
	Network:Subscribe( "InvitationPromocodeUses", self, self.InvitationPromocodeUses )

    Console:Subscribe( "addglobalpromocode", self, self.AddGlobalPromocode )
	Console:Subscribe( "addinvitationpromocode", self, self.AddInvitationPromocode )
	Console:Subscribe( "removeglobalpromocode", self, self.RemoveGlobalPromocode )
	Console:Subscribe( "removeinvitationpromocode", self, self.RemoveInvitationPromocode )
end

function PromoCodes:GlobalPromocodeUses( args, sender )
	local name = args.row[2].name
	local steamId = sender:GetSteamId().id

	local count = tonumber( args.row[2].count )

	if count <= 1 then
		local cmd = SQL:Command( "DELETE FROM promocodes_global WHERE name = (?)" )
		cmd:Bind( 1, name )
		cmd:Execute()

		local successfully_txt = "Global promocode " .. name .. " removed (limit)"

		print( successfully_txt )
		Events:Fire( "ToDiscordConsole", { text = successfully_txt } )
	else
		count = count - 1

		local cmd = SQL:Command( "UPDATE promocodes_global set count = ? WHERE name = ?" )
		cmd:Bind( 1, count )
		cmd:Bind( 2, name )
		cmd:Execute()

		local successfully_txt = "Global promocode " .. name .. " activated. Count: " .. count

		print( successfully_txt )
		Events:Fire( "ToDiscordConsole", { text = successfully_txt } )
	end

	self:LoadGlobalPromocodes()

	sender:SetMoney( sender:GetMoney() + tonumber( args.row[2].bonus ) )
end

function PromoCodes:InvitationPromocodeUses( args, sender )
	local name = args.row[2].name
	local uses = tonumber( args.row[2].uses ) + 1
	local activations = tonumber( args.row[2].activations )

	local cmd = SQL:Command( "UPDATE promocodes_invitations set uses = ?, activations = ? WHERE name = ?" )
	cmd:Bind( 1, uses )
	cmd:Bind( 2, activations )
	cmd:Bind( 3, name )
	cmd:Execute()

	local successfully_txt = "Invitation promocode " .. name .. " used. Uses: " .. uses .. ", Activations: " .. activations

	print( successfully_txt )
	Events:Fire( "ToDiscordConsole", { text = successfully_txt } )

	self:LoadInvitationsPromocodes()

    local cmd = SQL:Command( "INSERT OR REPLACE INTO promocodes_activeplayers (steamid, name, bonus) values (?, ?, ?)" )
    cmd:Bind( 1, sender:GetSteamId().id )
	cmd:Bind( 2, name )
    cmd:Bind( 3, tonumber( args.row[2].bonus2 ) )
    cmd:Execute()
end

function PromoCodes:InvitationPromocodeActivated( player )
    local steamId = player:GetSteamId().id

    local qry = SQL:Query( "SELECT name, bonus FROM promocodes_activeplayers WHERE steamid = ?" )
    qry:Bind( 1, steamId )
    local result = qry:Execute()

    if #result == 0 then return end

	player:SetNetworkValue( "ActivePromocode", result[1].bonus )

    local name = result[1].name

    local qry = SQL:Query( "SELECT uses, activations, rewards FROM promocodes_invitations WHERE name = ?" )
    qry:Bind( 1, name )
    local result = qry:Execute()

    if #result == 0 then return end

    local uses = tonumber( result[1].uses )
    local activations = tonumber( result[1].activations ) + 1
	local rewards = tonumber( result[1].rewards ) + 1

    local cmd = SQL:Command( "UPDATE promocodes_invitations SET activations = ?, rewards = ? WHERE name = ?" )
    cmd:Bind( 1, activations )
	cmd:Bind( 2, rewards )
    cmd:Bind( 3, name )
    cmd:Execute()

    local successfully_txt = "Invitation promocode " .. name .. " activated. Uses: " .. uses .. ", Activations: " .. activations
    print( successfully_txt )
    Events:Fire( "ToDiscordConsole", { text = successfully_txt } )

    self:LoadInvitationsPromocodes()

	local cmd = SQL:Command( "DELETE FROM promocodes_activeplayers WHERE steamid = (?)" )
	cmd:Bind( 1, steamId )
	cmd:Execute()
end

function PromoCodes:GetInvitationPromocodesReward( player )
	local steamId = player:GetSteamId().id
	local rewards = 0

	local cmd = SQL:Command( "UPDATE promocodes_invitations set rewards = ? WHERE steamid = ?" )
	cmd:Bind( 1, rewards )
	cmd:Bind( 2, steamId )
	cmd:Execute()

	self:LoadInvitationsPromocodes()
end

function PromoCodes:AddGlobalPromocode( args )
	local cmd_args = args.text:split( " " )

	if cmd_args[1] == "" then
		print( self.invalidArguments_txt )
		return
	end

	local name = cmd_args[1]
	local bonus = cmd_args[2] or 500
	local count = 1 --cmd_args[3] or 1

	local cmd = SQL:Command( "INSERT OR REPLACE INTO promocodes_global (name, bonus, count) values (?, ?, ?)" )
    cmd:Bind( 1, name )
	cmd:Bind( 2, bonus )
	cmd:Bind( 3, count )
    cmd:Execute()

    local successfully_txt = "Global promocode successfully generated: " .. tostring( name ) .. ", " .. tostring( bonus ) .. ", " .. tostring( count )

    print( successfully_txt )
    Events:Fire( "ToDiscordConsole", { text = successfully_txt } )

	self:LoadGlobalPromocodes()
end

function PromoCodes:AddInvitationPromocode( args )
	local cmd_args = args.text:split( " " )

	if cmd_args[1] == "" then
		print( self.invalidArguments_txt )
		return
	end

	local steamId = cmd_args[1]
	local name = cmd_args[2] or cmd_args[1]
	local bonus1 = cmd_args[3] or 1000
	local bonus2 = cmd_args[4] or 500
	local date = os.date( "%d/%m/%y %X" )

	local cmd = SQL:Command( "INSERT OR REPLACE INTO promocodes_invitations (steamid, name, bonus1, bonus2, uses, activations, rewards, creationdate) values (?, ?, ?, ?, ?, ?, ?, ?)" )
    cmd:Bind( 1, steamId )
	cmd:Bind( 2, name )
	cmd:Bind( 3, bonus1 )
	cmd:Bind( 4, bonus2 )
	cmd:Bind( 5, 0 )
	cmd:Bind( 6, 0 )
	cmd:Bind( 7, 0 )
	cmd:Bind( 8, date )
    cmd:Execute()

    local successfully_txt = "Invitation promocode successfully generated: " .. tostring( steamId ) .. ", " .. tostring( name ) .. ", " .. tostring( bonus1 ) .. ", " .. tostring( bonus2 )

    print( successfully_txt )
    Events:Fire( "ToDiscordConsole", { text = successfully_txt } )

	self:LoadInvitationsPromocodes()
end

function PromoCodes:UpdateInvitationPromocodesInfo( player )
	local steamId = player:GetSteamId().id

    local qry = SQL:Query( "SELECT steamid, name, bonus1, bonus2, uses, activations, rewards, creationdate from promocodes_invitations WHERE steamid = (?)" )
	qry:Bind( 1, steamId )
    local result = qry:Execute()

	if #result > 0 then
		player:SetNetworkValue( "PromoCodeName", result[1].name )
        player:SetNetworkValue( "PromoCodeUses", result[1].uses )
		player:SetNetworkValue( "PromoCodeActivations", result[1].activations )
		player:SetNetworkValue( "PromoCodeRewards", result[1].rewards )
		player:SetNetworkValue( "PromoCodeCreationDate", result[1].creationdate )
	else
		player:SetNetworkValue( "PromoCodeName", nil )
        player:SetNetworkValue( "PromoCodeUses", nil )
		player:SetNetworkValue( "PromoCodeActivations", nil )
		player:SetNetworkValue( "PromoCodeRewards", nil )
		player:SetNetworkValue( "PromoCodeCreationDate", nil )
	end
end

function PromoCodes:RemoveGlobalPromocode( args )
	local cmd_args = args.text:split( " " )

	if cmd_args[1] == "" then
		print( self.invalidArguments_txt )
		return
	end

	local name = cmd_args[1]

	local qry = SQL:Query( "SELECT 1 FROM promocodes_global WHERE name = (?)" )
    qry:Bind( 1, name )
	local result = qry:Execute()

	if #result > 0 then
        local cmd = SQL:Command( "DELETE FROM promocodes_global WHERE name = (?)" )
        cmd:Bind( 1, name )
        cmd:Execute()

        local successfully_txt = "Global promocode " .. args.text .. " successfully removed"
        print( successfully_txt )
        Events:Fire( "ToDiscordConsole", { text = successfully_txt } )
	else
        local notfound_txt = "Global promocode " .. args.text .. " not found"
        print( notfound_txt )
        Events:Fire( "ToDiscordConsole", { text = notfound_txt } )
	end

	self:LoadGlobalPromocodes()
end

function PromoCodes:RemoveInvitationPromocode( args )
    local cmd_args = args.text:split( " " )

	if cmd_args[1] == "" then
		print( self.invalidArguments_txt )
		return
	end

    local steamId = cmd_args[1]

    local qry = SQL:Query( "SELECT 1 FROM promocodes_invitations WHERE steamid = (?)" )
    qry:Bind( 1, steamId )
    local result = qry:Execute()

    if #result > 0 then
        local cmd = SQL:Command( "DELETE FROM promocodes_invitations WHERE steamid = (?)" )
        cmd:Bind( 1, steamId )
        cmd:Execute()

        local successfully_txt = "Invitation promocode (SteamId: " .. args.text .. ") successfully removed"
        print( successfully_txt )
        Events:Fire( "ToDiscordConsole", { text = successfully_txt } )
	else
        local notfound_txt = "Invitation promocode (SteamId: " .. args.text .. ") not found"
        print( notfound_txt )
        Events:Fire( "ToDiscordConsole", { text = notfound_txt } )
	end

    self:LoadInvitationsPromocodes()
end

function PromoCodes:LoadGlobalPromocodes()
	self.globalPromocodes = {}

    local qry = SQL:Query( "SELECT name, bonus, count FROM promocodes_global" )
    local result = qry:Execute()

	if #result > 0 then
		for i, row in pairs( result ) do
			table.insert( self.globalPromocodes, { i, row } )
		end
    end

	print( "Loaded " .. #result .. " global promocode(s)" )

	Network:Broadcast( "GlobalPromocodes", self.globalPromocodes )
end

function PromoCodes:LoadInvitationsPromocodes()
	self.invitationsPromocodes = {}

    local qry = SQL:Query( "SELECT steamid, name, bonus1, bonus2, uses, activations, creationdate FROM promocodes_invitations" )
    local result = qry:Execute()

	if #result > 0 then
		for i, row in pairs( result ) do
			table.insert( self.invitationsPromocodes, { i, row } )
		end
    end

	print( "Loaded " .. #result .. " invitation promocode(s)" )

	Network:Broadcast( "InvitationsPromocodes", self.invitationsPromocodes )
end

function PromoCodes:ClientModuleLoad( args )
	args.player:SetNetworkValue( "AvailablePromoCodes", true )

	Network:Send( args.player, "GlobalPromocodes", self.globalPromocodes )
	Network:Send( args.player, "InvitationsPromocodes", self.invitationsPromocodes )
end

promocodes = PromoCodes()
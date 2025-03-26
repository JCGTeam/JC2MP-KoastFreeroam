class 'WarpGui'

function WarpGui:__init()
	self.actions = {
		[3] = true,
		[4] = true,
		[5] = true,
		[6] = true,
		[11] = true,
		[12] = true,
		[13] = true,
		[14] = true,
		[17] = true,
		[18] = true,
		[105] = true,
		[137] = true,
		[138] = true,
		[139] = true,
		[51] = true,
		[52] = true,
		[16] = true
	}

	self.cooldown = 15
	self.cooltime = 0

	self.textColor = Color( 255, 250, 150 )

	self.textSize = 13

	self.rows = {}
	self.acceptButtons = {}
	self.whitelistButtons = {}
	self.whitelist = {}
	self.whitelistAll = false
	self.warpRequests = {}
	self.windowShown = false
	self.warping = true

	self.window = Window.Create()
	self.window:SetVisible( self.windowShown )
	self.window:SetSizeRel( Vector2( 0.35, 0.7 ) )
	self.window:SetMinimumSize( Vector2( 400, 200 ) )
	self.window:SetPositionRel( Vector2( 0.75, 0.5 ) - self.window:GetSizeRel()/2 )
    self.window:Subscribe( "WindowClosed", self, self.OpenWarpGUI )

	self.playerList = SortedList.Create( self.window )
	self.playerList:SetMargin( Vector2(), Vector2( 0, 4 ) )
	self.playerList:SetBackgroundVisible( false )
	self.playerList:AddColumn( "Игрок" )
	self.playerList:AddColumn( "Телепорт к", Render:GetTextWidth( "Телепорт к" ) + 10 )
	self.playerList:AddColumn( "Запросы", Render:GetTextWidth( "Запросы" ) + 20 )
	self.playerList:AddColumn( "Режим", Render:GetTextWidth( "Режим" ) + 25 )
	self.playerList:SetButtonsVisible( true )
	self.playerList:SetDock( GwenPosition.Fill )

	self.filter = TextBox.Create( self.window )
	self.filter:SetDock( GwenPosition.Bottom )
	self.filter:SetHeight( 32 )
	self.filter:Subscribe( "TextChanged", self, self.TextChanged )
	self.filter:Subscribe( "Focus", self, self.Focus )
	self.filter:Subscribe( "Blur", self, self.Blur )
	self.filter:Subscribe( "EscPressed", self, self.EscPressed )

	local textSize = 15
	self.whitelistAllCheckbox = LabeledCheckBox.Create( self.window )
    self.whitelistAllCheckbox:SetDock( GwenPosition.Top )
	self.whitelistAllCheckbox:GetLabel():SetTextSize( textSize )
	self.whitelistAllCheckbox:SetMargin( Vector2( 5, 5 ), Vector2( 5, 0 ) )
	self.whitelistAllCheckbox:GetCheckBox():Subscribe( "CheckChanged", function() self.whitelistAll = self.whitelistAllCheckbox:GetCheckBox():GetChecked() end )

	self.blacklistAllCheckbox = LabeledCheckBox.Create( self.window )
	self.blacklistAllCheckbox:SetDock( GwenPosition.Top )
	self.blacklistAllCheckbox:GetLabel():SetTextSize( textSize )
	self.blacklistAllCheckbox:SetMargin( Vector2( 5, 0 ), Vector2( 5, 5 ) )
	self.blacklistAllCheckbox:GetCheckBox():Subscribe( "CheckChanged", function() self.warping = not self.warping end )	

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.tag = "[Телепорт] "
		self.w = "Подождите "
		self.ws = " секунд, чтобы вновь отправить запрос!"
		self.gonnawarp = ' хотел бы телепортироваться к вам. Нажмите "B" и зайдите в меню "Телепортация", чтобы принять.'
		self.tprequest_txt = "Запрос на телепорт"
		self.prequester_txt = "Игрок: "
		self.friend_txt = "Друг"
		self.teleport_txt = "Телепорт ≫"
		self.accept_txt = "Принять √"
		self.autotp_txt = "Авто-ТП"
		self.blacklist_txt = "Заблок."
		self.teleportrequest_txt = "Запрос на телепортацию отправлен. Ожидайте принятия запроса."
		self.teleportrequest2_txt = "Запрос на телепортацию отправлен, но игрок находится в другом режиме."
		self.teleportrequest3_txt = " хотел телепортироваться к вам, но вы находитесь в другом режиме."
		self.noteleport_txt = " не просил вас телепортироваться."

		if self.window then
			self.window:SetTitle( "▧ Телепорт к игрокам" )
			self.whitelistAllCheckbox:GetLabel():SetText( "Разрешить Авто-ТП всем" )
			self.blacklistAllCheckbox:GetLabel():SetText( "Не беспокоить" )
			self.filter:SetToolTip( "Поиск" )
		end
	end

	-- Add players
	--self:AddPlayer( LocalPlayer )
	for player in Client:GetPlayers() do
		self:AddPlayer( player )
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "OpenWarpGUI", self, self.OpenWarpGUI )
	Events:Subscribe( "CloseWarpGUI", self, self.CloseWarpGUI )

	Network:Subscribe( "CenterText", self, self.CenterText )
	Network:Subscribe( "WarpRequestToTarget", self, self.WarpRequest )
	Network:Subscribe( "WarpReturnWhitelists", self, self.WarpReturnWhitelists )
	Network:Subscribe( "WarpDoPoof", self, self.WarpDoPoof )

	-- Load whitelists from server
	Network:Send( "WarpGetWhitelists", LocalPlayer )
end

function WarpGui:Lang()
	self.tag = "[Teleport] "
	self.w = "Wait "
	self.ws = " seconds to send the request again!"
	self.gonnawarp = ' sent you a teleport request. Press "B" and go to the "Teleportation" menu to accept.'
	self.tprequest_txt = "Teleport request"
	self.prequester_txt = "Sender: "
	self.friend_txt = "Friend"
	self.teleport_txt = "Teleport ≫"
	self.accept_txt = "Accept √"
	self.autotp_txt = "Auto-TP"
	self.blacklist_txt = "Blocked"
	self.teleportrequest_txt = "Teleport request has been sent. Wait for the request to be accepted."
	self.teleportrequest2_txt = "Teleport request has been sent, but the player is in a different game mode."
	self.teleportrequest3_txt = " wanted teleport to you, but you are in a different game mode."
	self.noteleport_txt = " did not ask you to warp."

	if self.window then
		self.window:SetTitle( "▧ Teleport to players" )
		self.whitelistAllCheckbox:GetLabel():SetText( "Allow Auto-TP for all" )
		self.blacklistAllCheckbox:GetLabel():SetText( "Do not disturb" )
		self.filter:SetToolTip( "Search" )
	end
end

--  Player adding
function WarpGui:CreateListButton( text, enabled, listItem )
    local buttonBackground = Rectangle.Create( listItem )
    buttonBackground:SetSizeRel( Vector2( 0.5, 1.0 ) )
    buttonBackground:SetDock( GwenPosition.Fill )
    buttonBackground:SetColor( Color( 0, 0, 0, 100 ) )

	local button = Button.Create( listItem )
	button:SetText( text )
	button:SetTextSize( self.textSize )
	button:SetDock( GwenPosition.Fill )
	button:SetEnabled( enabled )

	return button
end

function WarpGui:AddPlayer( player )
	local playerId = tostring(player:GetSteamId().id)
	local playerName = player:GetName()
	local playerColor = player:GetColor()

	local item = self.playerList:AddItem( playerId )

	if LocalPlayer:IsFriend( player ) then
		item:SetToolTip( self.friend_txt )
	end

	local warpToButton = self:CreateListButton( self.teleport_txt, true, item )
	warpToButton:Subscribe( "Press", function() self:WarpToPlayerClick( player ) end )

	local acceptButton = self:CreateListButton( self.accept_txt, false, item )
	acceptButton:Subscribe( "Press", function() self:AcceptWarpClick( player ) end )
	self.acceptButtons[playerId] = acceptButton

	local whitelist = self.whitelist[playerId]
	local whitelistButtonText = "-"
	if whitelist ~= nil then
		if whitelist == 1 then whitelistButtonText = self.autotp_txt
		elseif whitelist == 2 then whitelistButtonText = self.blacklist_txt
		end
	end
	local whitelistButton = self:CreateListButton( whitelistButtonText, true, item )
	whitelistButton:Subscribe( "Press", function() self:WhitelistClick(playerId, whitelistButton) end )
	self.whitelistButtons[playerId] = whitelistButton

	item:SetCellText( 0, playerName )
	item:SetCellContents( 1, warpToButton )
	item:SetCellContents( 2, acceptButton )
	item:SetCellContents( 3, whitelistButton )
	item:SetTextColor( playerColor )
	item:SetHeight( 25 )

	self.rows[playerId] = item

	-- Add is serch filter matches
	local filter = self.filter:GetText():lower()
	if filter:len() > 0 then
		item:SetVisible( true )
	end
end

--  Player search
function WarpGui:TextChanged()
	local filter = self.filter:GetText()

	if filter:len() > 0 then
		for k, v in pairs( self.rows ) do
			v:SetVisible( playerNameContains(v:GetCellText( 0 ), filter) )
		end
	else
		for k, v in pairs( self.rows ) do
			v:SetVisible( true )
		end
	end
end

function WarpGui:WarpToPlayerClick( player )
	local effect = ClientEffect.Play(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})

	local time = Client:GetElapsedSeconds()
	if time < self.cooltime then
		self:SetWindowVisible( false )

		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
		if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end

		Events:Fire( "CastCenterText", { text = self.w .. math.ceil(self.cooltime - time) .. self.ws, time = 6, color = Color.Red } )
		return
	end

	Network:Send( "WarpRequestToServer", {requester = LocalPlayer, target = player} )

	if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end

	self:SetWindowVisible( false )

	self.cooltime = time + self.cooldown
	return false
end

function WarpGui:AcceptWarpClick( player )
	local playerId = tostring(player:GetSteamId().id)

	if not self.warpRequests[playerId] then
		Chat:Print( self.tag, Color.White, player:GetName() .. self.noteleport_txt, self.textColor )
		return
	else
		local acceptButton = self.acceptButtons[playerId]
		if not acceptButton then return end
		self.warpRequests[playerId] = nil
		acceptButton:SetEnabled( false )

		self.requesterId = nil

		Network:Send( "WarpTo", {requester = player, target = LocalPlayer} )
		self:SetWindowVisible( false )

		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
		if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	end
end

function WarpGui:CenterText( args )
	Events:Fire( "CastCenterText", { text = args.text, time = args.time } )
end

--  Warp request
function WarpGui:WarpRequest( args )
	if self.warping then
		local requestingPlayer = args
		local playerId = tostring(requestingPlayer:GetSteamId().id)
		local whitelist = self.whitelist[playerId]

		if whitelist == 1 or self.whitelistAll then -- In whitelist and not in blacklist
			Network:Send( "WarpTo", {requester = requestingPlayer, target = LocalPlayer} )
		elseif whitelist == 0 or not whitelist then -- Not in whitelist
			local acceptButton = self.acceptButtons[playerId]
			if not acceptButton then return end

			acceptButton:SetEnabled( true )
			self.warpRequests[playerId] = true
			if LocalPlayer:GetWorld() ~= DefaultWorld then
				Network:Send( "WarpMessageTo", {target = requestingPlayer, message = self.teleportrequest2_txt, centertext = true } )
				Chat:Print( self.tag, Color.White, requestingPlayer:GetName() .. self.teleportrequest3_txt, self.textColor )
				return
			end
			Network:Send( "WarpMessageTo", {target = requestingPlayer, message = self.teleportrequest_txt, centertext = true } )
			Events:Fire( "SendNotification", { txt = self.tprequest_txt, image = "Information", subtxt = self.prequester_txt .. requestingPlayer:GetName() } )
			Chat:Print( self.tag, Color.White, requestingPlayer:GetName() .. self.gonnawarp, self.textColor )

			self.requesterId = playerId
			if not self.PostTickEvent then
				self.PostTickEvent = Events:Subscribe( "PostTick", self, self.PostTick )
				self.RefreshTimer = Timer()
			else
				self.RefreshTimer:Restart()
			end
		end
	end
end

function WarpGui:PostTick()
	if self.RefreshTimer:GetSeconds() <= 30 then return end

	self.RefreshTimer = nil

	if self.PostTickEvent then Events:Unsubscribe( self.PostTickEvent ) self.PostTickEvent = nil end

	if not self.requesterId then return end

	local acceptButton = self.acceptButtons[self.requesterId]
	if not acceptButton then return end
	self.warpRequests[self.requesterId] = nil
	acceptButton:SetEnabled( false )

	self.requesterId = nil
end

--  White/black -list click
function WarpGui:WhitelistClick( playerId, button )
	local currentWhiteList = self.whitelist[playerId]

	if currentWhiteList == 0 or not currentWhiteList then -- Currently none, set whitelisted
		self:SetWhitelist( playerId, 1, true )
	elseif currentWhiteList == 1 then -- Currently whitelisted, blacklisted
		self:SetWhitelist( playerId, 2, true )
	elseif currentWhiteList == 2 then -- Currently blacklisted, set none
		self:SetWhitelist( playerId, 0, true )
	end
end

function WarpGui:SetWhitelist( playerId, whitelisted, sendToServer )
	if self.whitelist[playerId] ~= whitelisted then self.whitelist[playerId] = whitelisted end

	local whitelistButton = self.whitelistButtons[playerId]
	if not whitelistButton then return end

	if whitelisted == 0 then
		whitelistButton:SetText( "-" )
		whitelistButton:SetTextSize( self.textSize )
	elseif whitelisted == 1 then
		whitelistButton:SetText( self.autotp_txt )
		whitelistButton:SetTextSize( self.textSize )
	elseif whitelisted == 2 then
		whitelistButton:SetText( self.blacklist_txt )
		whitelistButton:SetTextSize( self.textSize )
	end

	if sendToServer then
		Network:Send( "WarpSetWhitelist", {playerSteamId = LocalPlayer:GetSteamId().id, targetSteamId = playerId, whitelist = whitelisted} )
	end
end

function WarpGui:WarpReturnWhitelists( whitelists )
	for i = 1, #whitelists do
		local targetSteamId = whitelists[i].target_steam_id
		local whitelisted = whitelists[i].whitelist
		self:SetWhitelist( targetSteamId, tonumber(whitelisted), false )
	end
end

function WarpGui:WarpDoPoof( position )
    local effect = ClientEffect.Play( AssetLocation.Game, {effect_id = 250, position = position, angle = Angle()} )
end

--  Window management
function WarpGui:LocalPlayerInput( args )
	if args.input == Action.GuiPause then
		self:SetWindowVisible( false )

		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
		if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	end

	if self.actions[args.input] then
		return false
	end
end

function WarpGui:Focus()
	Input:SetEnabled( false )
end

function WarpGui:Blur()
	Input:SetEnabled( true )
end

function WarpGui:EscPressed()
	self:Blur()
	self:SetWindowVisible( false )

	if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
end

function WarpGui:OpenWarpGUI()
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

	self:SetWindowVisible( not self.windowShown )

	if self.windowShown then
		if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end
		if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
	else
		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end

		if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	end

	local effect = ClientEffect.Play(AssetLocation.Game, {
		effect_id = self.windowShown and 382 or 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

function WarpGui:CloseWarpGUI()
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

	if self.window:GetVisible() == true then
		self:SetWindowVisible( false )

		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
		if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	end
end

function WarpGui:PlayerJoin( args )
	local player = args.player

	self:AddPlayer( player )
end

function WarpGui:PlayerQuit( args )
	local player = args.player
	local playerId = tostring(player:GetSteamId().id)

	if not self.rows[playerId] then return end

	self.playerList:RemoveItem(self.rows[playerId])
	self.rows[playerId] = nil
end

function WarpGui:Render()
	local is_visible = Game:GetState() == GUIState.Game

	if self.window:GetVisible() ~= is_visible then
		self.window:SetVisible( is_visible )
	end

	Mouse:SetVisible( is_visible )
end

function WarpGui:SetWindowVisible( visible )
    if self.windowShown ~= visible then
		self.windowShown = visible
		self.window:SetVisible( visible )
		Mouse:SetVisible( visible )

		for p in Client:GetPlayers() do
			self.rows[ tostring( p:GetSteamId().id ) ]:SetTextColor( p:GetColor() )
		end

		if LocalPlayer:GetValue( "SystemFonts" ) then
			self.whitelistAllCheckbox:GetLabel():SetFont( AssetLocation.SystemFont, "Impact" )
			self.blacklistAllCheckbox:GetLabel():SetFont( AssetLocation.SystemFont, "Impact" )
		end
	end
end

warpGui = WarpGui()
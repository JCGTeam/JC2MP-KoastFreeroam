class 'ActionsMenu'

function ActionsMenu:__init()
	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
        self.title = "▧ Меню действий"
        self.healme_txt = "Вылечить себя"
        self.killme_txt = "Убить себя"
        self.clearinv_txt = "Очистить инвентарь"
        self.sendmoney_txt = "Отправить деньги"
        self.bloozing_txt = "Бухнуть"
        self.seat_txt = "Сесть"
        self.lezat_txt = "Лечь"
		self.vehicleboom_txt = "Взорвать транспорт"
		self.vehiclerepair_txt = "Починить транспорт (Не визуально)"
		self.sky_txt = "Взлететь в небо"
		self.down_txt = "Опуститься вниз"
		self.pvpblock = "Вы не можете использовать это во время боя!"
		self.novehicle = "Вы должны находиться за водительским местом!"
		self.noVipText = "У вас отсутствует VIP-статус :("
		self.healtxt = "++ Восстановление ++"
		self.healnotneededtxt = "Восстановление не требуется"
		self.ltext1 = "Игрок:"
		self.ltext2 = "Транспорт:"
	end

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

	self.permissions = {
		["Creator"] = true,
		["GlAdmin"] = true,
		["Admin"] = true,
		["AdminD"] = true,
		["ModerD"] = true,
		["Organizer"] = true,
		["Parther"] = true,
		["VIP"] = true
    }

	self.textSize = 15

    Events:Subscribe( "Lang", self, self.Lang )
    Events:Subscribe( "KeyUp", self, self.KeyUp )
	Events:Subscribe( "LocalPlayerWorldChange", self, self.LocalPlayerWorldChange )
end

function ActionsMenu:Lang()
    self.title = "▧ Actions Menu"
    self.healme_txt = "Heal yourself"
    self.killme_txt = "Kill yourself"
    self.clearinv_txt = "Clear inventory"
    self.sendmoney_txt = "Send money"
    self.bloozing_txt = "Drink"
    self.seat_txt = "Sit"
    self.lezat_txt = "Lie"
	self.vehicleboom_txt = "Blow up a vehicle"
	self.vehiclerepair_txt = "Repair a vehicle (Not visually)"
	self.sky_txt = "Take to the sky"
	self.down_txt = "Going down"
	self.pvpblock = "You cannot use this during combat!"
	self.novehicle = "You must be behind the driver's seat!"
	self.noVipText = "Required VIP status :("
	self.healtxt = "++ Healing ++"
	self.healnotneededtxt = "Healing is not required"
	self.ltext1 = "Player:"
	self.ltext2 = "Vehicle:"
end

function ActionsMenu:KeyUp( args )
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    if args.key == 86 then
        if self.window and self.window:GetVisible() then
            self:WindowClosed()
        else
            self:CreateActionsMenu()
            self.window:SetVisible( true )
            Mouse:SetVisible( true )

            if not self.LocalPlayerInputEvent then
                self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
                self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
            end

            Events:Fire( "CloseSendMoney" )

            local effect = ClientEffect.Play(AssetLocation.Game, {
                effect_id = 382,
    
                position = Camera:GetPosition(),
                angle = Angle()
            })
        end
    end
end

function ActionsMenu:LocalPlayerWorldChange()
	if self.window and self.window:GetVisible() then
		self:WindowClosed()
	end
end

function ActionsMenu:CreateActionButton( title, event, color )
	local actionBtn = Button.Create( self.scroll )
	actionBtn:SetText( title )
	actionBtn:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )
	if color then
		actionBtn:SetTextHoveredColor( color )
		actionBtn:SetTextPressedColor( color )
	end
    actionBtn:SetTextSize( self.textSize )
    actionBtn:SetHeight( 30 )
	actionBtn:SetDock( GwenPosition.Top )
    if LocalPlayer:GetValue( "SystemFonts" ) then
        actionBtn:SetFont( AssetLocation.SystemFont, "Impact" )
    end
	actionBtn:Subscribe( "Press", self, event )

	return actionBtn
end

function ActionsMenu:CreateActionsMenu()
    if self.window then return end

    self.window = Window.Create()
    self.window:SetSize( Vector2( Render:GetTextWidth( self.vehiclerepair_txt, self.textSize ) + 90, 430 ) )
    self.window:SetMinimumSize( Vector2( 300, 315 ) )
    self.window:SetPosition( Vector2( Render.Size.x - self.window:GetSize().x - 45, Render.Size.y / 2 - self.window:GetSize().y / 2 ) )
    self.window:SetVisible( false )
    self.window:SetTitle( self.title )
    self.window:Subscribe( "WindowClosed", self, self.WindowClosed )

	self.scroll = ScrollControl.Create( self.window )
    self.scroll:SetDock( GwenPosition.Fill )
	self.scroll:SetScrollable( false, true )

	self.SendMoneyBtn = self:CreateActionButton( self.sendmoney_txt, function() Events:Fire( "OpenSendMoneyMenu" ) self:WindowClosed() end )

	self.label1 = Label.Create( self.scroll )
    self.label1:SetDock( GwenPosition.Top )
	self.label1:SetText( self.ltext1 )
	self.label1:SetMargin( Vector2( 5, 5 ), Vector2( 5, 0 ) )
	self.label1:SizeToContents()

	self.HealMeBtn = self:CreateActionButton( self.healme_txt, self.Heal, Color.GreenYellow )
    self.KillMeBtn = self:CreateActionButton( self.killme_txt, function() Network:Send( "KillMe" ) self:WindowClosed() end )
    self.ClearInvBtn = self:CreateActionButton( self.clearinv_txt, function() Network:Send( "ClearInv") self:WindowClosed() end )
    self.BloozingBtn = self:CreateActionButton( self.bloozing_txt, function() Events:Fire( "BloozingStart" ) self:WindowClosed() end )
    self.SeatBtn = self:CreateActionButton( self.seat_txt, self.Seat )
    self.LezatBtn = self:CreateActionButton( self.lezat_txt, self.Sleep )

	self.label2 = Label.Create( self.scroll )
    self.label2:SetDock( GwenPosition.Top )
	self.label2:SetText( self.ltext2 )
	self.label2:SetMargin( Vector2( 5, 5 ), Vector2( 5, 0 ) )
	self.label2:SizeToContents()

	self.VehicleBoomBtn = self:CreateActionButton( self.vehicleboom_txt, self.VehicleBoom )
	self.VehicleRepairBtn = self:CreateActionButton( self.vehiclerepair_txt, self.VehicleRepair, Color.GreenYellow )

	self.label3 = Label.Create( self.scroll )
    self.label3:SetDock( GwenPosition.Top )
	self.label3:SetText( "VIP:" )
	self.label3:SetMargin( Vector2( 5, 5 ), Vector2( 5, 0 ) )
	self.label3:SizeToContents()

	self.SkyBtn = self:CreateActionButton( self.sky_txt, self.Sky )
	self.DownBtn = self:CreateActionButton( self.down_txt, self.Down )
end

function ActionsMenu:Heal()
	if LocalPlayer:GetValue( "PVPMode" ) then
		Events:Fire( "CastCenterText", { text = self.pvpblock, time = 6, color = Color.Red } )
	else
		if LocalPlayer:GetHealth() >= 1 then
			Events:Fire( "CastCenterText", { text = self.healnotneededtxt, time = 0.6, color = Color.White } )
		else
			Network:Send( "HealMe" )
			local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 19,
				sound_id = 30,
				position = LocalPlayer:GetPosition(),
				angle = Angle()
			})

			sound:SetParameter(0,1)
			Events:Fire( "CastCenterText", { text = self.healtxt, time = 0.3, color = Color.GreenYellow } )
		end
	end
	self:WindowClosed()
end

function ActionsMenu:Seat()
	if LocalPlayer:GetVehicle() then self:WindowClosed() return end

	local bs = LocalPlayer:GetBaseState()

	if bs == 6 then
		if not self.SeatInputEvent then
			self.SeatInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.SeatInput )
			self.CalcViewEvent = Events:Subscribe( "CalcView", self, self.CalcView )
		end
		LocalPlayer:SetBaseState( AnimationState.SIdlePassengerVehicle )
		self:WindowClosed()
	elseif bs == AnimationState.SIdlePassengerVehicle then
		LocalPlayer:SetBaseState( AnimationState.SUprightIdle )
		if self.SeatInputEvent then
			Events:Unsubscribe( self.SeatInputEvent ) self.SeatInputEvent = nil
			Events:Unsubscribe( self.CalcViewEvent ) self.CalcViewEvent = nil
		end
		self:WindowClosed()
	end
end

function ActionsMenu:SeatInput( args )
	if args.input == 39 or args.input == 40 or args.input == 41 or args.input == 42 then
		LocalPlayer:SetBaseState( AnimationState.SUprightIdle )
		Events:Unsubscribe( self.SeatInputEvent ) self.SeatInputEvent = nil
		Events:Unsubscribe( self.CalcViewEvent ) self.CalcViewEvent = nil
	end
end

function ActionsMenu:Sleep()
	local bs = LocalPlayer:GetBaseState()

	if bs == AnimationState.SUprightIdle then
		LocalPlayer:SetBaseState( AnimationState.SSwimDie )
	else
		if bs == AnimationState.SDead then
			LocalPlayer:SetBaseState( AnimationState.SUprightIdle )
		end
	end
	self:WindowClosed()
end

function ActionsMenu:VehicleBoom()
	local vehicle = LocalPlayer:GetVehicle()

	if vehicle and vehicle:GetDriver() == LocalPlayer then
		Network:Send( "VehicleBoom" )
	else
		Events:Fire( "CastCenterText", { text = self.novehicle, time = 3, color = Color.Red } )
	end
	self:WindowClosed()
end

function ActionsMenu:VehicleRepair()
	local vehicle = LocalPlayer:GetVehicle()

	if vehicle and vehicle:GetDriver() == LocalPlayer then
		if LocalPlayer:GetValue( "PVPMode" ) then
			Events:Fire( "CastCenterText", { text = self.pvpblock, time = 6, color = Color.Red } )
		else
			if vehicle:GetHealth() >= 1 then
				Events:Fire( "CastCenterText", { text = self.healnotneededtxt, time = 0.6, color = Color.White } )
			else
				Network:Send( "VehicleRepair" )

				local sound = ClientSound.Create(AssetLocation.Game, {
					bank_id = 19,
					sound_id = 30,
					position = LocalPlayer:GetPosition(),
					angle = Angle()
				})

				sound:SetParameter(0,1)
				Events:Fire( "CastCenterText", { text = self.healtxt, time = 0.3, color = Color.GreenYellow } )
			end
		end
	else
		Events:Fire( "CastCenterText", { text = self.novehicle, time = 3, color = Color.Red } )
	end
	self:WindowClosed()
end

function ActionsMenu:Sky()
	local gettag = LocalPlayer:GetValue( "Tag" )

	if self.permissions[gettag] then
		Network:Send( "Sky" )
	else
		Events:Fire( "CastCenterText", { text = self.noVipText, time = 3, color = Color.Red } )
	end
	self:WindowClosed()
end

function ActionsMenu:Down()
	local gettag = LocalPlayer:GetValue( "Tag" )

	if self.permissions[gettag] then
		Network:Send( "Down" )
	else
		Events:Fire( "CastCenterText", { text = self.noVipText, time = 3, color = Color.Red } )
	end
	self:WindowClosed()
end

function ActionsMenu:LocalPlayerInput( args )
    if self.actions[args.input] then
        return false
    end

    if self.window:GetVisible() == true then
		if args.input == Action.GuiPause then
            self:WindowClosed()
        end
    end
end

function ActionsMenu:Render()
	local is_visible = Game:GetState() == GUIState.Game

	if self.window:GetVisible() ~= is_visible then
		self.window:SetVisible( is_visible )
	end

	Mouse:SetVisible( is_visible )
end

function ActionsMenu:WindowClosed()
    self.window:SetVisible( false )
	Mouse:SetVisible( false )

    if self.LocalPlayerInputEvent then
        Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil
        Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil
    end

    local effect = ClientEffect.Play(AssetLocation.Game, {
        effect_id = 383,

        position = Camera:GetPosition(),
        angle = Angle()
    })
end

function ActionsMenu:Lezat()
	local bs = LocalPlayer:GetBaseState()

	if bs == AnimationState.SUprightIdle then
		LocalPlayer:SetBaseState( AnimationState.SSwimDie )
	else
		if bs == AnimationState.SDead then
			LocalPlayer:SetBaseState( AnimationState.SUprightIdle )
		end
	end
    self:WindowClosed()
end

function ActionsMenu:SeatInput( args )
	if args.input == 39 or args.input == 40 or args.input == 41 or args.input == 42 then
		LocalPlayer:SetBaseState( AnimationState.SUprightIdle )
		Events:Unsubscribe( self.SeatInputEvent ) self.SeatInputEvent = nil
		Events:Unsubscribe( self.CalcViewEvent ) self.CalcViewEvent = nil
	end
end

function ActionsMenu:CalcView()
	Camera:SetPosition( Camera:GetPosition() - Vector3( 0, 1, 0 ) )
end

actionsmenu = ActionsMenu()
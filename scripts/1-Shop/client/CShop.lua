function Shop:__init()
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
		[16] = true,
		[114] = true,
		[115] = true,
		[117] = true,
		[51] = true,
		[52] = true,
		[116] = true
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

	self.cooldown = 5
	self.cooltime = 0

	self.active = false
	self.home = true
	self.unit = 0

	self.BuyMenuLineColor = Color( 155, 205, 255 )

	self.tone1 = Color.White
	self.tone2 = Color.White
	self.pcolor = LocalPlayer:GetColor()

	self.tone1Picker = nil
	self.tone2Picker = nil

	self.HomeImage = Image.Create( AssetLocation.Resource, "HomeImage" )

	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.5, 0.63 ) )
	self.window:SetPositionRel( Vector2( 0.7, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetVisible( self.active )
	self.window:SetTitle( "▧ Чёрный рынок" )
	self.window:Subscribe( "WindowClosed", self, self.Close )

	self.tab_control = TabControl.Create( self.window )
	self.tab_control:SetDock( GwenPosition.Fill )

	self.tab_control:Subscribe( "TabSwitch", function()
		if self.tab_control:GetCurrentTab():GetText() == "Транспорт" then
			self.decalLabel:SetVisible( true )
		else
			self.decalLabel:SetVisible( false )
			self.vehColorWindow:SetVisible( false )
		end

		if self.tab_control:GetCurrentTab():GetText() == "Точки дома" then
			self.buy_button:SetEnabled( false )
		else
			self.buy_button:SetEnabled( true )
		end
	end)

	local base1 = BaseWindow.Create( self.window )
	base1:SetDock( GwenPosition.Bottom )
	base1:SetSize( Vector2( self.window:GetSize().x, 32 ) )

	local background = Rectangle.Create( base1 )
	background:SetSizeRel( Vector2( 0.5, 1.0 ) )
	background:SetDock( GwenPosition.Fill )
	background:SetColor( Color( 0, 0, 0, 100 ) )

	self.buy_button = Button.Create( base1 )
	self.buy_button:SetWidthAutoRel( 0.5 )
	self.buy_button:SetText( "Взять" )
	local btnColor = Color( 185, 215, 255 )
	self.buy_button:SetTextHoveredColor( btnColor )
	self.buy_button:SetTextPressedColor( btnColor )
	self.buy_button:SetTextSize( 15 )
	self.buy_button:SetHeight( 30 )
	self.buy_button:SetDock( GwenPosition.Bottom )
	self.buy_button:Subscribe( "Press", self, self.Buy )

	self.decalLabel = Label.Create( self.window )
	self.decalLabel:SetDock( GwenPosition.Bottom )
	self.decalLabel:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )
	self.decalLabel:SetHeight( 20 )

	local decal = ComboBox.Create( self.decalLabel )
	decal:SetDock( GwenPosition.Right )

	self.decalText = Label.Create( self.decalLabel )
	self.decalText:SetDock( GwenPosition.Right )
	self.decalText:SetMargin( Vector2.Zero, Vector2( 2, 0 ) )
	self.decalText:SetAlignment( GwenPosition.Center )

	self.vehColorText = Label.Create( self.decalLabel )
	self.vehColorText:SetDock( GwenPosition.Left )
	self.vehColorText:SetMargin( Vector2.Zero, Vector2( 2, 0 ) )
	self.vehColorText:SetAlignment( GwenPosition.Center )

	local vehColor = Label.Create( self.decalLabel )
	vehColor:SetDock( GwenPosition.Left )
	vehColor:SetWidth( 60 )

	local vehColorsPreview = Label.Create( vehColor )
	vehColorsPreview:SetDock( GwenPosition.Fill )

	self.vehColorPreview = Rectangle.Create( vehColorsPreview )
	self.vehColorPreview:SetDock( GwenPosition.Top )
	self.vehColorPreview:SetColor( self.tone1 )

	self.vehColor2Preview = Rectangle.Create( vehColorsPreview )
	self.vehColor2Preview:SetDock( GwenPosition.Bottom )
	self.vehColor2Preview:SetColor( self.tone2 )

	local vehColorArrow = Label.Create( vehColor )
	vehColorArrow:SetDock( GwenPosition.Right )
	vehColorArrow:SetAlignment( GwenPosition.Center )
	vehColorArrow:SetMargin( Vector2( 4, 0 ), Vector2( 4, 0 ) )
	vehColorArrow:SetText( ">" )
	vehColorArrow:SizeToContents()

	local vehColorButton = MenuItem.Create( vehColor )
	vehColorButton:SetDock( GwenPosition.None )
	vehColorButton:Subscribe( "Press", function() self.vehColorWindow:SetSize( Vector2( 500, 350 ) ) self.vehColorWindow:SetPosition( Vector2( Mouse:GetPosition().x - self.vehColorWindow:GetSize().x / 2, Mouse:GetPosition().y - self.vehColorWindow:GetSize().y - 15 ) ) self.vehColorWindow:SetVisible( not self.vehColorWindow:GetVisible() ) end )

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.vehicleColor_txt = "Цвет транспорта"
		self.save_txt = "Сохранить"
		self.noVipText = "У вас отсувствует VIP-статус :("
		self.home_txt = "Дом"
		self.sethomebutton_txt = "Установить точку дома здесь ( $500 )"
		self.spawnonhomepoint_txt = "Появляться на точке дома после подключения к серверу"
		self.gohome_txt = "Переместиться домой »"
		self.pvpblock = "Вы не можете использовать это во время боя!"
		self.dlcwarning_txt = "ВНИМАНИЕ! DLC-контент не сможет наносить урон и не будет виден игрокам, которые его не имеют."
		self.w = "Пожалуйста, подождите "
		self.ws = " секунд."

		if self.window then
			self.vehColorText:SetText( self.vehicleColor_txt .. ": " )
			self.vehColorText:SizeToContents()

			self.decalText:SetText( "Декаль: " )
			self.decalText:SizeToContents()

			self.decalNames = { "По умолчанию", "Панау", "Японцы", "Жнецы", "Тараканы", "Улары", "Такси" }
		end
	end

	for i, v in ipairs( self.decalNames ) do
		decal:AddItem( v, tostring( i ) )
	end

	decal:SetWidth( Render:GetTextWidth( "По умолчанию" ) )
	decal:Subscribe( "Selection", function() self.unit = tonumber( decal:GetSelectedItem():GetName() ) end )

	self.categories = {}

	self:CreateItems()

	self.sort_dir = false
	self.last_column = -1

	self.player_hats = {}
	self.player_coverings = {}
	self.player_hairs = {}
	self.player_faces = {}
	self.player_necks = {}
	self.player_backs = {}
	self.player_torso = {}
	self.player_righthand = {}
	self.player_lefthand = {}
	self.player_legs = {}
	self.player_rightfoot = {}
	self.player_leftfoot = {}

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "OpenShop", self, self.OpenShop )
	Events:Subscribe( "CloseShop", self, self.CloseShop )

	Events:Subscribe( "Render", self, self.RenderAppearanceHat )
	Events:Subscribe( "PlayerNetworkValueChange", self, self.PlayerValueChangeAppearance )
	Events:Subscribe( "EntitySpawn", self, self.EntitySpawnAppearance )
	Events:Subscribe( "EntityDespawn", self, self.EntityDespawnAppearance )
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoadAppearance )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnloadAppearance )
	Events:Subscribe( "RestoreParachute", self, self.RestoreParachute )

	Network:Subscribe( "Shop", self, self.Shop )
	Network:Subscribe( "PlayerFired", self, self.Sound )
	Network:Subscribe( "NoVipText", self, self.NoVipText )
	Network:Subscribe( "Parachute", self, self.Parachute )

	Network:Subscribe( "BuyMenuSavedColor", self, self.SavedColor )
end

function Shop:Lang()
	if self.buy_button then
		self.buy_button:SetText( "Get" )
	end

	self.vehicleColor_txt = "Vehicle color"
	self.save_txt = "Save"
	self.noVipText = "Needed VIP status not found."
	self.home_txt = "Home"
	self.sethomebutton_txt = "Set home point here ( $500 )"
	self.spawnonhomepoint_txt = "Spawn on home point after connecting to the server"
	self.gohome_txt = "Go home »"
	self.pvpblock = "You cannot use this during combat!"
	self.dlcwarning_txt = "WARNING: DLC content will not be able to deal damage and will not be visible to players who do not have it."
	self.w = "Please, wait "
	self.ws = " seconds."

	if self.window then
		self.window:SetTitle( "▧ Black Market" )
		self.vehColorText:SetText( self.vehicleColor_txt .. ": " )
		self.vehColorText:SizeToContents()

		self.decalText:SetText( "Decal: " )
		self.decalText:SizeToContents()

		self.decalNames = { "Default", "Panau", "Japan", "Reapers", "Roaches", "Ular Boys", "Taxi" }
	end
end

function Shop:RenderAppearanceHat()
	for p in Client:GetStreamedPlayers() do
		self:MoveAppearance(p)
	end
	self:MoveAppearance(LocalPlayer)
end

function Shop:CreateAppearance( player )
	self:RemoveAppearance( player )

	local pId = player:GetId()

	local hatModel = player:GetValue("AppearanceHat")
	local coveringModel = player:GetValue("AppearanceCovering")
	local hairModel = player:GetValue("AppearanceHair")
	local faceModel = player:GetValue("AppearanceFace")
	local neckModel = player:GetValue("AppearanceNeck")
	local backModel = player:GetValue("AppearanceBack")
	local torsoModel = player:GetValue("AppearanceTorso")
	local righthandModel = player:GetValue("AppearanceRightHand")
	local lefthandModel = player:GetValue("AppearanceLeftHand")
	local legsModel = player:GetValue("AppearanceLegs")
	local rightfootModel = player:GetValue("AppearanceRightFoot")
	local leftfootModel = player:GetValue("AppearanceLeftFoot")

	if hatModel ~= nil and string.len(hatModel) >= 10 then
			self.player_hats[pId] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Head"),
			angle = player:GetBoneAngle("ragdoll_Head"),
			model = hatModel
			})
	else
		if self.player_hats[pId] ~= nil then
			if IsValid( self.player_hats[pId] ) then
				self.player_hats[pId]:Remove()
			end
			self.player_hats[pId] = nil
		end
	end
	if coveringModel ~= nil and string.len(coveringModel) >= 10 then
			self.player_coverings[pId] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Head"),
			angle = player:GetBoneAngle("ragdoll_Head"),
			model = coveringModel
			})
	else
		if self.player_coverings[pId] ~= nil then
			if IsValid( self.player_coverings[pId] ) then
				self.player_coverings[pId]:Remove()
			end
			self.player_coverings[pId] = nil
		end
	end
	if hairModel ~= nil and string.len(hairModel) >= 10 then
		self.player_hairs[pId] = ClientStaticObject.Create({
		position = player:GetBonePosition("ragdoll_Head"),
		angle = player:GetBoneAngle("ragdoll_Head"),
		model = hairModel
		})
	else
		if self.player_hairs[pId] ~= nil then
			if IsValid( self.player_hairs[pId] ) then
				self.player_hairs[pId]:Remove()
			end
			self.player_hairs[pId] = nil
		end
	end
	if faceModel ~= nil and string.len(faceModel) >= 10 then
			self.player_faces[pId] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Head"),
			angle = player:GetBoneAngle("ragdoll_Head"),
			model = faceModel
			})
	else
		if self.player_faces[pId] ~= nil then
			if IsValid( self.player_faces[pId] ) then
				self.player_faces[pId]:Remove()
			end
			self.player_faces[pId] = nil
		end
	end
	if neckModel ~= nil and string.len(neckModel) >= 10 then
			self.player_necks[pId] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Head"),
			angle = player:GetBoneAngle("ragdoll_Head"),
			model = neckModel
			})
	else
		if self.player_necks[pId] ~= nil then
			if IsValid( self.player_necks[pId] ) then
				self.player_necks[pId]:Remove()
			end
			self.player_necks[pId] = nil
		end
	end
	if backModel ~= nil and string.len(backModel) >= 10 then
			self.player_backs[pId] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Spine1"),
			angle = player:GetBoneAngle("ragdoll_Spine1"),
			model = backModel
			})
	else
		if self.player_backs[pId] ~= nil then
			if IsValid( self.player_backs[pId] ) then
				self.player_backs[pId]:Remove()
			end
			self.player_backs[pId] = nil
		end
	end
	if torsoModel ~= nil and string.len(torsoModel) >= 10 then
			self.player_torso[pId] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Spine1"),
			angle = player:GetBoneAngle("ragdoll_Spine1"),
			model = torsoModel
			})
	else
		if self.player_torso[pId] ~= nil then
			if IsValid( self.player_torso[pId] ) then
				self.player_torso[pId]:Remove()
			end
			self.player_torso[pId] = nil
		end
	end
	if righthandModel ~= nil and string.len(righthandModel) >= 10 then
			self.player_righthand[pId] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_RightForeArm"),
			angle = player:GetBoneAngle("ragdoll_RightForeArm"),
			model = righthandModel
			})
	else
		if self.player_righthand[pId] ~= nil then
			if IsValid( self.player_righthand[pId] ) then
				self.player_righthand[pId]:Remove()
			end
			self.player_righthand[pId] = nil
		end
	end
	if lefthandModel ~= nil and string.len(lefthandModel) >= 10 then
		self.player_lefthand[pId] = ClientStaticObject.Create({
		position = player:GetBonePosition("ragdoll_LeftForeArm"),
		angle = player:GetBoneAngle("ragdoll_LeftForeArm"),
		model = lefthandModel
		})
	else
		if self.player_lefthand[pId] ~= nil then
			if IsValid( self.player_lefthand[pId] ) then
				self.player_lefthand[pId]:Remove()
			end
			self.player_lefthand[pId] = nil
		end
	end
	if legsModel ~= nil and string.len(legsModel) >= 10 then
			self.player_legs[pId] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Hips"),
			angle = player:GetBoneAngle("ragdoll_Hips"),
			model = legsModel
			})
	else
		if self.player_legs[pId] ~= nil then
			if IsValid( self.player_legs[pId] ) then
				self.player_legs[pId]:Remove()
			end
			self.player_legs[pId] = nil
		end
	end
	if rightfootModel ~= nil and string.len(rightfootModel) >= 10 then
			self.player_rightfoot[pId] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_RightFoot"),
			angle = player:GetBoneAngle("ragdoll_RightFoot"),
			model = rightfootModel
			})
	else
		if self.player_rightfoot[pId] ~= nil then
			if IsValid( self.player_rightfoot[pId] ) then
				self.player_rightfoot[pId]:Remove()
			end
			self.player_rightfoot[pId] = nil
		end
	end
	if leftfootModel ~= nil and string.len(leftfootModel) >= 10 then
			self.player_leftfoot[pId] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_LeftFoot"),
			angle = player:GetBoneAngle("ragdoll_LeftFoot"),
			model = leftfootModel
			})
	else
		if self.player_leftfoot[pId] ~= nil then
			if IsValid( self.player_leftfoot[pId] ) then
				self.player_leftfoot[pId]:Remove()
			end
			self.player_leftfoot[pId] = nil
		end
	end
end

function Shop:RemoveAppearance( player )
	local pId = player:GetId()

	if self.player_hats[pId] ~= nil then
		if IsValid( self.player_hats[pId] ) then
			self.player_hats[pId]:Remove()
		end
		self.player_hats[pId] = nil
	end
	if self.player_coverings[pId] ~= nil then
		if IsValid( self.player_coverings[pId] ) then
			self.player_coverings[pId]:Remove()
		end
		self.player_coverings[pId] = nil
	end
	if self.player_hairs[pId] ~= nil then
		if IsValid( self.player_hairs[pId] ) then
			self.player_hairs[pId]:Remove()
		end
		self.player_hairs[pId] = nil
	end
	if self.player_faces[pId] ~= nil then
		if IsValid( self.player_faces[pId] ) then
			self.player_faces[pId]:Remove()
		end
		self.player_faces[pId] = nil
	end
	if self.player_necks[pId] ~= nil then
		if IsValid( self.player_necks[pId] ) then
			self.player_necks[pId]:Remove()
		end
		self.player_necks[pId] = nil
	end
	if self.player_backs[pId] ~= nil then
		if IsValid( self.player_backs[pId] ) then
			self.player_backs[pId]:Remove()
		end
		self.player_backs[pId] = nil
	end
	
	if self.player_torso[pId] ~= nil then
		if IsValid( self.player_torso[pId] ) then
			self.player_torso[pId]:Remove()
		end
		self.player_torso[pId] = nil
	end
	if self.player_righthand[pId] ~= nil then
		if IsValid( self.player_righthand[pId] ) then
			self.player_righthand[pId]:Remove()
		end
		self.player_righthand[pId] = nil
	end
	if self.player_lefthand[pId] ~= nil then
		if IsValid( self.player_lefthand[pId] ) then
			self.player_lefthand[pId]:Remove()
		end
		self.player_lefthand[pId] = nil
	end
	if self.player_legs[pId] ~= nil then
		if IsValid( self.player_legs[pId] ) then
			self.player_legs[pId]:Remove()
		end
		self.player_legs[pId] = nil
	end
	if self.player_rightfoot[pId] ~= nil then
		if IsValid( self.player_rightfoot[pId] ) then
			self.player_rightfoot[pId]:Remove()
		end
		self.player_rightfoot[pId] = nil
	end
	if self.player_leftfoot[pId] ~= nil then
		if IsValid( self.player_leftfoot[pId] ) then
			self.player_leftfoot[pId]:Remove()
		end
		self.player_leftfoot[pId] = nil
	end
end

function Shop:MoveAppearance( player )
	if IsValid( player ) then
		local pId = player:GetId()

		local hat = self.player_hats[pId]
		local covering = self.player_coverings[pId]
		local hair = self.player_hairs[pId]
		local face = self.player_faces[pId]
		local neck = self.player_necks[pId]
		local back = self.player_backs[pId]
		local torso = self.player_torso[pId]
		local righthand = self.player_righthand[pId]
		local lefthand = self.player_lefthand[pId]
		local legs = self.player_legs[pId]
		local rightfoot = self.player_rightfoot[pId]
		local leftfoot = self.player_leftfoot[pId]

		if hat ~= nil and IsValid(hat) then
			hat:SetAngle( player:GetBoneAngle( "ragdoll_Head" ) )
			local AppearanceOffset = hat:GetAngle() * Vector3( 0, 1.62, .03 )
			hat:SetPosition( player:GetBonePosition( "ragdoll_Head" ) - AppearanceOffset ) 
		end
		if covering ~= nil and IsValid(covering) then
			covering:SetAngle( player:GetBoneAngle( "ragdoll_Head" ) )
			local AppearanceOffset = covering:GetAngle() * Vector3( 0, 1.62, .03 )
			covering:SetPosition( player:GetBonePosition( "ragdoll_Head" ) - AppearanceOffset ) 
		end
		if hair ~= nil and IsValid(hair) then
			hair:SetAngle( player:GetBoneAngle( "ragdoll_Head" ) )
			local AppearanceOffset = hair:GetAngle() * Vector3( 0, 1.61, .03 )
			hair:SetPosition( player:GetBonePosition( "ragdoll_Head" ) - AppearanceOffset ) 
		end
		if face ~= nil and IsValid(face) then
			face:SetAngle( player:GetBoneAngle( "ragdoll_Head" ))
			local AppearanceOffset = face:GetAngle() * Vector3( 0, 1.65, .0375 )
			face:SetPosition( player:GetBonePosition( "ragdoll_Head" ) - AppearanceOffset ) 
		end
		if neck ~= nil and IsValid(neck) then
			neck:SetAngle( player:GetBoneAngle( "ragdoll_Head" ) )
			local AppearanceOffset = neck:GetAngle() * Vector3( 0, 1.54, .065 )
			neck:SetPosition( player:GetBonePosition( "ragdoll_Head" ) - AppearanceOffset ) 
		end
		if back ~= nil and IsValid(back) then
			back:SetAngle( player:GetBoneAngle( "ragdoll_Spine1" ) )
			local AppearanceOffset = back:GetAngle() * Vector3( 0, 1.225, 0.05 )
			back:SetPosition( player:GetBonePosition( "ragdoll_Spine1" ) - AppearanceOffset ) 
		end

		if torso ~= nil and IsValid( torso ) then
			torso:SetAngle( player:GetBoneAngle( "ragdoll_Spine1" ) )
			local AppearanceOffset = torso:GetAngle() * Vector3( 0, 1.225, 0.05 )
			torso:SetPosition( player:GetBonePosition( "ragdoll_Spine1" ) - AppearanceOffset ) 
		end
		if righthand ~= nil and IsValid( righthand ) then
			righthand:SetAngle( player:GetBoneAngle( "ragdoll_RightForeArm" ) )
			local AppearanceOffset = righthand:GetAngle() * Vector3.Zero
			righthand:SetPosition( player:GetBonePosition( "ragdoll_RightForeArm" ) - AppearanceOffset ) 
		end
		if lefthand ~= nil and IsValid( lefthand ) then
			lefthand:SetAngle( player:GetBoneAngle( "ragdoll_LeftForeArm" ) )
			local AppearanceOffset = lefthand:GetAngle() * Vector3.Zero
			lefthand:SetPosition( player:GetBonePosition( "ragdoll_LeftForeArm" ) - AppearanceOffset ) 
		end
		if legs ~= nil and IsValid( legs ) then
			legs:SetAngle( player:GetBoneAngle( "ragdoll_Hips" ) )
			local AppearanceOffset = legs:GetAngle() * Vector3.Zero
			legs:SetPosition( player:GetBonePosition( "ragdoll_Hips" ) - AppearanceOffset ) 
		end
		if rightfoot ~= nil and IsValid( rightfoot ) then
			rightfoot:SetAngle( player:GetBoneAngle( "ragdoll_RightFoot" ) )
			local AppearanceOffset = rightfoot:GetAngle() * Vector3.Zero
			rightfoot:SetPosition( player:GetBonePosition( "ragdoll_RightFoot" ) - AppearanceOffset ) 
		end
		if leftfoot ~= nil and IsValid( leftfoot ) then
			leftfoot:SetAngle( player:GetBoneAngle( "ragdoll_LeftFoot" ) )
			local AppearanceOffset = leftfoot:GetAngle() * Vector3.Zero
			leftfoot:SetPosition( player:GetBonePosition( "ragdoll_LeftFoot" ) - AppearanceOffset ) 
		end
	end
end

function Shop:PlayerValueChangeAppearance( args )
	if args.key == "AppearanceHat" or 
		args.key == "AppearanceCovering" or
		args.key == "AppearanceHair" or
		args.key == "AppearanceFace" or
		args.key == "AppearanceNeck" or
		args.key == "AppearanceBack" or
		args.key == "AppearanceTorso" or
		args.key == "AppearanceRightHand" or
		args.key == "AppearanceLeftHand" or
		args.key == "AppearanceLegs" or
		args.key == "AppearanceRightFoot" or
		args.key == "AppearanceLeftFoot" then
		self:CreateAppearance(args.player)
	end
end

function Shop:EntitySpawnAppearance( args )
	if args.entity.__type == "Player" then
		self:CreateAppearance(args.entity)
	end
end

function Shop:EntityDespawnAppearance( args )
	if args.entity.__type == "Player" then
		self:RemoveAppearance(args.entity)
	end
end

function Shop:ModuleLoadAppearance()
	for p in Client:GetStreamedPlayers() do
		self:CreateAppearance(p)
	end
	self:CreateAppearance(LocalPlayer)
end

function Shop:ModuleUnloadAppearance()
	for k, v in pairs(self.player_hats) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(self.player_coverings) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(self.player_hairs) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(self.player_faces) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(self.player_necks) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(self.player_backs) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(self.player_torso) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(self.player_righthand) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(self.player_lefthand) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(self.player_legs) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(self.player_rightfoot) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(self.player_leftfoot) do
		if IsValid(v) then
			v:Remove()
		end
	end
end

function Shop:SavedColor( args )
	if self.tone1Picker == nil or self.tone2Picker == nil then return end

	local tone1 = args.tone1
	local tone2 = args.tone2

	self.tone1 = tone1
	self.tone2 = tone2

	self.tone1Picker:SetColor( self.tone1 )
	self.tone2Picker:SetColor( self.tone2 )

	self.vehColorPreview:SetColor( self.tone1 )
	self.vehColor2Preview:SetColor( self.tone2 )
end

function Shop:CreateCategory( category_name )
	local t = {}
	t.window = BaseWindow.Create( self.window )
	t.window:SetDock( GwenPosition.Fill )
	t.button = self.tab_control:AddPage( category_name, t.window )

	t.tab_control = TabControl.Create( t.window )
	t.tab_control:SetDock( GwenPosition.Fill )

	t.categories = {}

	self.categories[category_name] = t

    return t
end

function Shop:SortFunction( column, a, b )
	if column ~= -1 then
		self.last_column = column
	elseif column == -1 and self.last_column ~= -1 then
		column = self.last_column
	else
		column = 0
	end

	local a_value = a:GetCellText( column )
	local b_value = b:GetCellText( column )

	if column == 1 then
		local a_num = tonumber( a_value )
		local b_num = tonumber( b_value )

		if a_num ~= nil and b_num ~= nil then
			a_value = a_num
			b_value = b_num
		end
	end

	if self.sort_dir then
		return a_value > b_value
	else
		return a_value < b_value
	end
end

function Shop:CreateSubCategory( category, subcategory_name )
	local t = {}
	t.window = BaseWindow.Create( self.window )
	t.window:SetDock( GwenPosition.Fill )
	t.button = category.tab_control:AddPage( subcategory_name, t.window )

	t.listbox = SortedList.Create( t.window )
	t.listbox:SetDock( GwenPosition.Fill )
	t.listbox:AddColumn( subcategory_name .. ":" )
	t.listbox:SetSort( self, self.SortFunction )
	t.listbox:Subscribe( "SortPress",
		function( button )
			self.sort_dir = not self.sort_dir
		end )

	category.categories[subcategory_name] = t

	if LocalPlayer:GetValue( "DLCWarning" ) then
		if subcategory_name == "DLC" or subcategory_name == "Правая рука" or subcategory_name == "Левая рука" or subcategory_name == "Основное" or subcategory_name == "Парашюты" then
			local dlc_warning = Label.Create( t.window )
			dlc_warning:SetText( self.dlcwarning_txt )
			dlc_warning:SetTextColor( Color( 200, 200, 200 ) )
			dlc_warning:SetDock( GwenPosition.Top )
			dlc_warning:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )
			dlc_warning:SizeToContents()
		end
	end

	return t
end

function Shop:LoadCategories()
	if self.categoriesloaded then return end
	self.categoriesloaded = true

	for category_id, category in ipairs( self.items ) do
		local category_table = self:CreateCategory( self.id_types[category_id] )

		for _, subcategory_name in ipairs( category[1] ) do
			local subcategory = category[subcategory_name]

			local subcategory_table = self:CreateSubCategory( category_table, subcategory_name )

			local item_id = 0

			for _, entry in pairs( subcategory ) do
				item_id = item_id + 1
				local row = subcategory_table.listbox:AddItem( entry:GetName() )
				row:SetTextColor( self.BuyMenuLineColor )
				row:SetDataNumber( "id", item_id )

				entry:SetListboxItem( row )
			end
		end
	end

	self.vehColorWindow = Window.Create()
	self.vehColorWindow:SetVisible( false )
	--self.vehColorWindow:SetClosable( false )
	self.vehColorWindow:SetTitle( self.vehicleColor_txt )

	local tab_control = TabControl.Create( self.vehColorWindow )
	tab_control:SetDock( GwenPosition.Fill )
	tab_control:SetMargin( Vector2( 1, 0 ), Vector2( 1, 5 ) )

	self.tone1Picker = HSVColorPicker.Create()
	tab_control:AddPage( "▧ Тон 1", self.tone1Picker )
	self.tone1Picker:SetDock( GwenPosition.Fill )

	self.tone1Picker:Subscribe( "ColorChanged", function()
		self.tone1 = self.tone1Picker:GetColor()
		self.colorChanged = true
	end )

	self.tone1Picker:SetColor( Color.White )
	self.tone1 = self.tone1Picker:GetColor()

	self.tone2Picker = HSVColorPicker.Create()
	tab_control:AddPage( "▨ Тон 2", self.tone2Picker )
	self.tone2Picker:SetDock( GwenPosition.Fill )

	self.tone2Picker:Subscribe( "ColorChanged", function()
		self.tone2 = self.tone2Picker:GetColor() 
		self.colorChanged = true
	end )

	self.tone2Picker:SetColor( Color.White )
	self.tone2 = self.tone2Picker:GetColor()

	local lpColor = LocalPlayer:GetColor()
	self.tone1Picker:SetColor( lpColor )
	self.tone2Picker:SetColor( lpColor )

	local setColorBtn = Button.Create( self.vehColorWindow )
	setColorBtn:SetText( self.save_txt )
	setColorBtn:SetHeight( 30 )
	setColorBtn:SetDock( GwenPosition.Bottom )
	setColorBtn:Subscribe( "Press", function()
		self.vehColorPreview:SetColor( self.tone1 )
		self.vehColor2Preview:SetColor( self.tone2 )

		Game:FireEvent( "bm.savecheckpoint.go" )

		self.vehColorWindow:SetVisible( false )
	end )

	local home = self:CreateCategory( "Точки дома" )

	local window = ScrollControl.Create( home.tab_control )
	window:SetDock( GwenPosition.Fill )
	window:SetMargin( Vector2( 10, 10 ), Vector2( 10, 10 ) )

	local textSize = 12

	local top = Label.Create( window )
	top:SetDock( GwenPosition.Top )
	top:SetHeight( Render:GetTextHeight( self.sethomebutton_txt, textSize ) + 18 )

	self.texter = Label.Create( top )
	self.texter:SetText( self.home_txt .. " 1: " )
	self.texter:SetDock( GwenPosition.Left )
	self.texter:SetAlignment( GwenPosition.Center )
	self.texter:SizeToContents()

	self.buttonHB = Button.Create( top )
	self.buttonHB:SetText( self.sethomebutton_txt )
	local btnColor = Color.GreenYellow
	self.buttonHB:SetTextHoveredColor( btnColor )
	self.buttonHB:SetTextPressedColor( btnColor )
	self.buttonHB:SetTextSize( textSize )
	self.buttonHB:SetDock( GwenPosition.Left )
	local padding = Vector2( 3, 0 )
	self.buttonHB:SetMargin( padding, padding )
	self.buttonHB:SetWidth( Render:GetTextWidth( self.sethomebutton_txt, textSize ) + 30 )
	self.buttonHB:Subscribe( "Press", self, self.BuyHome )

	self.toggleH = Button.Create( top )
	self.toggleH:SetText( ">" )
	self.toggleH:SetWidth( 60 )
	self.toggleH:SetTextSize( 15 )
	self.toggleH:SetDock( GwenPosition.Left )
	self.toggleH:Subscribe( "Press", self, self.ToggleHome )

	local spawninhome = LabeledCheckBox.Create( window )
	spawninhome:GetLabel():SetText( self.spawnonhomepoint_txt )
	spawninhome:SetWidth( 350 )
	spawninhome:SetDock( GwenPosition.Top )
	local padding = Vector2( 0, 10 )
	spawninhome:SetMargin( padding, padding )
	spawninhome:GetCheckBox():SetChecked( self:NumberToBoolean( LocalPlayer:GetValue( "SpawnInHome" ) ) )
	spawninhome:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateSpawnInHome" ) end )

	local textWidth = Render:GetTextWidth( "A", 19 )
	local height = textWidth * 16

	local home_img = ImagePanel.Create( window )
	home_img:SetImage( self.HomeImage )
	home_img:SetPosition( Vector2( 5, spawninhome:GetSize().y + Render:GetTextHeight( self.toggleH:GetText(), self.toggleH:GetTextSize() ) + 35 ) )
	home_img:SetSize( Vector2( textWidth * 27, height ) )

	self.Home_button = MenuItem.Create( window )
	self.Home_button:SetPosition( home_img:GetPosition() )
	self.Home_button:SetSize( Vector2( home_img:GetSize().x, height * 1.25 ) )
	self.Home_button:SetText( self.gohome_txt )
	local btnColor = Color.GreenYellow
	self.Home_button:SetTextHoveredColor( btnColor )
	self.Home_button:SetTextPressedColor( btnColor )
	self.Home_button:SetTextPadding( Vector2( 0, height ), Vector2.Zero )
	self.Home_button:SetTextSize( 19 )
	self.Home_button:Subscribe( "Press", self, self.GoHome )

	Network:Send( "BuyMenuGetSaveColor" )
end

function Shop:NumberToBoolean( value )
	return value == 1 and true or value == 0 and false
end

function Shop:CalcView()
	Camera:SetPosition( Camera:GetPosition() - Vector3( 0, 1, 0 ) )
end

function Shop:ToggleHome()
	if self.home then
		self.home = false
		self.texter:SetText( self.home_txt .. " 2: " )
	else
		self.home = true
		self.texter:SetText( self.home_txt .. " 1: " )
	end
	self.texter:SizeToContents()
	self.buttonHB:SetPosition( Vector2( self.texter:GetSize().x + 12, 10 ) )
	self.toggleH:SetPosition( Vector2( self.buttonHB:GetPosition().x + self.buttonHB:GetSize().x + 5, 10 ) )
end

function Shop:GoHome()
	self:Close()
	if self.home then
		Events:Fire( "GoHome" )
	else
		Events:Fire( "GoHomeTw" )
	end
end

function Shop:BuyHome()
	self:Close()
	if self.home then
		Events:Fire( "BuyHome" )
	else
		Events:Fire( "BuyHomeTw" )
	end
end

function Shop:GetUnitString()
	if self.unit == 1 then
		Network:Send( "Skin", nil )
	elseif self.unit == 2 then
		Network:Send( "Skin", "MilStandard" )
	elseif self.unit == 3 then
		Network:Send( "Skin", "OldJapan" )
	elseif self.unit == 4 then
		Network:Send( "Skin", "Reapers" )
	elseif self.unit == 5 then
		Network:Send( "Skin", "Roaches" )
	elseif self.unit == 6 then
		Network:Send( "Skin", "UlarBoys" )
	elseif self.unit == 7 then
		Network:Send( "Skin", "Taxi" )
	end
end

function Shop:GetActive()
    return self.active
end

function Shop:SetActive( active )
    if self.active ~= active then
        self.active = active
		self:LoadCategories()

        Mouse:SetVisible( self.active )

		self.vehColorWindow:SetVisible( false )

		if not self.active and self.colorChanged then
			self.colorChanged = false
			Network:Send( "BuyMenuSaveColor", {tone1 = self.tone1, tone2 = self.tone2} )
		end
    end
end

function Shop:Render()
	local is_visible = self.active and (Game:GetState() == GUIState.Game)

	if self.window:GetVisible() ~= is_visible then
		self.window:SetVisible( is_visible )
	end

	if self.active then
		Mouse:SetVisible( is_visible )
	end
end

function Shop:OpenShop()
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	local effect = ClientEffect.Play(AssetLocation.Game, {
		effect_id = 382,

		position = Camera:GetPosition(),
		angle = Angle()
	})
	self:SetActive( not self:GetActive() )
	if self.active then
		if LocalPlayer:GetValue( "SystemFonts" ) then
			self.Home_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.buy_button:SetFont( AssetLocation.SystemFont, "Impact" )
		end

		if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end

		local gettag = LocalPlayer:GetValue( "Tag" )

		if self.permissions[gettag] then
			self.toggleH:SetEnabled( true )
		else
			self.toggleH:SetEnabled( false )
		end
	else
		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
	end
end

function Shop:CloseShop()
	if Game:GetState() ~= GUIState.Game and LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if self.window:GetVisible() == true then
		self:SetActive( false )
		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
	end
end

function Shop:LocalPlayerInput( args )
	if args.input == Action.GuiPause then
		self:SetActive( false )
		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil
		end
	end
	if self.actions[args.input] then
		return false
	end
end

function Shop:Buy()
	local category_name = self.tab_control:GetCurrentTab():GetText()
	local category = self.categories[category_name]

	local subcategory_name = category.tab_control:GetCurrentTab():GetText()
	local subcategory = category.categories[subcategory_name]

	if subcategory == nil then return end

	local listbox = subcategory.listbox

	local first_selected_item = listbox:GetSelectedRow()

	if first_selected_item ~= nil then
		local index = first_selected_item:GetDataNumber( "id" )
		local time = Client:GetElapsedSeconds()
		self:GetUnitString()
		self:Close()
		if self.types[category_name] == 1 then
			if LocalPlayer:GetValue( "PVPMode" ) then
				Events:Fire( "CastCenterText", { text = self.pvpblock, time = 6, color = Color.Red } )
				return
			end

			if time < self.cooltime then
				Events:Fire( "CastCenterText", { text = self.w .. math.ceil( self.cooltime - time ) .. self.ws, time = 6, color = Color.Red } )
				return false
			end
			self.cooltime = time + self.cooldown
		end
	
		Network:Send( "PlayerFired", { self.types[category_name], subcategory_name, index, self.tone1, self.tone2 } )
		return false
	end
end

function Shop:Close()
	if self.active then
		self:SetActive( false )

		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end

		local effect = ClientEffect.Create(AssetLocation.Game, {
			effect_id = 383,

			position = Camera:GetPosition(),
			angle = Angle()
		})
	end
end

function Shop:NoVipText()
	Events:Fire( "CastCenterText", { text = self.noVipText, time = 3, color = Color.Red } )
end

function Shop:Parachute( message )
	Game:FireEvent( message )
end

function Shop:RestoreParachute()
	if LocalPlayer:GetValue( "GameMode" ) == "Охота" then return end
	Network:Send( "GiveMeParachute" )
end

function Shop:Sound()
	Game:FireEvent( "ply.blackmarket.item_ordered" )

	local sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 19,
			sound_id = 30,
			position = LocalPlayer:GetPosition(),
			angle = Angle()
	})

	sound:SetParameter(0,1)
end

function Shop:Shop( args )
	self.active = true
end

shop = Shop()
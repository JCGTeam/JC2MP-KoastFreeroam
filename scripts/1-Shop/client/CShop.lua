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
        ["VIP"] = true
    }

	self.cooldown = 5
	self.cooltime = 0

	self.active = false
	self.home = true
	self.unit = 0

	BuyMenuLineColor = Color.LightSkyBlue

	self.HomeImage = Image.Create( AssetLocation.Resource, "HomeImage" )

	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.5, 0.63 ) )
	self.window:SetPositionRel( Vector2( 0.7, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetVisible( self.active )
	self.window:SetTitle( "▧ Чёрный рынок" )
	self.window:Subscribe( "WindowClosed", self, self.Close )

	self.tab_control = TabControl.Create( self.window )
	self.tab_control:SetDock( GwenPosition.Fill )

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
	self.buy_button:SetTextHoveredColor( Color.LightBlue )
	self.buy_button:SetTextPressedColor( Color.LightBlue )
	self.buy_button:SetTextSize( 15 )
	self.buy_button:SetSize( Vector2( 0, 30 ) )
	self.buy_button:SetDock( GwenPosition.Bottom )
	self.buy_button:Subscribe( "Press", self, self.Buy )

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "ENG" then
		self:Lang()
	else
		self.noVipText = "У вас отсувствует VIP-статус :("
		self.pvpblock = "Вы не можете использовать это во время боя!"
		self.dlcwarning_txt = "ВНИМАНИЕ! DLC-контент не сможет наносить урон и не будет виден игрокам, которые его не имеют."
		self.w = "Пожалуйста, подождите "
		self.ws = " секунд."
	end

	self.categories = {}

	self.tone1 = Color.White
	self.tone2 = Color.White
	self.pcolor = LocalPlayer:GetColor()

	self.tone1Picker = nil
	self.tone2Picker = nil

	self:CreateItems()

	self.sort_dir = false
	self.last_column = -1

	player_hats = {}
	player_coverings = {}
	player_hairs = {}
	player_faces = {}
	player_necks = {}
	player_backs = {}
	player_torso = {}
	player_righthand = {}
	player_lefthand = {}
	player_legs = {}
	player_rightfoot = {}
	player_leftfoot = {}

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

function Shop:Lang( args )
	if self.window then
		self.window:SetTitle( "▧ Black Market" )
	end

	if self.buy_button then
		self.buy_button:SetText( "Get" )
	end

	self.noVipText = "Needed VIP status not found."
	self.pvpblock = "You cannot use this during combat!"
	self.dlcwarning_txt = "WARNING: DLC content will not be able to deal damage and will not be visible to players who do not have it."
	self.w = "Please, wait "
	self.ws = " seconds."
end

function Shop:RenderAppearanceHat()
	for p in Client:GetStreamedPlayers() do
		self:MoveAppearance(p)
	end
	self:MoveAppearance(LocalPlayer)
end

function Shop:CreateAppearance( player )
	self:RemoveAppearance( player )	
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
			player_hats[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Head"),
			angle = player:GetBoneAngle("ragdoll_Head"),
			model = hatModel
			})
	else
		if player_hats[player:GetId()] ~= nil then
			if IsValid( player_hats[player:GetId()] ) then
				player_hats[player:GetId()]:Remove()
			end
			player_hats[player:GetId()] = nil
		end
	end
	if coveringModel ~= nil and string.len(coveringModel) >= 10 then
			player_coverings[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Head"),
			angle = player:GetBoneAngle("ragdoll_Head"),
			model = coveringModel
			})
	else
		if player_coverings[player:GetId()] ~= nil then
			if IsValid( player_coverings[player:GetId()] ) then
				player_coverings[player:GetId()]:Remove()
			end
			player_coverings[player:GetId()] = nil
		end
	end
	if hairModel ~= nil and string.len(hairModel) >= 10 then
		player_hairs[player:GetId()] = ClientStaticObject.Create({
		position = player:GetBonePosition("ragdoll_Head"),
		angle = player:GetBoneAngle("ragdoll_Head"),
		model = hairModel
		})
	else
		if player_hairs[player:GetId()] ~= nil then
			if IsValid( player_hairs[player:GetId()] ) then
				player_hairs[player:GetId()]:Remove()
			end
			player_hairs[player:GetId()] = nil
		end
	end
	if faceModel ~= nil and string.len(faceModel) >= 10 then
			player_faces[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Head"),
			angle = player:GetBoneAngle("ragdoll_Head"),
			model = faceModel
			})
	else
		if player_faces[player:GetId()] ~= nil then
			if IsValid( player_faces[player:GetId()] ) then
				player_faces[player:GetId()]:Remove()
			end
			player_faces[player:GetId()] = nil
		end
	end
	if neckModel ~= nil and string.len(neckModel) >= 10 then
			player_necks[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Head"),
			angle = player:GetBoneAngle("ragdoll_Head"),
			model = neckModel
			})
	else
		if player_necks[player:GetId()] ~= nil then
			if IsValid( player_necks[player:GetId()] ) then
				player_necks[player:GetId()]:Remove()
			end
			player_necks[player:GetId()] = nil
		end
	end
	if backModel ~= nil and string.len(backModel) >= 10 then
			player_backs[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Spine1"),
			angle = player:GetBoneAngle("ragdoll_Spine1"),
			model = backModel
			})
	else
		if player_backs[player:GetId()] ~= nil then
			if IsValid( player_backs[player:GetId()] ) then
				player_backs[player:GetId()]:Remove()
			end
			player_backs[player:GetId()] = nil
		end
	end
	if torsoModel ~= nil and string.len(torsoModel) >= 10 then
			player_torso[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Spine1"),
			angle = player:GetBoneAngle("ragdoll_Spine1"),
			model = torsoModel
			})
	else
		if player_torso[player:GetId()] ~= nil then
			if IsValid( player_torso[player:GetId()] ) then
				player_torso[player:GetId()]:Remove()
			end
			player_torso[player:GetId()] = nil
		end
	end
	if righthandModel ~= nil and string.len(righthandModel) >= 10 then
			player_righthand[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_RightForeArm"),
			angle = player:GetBoneAngle("ragdoll_RightForeArm"),
			model = righthandModel
			})
	else
		if player_righthand[player:GetId()] ~= nil then
			if IsValid( player_righthand[player:GetId()] ) then
				player_righthand[player:GetId()]:Remove()
			end
			player_righthand[player:GetId()] = nil
		end
	end
	if lefthandModel ~= nil and string.len(lefthandModel) >= 10 then
		player_lefthand[player:GetId()] = ClientStaticObject.Create({
		position = player:GetBonePosition("ragdoll_LeftForeArm"),
		angle = player:GetBoneAngle("ragdoll_LeftForeArm"),
		model = lefthandModel
		})
	else
		if player_lefthand[player:GetId()] ~= nil then
			if IsValid( player_lefthand[player:GetId()] ) then
				player_lefthand[player:GetId()]:Remove()
			end
			player_lefthand[player:GetId()] = nil
		end
	end
	if legsModel ~= nil and string.len(legsModel) >= 10 then
			player_legs[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Hips"),
			angle = player:GetBoneAngle("ragdoll_Hips"),
			model = legsModel
			})
	else
		if player_legs[player:GetId()] ~= nil then
			if IsValid( player_legs[player:GetId()] ) then
				player_legs[player:GetId()]:Remove()
			end
			player_legs[player:GetId()] = nil
		end
	end
	if rightfootModel ~= nil and string.len(rightfootModel) >= 10 then
			player_rightfoot[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_RightFoot"),
			angle = player:GetBoneAngle("ragdoll_RightFoot"),
			model = rightfootModel
			})
	else
		if player_rightfoot[player:GetId()] ~= nil then
			if IsValid( player_rightfoot[player:GetId()] ) then
				player_rightfoot[player:GetId()]:Remove()
			end
			player_rightfoot[player:GetId()] = nil
		end
	end
	if leftfootModel ~= nil and string.len(leftfootModel) >= 10 then
			player_leftfoot[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_LeftFoot"),
			angle = player:GetBoneAngle("ragdoll_LeftFoot"),
			model = leftfootModel
			})
	else
		if player_leftfoot[player:GetId()] ~= nil then
			if IsValid( player_leftfoot[player:GetId()] ) then
				player_leftfoot[player:GetId()]:Remove()
			end
			player_leftfoot[player:GetId()] = nil
		end
	end
end

function Shop:RemoveAppearance( player )
	if player_hats[player:GetId()] ~= nil then
		if IsValid( player_hats[player:GetId()] ) then
			player_hats[player:GetId()]:Remove()
		end
		player_hats[player:GetId()] = nil
	end
	if player_coverings[player:GetId()] ~= nil then
		if IsValid( player_coverings[player:GetId()] ) then
			player_coverings[player:GetId()]:Remove()
		end
		player_coverings[player:GetId()] = nil
	end
	if player_hairs[player:GetId()] ~= nil then
		if IsValid( player_hairs[player:GetId()] ) then
			player_hairs[player:GetId()]:Remove()
		end
		player_hairs[player:GetId()] = nil
	end
	if player_faces[player:GetId()] ~= nil then
		if IsValid( player_faces[player:GetId()] ) then
			player_faces[player:GetId()]:Remove()
		end
		player_faces[player:GetId()] = nil
	end
	if player_necks[player:GetId()] ~= nil then
		if IsValid( player_necks[player:GetId()] ) then
			player_necks[player:GetId()]:Remove()
		end
		player_necks[player:GetId()] = nil
	end
	if player_backs[player:GetId()] ~= nil then
		if IsValid( player_backs[player:GetId()] ) then
			player_backs[player:GetId()]:Remove()
		end
		player_backs[player:GetId()] = nil
	end
	
	if player_torso[player:GetId()] ~= nil then
		if IsValid( player_torso[player:GetId()] ) then
			player_torso[player:GetId()]:Remove()
		end
		player_torso[player:GetId()] = nil
	end
	if player_righthand[player:GetId()] ~= nil then
		if IsValid( player_righthand[player:GetId()] ) then
			player_righthand[player:GetId()]:Remove()
		end
		player_righthand[player:GetId()] = nil
	end
	if player_lefthand[player:GetId()] ~= nil then
		if IsValid( player_lefthand[player:GetId()] ) then
			player_lefthand[player:GetId()]:Remove()
		end
		player_lefthand[player:GetId()] = nil
	end
	if player_legs[player:GetId()] ~= nil then
		if IsValid( player_legs[player:GetId()] ) then
			player_legs[player:GetId()]:Remove()
		end
		player_legs[player:GetId()] = nil
	end
	if player_rightfoot[player:GetId()] ~= nil then
		if IsValid( player_rightfoot[player:GetId()] ) then
			player_rightfoot[player:GetId()]:Remove()
		end
		player_rightfoot[player:GetId()] = nil
	end
	if player_leftfoot[player:GetId()] ~= nil then
		if IsValid( player_leftfoot[player:GetId()] ) then
			player_leftfoot[player:GetId()]:Remove()
		end
		player_leftfoot[player:GetId()] = nil
	end
end

function Shop:MoveAppearance( player )
	if IsValid(player) then
		local hat = player_hats[player:GetId()]
		local covering = player_coverings[player:GetId()]
		local hair = player_hairs[player:GetId()]
		local face = player_faces[player:GetId()]
		local neck = player_necks[player:GetId()]
		local back = player_backs[player:GetId()]
		local torso = player_torso[player:GetId()]
		local righthand = player_righthand[player:GetId()]
		local lefthand = player_lefthand[player:GetId()]
		local legs = player_legs[player:GetId()]
		local rightfoot = player_rightfoot[player:GetId()]
		local leftfoot = player_leftfoot[player:GetId()]

		if hat ~= nil and IsValid(hat) then
			hat:SetAngle(player:GetBoneAngle("ragdoll_Head"))
			local AppearanceOffset = hat:GetAngle() * Vector3( 0, 1.62, .03 )
			hat:SetPosition(player:GetBonePosition("ragdoll_Head") - AppearanceOffset) 
		end
		if covering ~= nil and IsValid(covering) then
			covering:SetAngle(player:GetBoneAngle("ragdoll_Head"))
			local AppearanceOffset = covering:GetAngle() * Vector3( 0, 1.62, .03 )
			covering:SetPosition(player:GetBonePosition("ragdoll_Head") - AppearanceOffset) 
		end
		if hair ~= nil and IsValid(hair) then
			hair:SetAngle(player:GetBoneAngle("ragdoll_Head"))
			local AppearanceOffset = hair:GetAngle() * Vector3( 0, 1.61, .03 )
			hair:SetPosition(player:GetBonePosition("ragdoll_Head") - AppearanceOffset) 
		end
		if face ~= nil and IsValid(face) then
			face:SetAngle(player:GetBoneAngle("ragdoll_Head"))
			local AppearanceOffset = face:GetAngle() * Vector3( 0, 1.65, .0375 )
			face:SetPosition(player:GetBonePosition("ragdoll_Head") - AppearanceOffset) 
		end
		if neck ~= nil and IsValid(neck) then
			neck:SetAngle(player:GetBoneAngle("ragdoll_Head"))
			local AppearanceOffset = neck:GetAngle() * Vector3( 0, 1.54, .065 )
			neck:SetPosition(player:GetBonePosition("ragdoll_Head") - AppearanceOffset) 
		end
		if back ~= nil and IsValid(back) then
			back:SetAngle(player:GetBoneAngle("ragdoll_Spine1"))
			local AppearanceOffset = back:GetAngle() * Vector3( 0, 1.225, 0.05 )
			back:SetPosition(player:GetBonePosition("ragdoll_Spine1") - AppearanceOffset) 
		end

		if torso ~= nil and IsValid(torso) then
			torso:SetAngle(player:GetBoneAngle("ragdoll_Spine1"))
			local AppearanceOffset = torso:GetAngle() * Vector3( 0, 1.225, 0.05 )
			torso:SetPosition(player:GetBonePosition("ragdoll_Spine1") - AppearanceOffset) 
		end
		if righthand ~= nil and IsValid(righthand) then
			righthand:SetAngle(player:GetBoneAngle("ragdoll_RightForeArm"))
			local AppearanceOffset = righthand:GetAngle() * Vector3( 0, 0, 0 )
			righthand:SetPosition(player:GetBonePosition("ragdoll_RightForeArm") - AppearanceOffset) 
		end
		if lefthand ~= nil and IsValid(lefthand) then
			lefthand:SetAngle(player:GetBoneAngle("ragdoll_LeftForeArm"))
			local AppearanceOffset = lefthand:GetAngle() * Vector3( 0, 0, 0 )
			lefthand:SetPosition(player:GetBonePosition("ragdoll_LeftForeArm") - AppearanceOffset) 
		end
		if legs ~= nil and IsValid(legs) then
			legs:SetAngle(player:GetBoneAngle("ragdoll_Hips"))
			local AppearanceOffset = legs:GetAngle() * Vector3( 0, 0, 0 )
			legs:SetPosition(player:GetBonePosition("ragdoll_Hips") - AppearanceOffset) 
		end
		if rightfoot ~= nil and IsValid(rightfoot) then
			rightfoot:SetAngle(player:GetBoneAngle("ragdoll_RightFoot"))
			local AppearanceOffset = rightfoot:GetAngle() * Vector3( 0, 0, 0 )
			rightfoot:SetPosition(player:GetBonePosition("ragdoll_RightFoot") - AppearanceOffset) 
		end
		if leftfoot ~= nil and IsValid(leftfoot) then
			leftfoot:SetAngle(player:GetBoneAngle("ragdoll_LeftFoot"))
			local AppearanceOffset = leftfoot:GetAngle() * Vector3( 0, 0, 0 )
			leftfoot:SetPosition(player:GetBonePosition("ragdoll_LeftFoot") - AppearanceOffset) 
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
	for k, v in pairs(player_hats) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_coverings) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_hairs) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_faces) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_necks) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_backs) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_torso) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_righthand) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_lefthand) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_legs) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_rightfoot) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_leftfoot) do
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

	if (subcategory_name == "Машины" or subcategory_name == "Мотоциклы" or subcategory_name == "Джипы" or subcategory_name == "Пикапы" or subcategory_name == "Автобусы" or subcategory_name == "Тяжи" or 
	subcategory_name == "Трактора" or subcategory_name == "Вертолёты" or subcategory_name == "Самолёты" or subcategory_name == "Лодки" or subcategory_name == "DLC") then
		local skin = RadioButtonController.Create( t.window )
		skin:SetMargin( Vector2( 0, 5 ), Vector2( 0, 0 ) )
		skin:SetSize( Vector2( 0, 20 ) )
		skin:SetDock( GwenPosition.Bottom )
		local units = { "Декаль Панау", "Декаль Японцев", "Декаль Уларов", "Декаль Жнецов", "Декаль Тараканов"}
		for i, v in ipairs( units ) do
			local option = skin:AddOption( v )
			option:SetDock( GwenPosition.Left )
			option:SetWidth( Render:GetTextWidth( v ) + 15 )

			if i-1 == self.unit then
				option:Select()
			end

			option:GetRadioButton():Subscribe( "Checked", function() self.unit = i-1 end )
		end
	end

	if LocalPlayer:GetValue( "DLCWarning" ) then
		if subcategory_name == "DLC" or subcategory_name == "Правая рука" or subcategory_name == "Левая рука" or subcategory_name == "Основное" then
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
				row:SetTextColor( BuyMenuLineColor )
				row:SetDataNumber( "id", item_id )

				entry:SetListboxItem( row )
			end
		end

		if category_id == self.types["Остальное >"] then
			local window = BaseWindow.Create( self.window )
			window:SetDock( GwenPosition.Fill )
			category_table.tab_control:AddPage( "Цвет транспорта", window )

			local tab_control = TabControl.Create( window )
			tab_control:SetDock( GwenPosition.Fill )

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
			self.tone1Picker:SetColor( LocalPlayer:GetColor() )
			self.tone2Picker:SetColor( LocalPlayer:GetColor() )

			local setColorBtn = Button.Create( window )
			setColorBtn:SetText( "Установить цвет »" )
			setColorBtn:SetTextHoveredColor( Color.GreenYellow )
			setColorBtn:SetTextPressedColor( Color.GreenYellow )
			setColorBtn:SetTextSize( 15 )
			setColorBtn:SetSize( Vector2( 0, 30 ) )
			setColorBtn:SetDock( GwenPosition.Bottom )
			setColorBtn:Subscribe( "Down", function()
				Network:Send( "ColorChanged", { tone1 = self.tone1, tone2 = self.tone2 } )
				local sound = ClientSound.Create(AssetLocation.Game, {
						bank_id = 20,
						sound_id = 22,
						position = LocalPlayer:GetPosition(),
						angle = Angle()
				})

				sound:SetParameter(0,1)	
				Game:FireEvent( "bm.savecheckpoint.go" )
			end )

			local window = BaseWindow.Create( self.window )
			window:SetDock( GwenPosition.Fill )
			category_table.tab_control:AddPage( "Дом", window )

			self.texter = Label.Create( window )
			self.texter:SetVisible( true )
			self.texter:SetText( "Дом 1:" )
			self.texter:SetPosition( Vector2( 5, 20 ) )
			self.texter:SizeToContents()

			local sethomebutton_txt = "Установить точку дома здесь ( $500 )"

			self.buttonHB = Button.Create( window )
			self.buttonHB:SetVisible( true )
			self.buttonHB:SetText( sethomebutton_txt )
			self.buttonHB:SetSize( Vector2( Render.Size.x / 5.5, Render.Size.x / 40 ) )
			self.buttonHB:SetTextHoveredColor( Color.GreenYellow )
			self.buttonHB:SetTextPressedColor( Color.GreenYellow )
			self.buttonHB:SetTextSize( 12 )
			self.buttonHB:SetPosition( Vector2( self.texter:GetSize().x + 12, 10 ) )
			self.buttonHB:SetSize( Vector2( Render:GetTextWidth( sethomebutton_txt, 12 ) + 30, Render:GetTextHeight( sethomebutton_txt, 12 ) + 18 ) )
			self.buttonHB:Subscribe( "Press", self, self.BuyHome )

			self.toggleH = Button.Create( window )
			self.toggleH:SetVisible( true )
			self.toggleH:SetText( ">" )
			self.toggleH:SetSize( Vector2( 60, Render:GetTextHeight( ">", 12 ) + 18 ) )
			self.toggleH:SetTextSize( 15 )
			self.toggleH:SetPosition( Vector2( self.buttonHB:GetPosition().x + self.buttonHB:GetSize().x + 5, 10 ) )
			self.toggleH:Subscribe( "Press", self, self.ToggleHome )

			local spawninhome = LabeledCheckBox.Create( window )
			spawninhome:GetLabel():SetText( "Появляться на точке дома после подключения к серверу" )
			spawninhome:SetWidth( 350 )
			spawninhome:SetPosition( Vector2( 5, self.buttonHB:GetPosition().y + self.buttonHB:GetSize().y + 10 ) )
			spawninhome:GetCheckBox():SetChecked( self:NumberToBoolean( LocalPlayer:GetValue( "SpawnInHome" ) ) )
			spawninhome:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateSpawnInHome" ) end )

			self.Home_Image = ImagePanel.Create( window )
			self.Home_Image:SetImage( self.HomeImage )
			self.Home_Image:SetPosition( Vector2( 5, spawninhome:GetPosition().y + spawninhome:GetSize().y + 15 ) )
			self.Home_Image:SetHeight( Render.Size.x / 9 )
			self.Home_Image:SetWidth( Render.Size.x / 5.5 )

			self.Home_button = MenuItem.Create( window )
			self.Home_button:SetPosition( self.Home_Image:GetPosition() )
			self.Home_button:SetSize( Vector2( Render.Size.x / 5.5, Render.Size.x / 7 ) )
			self.Home_button:SetText( "Переместиться домой »" )
			self.Home_button:SetTextHoveredColor( Color.GreenYellow )
			self.Home_button:SetTextPressedColor( Color.GreenYellow )
			self.Home_button:SetTextPadding( Vector2( 0, Render.Size.x / 9 ), Vector2.Zero )
			self.Home_button:SetTextSize( Render.Size.x / 0.75 / Render:GetTextWidth( "BTextResoliton" ) )
			self.Home_button:Subscribe( "Press", self, self.GoHome )
		end	
	end
	Network:Send( "BuyMenuGetSaveColor" )
end

function Shop:NumberToBoolean( value )
	return value == 1 and true or value == 0 and false
end

function Shop:CalcView( args )
	Camera:SetPosition( Camera:GetPosition() - Vector3( 0, 1, 0 ) )
end

function Shop:ToggleHome()
	if self.home then
		self.home = false
		self.texter:SetText( "Дом 2:" )
	else
		self.home = true
		self.texter:SetText( "Дом 1:" )
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
	if self.unit == 0 then
		Network:Send( "Skin", nil )
	elseif self.unit == 1 then
		Network:Send( "Skin", "OldJapan" )
	elseif self.unit == 2 then
		Network:Send( "Skin", "UlarBoys" )
	elseif self.unit == 3 then
		Network:Send( "Skin", "Reapers" )
	elseif self.unit == 4 then
		Network:Send( "Skin", "Roaches" )
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
	ClientEffect.Play(AssetLocation.Game, {
		effect_id = 382,

		position = Camera:GetPosition(),
		angle = Angle()
	})
	self:SetActive( not self:GetActive() )
	if self.active then
		if LocalPlayer:GetValue( "SystemFonts" ) then
			self.Home_button:SetFont( AssetLocation.SystemFont, "Impact" )
		end

		if not self.LocalPlayerInputEvent then
			self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
		end

		local gettag = LocalPlayer:GetValue( "Tag" )

		if self.permissions[gettag] then
			self.toggleH:SetEnabled( true )
		else
			self.toggleH:SetEnabled( false )
		end
	else
		if self.LocalPlayerInputEvent then
			Events:Unsubscribe( self.LocalPlayerInputEvent )
			self.LocalPlayerInputEvent = nil
		end
	end
end

function Shop:CloseShop()
	if Game:GetState() ~= GUIState.Game and LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if self.window:GetVisible() == true then
		self:SetActive( false )
		if self.LocalPlayerInputEvent then
			Events:Unsubscribe( self.LocalPlayerInputEvent )
			self.LocalPlayerInputEvent = nil
		end
	end
end

function Shop:LocalPlayerInput( args )
	if args.input == Action.GuiPause then
		self:SetActive( false )
		if self.LocalPlayerInputEvent then
			Events:Unsubscribe( self.LocalPlayerInputEvent )
			self.LocalPlayerInputEvent = nil
		end
	end
	if self.actions[args.input] then
		return false
	end
end

function Shop:Buy( args )
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

function Shop:Close( args )
	if self.active then
		self:SetActive( false )
		if self.LocalPlayerInputEvent then
			Events:Unsubscribe( self.LocalPlayerInputEvent )
			self.LocalPlayerInputEvent = nil
		end
		ClientEffect.Create(AssetLocation.Game, {
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
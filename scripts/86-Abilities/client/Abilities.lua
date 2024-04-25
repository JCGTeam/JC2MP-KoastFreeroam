class 'Abilities'

function Abilities:__init()
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

    self.wingsuitIMG = Image.Create( AssetLocation.Resource, "Wingsuit" )
    self.boostIMG = Image.Create( AssetLocation.Resource, "Boost" )
    self.moneyBonusIMG = Image.Create( AssetLocation.Resource, "MoneyBonus" )
    self.moreC4IMG = Image.Create( AssetLocation.Resource, "MoreC4" )
    self.superNuclearBombIMG = Image.Create( AssetLocation.Resource, "SuperNuclearBomb" )
    self.longerGrappleIMG = Image.Create( AssetLocation.Resource, "LongerGrapple" )
    self.jesusModeIMG = Image.Create( AssetLocation.Resource, "JesusMode" )

    self.active = false

    self.boostValue_1 = 1
    self.boostValue_2 = 2
    self.boostValue_3 = 3

    self.moreC4Value_5 = 5
    self.moreC4Value_8 = 8
    self.moreC4Value_10 = 10
    self.moreC4Value_15 = 15

    self.GrappleLongerValue_1 = 150
    self.GrappleLongerValue_2 = 180
    self.GrappleLongerValue_3 = 200
    self.GrappleLongerValue_4 = 250

    self.unlocked_clr = Color( 0, 255, 0, 30 )

    self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.4, 0.5 ) )
	self.window:SetMinimumSize( Vector2( 500, 442 ) )
	self.window:SetPositionRel( Vector2( 0.7, 0.5 ) - self.window:GetSizeRel()/2 )
    self.window:SetTitle( "▧ Способности" )
    self.window:SetVisible( self.active )
    self.window:Subscribe( "WindowClosed", self, self.WindowClosed )

    if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
        self.needed_txt = "Цена"
        self.unlocked_txt = "Приобретено"
        self.morec4_txt = "Увеличение кол-во C4"
        self.items_txt = "штук"
        self.wingsuit_txt = "Вингсьют"
        self.landvehicleboost_txt = "Ускорение для наземного транспорта"
        self.watervehicleboost_txt = "Ускорение для морского транспорта"
        self.airvehicleboost_txt = "Ускорение для воздушного транспорта"
        self.bonusmoney_txt = "Денежный бонус"
        self.supernuclearbomb_txt = "СУПЕР Ядерная граната"
        self.longergrapple_txt =  "Дальность крюка"
        self.meters_txt = "м"
        self.jesusmode_txt = "Режим Иисуса"
        self.abilities_txt = "Способности"
        self.noselected_description = "Наведите на любую способность, чтобы прочитать описание."
        self.wingsuit_description = "Специальный костюм-крыло, позволяющий летать по небу."
        self.boost_description = "Ускоряет ваше транспортное средство нажатием одной кнопки до скорости света!"
        self.bonusmoney_description = "Денежная награда в размере $100-2500 каждый час игры."
        self.moreC4_description = "Увеличивает максимальное количество слотов C4 для установки."
        self.supernuclearbomb_description = "Мощнейший взрыв, который уничтожает всё, что находится поблизости с этой волшебной гранатой :)"
        self.longergrapple_description = "Увеличивает максимальную дальность выстрела крюком-кошки."
        self.jesusmode_description = "Возможность ходить и ездить по воде."
        self.wingsuittutorial_txt = "Используйте клавишу 'Q' находясь в свободном полете или на парашюте, чтобы раскрыть вингсьют."
        self.landvehboosttutorial_txt = "Используйте клавишу 'Shift', чтобы воспользоваться супер-пупер ускорением."
        self.airvehboosttutorial_txt = "Используйте клавишу 'Q', чтобы воспользоваться супер-пупер ускорением."
	end

    self.toplabel = Label.Create( self.window )
    self.toplabel:SetHeight( Render:GetTextHeight( "A", 18 ) + 10 )
    self.toplabel:SetMargin( Vector2( 0, 0 ), Vector2( 0, 0 ) )
    self.toplabel:SetDock( GwenPosition.Top )

    self.toplabelbk = Label.Create( self.toplabel )
    self.toplabelbk:SetDock( GwenPosition.Fill )

    self.money_text = Label.Create( self.toplabelbk )
    self.money_text:SetDock( GwenPosition.Left )
    self.money_text:SetMargin( Vector2( 10, 5 ), Vector2( 0, 0 ) )
    self.money_text:SetText( "Баланс: $" .. formatNumber( LocalPlayer:GetMoney() ) )
    self.money_text:SetTextColor( Color( 251, 184, 41 ) )
    self.money_text:SetTextSize( 18 )
    self.money_text:SizeToContents()

    self.mainlabel = Label.Create( self.window )
    self.mainlabel:SetDock( GwenPosition.Fill )

    if Debug.ShowResetButton then
        self.resetbutton = Button.Create( self.mainlabel )
        self.resetbutton:SetSize( Vector2( 50, 50 ) )
        self.resetbutton:SetDock( GwenPosition.Bottom )
        self.resetbutton:SetText( "RESET ACHIEVEMENTS" )
        self.resetbutton:Subscribe( "Press", self, self.Clear )
    end

    self.wingsuitbutton = Button.Create( self.mainlabel )
    self.wingsuitbutton:SetSize( Vector2( 50, 50 ) )
    self.wingsuitbutton:SetPosition( Vector2( 10, 5 ) )
    self.wingsuitbutton:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.wingsuit_txt ) self.tip_descrition:SetText( self.wingsuit_description ) self.tip_descrition:SizeToContents() end )
    self.wingsuitbutton:Subscribe( "Press", self, self.WingsuitUnlocker )

    self.wingsuitbutton.unlockstats = Rectangle.Create( self.wingsuitbutton )
    self.wingsuitbutton.unlockstats:SetDock( GwenPosition.Fill )
    self.wingsuitbutton.unlockstats:SetColor( self.unlocked_clr )
    self.wingsuitbutton.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.wingsuit_txt ) self.tip_descrition:SetText( self.wingsuit_description ) self.tip_descrition:SizeToContents() end )

    self.wingsuitbutton.image = ImagePanel.Create( self.wingsuitbutton )
    self.wingsuitbutton.image:SetDock( GwenPosition.Fill )
    self.wingsuitbutton.image:SetImage( self.wingsuitIMG )


    self.boost_1button = Button.Create( self.mainlabel )
    self.boost_1button:SetSize( Vector2( 50, 50 ) )
    self.boost_1button:SetPosition( Vector2( self.wingsuitbutton:GetPosition().x + 60 , 5 ) )
    self.boost_1button:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.landvehicleboost_txt ) self.tip_descrition:SetText( self.boost_description ) self.tip_descrition:SizeToContents() end )
    self.boost_1button:Subscribe( "Press", self, self.BoostUnlocker )

    self.boost_1button.unlockstats = Rectangle.Create( self.boost_1button )
    self.boost_1button.unlockstats:SetDock( GwenPosition.Fill )
    self.boost_1button.unlockstats:SetColor( self.unlocked_clr )
    self.boost_1button.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.landvehicleboost_txt ) self.tip_descrition:SetText( self.boost_description ) self.tip_descrition:SizeToContents() end )

    self.boost_1button.image = ImagePanel.Create( self.boost_1button )
    self.boost_1button.image:SetDock( GwenPosition.Fill )
    self.boost_1button.image:SetImage( self.boostIMG )

    self.boost_2button = Button.Create( self.mainlabel )
    self.boost_2button:SetSize( Vector2( 50, 50 ) )
    self.boost_2button:SetPosition( Vector2( self.wingsuitbutton:GetPosition().x + 60 , self.boost_1button:GetPosition().y + 55 ) )
    self.boost_2button:SetVisible( false )
    self.boost_2button:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.watervehicleboost_txt ) self.tip_descrition:SetText( self.boost_description ) self.tip_descrition:SizeToContents() end )
    self.boost_2button:Subscribe( "Press", self, self.BoostUnlocker )

    self.boost_2button.unlockstats = Rectangle.Create( self.boost_2button )
    self.boost_2button.unlockstats:SetDock( GwenPosition.Fill )
    self.boost_2button.unlockstats:SetColor( self.unlocked_clr )
    self.boost_2button.unlockstats:SetVisible( false )
    self.boost_2button.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.watervehicleboost_txt ) self.tip_descrition:SetText( self.boost_description ) self.tip_descrition:SizeToContents() end )

    self.boost_2button.image = ImagePanel.Create( self.boost_2button )
    self.boost_2button.image:SetDock( GwenPosition.Fill )
    self.boost_2button.image:SetImage( self.boostIMG )

    self.boost_3button = Button.Create( self.mainlabel )
    self.boost_3button:SetSize( Vector2( 50, 50 ) )
    self.boost_3button:SetPosition( Vector2( self.wingsuitbutton:GetPosition().x + 60 , self.boost_2button:GetPosition().y + 55 ) )
    self.boost_3button:SetVisible( false )
    self.boost_3button:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.airvehicleboost_txt ) self.tip_descrition:SetText( self.boost_description ) self.tip_descrition:SizeToContents() end )
    self.boost_3button:Subscribe( "Press", self, self.BoostUnlocker )

    self.boost_3button.unlockstats = Rectangle.Create( self.boost_3button )
    self.boost_3button.unlockstats:SetDock( GwenPosition.Fill )
    self.boost_3button.unlockstats:SetColor( self.unlocked_clr )
    self.boost_3button.unlockstats:SetVisible( false )
    self.boost_3button.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.airvehicleboost_txt ) self.tip_descrition:SetText( self.boost_description ) self.tip_descrition:SizeToContents() end )

    self.boost_3button.image = ImagePanel.Create( self.boost_3button )
    self.boost_3button.image:SetDock( GwenPosition.Fill )
    self.boost_3button.image:SetImage( self.boostIMG )


    self.bonusmoneybutton = Button.Create( self.mainlabel )
    self.bonusmoneybutton:SetSize( Vector2( 50, 50 ) )
    self.bonusmoneybutton:SetPosition( Vector2( self.boost_1button:GetPosition().x + 60 , 5 ) )
    self.bonusmoneybutton:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.bonusmoney_txt ) self.tip_descrition:SetText( self.bonusmoney_description ) self.tip_descrition:SizeToContents() end )
    self.bonusmoneybutton:Subscribe( "Press", self, self.MoneyBonusUnlocker )

    self.bonusmoneybutton.unlockstats = Rectangle.Create( self.bonusmoneybutton )
    self.bonusmoneybutton.unlockstats:SetDock( GwenPosition.Fill )
    self.bonusmoneybutton.unlockstats:SetColor( self.unlocked_clr )
    self.bonusmoneybutton.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.bonusmoney_txt ) self.tip_descrition:SetText( self.bonusmoney_description ) self.tip_descrition:SizeToContents() end )

    self.bonusmoneybutton.image = ImagePanel.Create( self.bonusmoneybutton )
    self.bonusmoneybutton.image:SetDock( GwenPosition.Fill )
    self.bonusmoneybutton.image:SetImage( self.moneyBonusIMG )


    self.moreC4_5button = Button.Create( self.mainlabel )
    self.moreC4_5button:SetSize( Vector2( 50, 50 ) )
    self.moreC4_5button:SetPosition( Vector2( self.bonusmoneybutton:GetPosition().x + 60 , 5 ) )
    self.moreC4_5button:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.morec4_txt ) self.tip_descrition:SetText( self.moreC4_description ) self.tip_descrition:SizeToContents() end )
    self.moreC4_5button:Subscribe( "Press", self, self.MoreC4Unlocker )

    self.moreC4_5button.unlockstats = Rectangle.Create( self.moreC4_5button )
    self.moreC4_5button.unlockstats:SetDock( GwenPosition.Fill )
    self.moreC4_5button.unlockstats:SetColor( self.unlocked_clr )
    self.moreC4_5button.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.morec4_txt ) self.tip_descrition:SetText( self.moreC4_description ) self.tip_descrition:SizeToContents() end )

    self.moreC4_5button.image = ImagePanel.Create( self.moreC4_5button )
    self.moreC4_5button.image:SetDock( GwenPosition.Fill )
    self.moreC4_5button.image:SetImage( self.moreC4IMG )

    self.moreC4_8button = Button.Create( self.mainlabel )
    self.moreC4_8button:SetSize( Vector2( 50, 50 ) )
    self.moreC4_8button:SetPosition( Vector2( self.bonusmoneybutton:GetPosition().x + 60 , self.moreC4_5button:GetPosition().y + 55 ) )
    self.moreC4_8button:SetVisible( false )
    self.moreC4_8button:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.morec4_txt ) self.tip_descrition:SetText( self.moreC4_description ) self.tip_descrition:SizeToContents() end )
    self.moreC4_8button:Subscribe( "Press", self, self.MoreC4Unlocker )

    self.moreC4_8button.unlockstats = Rectangle.Create( self.moreC4_8button )
    self.moreC4_8button.unlockstats:SetDock( GwenPosition.Fill )
    self.moreC4_8button.unlockstats:SetColor( self.unlocked_clr )
    self.moreC4_8button.unlockstats:SetVisible( false )
    self.moreC4_8button.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.morec4_txt ) self.tip_descrition:SetText( self.moreC4_description ) self.tip_descrition:SizeToContents() end )

    self.moreC4_8button.image = ImagePanel.Create( self.moreC4_8button )
    self.moreC4_8button.image:SetDock( GwenPosition.Fill )
    self.moreC4_8button.image:SetImage( self.moreC4IMG )

    self.moreC4_10button = Button.Create( self.mainlabel )
    self.moreC4_10button:SetSize( Vector2( 50, 50 ) )
    self.moreC4_10button:SetPosition( Vector2( self.bonusmoneybutton:GetPosition().x + 60 , self.moreC4_8button:GetPosition().y + 55 ) )
    self.moreC4_10button:SetVisible( false )
    self.moreC4_10button:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.morec4_txt ) self.tip_descrition:SetText( self.moreC4_description ) self.tip_descrition:SizeToContents() end )
    self.moreC4_10button:Subscribe( "Press", self, self.MoreC4Unlocker )

    self.moreC4_10button.unlockstats = Rectangle.Create( self.moreC4_10button )
    self.moreC4_10button.unlockstats:SetDock( GwenPosition.Fill )
    self.moreC4_10button.unlockstats:SetColor( self.unlocked_clr )
    self.moreC4_10button.unlockstats:SetVisible( false )
    self.moreC4_10button.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.morec4_txt ) self.tip_descrition:SetText( self.moreC4_description ) self.tip_descrition:SizeToContents() end )

    self.moreC4_10button.image = ImagePanel.Create( self.moreC4_10button )
    self.moreC4_10button.image:SetDock( GwenPosition.Fill )
    self.moreC4_10button.image:SetImage( self.moreC4IMG )


    self.moreC4_15button = Button.Create( self.mainlabel )
    self.moreC4_15button:SetSize( Vector2( 50, 50 ) )
    self.moreC4_15button:SetPosition( Vector2( self.bonusmoneybutton:GetPosition().x + 60 , self.moreC4_10button:GetPosition().y + 55 ) )
    self.moreC4_15button:SetVisible( false )
    self.moreC4_15button:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.morec4_txt ) self.tip_descrition:SetText( self.moreC4_description ) self.tip_descrition:SizeToContents() end )
    self.moreC4_15button:Subscribe( "Press", self, self.MoreC4Unlocker )

    self.moreC4_15button.unlockstats = Rectangle.Create( self.moreC4_15button )
    self.moreC4_15button.unlockstats:SetDock( GwenPosition.Fill )
    self.moreC4_15button.unlockstats:SetColor( self.unlocked_clr )
    self.moreC4_15button.unlockstats:SetVisible( false )
    self.moreC4_15button.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.morec4_txt ) self.tip_descrition:SetText( self.moreC4_description ) self.tip_descrition:SizeToContents() end )

    self.moreC4_15button.image = ImagePanel.Create( self.moreC4_15button )
    self.moreC4_15button.image:SetDock( GwenPosition.Fill )
    self.moreC4_15button.image:SetImage( self.moreC4IMG )


    self.supernuclearbombbutton = Button.Create( self.mainlabel )
    self.supernuclearbombbutton:SetSize( Vector2( 50, 50 ) )
    self.supernuclearbombbutton:SetPosition( Vector2( self.moreC4_5button:GetPosition().x + 60 , 5 ) )
    self.supernuclearbombbutton:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.supernuclearbomb_txt ) self.tip_descrition:SetText( self.supernuclearbomb_description ) self.tip_descrition:SizeToContents() end )
    self.supernuclearbombbutton:Subscribe( "Press", self, self.SuperNuclearBombUnlocker )

    self.supernuclearbombbutton.unlockstats = Rectangle.Create( self.supernuclearbombbutton )
    self.supernuclearbombbutton.unlockstats:SetDock( GwenPosition.Fill )
    self.supernuclearbombbutton.unlockstats:SetColor( self.unlocked_clr )
    self.supernuclearbombbutton.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.supernuclearbomb_txt ) self.tip_descrition:SetText( self.supernuclearbomb_description ) self.tip_descrition:SizeToContents() end )

    self.supernuclearbombbutton.image = ImagePanel.Create( self.supernuclearbombbutton )
    self.supernuclearbombbutton.image:SetDock( GwenPosition.Fill )
    self.supernuclearbombbutton.image:SetImage( self.superNuclearBombIMG )


    self.longergrapple_150button = Button.Create( self.mainlabel )
    self.longergrapple_150button:SetSize( Vector2( 50, 50 ) )
    self.longergrapple_150button:SetPosition( Vector2( self.supernuclearbombbutton:GetPosition().x + 60 , 5 ) )
    self.longergrapple_150button:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.longergrapple_txt ) self.tip_descrition:SetText( self.longergrapple_description ) self.tip_descrition:SizeToContents() end )
    self.longergrapple_150button:Subscribe( "Press", self, self.LongerGrappleUnlocker )

    self.longergrapple_150button.unlockstats = Rectangle.Create( self.longergrapple_150button )
    self.longergrapple_150button.unlockstats:SetDock( GwenPosition.Fill )
    self.longergrapple_150button.unlockstats:SetColor( self.unlocked_clr )
    self.longergrapple_150button.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.longergrapple_txt ) self.tip_descrition:SetText( self.longergrapple_description ) self.tip_descrition:SizeToContents() end )

    self.longergrapple_150button.image = ImagePanel.Create( self.longergrapple_150button )
    self.longergrapple_150button.image:SetDock( GwenPosition.Fill )
    self.longergrapple_150button.image:SetImage( self.longerGrappleIMG )

    self.longergrapple_200button = Button.Create( self.mainlabel )
    self.longergrapple_200button:SetSize( Vector2( 50, 50 ) )
    self.longergrapple_200button:SetPosition( Vector2( self.supernuclearbombbutton:GetPosition().x + 60 , self.longergrapple_150button:GetPosition().y + 55 ) )
    self.longergrapple_200button:SetVisible( false )
    self.longergrapple_200button:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.longergrapple_txt ) self.tip_descrition:SetText( self.longergrapple_description ) self.tip_descrition:SizeToContents() end )
    self.longergrapple_200button:Subscribe( "Press", self, self.LongerGrappleUnlocker )

    self.longergrapple_200button.unlockstats = Rectangle.Create( self.longergrapple_200button )
    self.longergrapple_200button.unlockstats:SetDock( GwenPosition.Fill )
    self.longergrapple_200button.unlockstats:SetColor( self.unlocked_clr )
    self.longergrapple_200button.unlockstats:SetVisible( false )
    self.longergrapple_200button.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.longergrapple_txt ) self.tip_descrition:SetText( self.longergrapple_description ) self.tip_descrition:SizeToContents() end )

    self.longergrapple_200button.image = ImagePanel.Create( self.longergrapple_200button )
    self.longergrapple_200button.image:SetDock( GwenPosition.Fill )
    self.longergrapple_200button.image:SetImage( self.longerGrappleIMG )

    self.longergrapple_350button = Button.Create( self.mainlabel )
    self.longergrapple_350button:SetSize( Vector2( 50, 50 ) )
    self.longergrapple_350button:SetPosition( Vector2( self.supernuclearbombbutton:GetPosition().x + 60 , self.longergrapple_200button:GetPosition().y + 55 ) )
    self.longergrapple_350button:SetVisible( false )
    self.longergrapple_350button:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.longergrapple_txt ) self.tip_descrition:SetText( self.longergrapple_description ) self.tip_descrition:SizeToContents() end )
    self.longergrapple_350button:Subscribe( "Press", self, self.LongerGrappleUnlocker )

    self.longergrapple_350button.unlockstats = Rectangle.Create( self.longergrapple_350button )
    self.longergrapple_350button.unlockstats:SetDock( GwenPosition.Fill )
    self.longergrapple_350button.unlockstats:SetColor( self.unlocked_clr )
    self.longergrapple_350button.unlockstats:SetVisible( false )
    self.longergrapple_350button.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.longergrapple_txt ) self.tip_descrition:SetText( self.longergrapple_description ) self.tip_descrition:SizeToContents() end )

    self.longergrapple_350button.image = ImagePanel.Create( self.longergrapple_350button )
    self.longergrapple_350button.image:SetDock( GwenPosition.Fill )
    self.longergrapple_350button.image:SetImage( self.longerGrappleIMG )

    self.longergrapple_500button = Button.Create( self.mainlabel )
    self.longergrapple_500button:SetSize( Vector2( 50, 50 ) )
    self.longergrapple_500button:SetPosition( Vector2( self.supernuclearbombbutton:GetPosition().x + 60 , self.longergrapple_350button:GetPosition().y + 55 ) )
    self.longergrapple_500button:SetVisible( false )
    self.longergrapple_500button:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.longergrapple_txt ) self.tip_descrition:SetText( self.longergrapple_description ) self.tip_descrition:SizeToContents() end )
    self.longergrapple_500button:Subscribe( "Press", self, self.LongerGrappleUnlocker )

    self.longergrapple_500button.unlockstats = Rectangle.Create( self.longergrapple_500button )
    self.longergrapple_500button.unlockstats:SetDock( GwenPosition.Fill )
    self.longergrapple_500button.unlockstats:SetColor( self.unlocked_clr )
    self.longergrapple_500button.unlockstats:SetVisible( false )
    self.longergrapple_500button.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.longergrapple_txt ) self.tip_descrition:SetText( self.longergrapple_description ) self.tip_descrition:SizeToContents() end )

    self.longergrapple_500button.image = ImagePanel.Create( self.longergrapple_500button )
    self.longergrapple_500button.image:SetDock( GwenPosition.Fill )
    self.longergrapple_500button.image:SetImage( self.longerGrappleIMG )


    self.jesusmode_button = Button.Create( self.mainlabel )
    self.jesusmode_button:SetSize( Vector2( 50, 50 ) )
    self.jesusmode_button:SetPosition( Vector2( self.longergrapple_150button:GetPosition().x + 60 , 5 ) )
    self.jesusmode_button:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.jesusmode_txt ) self.tip_descrition:SetText( self.jesusmode_description ) self.tip_descrition:SizeToContents() end )
    self.jesusmode_button:Subscribe( "Press", self, self.JesusModeUnlocker )

    self.jesusmode_button.unlockstats = Rectangle.Create( self.jesusmode_button )
    self.jesusmode_button.unlockstats:SetDock( GwenPosition.Fill )
    self.jesusmode_button.unlockstats:SetColor( self.unlocked_clr )
    self.jesusmode_button.unlockstats:Subscribe( "HoverEnter", self, function() self.tip_title:SetText( self.jesusmode_txt ) self.tip_descrition:SetText( self.jesusmode_description ) self.tip_descrition:SizeToContents() end )

    self.jesusmode_button.image = ImagePanel.Create( self.jesusmode_button )
    self.jesusmode_button.image:SetDock( GwenPosition.Fill )
    self.jesusmode_button.image:SetImage( self.jesusModeIMG )

    self.tip_label = Label.Create( self.window )
    self.tip_label:SetDock( GwenPosition.Bottom )
    self.tip_label:SetHeight( Render:GetTextHeight( "A", 18 ) + 60 )
    self.tip_label:SetMargin( Vector2( 10, 10 ), Vector2( 10, 10 ) )

    self.tip_descrition = Label.Create( self.tip_label )
    self.tip_descrition:SetText( self.noselected_description )
    self.tip_descrition:SetTextColor( Color( 220, 220, 220 ) )
    self.tip_descrition:SetTextSize( 12 )
    self.tip_descrition:SetDock( GwenPosition.Bottom )
    self.tip_descrition:SizeToContents()

    self.tip_title = Label.Create( self.tip_label )
    self.tip_title:SetDock( GwenPosition.Bottom )
    self.tip_title:SetText( self.abilities_txt )
    self.tip_title:SetTextSize( 20 )
    self.tip_title:SizeToContents()

    Events:Subscribe( "Lang", self, self.Lang )
    Events:Subscribe( "OpenAbitiliesMenu", self, self.OpenAbitiliesMenu )
    Events:Subscribe( "CloseAbitiliesMenu", self, self.CloseAbitiliesMenu )
end

function Abilities:Lang()
    if self.window then
        self.window:SetTitle( "▧ Abilities" )
    end
    self.needed_txt = "Price"
    self.unlocked_txt = "Unlocked"
    self.morec4_txt = "More C4"
    self.items_txt = "items"
    self.wingsuit_txt = "Wingsuit"
    self.landvehicleboost_txt = "Land Vehicle Boost"
    self.watervehicleboost_txt = "Water Vehicle Boost"
    self.airvehicleboost_txt = "Air Vehicle Boost"
    self.bonusmoney_txt = "Money Bonus"
    self.supernuclearbomb_txt = "SUPER Nuclear Grenade"
    self.longergrapple_txt = "Longer Grapple"
    self.meters_txt = "m"
    self.jesusmode_txt = "Jesus Mode"
    self.abilities_txt = "Abilities"
    self.noselected_description = "Hover over any ability to read the description."
    self.wingsuit_description = "Allows you to fly in the sky."
    self.boost_description = "Accelerates your vehicle at the touch of a button to the speed of light!"
    self.bonusmoney_description = "A cash reward of $100-2500 every hour of play."
    self.moreC4_description = "Increases the maximum number of C4 slots for installation."
    self.supernuclearbomb_description = "A powerful explosion that destroys everything in the vicinity of this magic grenade :)"
    self.longergrapple_description = "Increases the maximum range of the grapple hook shot."
    self.jesusmode_description = "The ability to walk and drive on water."
    self.wingsuittutorial_txt = "Use 'Q' key while in free flight or on a parachute to open the wingsuit."
    self.landvehboosttutorial_txt = "Use 'Shift' key to use super boost."
    self.airvehboosttutorial_txt = "Use 'Q' key to use super boost."
end

function Abilities:Clear()
    Network:Send( "Clear" )
    self:WindowClosed()
end

function Abilities:WingsuitUnlocker()
    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 16,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })

    sound:SetParameter(0,0.75)
    Network:Send( "WingsuitUnlock" )

    self.wingsuitbutton.unlockstats:SetToolTip( self.wingsuit_txt .. " ( " .. self.unlocked_txt .. " )" )
    self.wingsuitbutton.unlockstats:SetVisible( true )

    Events:Fire( "OpenWhatsNew", { titletext = self.wingsuit_txt, text = self.wingsuittutorial_txt } )
end

function Abilities:BoostUnlocker()
    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 16,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })

    sound:SetParameter(0,0.75)
    Network:Send( "BoostUnlock" )

    local boost = LocalPlayer:GetValue( "Boost" )

    if not boost then
        self.boost_1button.unlockstats:SetToolTip( self.landvehicleboost_txt .. " ( " .. self.unlocked_txt .. " )" )
        self.boost_1button.unlockstats:SetVisible( true )

        self.boost_2button:SetToolTip( self.watervehicleboost_txt .. " ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.Boost_2 ) .. " )" )
        self.boost_2button:SetVisible( true )

        Events:Fire( "OpenWhatsNew", { titletext = self.landvehicleboost_txt, text = self.airvehboosttutorial_txt } )
    elseif boost == self.boostValue_1 then
        self.boost_2button.unlockstats:SetToolTip( self.watervehicleboost_txt .. " ( " .. self.unlocked_txt .. " )" )
        self.boost_2button.unlockstats:SetVisible( true )

        self.boost_3button:SetToolTip( self.airvehicleboost_txt .. " ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.Boost_3 ) .. " )" )
        self.boost_3button:SetVisible( true )
    elseif boost == self.boostValue_2 then
        self.boost_3button.unlockstats:SetToolTip( self.airvehicleboost_txt .. " ( " .. self.unlocked_txt .. " )" )
        self.boost_3button.unlockstats:SetVisible( true )

        Events:Fire( "OpenWhatsNew", { titletext = self.airvehicleboost_txt, text = self.airvehboosttutorial_txt } )
    end
end

function Abilities:MoneyBonusUnlocker()
    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 16,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })

    sound:SetParameter(0,0.75)
    Network:Send( "MoneyBonusUnlock" )

    self.bonusmoneybutton.unlockstats:SetToolTip( self.bonusmoney_txt .. " ( " .. self.unlocked_txt .. " )" )
    self.bonusmoneybutton.unlockstats:SetVisible( true )

    Events:Fire( "OpenWhatsNew", { titletext = self.bonusmoney_txt, text = "                                              Поздравляем! Теперь вам доступен денежный бонус.\nДенежный бонус выдается каждый час игры. Чтобы его поулчить - зайдите в меню сервера." } )
end

function Abilities:MoreC4Unlocker()
    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 16,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })

    sound:SetParameter(0,0.75)
    Network:Send( "MoreC4Unlock" )

    local moreC4 = LocalPlayer:GetValue( "MoreC4" )

    if not moreC4 then
        self.moreC4_5button.unlockstats:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_5 .. " " .. self.items_txt .. ") ( " .. self.unlocked_txt .. " )" )
        self.moreC4_5button.unlockstats:SetVisible( true )

        self.moreC4_8button:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_8 .. " " .. self.items_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.MoreC4_8 ) .. " )" )
        self.moreC4_8button:SetVisible( true )
    elseif moreC4 == self.moreC4Value_5 then
        self.moreC4_8button.unlockstats:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_8 .. " " .. self.items_txt .. ") ( " .. self.unlocked_txt .. " )" )
        self.moreC4_8button.unlockstats:SetVisible( true )

        self.moreC4_10button:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_10 .. " " .. self.items_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.MoreC4_10 ) .. " )" )
        self.moreC4_10button:SetVisible( true )
    elseif moreC4 == self.moreC4Value_8 then
        self.moreC4_10button.unlockstats:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_10 .. " " .. self.items_txt .. ") ( " .. self.unlocked_txt .. " )" )
        self.moreC4_10button.unlockstats:SetVisible( true )

        self.moreC4_15button:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_15 .. " " .. self.items_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.MoreC4_15 ) .. " )" )
        self.moreC4_15button:SetVisible( true )
    elseif moreC4 == self.moreC4Value_10 then
        self.moreC4_15button.unlockstats:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_15 .. " " .. self.items_txt .. ") ( " .. self.unlocked_txt .. " )" )
        self.moreC4_15button.unlockstats:SetVisible( true )
    end
end

function Abilities:UpdateButtons( money )
    self.wingsuitbutton:SetEnabled( money >= Prices.Wingsuit )
    self.boost_1button:SetEnabled( money >= Prices.Boost_1 )
    self.boost_2button:SetEnabled( money >= Prices.Boost_2 )
    self.boost_3button:SetEnabled( money >= Prices.Boost_3 )
    self.bonusmoneybutton:SetEnabled( money >= Prices.BonusMoney )
    self.moreC4_5button:SetEnabled( money >= Prices.MoreC4_5 )
    self.moreC4_8button:SetEnabled( money >= Prices.MoreC4_8 )
    self.moreC4_10button:SetEnabled( money >= Prices.MoreC4_10 )
    self.moreC4_15button:SetEnabled( money >= Prices.MoreC4_15 )
    self.supernuclearbombbutton:SetEnabled( money >= Prices.SuperNuclearBomb )
    self.longergrapple_150button:SetEnabled( money >= Prices.LongerGrapple_150 )
    self.longergrapple_200button:SetEnabled( money >= Prices.LongerGrapple_200 )
    self.longergrapple_350button:SetEnabled( money >= Prices.LongerGrapple_350 )
    self.longergrapple_500button:SetEnabled( money >= Prices.LongerGrapple_500 )
    self.jesusmode_button:SetEnabled( money >= Prices.JesusMode )
end

function Abilities:SuperNuclearBombUnlocker()
    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 16,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })

    sound:SetParameter(0,0.75)
    Network:Send( "SuperNuclearBombUnlock" )

    self.supernuclearbombbutton.unlockstats:SetToolTip( self.supernuclearbomb_txt .. " ( " .. self.unlocked_txt .. " )" )
    self.supernuclearbombbutton.unlockstats:SetVisible( true )

    Events:Fire( "OpenWhatsNew", { titletext = self.supernuclearbomb_txt, text = "Попробуйте пролистать список гранат, вы обязательно там её найдете :)\n              Используйте клавишу 'G', чтобы пролистать список гранат." } )
end

function Abilities:LongerGrappleUnlocker()
    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 16,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })

    sound:SetParameter(0,0.75)
    Network:Send( "LongerGrappleUnlock" )

    local longerGrapple = LocalPlayer:GetValue( "LongerGrapple" )

    if not longerGrapple then
        self.longergrapple_150button.unlockstats:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_1 .. " " .. self.meters_txt .. ") ( " .. self.unlocked_txt .. " )" )
        self.longergrapple_150button.unlockstats:SetVisible( true )

        self.longergrapple_200button:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_2 .. " " .. self.meters_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.LongerGrapple_200 ) .. " )" )
        self.longergrapple_200button:SetVisible( true )
    elseif longerGrapple == self.GrappleLongerValue_1 then
        self.longergrapple_200button.unlockstats:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_2 .. " " .. self.meters_txt .. ") ( " .. self.unlocked_txt .. " )" )
        self.longergrapple_200button.unlockstats:SetVisible( true )

        self.longergrapple_350button:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_3 .. " " .. self.meters_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.LongerGrapple_350 ) .. " )" )
        self.longergrapple_350button:SetVisible( true )
    elseif longerGrapple == self.GrappleLongerValue_2 then
        self.longergrapple_350button.unlockstats:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_3 .. " " .. self.meters_txt .. ") ( " .. self.unlocked_txt .. " )" )
        self.longergrapple_350button.unlockstats:SetVisible( true )

        self.longergrapple_500button:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_4 .. " " .. self.meters_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.LongerGrapple_500 ) .. " )" )
        self.longergrapple_500button:SetVisible( true )
    elseif longerGrapple == self.GrappleLongerValue_3 then
        self.longergrapple_500button.unlockstats:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_4 .. " " .. self.meters_txt .. ") ( " .. self.unlocked_txt .. " )" )
        self.longergrapple_500button.unlockstats:SetVisible( true )
    end
end

function Abilities:JesusModeUnlocker()
    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 16,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })

    sound:SetParameter(0,0.75)
    Network:Send( "JesusModeUnlock" )

    self.jesusmode_button.unlockstats:SetToolTip( self.jesusmode_txt .. " ( " .. self.unlocked_txt .. " )" )
    self.jesusmode_button.unlockstats:SetVisible( true )

    Events:Fire( "OpenWhatsNew", { titletext = self.jesusmode_txt, text = "                Поздравляем, теперь вы можете ходить и ездить по воде!\nЗайдите в меню сервера, чтобы включить или отключить режим Иисуса." } )
end

function Abilities:Render()
    local is_visible = Game:GetState() == GUIState.Game

    if self.window:GetVisible() ~= is_visible then
        self.window:SetVisible( is_visible )
    end

    Mouse:SetVisible( is_visible )
end

function Abilities:OpenAbitiliesMenu()
    self:Open()
end

function Abilities:CloseAbitiliesMenu()
	if self.window:GetVisible() == true then
        self:SetWindowVisible( false )

        if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
        if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
        if self.LocalPlayerMoneyChangeEvent then Events:Unsubscribe( self.LocalPlayerMoneyChangeEvent ) self.LocalPlayerMoneyChangeEvent = nil end
	end
end

function Abilities:Open()
    self:SetWindowVisible( not self.active )

    if self.active then
		local effect = ClientEffect.Play(AssetLocation.Game, {
			effect_id = 382,

			position = Camera:GetPosition(),
			angle = Angle()
		})

        if self.window then self:UpdateButtons( LocalPlayer:GetMoney() ) end

        self.tip_title:SetText( self.abilities_txt ) self.tip_descrition:SetText( self.noselected_description ) self.tip_descrition:SizeToContents()
        self.tip_descrition:SetWrap( true )

        if LocalPlayer:GetValue( "SystemFonts" ) then
            self.money_text:SetFont( AssetLocation.SystemFont, "Impact" )
            self.tip_title:SetFont( AssetLocation.SystemFont, "Impact" )
        end

        if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
        if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end
        if not self.LocalPlayerMoneyChangeEvent then self.LocalPlayerMoneyChangeEvent = Events:Subscribe( "LocalPlayerMoneyChange", self, self.LocalPlayerMoneyChange ) end

        if LocalPlayer:GetValue( "Lang" ) then
            self.money_text:SetText( LocalPlayer:GetValue( "Lang" ) == "EN" and "Balance: $" .. formatNumber( LocalPlayer:GetMoney() ) or "Баланс: $" .. formatNumber( LocalPlayer:GetMoney() ) )
            self.money_text:SizeToContents()
        end

        if LocalPlayer:GetValue( "Wingsuit" ) then
            self.wingsuitbutton.unlockstats:SetToolTip( self.wingsuit_txt .. " ( " .. self.unlocked_txt .. " )" )
            self.wingsuitbutton.unlockstats:SetVisible( true )
        else
            self.wingsuitbutton:SetToolTip( self.wingsuit_txt .. " ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.Wingsuit ) .. " )" )
            self.wingsuitbutton.unlockstats:SetVisible( false )
        end

        local boost = LocalPlayer:GetValue( "Boost" )

        if boost then
            self.boost_1button.unlockstats:SetToolTip( self.landvehicleboost_txt .. " ( " .. self.unlocked_txt .. " )" )
            self.boost_1button.unlockstats:SetVisible( true )

            if boost == self.boostValue_1 then
                self.boost_2button:SetToolTip( self.watervehicleboost_txt .. " ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.Boost_2 ) .. " )" )
                self.boost_2button:SetVisible( true )
            end

            if boost >= self.boostValue_2 then
                self.boost_2button.unlockstats:SetToolTip( self.watervehicleboost_txt .. " ( " .. self.unlocked_txt .. " )" )
                self.boost_2button:SetVisible( true )
                self.boost_2button.unlockstats:SetVisible( true )
            end

            if boost == self.boostValue_2 then
                self.boost_3button:SetToolTip( self.airvehicleboost_txt .. " ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.Boost_3 ) .. " )" )
                self.boost_3button:SetVisible( true )
            end

            if boost >= self.boostValue_3 then
                self.boost_3button.unlockstats:SetToolTip( self.airvehicleboost_txt .. " ( " .. self.unlocked_txt .. " )" )
                self.boost_3button:SetVisible( true )
                self.boost_3button.unlockstats:SetVisible( true )
            end
        else
            self.boost_1button:SetToolTip( self.landvehicleboost_txt .. " ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.Boost_1 ) .. " )" )
            self.boost_1button.unlockstats:SetVisible( false )

            self.boost_2button.unlockstats:SetToolTip( self.watervehicleboost_txt .. " ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.Boost_2 ) .. " )" )
            self.boost_2button:SetVisible( false )
            self.boost_2button.unlockstats:SetVisible( false )

            self.boost_3button.unlockstats:SetToolTip( self.airvehicleboost_txt .. " ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.Boost_3 ) .. " )" )
            self.boost_3button:SetVisible( false )
            self.boost_3button.unlockstats:SetVisible( false )
        end

        if LocalPlayer:GetValue( "MoneyBonus" ) then
            self.bonusmoneybutton.unlockstats:SetToolTip( self.bonusmoney_txt .. " ( " .. self.unlocked_txt .. " )" )
            self.bonusmoneybutton.unlockstats:SetVisible( true )
        else
            self.bonusmoneybutton:SetToolTip( self.bonusmoney_txt .. " ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.BonusMoney ) .. " )" )
            self.bonusmoneybutton.unlockstats:SetVisible( false )
        end

        local moreC4 = LocalPlayer:GetValue( "MoreC4" )

        if moreC4 then
            self.moreC4_5button.unlockstats:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_5 .. " " .. self.items_txt .. ") ( " .. self.unlocked_txt .. " )" )
            self.moreC4_5button.unlockstats:SetVisible( true )

            if moreC4 == self.moreC4Value_5 then
                self.moreC4_8button:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_8 .. " " .. self.items_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.MoreC4_8 ) .. " )" )
                self.moreC4_8button:SetVisible( true )
            end

            if moreC4 >= self.moreC4Value_8 then
                self.moreC4_8button.unlockstats:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_8 .." " .. self.items_txt .. ") ( " .. self.unlocked_txt .. " )" )
                self.moreC4_8button:SetVisible( true )
                self.moreC4_8button.unlockstats:SetVisible( true )
            end

            if LmoreC4 == self.moreC4Value_8 then
                self.moreC4_10button:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_10 .. " " .. self.items_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.MoreC4_10 ) .. " )" )
                self.moreC4_10button:SetVisible( true )
            end

            if moreC4 >= self.moreC4Value_10 then
                self.moreC4_10button.unlockstats:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_10 .. " " .. self.items_txt .. ") ( " .. self.unlocked_txt .. " )" )
                self.moreC4_10button:SetVisible( true )
                self.moreC4_10button.unlockstats:SetVisible( true )
            end

            if moreC4 == self.moreC4Value_10 then
                self.moreC4_15button:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_15 .. " " .. self.items_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.MoreC4_15 ) .. " )" )
                self.moreC4_15button:SetVisible( true )
            end

            if moreC4 >= self.moreC4Value_15 then
                self.moreC4_15button.unlockstats:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_15 .. " " .. self.items_txt .. ") ( " .. self.unlocked_txt .. " )" )
                self.moreC4_15button:SetVisible( true )
                self.moreC4_15button.unlockstats:SetVisible( true )
            end
        else
            self.moreC4_5button:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_5 .. " " .. self.items_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.MoreC4_5 ) .. " )" )
            self.moreC4_5button.unlockstats:SetVisible( false )

            self.moreC4_8button:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_8 .. " " .. self.items_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.MoreC4_8 ) .. " )" )
            self.moreC4_8button:SetVisible( false )
            self.moreC4_8button.unlockstats:SetVisible( false )

            self.moreC4_10button:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_10 .. " " .. self.items_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.MoreC4_10 ) .. " )" )
            self.moreC4_10button:SetVisible( false )
            self.moreC4_10button.unlockstats:SetVisible( false )

            self.moreC4_15button:SetToolTip( self.morec4_txt .. " (" .. self.moreC4Value_15 .. " " .. self.items_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.MoreC4_15 ) .. " )" )
            self.moreC4_15button:SetVisible( false )
            self.moreC4_15button.unlockstats:SetVisible( false )
        end

        if LocalPlayer:GetValue( "SuperNuclearBomb" ) then
            self.supernuclearbombbutton.unlockstats:SetToolTip( self.supernuclearbomb_txt .. " ( " .. self.unlocked_txt .. " )" )
            self.supernuclearbombbutton.unlockstats:SetVisible( true )
        else
            self.supernuclearbombbutton:SetToolTip( self.supernuclearbomb_txt .. " ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.SuperNuclearBomb ) .. " )" )
            self.supernuclearbombbutton.unlockstats:SetVisible( false )
        end

        local longerGrapple = LocalPlayer:GetValue( "LongerGrapple" )

        if longerGrapple then
            self.longergrapple_150button.unlockstats:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_1 .. " " .. self.meters_txt .. ") ( " .. self.unlocked_txt .. " )" )
            self.longergrapple_150button.unlockstats:SetVisible( true )

            if longerGrapple == self.GrappleLongerValue_1 then
                self.longergrapple_200button:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_2 .. " " .. self.meters_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.LongerGrapple_200 ) .. " )" )
                self.longergrapple_200button:SetVisible( true )
            end

            if longerGrapple >= self.GrappleLongerValue_2 then
                self.longergrapple_200button.unlockstats:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_2 .. " " .. self.meters_txt .. ") ( " .. self.unlocked_txt .. " )" )
                self.longergrapple_200button:SetVisible( true )
                self.longergrapple_200button.unlockstats:SetVisible( true )
            end

            if longerGrapple == self.GrappleLongerValue_2 then
                self.longergrapple_350button:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_3 .. " " .. self.meters_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.LongerGrapple_350 ) .. " )" )
                self.longergrapple_350button:SetVisible( true )
            end

            if longerGrapple >= self.GrappleLongerValue_3 then
                self.longergrapple_350button.unlockstats:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_3 .. " " .. self.meters_txt .. ") ( " .. self.unlocked_txt .. " )" )
                self.longergrapple_350button:SetVisible( true )
                self.longergrapple_350button.unlockstats:SetVisible( true )
            end

            if longerGrapple == self.GrappleLongerValue_3 then
                self.longergrapple_500button:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_4 .. " " .. self.meters_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.LongerGrapple_500 ) .. " )" )
                self.longergrapple_500button:SetVisible( true )
            end

            if longerGrapple >= self.GrappleLongerValue_4 then
                self.longergrapple_500button.unlockstats:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_4 .. " " .. self.meters_txt .. ") ( " .. self.unlocked_txt .. " )" )
                self.longergrapple_500button:SetVisible( true )
                self.longergrapple_500button.unlockstats:SetVisible( true )
            end
        else
            self.longergrapple_150button:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_1 .. " " .. self.meters_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.LongerGrapple_150 ) .. " )" )
            self.longergrapple_150button.unlockstats:SetVisible( false )

            self.longergrapple_200button:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_2 .. " " .. self.meters_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.LongerGrapple_200 ) .. " )" )
            self.longergrapple_200button:SetVisible( false )
            self.longergrapple_200button.unlockstats:SetVisible( false )

            self.longergrapple_350button:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_3 .. " " .. self.meters_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.LongerGrapple_350 ) .. " )" )
            self.longergrapple_350button:SetVisible( false )
            self.longergrapple_350button.unlockstats:SetVisible( false )

            self.longergrapple_500button:SetToolTip( self.longergrapple_txt .. " (" .. self.GrappleLongerValue_4 .. " " .. self.meters_txt .. ") ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.LongerGrapple_500 ) .. " )" )
            self.longergrapple_500button:SetVisible( false )
            self.longergrapple_500button.unlockstats:SetVisible( false )
        end

        if LocalPlayer:GetValue( "JesusModeEnabled" ) then
            self.jesusmode_button.unlockstats:SetToolTip( self.jesusmode_txt .. " ( " .. self.unlocked_txt .. " )" )
            self.jesusmode_button.unlockstats:SetVisible( true )
        else
            self.jesusmode_button:SetToolTip( self.jesusmode_txt .. " ( " .. self.needed_txt .. ": $" .. formatNumber( Prices.JesusMode ) .. " )" )
            self.jesusmode_button.unlockstats:SetVisible( false )
        end
    end
end

function Abilities:UpdateMoneyString( money )
    if money == nil then
        money = LocalPlayer:GetMoney()
    end

    if LocalPlayer:GetValue( "Lang" ) then
        self.money_text:SetText( LocalPlayer:GetValue( "Lang" ) == "EN" and "Balance: $" .. formatNumber( money ) or "Баланс: $" .. formatNumber( money ) )
        self.money_text:SizeToContents()
    end
end

function Abilities:LocalPlayerMoneyChange( args )
    self:UpdateMoneyString( args.new_money )

    if self.window then self:UpdateButtons( args.new_money ) end
end

function Abilities:SetWindowVisible( visible )
    if self.active ~= visible then
		self.active = visible
		self.window:SetVisible( visible )
		Mouse:SetVisible( visible )
	end
end

function Abilities:LocalPlayerInput( args )
	if args.input == Action.GuiPause then
        self:CloseAbitiliesMenu()
	end
    if self.actions[args.input] then
        return false
    end
end

function Abilities:WindowClosed()
	if self.window:GetVisible() == true then
        local effect = ClientEffect.Create(AssetLocation.Game, {
            effect_id = 383,
    
            position = Camera:GetPosition(),
            angle = Angle()
        })

        self:SetWindowVisible( false )

        if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
        if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
        if self.LocalPlayerMoneyChangeEvent then Events:Unsubscribe( self.LocalPlayerMoneyChangeEvent ) self.LocalPlayerMoneyChangeEvent = nil end
	end
end

abilities = Abilities()
class 'Menu'

function Menu:__init()
    self.step = 0

    --self.rusFlag = Image.Create( AssetLocation.Resource, "RusFlag" )
	--self.engFlag = Image.Create( AssetLocation.Resource, "EngFlag" )

    self.qrTelegram = Image.Create( AssetLocation.Resource, "QRTelegram" )
    self.qrDiscord = Image.Create( AssetLocation.Resource, "QRDiscord" )
    self.qrSteam = Image.Create( AssetLocation.Resource, "QRSteam" )
    self.qrYouTube = Image.Create( AssetLocation.Resource, "QRYouTube" )
    self.qrBoosty = Image.Create( AssetLocation.Resource, "QRBoosty" )

    Chat:SetEnabled( false )

    Game:FireEvent( "ply.pause" )

    local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
        self.locStrings = {
            welcomeTitle = "Добро пожаловать на Koast Freeroam :3",
            initialSetup = "Первоначальная настройка",
            nicknameColor = "Цвет ника",
            promocode = "Промокод",
            promocodeDescription = "Если у вас имеется промокод - введите его здесь.",
            enterpromocode = "Введите промокод",
            skip = "Пропустить",
            apply = "Применить",
            next = "Далее >",
            continue = "Продолжить ( ͡° ͜ʖ ͡°)",
            setupFinished = "Настройка завершена! Приятной игры :3"
        }
	end

    self.LangEvent = Events:Subscribe( "Lang", self, self.Lang )
    self.ModuleUnloadEvent = Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
    self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
    self.ResolutionChangeEvent = Events:Subscribe( "ResolutionChange", self, self.ResolutionChange )
    self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
    --self.CalcViewEvent = Events:Subscribe( "CalcView", self, self.CalcView )

	if Game:GetState() ~= GUIState.Loading then
		self:GameLoad()
	else
		self.GameLoadEvent = Events:Subscribe( "GameLoad", self, self.GameLoad )
	end
end

function Menu:Lang()
    self.locStrings = {
        welcomeTitle = "Welcome to Koast Freeroam :3",
        initialSetup = "Initial Setup",
        nicknameColor = "Nickname Color",
        promocode = "Promo Code",
        promocodeDescription = "If you have a promo code, enter it here.",
        enterpromocode = "Enter promo code",
        skip = "Skip",
        apply = "Apply",
        next = "Next >",
        continue = "Continue ( ͡° ͜ʖ ͡°)",
        setupFinished = "Setup completed! Enjoy the game :3"
    }
end

function Menu:LangItem( langCode, langFull, flag )
    local langItem = ModernGUI.Button.Create( self.langScreen.list )
    langItem:SetDock( GwenPosition.Top )
    langItem:SetHeight( 40 )
    langItem:SetMargin( Vector2( 0, 3 ), Vector2( 0, 3 ) )
    langItem:SetText( "[" .. langCode .. "] " .. langFull )
    if LocalPlayer:GetValue( "SystemFonts" ) then
        langItem:SetFont( AssetLocation.SystemFont, "Impact" )
    end
    langItem:SetAlignment( GwenPosition.CenterV )
    langItem:SetTextPadding( Vector2( 20, 0 ), Vector2( 75, 0 ) )
    langItem:Subscribe( "Press", function() Network:Send( "SetLang", { lang = langCode } ) self:NextStep() end )

    --[[local langFlag = ImagePanel.Create( langItem.button )
    langFlag:SetDock( GwenPosition.Left )
    langFlag:SetImage( flag )
    langFlag:SetWidth( 65 )]]--

    local langArrow = Label.Create( langItem.button )
    langArrow:SetDock( GwenPosition.Right )
    langArrow:SetAlignment( GwenPosition.CenterV )
    langArrow:SetMargin( Vector2( 17, 0 ), Vector2( 20, 0 ) )
    langArrow:SetText( ">" )
    langArrow:SetTextSize( 20 )
    if LocalPlayer:GetValue( "SystemFonts" ) then
        langArrow:SetFont( AssetLocation.SystemFont, "Impact" )
    end
    langArrow:SizeToContents()

    langItem:Subscribe( "HoverEnter", function() Animation:Play( 20, 17, 0.1, easeIOnut, function( value ) if IsValid( langArrow ) then langArrow:SetMargin( Vector2( 15, 0 ), Vector2( value, 0 ) ) end end ) end )
    langItem:Subscribe( "HoverLeave", function() Animation:Play( 17, 20, 0.1, easeIOnut, function( value ) if IsValid( langArrow ) then langArrow:SetMargin( Vector2( 15, 0 ), Vector2( value, 0 ) ) end end ) end )

    local result = { langItem = langItem, langArrow = langArrow }

    function result:Remove()
        if result.langItem then result.langItem:Remove() result.langItem = nil end
        --if result.langFlag then result.langFlag:Remove() result.langFlag = nil end
        if result.langArrow then result.langArrow:Remove() result.langArrow = nil end
    end

    return result
end

function Menu:QRLink( parent, titleText, qrImage, linkText )
    local window = ModernGUI.Window.Create( parent or "" )

    local title = Label.Create( window.window )
    title:SetDock( GwenPosition.Top )
    local margin = Vector2( 10, 5 )
    title:SetMargin( Vector2( 10, 10 ), margin )
    title:SetAlignment( GwenPosition.Center )
    title:SetText( titleText )
    title:SetTextSize( 20 )
    if LocalPlayer:GetValue( "SystemFonts" ) then
        title:SetFont( AssetLocation.SystemFont, "Impact" )
    end
    title:SizeToContents()

    local qr = ImagePanel.Create( window.window )
    qr:SetDock( GwenPosition.Fill )
    qr:SetMargin( margin, margin )
    qr:SetImage( qrImage )

    local link = TextBox.Create( window.window )
    link:SetDock( GwenPosition.Bottom )
    local margin = Vector2( 3, 3 )
    link:SetMargin( margin, margin )
    link:SetText( linkText )
    link:SetTextColor( Color.White )
    link:SetBackgroundVisible( false )
    link:Subscribe( "Render", function() link:SetAlignment( GwenPosition.CenterH ) end )
    local text = link:GetText()
    link:Subscribe( "TextChanged", function() link:SetText( text ) end )

    local result = { window = window, title = title, qr = qr, link = link }

    function result:Remove()
        if result.window then result.window:Remove() result.window = nil end
        if result.title then result.title:Remove() result.title = nil end
        if result.qr then result.qr:Remove() result.qr = nil end
        if result.link then result.link:Remove() result.link = nil end
    end

    return result
end

function Menu:GameLoad()
    Mouse:SetPosition( Vector2( Render.Width / 2, Render.Height / 2 ) )

    self:ChangeStep( self.step )

    if self.GameLoadEvent then Events:Unsubscribe( self.GameLoadEvent ) self.GameLoadEvent = nil end
end

function Menu:Render()
    Game:FireEvent( "gui.hud.hide" )
    Game:FireEvent( "gui.minimap.hide" )

    Render:FillArea( Vector2.Zero, Render.Size, Color( 10, 10, 10, 200 ) )

    if self.rico and self.rico:GetAlpha() > 0 then
        self.rico:Draw()
    end

    local version_txt = "KMod Version: " .. tostring( LocalPlayer:GetValue( "KoastBuild" ) )

    if LocalPlayer:GetValue( "KoastBuild" ) then
        --Render:DrawText( Vector2( (Render.Width - Render:GetTextWidth( version_txt, 15 ) - 30 ), Render.Size.y - 45 ), version_txt, Color( 255, 255, 255, 100 ), 15 )
    end

    if self.welcomeTextAlpha then
        if LocalPlayer:GetValue( "SystemFonts" ) then Render:SetFont( AssetLocation.SystemFont, "Impact" ) end

        local textSize = 36

        Render:DrawShadowedText( Vector2( Render.Size.x / 2 - Render:GetTextWidth( self.locStrings["welcomeTitle"], textSize ) / 2, self.welcomeTextPos ), self.locStrings["welcomeTitle"], Color( 255, 255, 255, self.welcomeTextAlpha ), Color( 0, 0, 0, self.welcomeTextAlpha ), textSize )
    end

    if self.welcomeScreenTimer then
        local welcomeScreenSeconds = self.welcomeScreenTimer:GetSeconds()

        if welcomeScreenSeconds >= 0.5 then
            if not self.rico then
                self.rico = Image.Create( AssetLocation.Resource, "Rico" )
                self.rico:SetSize( Vector2( Render.Size.x / 5.5, Render.Size.x / 2.65 ) * 1.5 )
                self.rico:SetPosition( Vector2( Render.Size.x / 1.42, Render.Size.y ) )
                self.rico:SetAlpha( 0 )

                Animation:Play( 0, 255, 2, easeInOut, function( value ) self.welcomeTextAlpha = value end )
                Animation:Play( Render.Size.y, Render.Size.y / 1.2 - self.rico:GetSize().y / 2, 2, easeInOut, function( value ) self.rico:SetPosition( Vector2( self.rico:GetPosition().x, value ) ) end )
                Animation:Play( self.rico:GetAlpha(), 1, 1, easeIOnut, function( value ) self.rico:SetAlpha( value ) end )
            end
        end

        if welcomeScreenSeconds >= 5 then
            Animation:Play( self.rico:GetPosition().y, Render.Size.y, 2, easeInOut, function( value ) self.rico:SetPosition( Vector2( self.rico:GetPosition().x, value ) ) end )
            Animation:Play( self.rico:GetAlpha(), 0, 2, easeInOut, function( value ) self.rico:SetAlpha( value ) end )
            Animation:Play( self.welcomeTextPos, Render.Size.y / 6, 2, easeInOut, function( value ) self.welcomeTextPos = value end )

            self.welcomeScreenTimer = nil

            self:NextStep()
        end
    end

    local visiblity = Game:GetState() ~= GUIState.Loading

    if self.langScreen then self.langScreen.window:SetVisible( visiblity ) end
    if self.nicknameColorScreen then self.nicknameColorScreen.label:SetVisible( visiblity ) end
    if self.rulesScreen then self.rulesScreen.label:SetVisible( visiblity ) end

    if LocalPlayer:GetValue( "SystemFonts" ) then
        if self.langList then
            for _, v in pairs( self.langList ) do
                if IsValid( v ) then
                    v.langItem:SetFont( AssetLocation.SystemFont, "Impact" )
                    v.langArrow:SetFont( AssetLocation.SystemFont, "Impact" )
                end
            end
        end
	end
end

function Menu:ResolutionChange( args )
    if self.langScreen then
        local langScreenSize = self.langScreen.window:GetSize()
        self.langScreen.window:SetPosition( Vector2( args.size.x / 2 - langScreenSize.x / 2, args.size.y / 2 - langScreenSize.y / 2 ) )
    end

    if self.welcomeTextPos and not self.welcomeScreenTimer then
        self.welcomeTextPos = args.size.y / 6
    end

    if self.nicknameColorScreen then
        local nicknameColorScreenSize = self.nicknameColorScreen.label:GetSize()
        self.nicknameColorScreen.label:SetPosition( Vector2( args.size.x / 2 - nicknameColorScreenSize.x / 2, args.size.y / 1.85 - nicknameColorScreenSize.y / 2 ) )
    end

    if self.rulesScreen then
        local rulesScreenSize = self.rulesScreen.label:GetSize()
        self.rulesScreen.label:SetPosition( Vector2( args.size.x / 2 - rulesScreenSize.x / 2, args.size.y / 1.85 - rulesScreenSize.y / 2 ) )
    end

    if self.linksScreen then
        local linksScreenSize = self.linksScreen.telegram.window:GetSize()
        local space = 8
        local finalPos = ( args.size.y / 2 - linksScreenSize.x / 2 ) - 20
        local pos = Vector2( args.size.x / 2 - linksScreenSize.x / 2 * 4 - space, finalPos )

        self.linksScreen.telegram.window:SetPosition( pos )

        pos.x = pos.x + linksScreenSize.x + space
        self.linksScreen.discord.window:SetPosition( pos )

        pos.x = pos.x + linksScreenSize.x + space
        self.linksScreen.steam.window:SetPosition( pos )

        pos.x = pos.x + linksScreenSize.x + space
        self.linksScreen.youtube.window:SetPosition( pos )

        if self.linksScreen.nextButton then
            local linkScreenSize = self.linksScreen.nextButton:GetSize()
            self.linksScreen.nextButton:SetPosition( Vector2( args.size.x / 2 - linkScreenSize.x / 2, finalPos + linksScreenSize.y + 60 ) )
        end
    end
end

function Menu:LocalPlayerInput()
    return false
end

function Menu:CalcView()
    Camera:SetPosition( Vector3( -5942.5, 203.3, 605.4 ) )
    Camera:SetAngle( Angle( -0.9, 0.2, 0.0 ) )
    return false
end

function Menu:ChangeStep( step )
    if step == 0 then
        Mouse:SetVisible( true )

        if self.langScreen then return end

        self.langScreen = {}

        self.langScreen.window = ModernGUI.Window.Create()
        self.langScreen.window:SetSize( Vector2( 500, 120 ) )
        local langScreenSize = self.langScreen.window:GetSize()
        self.langScreen.window:SetPosition( Vector2( Render.Size.x / 2 - langScreenSize.x / 2, Render.Size.y / 2 - langScreenSize.y / 2 ) )

        self.langScreen.list = ScrollControl.Create( self.langScreen.window.window )
        self.langScreen.list:SetDock( GwenPosition.Fill )
        local padding = Vector2( 10, 10 )
        self.langScreen.list:SetMargin( padding, padding )
        self.langScreen.list:SetScrollable( false, true )

        self.langList = {}
        self.langList.ru = self:LangItem( "RU", "Русский" )
        self.langList.en = self:LangItem( "EN", "English" )

        --[[
        self.langList.fr = self:LangItem( "FR", "Français" )
        self.langList.de = self:LangItem( "DE", "Deutsch" )
        self.langList.es = self:LangItem( "ES", "Español" )
        self.langList.it = self:LangItem( "IT", "Italiano" )
        self.langList.pt = self:LangItem( "PT", "Português" )
        self.langList.zh = self:LangItem( "ZH", "中文" )
        self.langList.ja = self:LangItem( "JA", "日本語" )
        self.langList.ko = self:LangItem( "KO", "한국어" )
        self.langList.ar = self:LangItem( "AR", "العربية" )
        self.langList.he = self:LangItem( "HE", "עברית" )
        self.langList.tr = self:LangItem( "TR", "Türkçe" )
        self.langList.pl = self:LangItem( "PL", "Polski" )
        self.langList.nl = self:LangItem( "NL", "Nederlands" )
        self.langList.sv = self:LangItem( "SV", "Svenska" )
        self.langList.da = self:LangItem( "DA", "Dansk" )
        self.langList.fi = self:LangItem( "FI", "Suomi" )
        self.langList.no = self:LangItem( "NO", "Norsk" )
        self.langList.cs = self:LangItem( "CS", "Čeština" )
        self.langList.hu = self:LangItem( "HU", "Magyar" )
        self.langList.el = self:LangItem( "EL", "Ελληνικά" )
        self.langList.ro = self:LangItem( "RO", "Română" )
        self.langList.id = self:LangItem( "ID", "Bahasa Indonesia" )
        ]]--
        
        self.langList.en.langItem:Subscribe( "Press", function() Events:Fire( "Lang" ) end )
    elseif step == 1 then
        Mouse:SetVisible( false )

        local sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 18,
            sound_id = 1,
            position = Camera:GetPosition(),
            angle = Angle()
        })

        sound:SetParameter(0,1)

        if self.langScreen then self:RemoveScreen( self.langScreen ) self.langScreen = nil end
        if self.langList then self:RemoveScreen( self.langList ) self.langList = nil end

        if LocalPlayer:GetValue( "Registered" ) then self.step = 3 self:NextStep() return false end

        if not self.welcomeScreenTimer then
            self.welcomeScreenTimer = Timer()
        end

        self.welcomeTextPos = Render.Size.y / 2
        self.welcomeTextAlpha = 0
    elseif step == 2 then
        Mouse:SetVisible( true )

        if self.promocodes then return end

        self.PromocodeFoundEvent = Events:Subscribe( "PromocodeFound", function() self:NextStep() end )
        self.PromocodeNotFoundEvent = Events:Subscribe( "PromocodeNotFound", function()
            self.promocodes.textBox:SetTextColor( Color.Red )

            local sound = ClientSound.Create(AssetLocation.Game, {
                bank_id = 18,
                sound_id = 7,
                position = Camera:GetPosition(),
                angle = Angle()
            })

            sound:SetParameter(0,1)
        end )

        self.promocodes = {}

        local description = self.locStrings["promocodeDescription"]
        self.promocodes.label = Label.Create()
        self.promocodes.label:SetSize( Vector2( math.clamp( Render:GetTextWidth( description, 18 ) + 50, 500, Render.Size.x ), ( Render:GetTextHeight( "A", 30 ) * 1.5 ) + 200) )
        self.promocodes.label:SetPosition( Vector2( Render.Size.x / 2 - self.promocodes.label:GetSize().x / 2, Render.Size.y ) )
        local padding = Vector2( 30, 30 )
        self.promocodes.label:SetPadding( padding, padding )

        self.promocodes.title = Label.Create( self.promocodes.label )
        self.promocodes.title:SetDock( GwenPosition.Top )
        self.promocodes.title:SetText( self.locStrings["promocode"] )
        padding = Vector2( 20, 20 )
        self.promocodes.title:SetMargin( padding, padding )
        self.promocodes.title:SetAlignment( GwenPosition.Center )
        if LocalPlayer:GetValue( "SystemFonts" ) then
            self.promocodes.title:SetFont( AssetLocation.SystemFont, "Impact" )
        end
        self.promocodes.title:SetTextSize( 30 )
        self.promocodes.title:SizeToContents()

        self.promocodes.window = ModernGUI.Window.Create( self.promocodes.label )
        self.promocodes.window:SetDock( GwenPosition.Fill )

        self.promocodes.windowTitle = Label.Create( self.promocodes.window.window )
        self.promocodes.windowTitle:SetDock( GwenPosition.Top )
        self.promocodes.windowTitle:SetMargin( Vector2( 10, 10 ), Vector2( 10, 5 ) )
        self.promocodes.windowTitle:SetText( description )
        if LocalPlayer:GetValue( "SystemFonts" ) then
            self.promocodes.windowTitle:SetFont( AssetLocation.SystemFont, "Impact" )
        end
        self.promocodes.windowTitle:SetTextSize( 18 )
        self.promocodes.windowTitle:SizeToContents()

        self.promocodes.scroll = ScrollControl.Create( self.promocodes.window.window )
        self.promocodes.scroll:SetDock( GwenPosition.Fill )
        self.promocodes.scroll:SetMargin( Vector2( 5, 0 ), Vector2( 5, 0 ) )
        self.promocodes.scroll:SetScrollable( false, true )

        self.promocodes.textBox = ModernGUI.TextBox.Create( self.promocodes.scroll )
        self.promocodes.textBox:SetDock( GwenPosition.Top )
        self.promocodes.textBox:SetMargin( Vector2( 2, 5 ), Vector2( 2, 2 ) )
        self.promocodes.textBox:InsertText( self.locStrings["enterpromocode"] )
        self.promocodes.textBox_color = self.promocodes.textBox:GetTextColor()
        self.promocodes.textBox:Subscribe( "TextChanged", self, function() self.promocodes.textBox:SetTextColor( self.promocodes.textBox_color ) end )
        self.promocodes.textBox:Subscribe( "ReturnPressed", function() Events:Fire( "ApplyPromocode", { type = 1, name = self.promocodes.textBox:GetText() } ) end )

        self.promocodes.bottom = Label.Create( self.promocodes.window.window )
        self.promocodes.bottom:SetDock( GwenPosition.Bottom )
        self.promocodes.bottom:SetHeight( 40 )

        self.promocodes.skipButton = ModernGUI.Button.Create( self.promocodes.bottom )
        self.promocodes.skipButton:SetDock( GwenPosition.Left )
        self.promocodes.skipButton:SetWidth( self.promocodes.label:GetWidth() / 2.5 )
        self.promocodes.skipButton:SetText( self.locStrings["skip"] )
        if LocalPlayer:GetValue( "SystemFonts" ) then
            self.promocodes.skipButton:SetFont( AssetLocation.SystemFont, "Impact" )
        end
        padding = Vector2( 5, 5 )
        self.promocodes.skipButton:SetMargin( padding, padding )
        self.promocodes.skipButton:Subscribe( "Press", function() self:NextStep() end )

        self.promocodes.nextButton = ModernGUI.Button.Create( self.promocodes.bottom )
        self.promocodes.nextButton:SetDock( GwenPosition.Right )
        self.promocodes.nextButton:SetWidth( self.promocodes.label:GetWidth() / 2.5 )
        self.promocodes.nextButton:SetText( self.locStrings["apply"] )
        if LocalPlayer:GetValue( "SystemFonts" ) then
            self.promocodes.nextButton:SetFont( AssetLocation.SystemFont, "Impact" )
        end
        padding = Vector2( 5, 5 )
        self.promocodes.nextButton:SetMargin( padding, padding )
        self.promocodes.nextButton:Subscribe( "Press", function() Events:Fire( "ApplyPromocode", { type = 1, name = self.promocodes.textBox:GetText() } ) end )

        Animation:Play( self.promocodes.label:GetPosition().y, ( Render.Size.y / 2 - self.promocodes.label:GetSize().y / 2 ) + 50, 2, easeInOut, function( value ) if self.promocodes then self.promocodes.label:SetPosition( Vector2( Render.Size.x / 2 - self.promocodes.label:GetSize().x / 2, value ) ) end end )
    elseif step == 3 then
        Mouse:SetVisible( true )

        local sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 18,
            sound_id = 1,
            position = Camera:GetPosition(),
            angle = Angle()
        })

        sound:SetParameter(0,1)

        if self.PromocodeFoundEvent then Events:Unsubscribe( self.PromocodeFoundEvent ) self.PromocodeFoundEvent = nil end
        if self.PromocodeNotFoundEvent then Events:Unsubscribe( self.PromocodeNotFoundEvent ) self.PromocodeNotFoundEvent = nil end

        if self.promocodes then self:RemoveScreen( self.promocodes ) self.promocodes = nil end

        if self.nicknameColorScreen then return end

        self.nicknameColorScreen = {}

        local description = self.locStrings["initialSetup"]
        self.nicknameColorScreen.label = Label.Create()
        self.nicknameColorScreen.label:SetSize( Vector2( math.clamp( Render:GetTextWidth( description, 30 ) + 100, 650, Render.Size.x ), 500 ) )
        self.nicknameColorScreen.label:SetPosition( Vector2( Render.Size.x / 2 - self.nicknameColorScreen.label:GetSize().x / 2, Render.Size.y ) )
        local padding = Vector2( 30, 30 )
        self.nicknameColorScreen.label:SetPadding( padding, padding )

        self.nicknameColorScreen.title = Label.Create( self.nicknameColorScreen.label )
        self.nicknameColorScreen.title:SetDock( GwenPosition.Top )
        self.nicknameColorScreen.title:SetText( description )
        padding = Vector2( 20, 20 )
        self.nicknameColorScreen.title:SetMargin( padding, padding )
        self.nicknameColorScreen.title:SetAlignment( GwenPosition.Center )
        if LocalPlayer:GetValue( "SystemFonts" ) then
            self.nicknameColorScreen.title:SetFont( AssetLocation.SystemFont, "Impact" )
        end
        self.nicknameColorScreen.title:SetTextSize( 30 )
        self.nicknameColorScreen.title:SizeToContents()

        self.nicknameColorScreen.window = ModernGUI.Window.Create( self.nicknameColorScreen.label )
        self.nicknameColorScreen.window:SetDock( GwenPosition.Fill )

        self.nicknameColorScreen.windowTitle = Label.Create( self.nicknameColorScreen.window.window )
        self.nicknameColorScreen.windowTitle:SetDock( GwenPosition.Top )
        self.nicknameColorScreen.windowTitle:SetMargin( Vector2( 10, 10 ), Vector2( 10, 5 ) )
        self.nicknameColorScreen.windowTitle:SetText( self.locStrings["nicknameColor"] )
        if LocalPlayer:GetValue( "SystemFonts" ) then
            self.nicknameColorScreen.windowTitle:SetFont( AssetLocation.SystemFont, "Impact" )
        end
        self.nicknameColorScreen.windowTitle:SetTextSize( 18 )
        self.nicknameColorScreen.windowTitle:SizeToContents()

        local lpColor = LocalPlayer:GetColor()

        self.nicknameColorScreen.preview = Label.Create( self.nicknameColorScreen.window.window )
        self.nicknameColorScreen.preview:SetDock( GwenPosition.Top )
        self.nicknameColorScreen.preview:SetPadding( Vector2( 10, 0 ), Vector2( 10, 10 ) )
        self.nicknameColorScreen.preview:SetText( LocalPlayer:GetName() )
        self.nicknameColorScreen.preview:SetTextColor( lpColor )
        self.nicknameColorScreen.preview:SetTextSize( 14 )
        self.nicknameColorScreen.preview:SizeToContents()

        self.nicknameColorScreen.picker = HSVColorPicker.Create( self.nicknameColorScreen.window.window )
        self.nicknameColorScreen.picker:SetColor( lpColor )
        self.nicknameColorScreen.picker:SetDock( GwenPosition.Fill )
        self.nicknameColorScreen.picker:Subscribe( "ColorChanged", function()
            self.nicknameColorScreen.preview:SetTextColor( lpColor )

            lpColor = self.nicknameColorScreen.picker:GetColor()
            self.colorChanged = true
        end )

        self.nicknameColorScreen.nextButton = ModernGUI.Button.Create( self.nicknameColorScreen.window.window )
        self.nicknameColorScreen.nextButton:SetDock( GwenPosition.Bottom )
        self.nicknameColorScreen.nextButton:SetText( self.locStrings["next"] )
        if LocalPlayer:GetValue( "SystemFonts" ) then
            self.nicknameColorScreen.nextButton:SetFont( AssetLocation.SystemFont, "Impact" )
        end
        padding = Vector2( 5, 5 )
        self.nicknameColorScreen.nextButton:SetMargin( padding, padding )
        self.nicknameColorScreen.nextButton:SetHeight( 40 )
        self.nicknameColorScreen.nextButton:Subscribe( "Press", function() Network:Send( "SetPlayerColor", { color = lpColor } ) self:NextStep() end )

        Animation:Play( self.nicknameColorScreen.label:GetPosition().y, ( Render.Size.y / 2 - self.nicknameColorScreen.label:GetSize().y / 2 ) + 50, 1, easeInOut, function( value ) if self.nicknameColorScreen then self.nicknameColorScreen.label:SetPosition( Vector2( Render.Size.x / 2 - self.nicknameColorScreen.label:GetSize().x / 2, value ) ) end end )
    elseif step == 4 then
        Mouse:SetVisible( true )

        local sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 18,
            sound_id = 1,
            position = Camera:GetPosition(),
            angle = Angle()
        })

        sound:SetParameter(0,1)

        if self.nicknameColorScreen then self:RemoveScreen( self.nicknameColorScreen ) self.nicknameColorScreen = nil end

        local size = Render.Size / 3.25 - Vector2( Render.Size.x / 6.15, 0 )
        local space = 8
        local pos = Vector2( Render.Size.x / 2 - size.x / 2 * 4 - space, Render.Size.y )

        if self.linksScreen then return end

        self.linksScreen = {}

        self.linksScreen.telegram = self:QRLink( nil, "Telegram", self.qrTelegram, "t.me/koastfreeroam" )
        self.linksScreen.telegram.window:SetPosition( pos )
        self.linksScreen.telegram.window:SetSize( size )

        self.linksScreen.discord = self:QRLink( nil, "Discord", self.qrDiscord, "t.me/koastfreeroam/197" )
        pos.x = pos.x + size.x + space
        self.linksScreen.discord.window:SetPosition( pos )
        self.linksScreen.discord.window:SetSize( size )

        self.linksScreen.steam = self:QRLink( nil, "Steam", self.qrSteam, "steamcommunity.com/groups/koastfreeroam" )
        pos.x = pos.x + size.x + space
        self.linksScreen.steam.window:SetPosition( pos )
        self.linksScreen.steam.window:SetSize( size )

        self.linksScreen.youtube = self:QRLink( nil, "YouTube", self.qrYouTube, "www.youtube.com/@jcgteam" )
        pos.x = pos.x + size.x + space
        self.linksScreen.youtube.window:SetPosition( pos )
        self.linksScreen.youtube.window:SetSize( size )

        local linksTable = {
            [0] = self.linksScreen.telegram.window, [1] = self.linksScreen.discord.window, [2] = self.linksScreen.steam.window, [3] = self.linksScreen.youtube.window
        }

        self:PlayLinkAnimation( 0, linksTable, ( Render.Size.y / 2 - size.x / 2 ) - 20, size )
    elseif step == 5 then
        Mouse:SetVisible( true )

        local sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 18,
            sound_id = 1,
            position = Camera:GetPosition(),
            angle = Angle()
        })

        sound:SetParameter(0,1)

        if self.linksScreen then self:RemoveScreen( self.linksScreen ) self.linksScreen = nil end

        local size = Render.Size / 3.25 - Vector2( Render.Size.x / 6.15, 0 )
        local space = 8
        local pos = Vector2( Render.Size.x / 2 - size.x / 2, Render.Size.y )

        if self.donateScreen then return end

        self.donateScreen = {}

        self.donateScreen.boosty = self:QRLink( nil, "Boosty", self.qrBoosty, "boosty.to/jcgteam/donate" )
        self.donateScreen.boosty.window:SetPosition( pos )
        self.donateScreen.boosty.window:SetSize( size )

        local finalPos = ( Render.Size.y / 2 - size.x / 2 ) - 20
        Animation:Play( Render.Size.y, finalPos, 0.35, easeInOut, function( value ) if self.donateScreen then self.donateScreen.boosty.window:SetPosition( Vector2( self.donateScreen.boosty.window:GetPosition().x, value ) ) end end, function()
            self.donateScreen.nextButton = ModernGUI.Button.Create()
            self.donateScreen.nextButton:SetSize( Vector2( Render:GetTextWidth( self.locStrings["continue"], self.donateScreen.nextButton:GetTextSize() ) + 30, 40 ) )
            self.donateScreen.nextButton:SetPosition( Vector2( Render.Size.x / 2 - self.donateScreen.nextButton:GetSize().x / 2, Render.Size.y ) )
            self.donateScreen.nextButton:SetText( self.locStrings["continue"] )
            if LocalPlayer:GetValue( "SystemFonts" ) then
                self.donateScreen.nextButton:SetFont( AssetLocation.SystemFont, "Impact" )
            end
            self.donateScreen.nextButton:Subscribe( "Press", function() self:NextStep() end )

            Animation:Play( self.donateScreen.nextButton:GetPosition().x, finalPos + size.y + 60, 0.25, easeInOut, function( value ) if self.donateScreen then self.donateScreen.nextButton:SetPosition( Vector2( Render.Size.x / 2 - self.donateScreen.nextButton:GetSize().x / 2, value ) ) end end )
        end )
    elseif step == 6 then
        Mouse:SetVisible( false )

        local sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 18,
            sound_id = 1,
            position = Camera:GetPosition(),
            angle = Angle()
        })

        sound:SetParameter(0,1)

        if not LocalPlayer:GetValue( "Registered" ) then
            Events:Fire( "CastCenterText", { text = self.locStrings["setupFinished"], time = 5 } )
        end

        if self.LangEvent then Events:Unsubscribe( self.LangEvent ) self.LangEvent = nil end
        if self.HealAppItemEvent then Events:Unsubscribe( self.HealAppItemEvent ) self.HealAppItemEvent = nil end
        if self.ModuleUnloadEvent then Events:Unsubscribe( self.ModuleUnloadEvent ) self.ModuleUnloadEvent = nil end
        if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
        if self.ResolutionChangeEvent then Events:Unsubscribe( self.ResolutionChangeEvent ) self.ResolutionChangeEvent = nil end
        if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
        --if self.CalcViewEvent then Events:Unsubscribe( self.CalcViewEvent ) self.CalcViewEvent = nil end

        self.step = nil
        self.locStrings = nil
        self.rusFlag = nil
	    self.engFlag = nil
        self.rico = nil

        self.welcomeTextPos = nil
        self.welcomeTextAlpha = nil

        if self.donateScreen then self:RemoveScreen( self.donateScreen ) self.donateScreen = nil end

        self.qrTelegram = nil
        self.qrDiscord = nil
        self.qrSteam = nil
        self.qrYouTube = nil

        if self.settingsLabel then self.settingsLabel:Remove() self.settingsLabel = nil end

        self:ModuleUnload()

        Network:Send( "SetFreeroam" )

        if LocalPlayer:GetValue( "Registered" ) then
            local lang = LocalPlayer:GetValue( "Lang" )
            if lang and lang == "EN" then
                Events:Fire( "OpenWhatsNew", { titletext = "Warning!", text = "This server is open source and is not official.", usepause = true } )
            else
                local type = 0

                if type == 0 then
                    Events:Fire( "OpenWhatsNew", { titletext = "Внимание!", text = "Данный сервер основан на открытом исходном коде и не является официальным.", usepause = true } )
                end
            end
        end
    end
end

function Menu:NextStep()
    self.step = ( self.step and self.step or 0 ) + 1
    self:ChangeStep( self.step )
end

function Menu:PlayLinkAnimation( currentLink, linksTable, finalPos, size )
    Animation:Play( Render.Size.y, finalPos, 0.35, easeInOut, function( value ) linksTable[currentLink]:SetPosition( Vector2( linksTable[currentLink]:GetPosition().x, value ) ) end, function()
        if currentLink < #linksTable then
            self:PlayLinkAnimation( currentLink + 1, linksTable, finalPos, size )
        else
            self.linksScreen.nextButton = ModernGUI.Button.Create()
            self.linksScreen.nextButton:SetSize( Vector2( Render:GetTextWidth( self.locStrings["next"], self.linksScreen.nextButton:GetTextSize() ) + 30, 40 ) )
            self.linksScreen.nextButton:SetPosition( Vector2( Render.Size.x / 2 - self.linksScreen.nextButton:GetSize().x / 2, Render.Size.y ) )
            self.linksScreen.nextButton:SetText( self.locStrings["next"] )
            if LocalPlayer:GetValue( "SystemFonts" ) then
                self.linksScreen.nextButton:SetFont( AssetLocation.SystemFont, "Impact" )
            end
            self.linksScreen.nextButton:Subscribe( "Press", function() self:NextStep() end )

            Animation:Play( self.linksScreen.nextButton:GetPosition().x, finalPos + size.y + 60, 0.25, easeInOut, function( value ) if self.linksScreen then self.linksScreen.nextButton:SetPosition( Vector2( Render.Size.x / 2 - self.linksScreen.nextButton:GetSize().x / 2, value ) ) end end )
        end
    end )
end

function Menu:RemoveScreen( table )
    for _, v in pairs( table ) do
        if IsValid( v ) and v.Remove then
            v:Remove() v = nil
        end
    end
end

function Menu:ModuleUnload()
    Chat:SetEnabled( true )

    Game:FireEvent( "gui.hud.show" )
    Game:FireEvent( "gui.minimap.show" )
    Game:FireEvent( "ply.unpause" )
end

menu = Menu()
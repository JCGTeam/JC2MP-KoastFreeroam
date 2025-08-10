class 'Load'

function Load:__init()
    self.backgroundImages = {
		Image.Create(AssetLocation.Resource, "BackgroundImage"),
		Image.Create(AssetLocation.Resource, "BackgroundImageTw"),
		Image.Create(AssetLocation.Resource, "BackgroundImageTh"),
		Image.Create(AssetLocation.Resource, "BackgroundImageFo"),
		Image.Create(AssetLocation.Resource, "BackgroundImageFi")
	}

    self.backgroundImage = table.randomvalue(self.backgroundImages)
    self.loadingCircle_Outer = Image.Create(AssetLocation.Game, "fe_initial_load_icon_dif.dds")

    self.backgroundImage:SetSize(Render.Size)

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            wtitle = "ОШИБКА :С",
            wtext = "Возможно, вы застряли на экране загрузки. \nЖелаете покинуть сервер?",
            wbutton = "Покинуть сервер"
        }
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("ModuleLoad", self, self.ModuleLoad)
    Events:Subscribe("ResolutionChange", self, self.ResolutionChange)
    Events:Subscribe("GameLoad", self, self.GameLoad)
    Events:Subscribe("LocalPlayerDeath", self, self.LocalPlayerDeath)
    self.PostRenderEvent = Events:Subscribe("PostRender", self, self.PostRender)

    self.isJoining = false
end

function Load:Lang()
    self.locStrings = {
        wtitle = "ERROR :С",
        wtext = "You maybe stuck on the loading screen. \nWant to leave the server?",
        wbutton = "Leave Server"
    }
end

function Load:ModuleLoad()
    if Game:GetState() ~= GUIState.Loading then
        self.isJoining = false
    else
        self.isJoining = true
        self.fadeInTimer = Timer()
    end
end

function Load:ResolutionChange(args)
    self.backgroundImage:SetSize(args.size)
end

function Load:GameLoad()
    self.fadeInTimer = nil

    if not self.PostRenderEvent then
        self.PostRenderEvent = Events:Subscribe("PostRender", self, self.PostRender)
        self:WindowClosed()
    end
end

function Load:LocalPlayerDeath()
    self.backgroundImage = table.randomvalue(self.backgroundImages)
    self.fadeInTimer = Timer()
end

function Load:PostRender()
    if Game:GetState() == GUIState.Loading then
        local circleSize = Vector2(70, 70)
        local rotation = self:GetRotation()
        local pos = Vector2(Render.Size.x - 80, Render.Size.y - 80)
        local background_clr = Color.Black
        local pi = math.pi

        Render:FillArea(Vector2.Zero, Render.Size, background_clr)
        self.backgroundImage:Draw()

        local TransformOuter = Transform2()
        TransformOuter:Translate(pos)
        TransformOuter:Rotate(pi * rotation)

        Render:SetTransform(TransformOuter)
        self.loadingCircle_Outer:Draw(-(circleSize / 2), circleSize, Vector2.Zero, Vector2.One)
        Render:ResetTransform()

        local fadeInTimer = self.fadeInTimer

        if fadeInTimer and fadeInTimer:GetMinutes() >= 1 then
            if self.PostRenderEvent then Events:Unsubscribe(self.PostRenderEvent) self.PostRenderEvent = nil end
            self:ExitWindow()
        end
    end
end

function Load:ExitWindow()
    self.fadeInTimer = nil
    Mouse:SetVisible(true)

    if self.window then return end

    local locStrings = self.locStrings

    self.window = Window.Create()
    self.window:SetSizeRel(Vector2(0.2, 0.2))
    self.window:SetMinimumSize(Vector2(500, 200))
    self.window:SetPositionRel(Vector2(0.7, 0.5) - self.window:GetSizeRel() / 2)
    self.window:SetVisible(true)
    self.window:SetTitle(locStrings["wtitle"])
    self.window:Subscribe("WindowClosed", self, self.WindowClosed)

    self.errorText = Label.Create(self.window)
    self.errorText:SetPosition(Vector2(20, 30))
    self.errorText:SetSize(Vector2(450, 100))
    self.errorText:SetText(locStrings["wtext"])
    self.errorText:SetTextSize(20)

    self.leaveButton = Button.Create(self.window)
    self.leaveButton:SetSize(Vector2(100, 40))
    self.leaveButton:SetDock(GwenPosition.Bottom)
    self.leaveButton:SetText(locStrings["wbutton"])
    self.leaveButton:Subscribe("Press", self, self.Exit)
end

function Load:WindowClosed()
    if self.window then self.window:Remove() self.window = nil end
    if self.errorText then self.errorText:Remove() self.errorText = nil end
    if self.leaveButton then self.leaveButton:Remove() self.leaveButton = nil end

    Mouse:SetVisible(false)
end

function Load:Exit()
    self:WindowClosed()
    Network:Send("KickPlayer")
end

function Load:GetRotation()
    local RotationValue = Client:GetElapsedSeconds() * 3
    return RotationValue
end

local load = Load()
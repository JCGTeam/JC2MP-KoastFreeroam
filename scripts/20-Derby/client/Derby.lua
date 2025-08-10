class 'Derby'

function Derby:__init()
    Network:Subscribe("SetState", self, self.SetState)

    Network:Subscribe("TriggerEvent", self, self.TriggerEvent)

    Network:Subscribe("OutOfArena", self, self.OutOfArena)
    Network:Subscribe("BackInArena", self, self.BackInArena)
    Network:Subscribe("enterVehicle", self, self.enterVehicle)
    Network:Subscribe("exitVehicle", self, self.exitVehicle)

    Network:Subscribe("PlayerCount", self, self.PlayerCount)
    Network:Subscribe("CourseName", self, self.CourseName)

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("Render", self, self.Render)

    Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)

    self.handbrake = nil

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            nameT = "Игроки",
            lobbyplayers = "Игроки: ",
            lobbymap = "Карта: ",
            loading = "Загрузка…",
            pleasewait = "Пожалуйста, подождите.",
            arenaleave = "Вы покидаете арену!",
            vehicledamaged = "% здоровья у транспорта потеряно. Вернитесь на Арену!",
            novehicle = "     Эй, вернулся!\nИначе проиграешь.",
            cdgo = "Го!"
        }
    end

    self.state = "Inactive"
    self.playerCount = nil
    self.courseName = nil
    self.countdownTimer = nil
    self.blockedKeys = {Action.StuntJump, Action.StuntposEnterVehicle, Action.ParachuteOpenClose, Action.ExitVehicle, Action.EnterVehicle, Action.UseItem}

    self.outOfArena = false
    self.inVehicleTimer = nil
    self.vehicleHealthLost = -5
end

function DrawCenteredShadowedText(position, text, color, textsize)
    local textsize = textsize or TextSize.Default
    local bounds = Render:GetTextSize(text, textsize)

    if not IsNaN(position) then
        Render:DrawShadowedText(position - (bounds / 2), text, color, Color(25, 25, 25, 150), textsize)
    end
end

function Derby:Lang()
    self.locStrings = {
        nameT = "Players",
        lobbyplayers = "Players: ",
        lobbymap = "Map: ",
        loading = "Loading…",
        pleasewait = "Please wait.",
        arenaleave = "You are leaving the arena!",
        vehicledamaged = "% of the vehicle's health is lost. Return to the Arena!",
        novehicle = "     Come back!\nOtherwise you will lose.",
        cdgo = "Go!"
    }
end

function Derby:SetState(newstate)
    self.state = newstate

    if newstate == "Inactive" then
        if self.handbrake then Events:Unsubscribe(self.handbrake) self.handbrake = nil end
        self:BackInArena()
    end

    if newstate == "Lobby" then
        self.state = "Lobby"
        self:BackInArena()
    elseif newstate == "Setup" then
        self.state = "Setup"
        if not self.handbrake then
            self.handbrake = Events:Subscribe("InputPoll", function() Input:SetValue(Action.Handbrake, 1) end)
        end
    elseif newstate == "Countdown" then
        self.state = "Countdown"
        self.countdownTimer = Timer()
    elseif newstate == "Running" then
        self.state = "Running"
        self.countdownTimer = nil
        if self.handbrake then Events:Unsubscribe(self.handbrake) self.handbrake = nil end
    end
end

function Derby:CourseName(name)
    self.courseName = name
end

function Derby:PlayerCount(amount)
    self.playerCount = amount
end

function Derby:enterVehicle()
    self.inVehicleTimer = nil
end

function Derby:exitVehicle()
    self.inVehicleTimer = Timer()
end

function Derby:OutOfArena()
    self.outOfArena = true
    self.vehicleHealthLost = self.vehicleHealthLost + 5
end

function Derby:BackInArena()
    self.outOfArena = false
    self.vehicleHealthLost = -5
end

function Derby:TriggerEvent(event)
    Game:FireEvent(event)
end

function Derby:LocalPlayerInput(args)
    if self.state == "Running" then
        if LocalPlayer:InVehicle() then
            for i, action in ipairs(self.blockedKeys) do
                if args.input == action then
                    return false
                end
            end
        end
    elseif (self.state == "Setup" or self.state == "Countdown") then
        return false
    end
end

function Derby:TextPos(text, size, offsetx, offsety)
    local text_width = Render:GetTextWidth(text, size)
    local text_height = Render:GetTextHeight(text, size)
    local pos = Vector2((Render.Width - text_width + offsetx) / 2, (Render.Height - text_height + offsety) / 2)

    return pos
end

function Derby:Render()
    local state = self.state

    if state == "Inactive" then return end
    if Game:GetState() ~= GUIState.Game then return end

    if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

    local players = {LocalPlayer}
    local color = Color.White
    local colorShadow = Color(25, 25, 25, 150)
    local lpWorld = LocalPlayer:GetWorld()

    for player in Client:GetPlayers() do
        if player:GetWorld() == lpWorld then
            table.insert(players, player)
        end
    end

    if state ~= "Inactive" then
        local pos = Vector2(Render.Width - 367, 0)
    end

    if state == "Lobby" then
        local text = self.locStrings["lobbyplayers"] .. self.playerCount
        local textinfo = self:TextPos(text, TextSize.Large, 0, -Render.Height + 150)
        Render:DrawShadowedText(textinfo, text, color, colorShadow, TextSize.Large)

        text = self.locStrings["lobbymap"] .. self.courseName
        textinfo = self:TextPos(text, 25, 0, -Render.Height + 215)
        Render:DrawShadowedText(textinfo, text, Color(165, 165, 165), colorShadow, 25)
    end

    if state == "Setup" then
        local text = self.locStrings["loading"]
        local textinfo = self:TextPos(text, TextSize.VeryLarge, 0, -200)
        Render:DrawShadowedText(textinfo, text, color, colorShadow, TextSize.VeryLarge)

        text = self.locStrings["pleasewait"]
        textinfo = self:TextPos(text, TextSize.Default, 0, -140)
        Render:DrawShadowedText(textinfo, text, Color(165, 165, 165), colorShadow, TextSize.Default)

        local color_players = Color.Black or Color.Gray

        for k, player in ipairs(players) do
            if player:InVehicle() then
                color_players = player:GetVehicle():GetColors()
            end

            DrawCenteredShadowedText(Vector2(Render.Width - 75, Render.Height - 75 - (k * 20)), player:GetName(), color_players)
        end

        DrawCenteredShadowedText(Vector2(Render.Width - 75, Render.Height - 75 - ((#players + 1) * 20)), self.locStrings["nameT"], color, 20)
    elseif state == "Countdown" then
        local time = 3 - math.floor(math.clamp(self.countdownTimer:GetSeconds(), 0, 3))
        local message = {self.locStrings["cdgo"], "1", "2", "3"}
        local text = message[time + 1]
        local textinfo = self:TextPos(text, TextSize.Huge, 0, -200)
        Render:DrawShadowedText(textinfo, text, color, colorShadow, TextSize.Huge)

        local color_players = Color.Black or Color.Gray

        for k, player in ipairs(players) do
            if player:InVehicle() then
                color_players = player:GetVehicle():GetColors()
            end

            DrawCenteredShadowedText(Vector2(Render.Width - 75, Render.Height - 75 - (k * 20)), player:GetName(), color_players)
        end

        DrawCenteredShadowedText(Vector2(Render.Width - 75, Render.Height - 75 - ((#players + 1) * 20)), self.locStrings["nameT"], color, 20)
    elseif state == "Running" then
        local text = self.locStrings["lobbyplayers"] .. self.playerCount
        local textinfo = self:TextPos(text, TextSize.Large, 0, -Render.Height + 215)
        Render:DrawShadowedText(textinfo, text, color, colorShadow, TextSize.Large)

        local color_players = Color.Black or Color.Gray

        for k, player in ipairs(players) do
            if player:InVehicle() then
                color_players = player:GetVehicle():GetColors()
            end

            DrawCenteredShadowedText(Vector2(Render.Width - 75, Render.Height - 75 - (k * 20)), player:GetName(), color_players)
        end

        DrawCenteredShadowedText(Vector2(Render.Width - 75, Render.Height - 75 - ((#players + 1) * 20)), self.locStrings["nameT"], color, 20)
        if self.outOfArena then
            local text = self.locStrings["arenaleave"]
            local text_width = Render:GetTextWidth(text, TextSize.VeryLarge)
            local text_height = Render:GetTextHeight(text, TextSize.VeryLarge)
            local pos = Vector2((Render.Width - text_width) / 2, (Render.Height - text_height - 200) / 2)

            Render:DrawShadowedText(pos, text, Color(255, 69, 0), colorShadow, TextSize.VeryLarge)
            local text = self.vehicleHealthLost .. self.locStrings["vehicledamaged"]
            pos.y = pos.y + 45
            pos.x = (Render.Width - Render:GetTextWidth(text, TextSize.Default)) / 2
            Render:DrawShadowedText(pos, text, color, colorShadow, TextSize.Default)
        end
        -- OUT OF VEHICLE
        if self.inVehicleTimer then
            Render:FillArea(Vector2(Render.Width - 110, 70), Vector2(Render.Width - 110, 110), Color(0, 0, 0, 165))
            local time = 20 - math.floor(math.clamp(self.inVehicleTimer:GetSeconds(), 0, 20))
            if time <= 0 then
                return
            end
            local text = tostring(time)
            local text_width = Render:GetTextWidth(text, TextSize.Huge)
            local text_height = Render:GetTextHeight(text, TextSize.Huge)
            local pos = Vector2(((110 - text_width) / 2) + Render.Width - 110, (text_height))

            Render:DrawText(pos, text, Color(255, 69, 0), TextSize.Huge)
            pos.y = pos.y + 70
            pos.x = Render.Width - 98
            Render:DrawText(pos, self.locStrings["novehicle"], color, 12)
        end
    end
end

local derby = Derby()
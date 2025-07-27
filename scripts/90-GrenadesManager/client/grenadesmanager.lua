class 'GrenadesManager'

function GrenadesManager:__init()
    if LocalPlayer:GetValue("Explosive") ~= 0 then
        self.TossTimer = Timer()
    end

    local moreC4 = LocalPlayer:GetValue("MoreC4")

    self.C4Max = moreC4 and tostring(moreC4) or "3"

    self.vehicle_blacklist = {64, 37, 57, 30, 34, 20, 53, 24}

    --[[self.leftarm_blacklist = {
		[AnimationState.LaSWielding] = false,
		[AnimationState.LaSAiming] = false,
		[AnimationState.LaSReload] = false
	}]] --

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            fragmentation = "Осколочная граната",
            triggered = "Бомбы-липучки",
            claymore = "Мины Клеймор",
            firework = "Фейерверковая граната",
            nuclear = "Ядерная граната",
            supernuclear = "СУПЕР Ядерная граната"
        }
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("KeyUp", self, self.KeyUp)
    Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
    Events:Subscribe("Render", self, self.Render)
end

function GrenadesManager:Lang()
    self.locStrings = {
        fragmentation = "Fragmentation Grenade",
        triggered = "Triggered Explosive",
        claymore = "Claymore Mine",
        firework = "Firework Grenade",
        nuclear = "Nuclear Grenade",
        supernuclear = "SUPER Nuclear Grenade"
    }
end

function GrenadesManager:CheckList(tableList, modelID)
    for k, v in ipairs(tableList) do
        if v == modelID then
            return true
        end
    end
    return false
end

function GrenadesManager:KeyUp(args)
    if args.key == 50 then
        LocalPlayer:SetValue("l_exp", LocalPlayer:GetValue("Explosive"))
        LocalPlayer:SetValue("Explosive", 0)

        self.FadeOutTimer = nil
    elseif args.key == 49 then
        if LocalPlayer:GetValue("l_exp") then
            LocalPlayer:SetValue("Explosive", LocalPlayer:GetValue("l_exp"))
            LocalPlayer:SetValue("l_exp", nil)

            if self.FadeOutTimer then
                self.FadeOutTimer:Restart()
            else
                self.FadeOutTimer = Timer()
            end
        end
    end
end

function GrenadesManager:LocalPlayerInput(args)
    if not self.weaponsImage then
        self.weaponsImage = Image.Create(AssetLocation.Game, "hud_weapons_a_dif.dds")

        self.uvs = {
            grenade = {Vector2(0.707, 0.467), Vector2(0.935, 0.695)},
            c4 = {Vector2(0.237, 0.707), Vector2(0.465, 0.935)},
            clay = {Vector2(0.472, 0.707), Vector2(0.700, 0.935)}
        }

        self.background = Image.Create(AssetLocation.Game, "hud_wea_bg_dif.dds")
        self.textb = Image.Create(AssetLocation.Resource, "TextBackground")

        --[[
        self.stars = Image.Create(AssetLocation.Resource, "Stars0")
        self.stars1 = Image.Create(AssetLocation.Resource, "Stars1")
        self.stars2 = Image.Create(AssetLocation.Resource, "Stars2")
        self.stars3 = Image.Create(AssetLocation.Resource, "Stars3")
        self.stars4 = Image.Create(AssetLocation.Resource, "Stars4")
        self.stars5 = Image.Create(AssetLocation.Resource, "Stars5")
        ]] --
    end

    if args.input == Action.ThrowGrenade then
        if Game:GetState() ~= GUIState.Game then return end
        if LocalPlayer:GetValue("Freeze") then return end
        if LocalPlayer:GetValue("Passive") then return end
        if LocalPlayer:GetValue("ServerMap") then return end

        local vehicle = LocalPlayer:GetVehicle()

        if Game:GetSetting(GameSetting.GamepadInUse) == 1 and vehicle then return end

        local driver = vehicle and vehicle:GetDriver()

        if driver and driver.__type == 'LocalPlayer' then
            local vehicleModel = vehicle:GetModelId()
            local vehicleTemplate = vehicle:GetTemplate()

            if vehicleModel == 7 or vehicleModel == 77 or vehicleModel == 56 or vehicleModel == 18 then
                if vehicleTemplate == "Armed" or vehicleTemplate == "FullyUpgraded" or vehicleTemplate == "" or vehicleTemplate == "Cannon" then return end
            else
                if vehicleTemplate == "Armed" or vehicleTemplate == "FullyUpgraded" or vehicleTemplate == "Dome" then return end
            end

            if self:CheckList(self.vehicle_blacklist, vehicleModel) then return end
        end

        -- local bs = LocalPlayer:GetBaseState()
        -- if self.leftarm_blacklist[bs] then return end

        local explosive = LocalPlayer:GetValue("Explosive")

        if explosive == 1 and self.grenade then
            Events:Fire("FireGrenade", {type = "Frag"})
            self.grenade = nil
            self.TossTimer = Timer()
        elseif explosive == 2 then
            Events:Fire("FireC4")
        elseif explosive == 4 and self.grenade then
            self.grenade = nil
            Events:Fire("FireGrenade", {type = "Smoke"})
            self.TossTimer = Timer()
        elseif explosive == 5 and self.grenade then
            self.grenade = nil
            Events:Fire("FireGrenade", {type = "MichaelBay"})
            self.TossTimer = Timer()
        elseif explosive == 6 and self.grenade then
            self.grenade = nil
            Events:Fire("FireGrenade", {type = "Atom"})
            self.TossTimer = Timer()
        end

        if explosive ~= 0 and explosive then
            if self.FadeOutTimer then
                self.FadeOutTimer:Restart()
            else
                self.FadeOutTimer = Timer()
            end
        end
    end

    local inputDown = Input:GetValue(Action.EquipLeftSlot) > 0

    if inputDown and not self.inputWasDown then
        if not (Game:GetSetting(GameSetting.GamepadInUse) == 1 and LocalPlayer:InVehicle()) then
            self:ToggleGrenades()
        end
    end

    self.inputWasDown = inputDown
end

function GrenadesManager:ToggleGrenades()
    if not self.TossTimer then
        self.TossTimer = Timer()
    else
        self.TossTimer:Restart()
    end

    local explosive = LocalPlayer:GetValue("Explosive")

    if not explosive then
        LocalPlayer:SetValue("Explosive", 1)

        if self.FadeOutTimer then
            self.FadeOutTimer:Restart()
        else
            self.FadeOutTimer = Timer()
        end
    elseif explosive == 0 then
        LocalPlayer:SetValue("Explosive", 1)

        if self.FadeOutTimer then
            self.FadeOutTimer:Restart()
        else
            self.FadeOutTimer = Timer()
        end
    elseif explosive == 1 then
        LocalPlayer:SetValue("Explosive", 2)

        local moreC4 = LocalPlayer:GetValue("MoreC4")

        if moreC4 then
            self.C4Max = tostring(moreC4)
        end

        if self.FadeOutTimer then
            self.FadeOutTimer:Restart()
        else
            self.FadeOutTimer = Timer()
        end
    elseif explosive == 2 then
        LocalPlayer:SetValue("Explosive", 3)

        if self.FadeOutTimer then
            self.FadeOutTimer:Restart()
        else
            self.FadeOutTimer = Timer()
        end
    elseif explosive == 3 then
        LocalPlayer:SetValue("Explosive", 4)

        if self.FadeOutTimer then
            self.FadeOutTimer:Restart()
        else
            self.FadeOutTimer = Timer()
        end
    elseif explosive == 4 then
        LocalPlayer:SetValue("Explosive", 5)

        if self.FadeOutTimer then
            self.FadeOutTimer:Restart()
        else
            self.FadeOutTimer = Timer()
        end
    elseif explosive == 5 then
        if LocalPlayer:GetValue("SuperNuclearBomb") then
            LocalPlayer:SetValue("Explosive", 6)
        else
            LocalPlayer:SetValue("Explosive", 0)
        end

        if self.FadeOutTimer then
            self.FadeOutTimer:Restart()
        else
            self.FadeOutTimer = Timer()
        end
    else
        LocalPlayer:SetValue("Explosive", 0)

        self.TossTimer = nil
    end
end

function GrenadesManager:Render()
    if Game:GetState() ~= GUIState.Game then return end

    local explosive = LocalPlayer:GetValue("Explosive")
    local fadeOutTimer = self.FadeOutTimer

    if explosive ~= 0 and explosive ~= nil and fadeOutTimer then
        local text_timer = ""
        local text_max = ""

        self.background:SetSize(Vector2(Render.Height * 0.18, Render.Height * 0.09))
        self.textb:SetSize(Vector2(Render.Height * 0.2, Render.Height * 0.035))

        local locStrings = self.locStrings
        local uv = self.uvs.grenade
        local text = locStrings["fragmentation"]

        if explosive == 1 then
            uv = self.uvs.grenade
            text = locStrings["fragmentation"]
            text_timer = "R"

            local tossTimer = self.TossTimer

            if tossTimer then
                local rem = 2 - tossTimer:GetSeconds()

                if rem - (rem % 1) > 0 then
                    text_timer = tostring(rem - (rem % 1))
                else
                    self.TossTimer = nil
                    self.grenade = true
                end
            end
        elseif explosive == 2 then
            uv = self.uvs.c4
            text = locStrings["triggered"]
            text_max = self.C4Max

            local c4Count = LocalPlayer:GetValue("C4Count")

            text_timer = c4Count and tostring(c4Count) or "0"

            self.c4actv = true
        elseif explosive == 3 then
            uv = self.uvs.clay
            text = locStrings["claymore"]
            text_timer = "∞"

            self.c4actv = false
        elseif explosive == 4 then
            text = locStrings["firework"]
            text_timer = "R"

            local tossTimer = self.TossTimer

            if tossTimer then
                local rem = 2 - tossTimer:GetSeconds()

                if rem - (rem % 1) > 0 then
                    text_timer = tostring(rem - (rem % 1))
                else
                    self.TossTimer = nil
                    self.grenade = true
                end
            end
        elseif explosive == 5 then
            text = locStrings["nuclear"]
            text_timer = "R"

            local tossTimer = self.TossTimer

            if tossTimer then
                local rem = 6 - tossTimer:GetSeconds()

                if rem - (rem % 1) > 0 then
                    text_timer = tostring(rem - (rem % 1))
                else
                    self.TossTimer = nil
                    self.grenade = true
                end
            end
        elseif explosive == 6 then
            text = locStrings["supernuclear"]
            text_timer = "R"

            local tossTimer = self.TossTimer

            if tossTimer then
                local rem = 61 - tossTimer:GetSeconds()

                if rem - (rem % 1) > 0 then
                    text_timer = tostring(rem - (rem % 1))
                else
                    self.TossTimer = nil
                    self.grenade = true
                end
            end
        end

        if fadeOutTimer:GetSeconds() >= 11 then self.FadeOutTimer = nil return end

        Render:SetFont(AssetLocation.Disk, "Archivo.ttf")

        self.weaponsImage:SetSize(Vector2(Render.Height * 0.09, Render.Height * 0.045))

        local imgaSize = self.weaponsImage:GetSize()
        local backgroundSize = self.background:GetSize()
        local textbSize = self.textb:GetSize()

        local timerwidth = Render:GetTextSize(text_timer, imgaSize.y / 1.8).x / 2
        local c4maxwidth = Render:GetTextSize(text_max, imgaSize.y / 1.8).x / 2

        local pos_2d = Vector2(Render.Size.x / 0.995 - backgroundSize.x, (Render.Height - Render.Height * 0.24) - imgaSize.y / 2)
        local pos_2d_a = Vector2(Render.Size.x / 1.003 - backgroundSize.x, (Render.Height - Render.Height * 0.24) - backgroundSize.y / 2)
        local pos_2d_t = Vector2(Render.Size.x / 1.014 - textbSize.x, (Render.Height - Render.Height * 0.193) - textbSize.y / 2)
        local pos_2d_timer = Vector2(Render.Size.x / 1.007 - timerwidth / 2 - imgaSize.x / 2, (Render.Height - Render.Height * 0.234) - textbSize.y / 2)
        if self.c4actv then
            pos_2d_timer = Vector2(Render.Size.x / 1.006 - timerwidth / 2 - imgaSize.x / 2, (Render.Height - Render.Height * 0.242) - textbSize.y / 2)
        end
        local pos_2d_c4max = Vector2(Render.Size.x / 1.0055 - c4maxwidth / 2 - imgaSize.x / 2, (Render.Height - Render.Height * 0.22) - textbSize.y / 2)
        local pos_2d_text = Vector2(Render.Size.x - (Render:GetTextWidth(text, textbSize.y / 0.018 / Render:GetTextWidth("BTextResoliton"))) - Render.Size.x / 40, (Render.Height - Render.Height * 0.186) - textbSize.y / 2)

        local gameAlpha = Game:GetSetting(4)
        if gameAlpha >= 1 then
            local sett_alpha = gameAlpha * 2.25
            local sett_alpha2 = gameAlpha * 2

            self.weaponsImage:SetPosition(pos_2d)
            self.weaponsImage:SetAlpha(201 - sett_alpha2)

            self.background:SetPosition(pos_2d_a)
            self.background:SetAlpha(201 - sett_alpha2)

            self.textb:SetPosition(pos_2d_t)
            self.textb:SetAlpha(201 - sett_alpha2)

            self.weaponsImage:SetUV(uv[1], uv[2])

            self.textb:Draw()
            self.background:Draw()
            self.weaponsImage:Draw()

            local color = Color(255, 255, 255, sett_alpha)
            local color2 = Color(169, 169, 169, sett_alpha)
            local shadow = Color(0, 0, 0, sett_alpha)

            Render:DrawShadowedText(pos_2d_text, text, color, shadow, textbSize.y / 0.018 / Render:GetTextWidth("BTextResoliton"))

            local textWidth = Render:GetTextWidth("00")
            Render:DrawText(pos_2d_timer, text_timer, color, imgaSize.y / 0.13 / textWidth)
            Render:DrawText(pos_2d_c4max, text_max, color2, imgaSize.y / 0.18 / textWidth)
        end
    end
end

local grenadesmanager = GrenadesManager()
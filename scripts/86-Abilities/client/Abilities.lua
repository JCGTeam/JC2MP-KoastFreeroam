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

    self.wingsuitIMG = Image.Create(AssetLocation.Resource, "Wingsuit")
    self.boostIMG = Image.Create(AssetLocation.Resource, "Boost")
    self.moneyBonusIMG = Image.Create(AssetLocation.Resource, "MoneyBonus")
    self.moreC4IMG = Image.Create(AssetLocation.Resource, "MoreC4")
    self.superNuclearBombIMG = Image.Create(AssetLocation.Resource, "SuperNuclearBomb")
    self.longerGrappleIMG = Image.Create(AssetLocation.Resource, "LongerGrapple")
    self.jesusModeIMG = Image.Create(AssetLocation.Resource, "JesusMode")

    self.activeWindow = false

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

    self.unlocked_clr = Color(0, 255, 0, 30)

    self.window = Window.Create()
    self.window:SetSizeRel(Vector2(0.4, 0.5))
    self.window:SetMinimumSize(Vector2(500, 442))
    self.window:SetPositionRel(Vector2(0.7, 0.5) - self.window:GetSizeRel() / 2)
    self.window:SetTitle("▧ Способности")
    self.window:SetVisible(self.activeWindow)
    self.window:Subscribe("WindowClosed", self, function() self:SetWindowVisible(false, true) end)

    self:UpdateKeyBinds()

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            needed = "Цена",
            unlocked = "Приобретено",
            morec4 = "Увеличение кол-во C4",
            items = "штук",
            wingsuit = "Вингсьют",
            landvehicleboost = "Ускорение для наземного транспорта",
            watervehicleboost = "Ускорение для морского транспорта",
            airvehicleboost = "Ускорение для воздушного транспорта",
            bonusmoney = "Денежный бонус",
            supernuclearbomb = "СУПЕР Ядерная граната",
            longergrapple = "Дальность крюка",
            meters = "м",
            jesusmode = "Режим Иисуса",
            abilities = "Способности",
            noselected_description = "Наведите на любую способность, чтобы прочитать описание.",
            wingsuit_description = "Специальный костюм-крыло, позволяющий летать по небу.",
            boost_description = "Ускоряет ваше транспортное средство нажатием одной кнопки до скорости света!",
            bonusmoney_description = "Денежная награда в размере $100-2500 каждый час игры.",
            moreC4_description = "Увеличивает максимальное количество слотов C4 для установки.",
            supernuclearbomb_description = "Мощнейший взрыв, который уничтожает всё, что находится поблизости с этой волшебной гранатой :)",
            longergrapple_description = "Увеличивает максимальную дальность выстрела крюком-кошки.",
            jesusmode_description = "Возможность ходить и ездить по воде.",
            usekey = 'Используйте клавишу "',
            wingsuittutorial = '" находясь в свободном полете или на парашюте, чтобы раскрыть вингсьют.',
            vehboosttutorial = '", чтобы воспользоваться супер-пупер ускорением.'
        }
    end

    local topcontainer = BaseWindow.Create(self.window)
    topcontainer:SetHeight(Render:GetTextHeight("A", 18) + 10)
    topcontainer:SetMargin(Vector2.Zero, Vector2.Zero)
    topcontainer:SetDock(GwenPosition.Top)

    local topcontainerbk = BaseWindow.Create(topcontainer)
    topcontainerbk:SetDock(GwenPosition.Fill)

    self.money_text = Label.Create(topcontainerbk)
    self.money_text:SetDock(GwenPosition.Left)
    self.money_text:SetMargin(Vector2(10, 5), Vector2.Zero)
    self.money_text:SetTextColor(Color(251, 184, 41))
    self.money_text:SetTextSize(18)

    self.maincontainer = BaseWindow.Create(self.window)
    self.maincontainer:SetDock(GwenPosition.Fill)

    local btnSize = Vector2(50, 50)
    if Debug.ShowResetButton then
        self.resetbutton = Button.Create(self.maincontainer)
        self.resetbutton:SetSize(btnSize)
        self.resetbutton:SetDock(GwenPosition.Bottom)
        self.resetbutton:SetText("RESET ACHIEVEMENTS")
        self.resetbutton:Subscribe("Press", self, self.Clear)
    end

    local tip_container = BaseWindow.Create(self.window)
    tip_container:SetDock(GwenPosition.Bottom)
    tip_container:SetHeight(Render:GetTextHeight("A", 18) + 60)
    tip_container:SetMargin(Vector2(10, 10), Vector2(10, 10))

    self.tip_descrition = Label.Create(tip_container)
    self.tip_descrition:SetText(self.locStrings["noselected_description"])
    self.tip_descrition:SetTextColor(Color(220, 220, 220))
    self.tip_descrition:SetTextSize(12)
    self.tip_descrition:SetDock(GwenPosition.Bottom)
    self.tip_descrition:SizeToContents()

    self.tip_title = Label.Create(tip_container)
    self.tip_title:SetDock(GwenPosition.Bottom)
    self.tip_title:SetText(self.locStrings["abilities"])
    self.tip_title:SetTextSize(20)
    self.tip_title:SizeToContents()

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("UpdateKeyBinds", self, self.UpdateKeyBinds)
    Events:Subscribe("OpenAbitiliesMenu", self, self.OpenAbitiliesMenu)
    Events:Subscribe("CloseAbitiliesMenu", self, function() self:SetWindowVisible(false) end)
end

function Abilities:Lang()
    if self.window then
        self.window:SetTitle("▧ Abilities")
    end

    self.locStrings = {
        needed = "Price",
        unlocked = "Unlocked",
        morec4 = "More C4",
        items = "items",
        wingsuit = "Wingsuit",
        landvehicleboost = "Land Vehicle Boost",
        watervehicleboost = "Water Vehicle Boost",
        airvehicleboost = "Air Vehicle Boost",
        bonusmoney = "Money Bonus",
        supernuclearbomb = "SUPER Nuclear Grenade",
        longergrapple = "Longer Grapple",
        meters = "m",
        jesusmode = "Jesus Mode",
        abilities = "Abilities",
        noselected_description = "Hover over any ability to read the description.",
        wingsuit_description = "Allows you to fly in the sky.",
        boost_description = "Accelerates your vehicle at the touch of a button to the speed of light!",
        bonusmoney_description = "A cash reward of $100-2500 every hour of play.",
        moreC4_description = "Increases the maximum number of C4 slots for installation.",
        supernuclearbomb_description = "A powerful explosion that destroys everything in the vicinity of this magic grenade :)",
        longergrapple_description = "Increases the maximum range of the grapple hook shot.",
        jesusmode_description = "The ability to walk and drive on water.",
        usekey = 'Use "',
        wingsuittutorial = '" key while in free flight or on a parachute to open the wingsuit.',
        vehboosttutorial = '" key to use super boost.'
    }
end

function Abilities:UpdateKeyBinds()
    local keyBinds = LocalPlayer:GetValue("KeyBinds")
    local openWingsuitBind = keyBinds and keyBinds["Wingsuit"]
    local landBoostBind = keyBinds and keyBinds["VehicleLandBoost"]
    local planeBoostBind = keyBinds and keyBinds["VehiclePlaneBoost"]

    self.openWingsuitStringKey = openWingsuitBind and openWingsuitBind.type == "Key" and openWingsuitBind.valueString or "Q"
    self.landBoostStringKey = landBoostBind and landBoostBind.type == "Key" and landBoostBind.valueString or "Shift"
    self.planeBoostStringKey = planeBoostBind and planeBoostBind.type == "Key" and planeBoostBind.valueString or "Q"
end

function Abilities:Clear()
    Network:Send("Clear")
    self:SetWindowVisible(false)
end

function Abilities:AbilityButton(visible, pos, title, description, event, image)
    local btnSize = Vector2(self.buttonsSize, self.buttonsSize)

    local button = Button.Create(self.maincontainer)
    button:SetVisible(visible)
    button:SetSize(btnSize)
    button:SetPosition(pos)
    button:Subscribe("HoverEnter", self, function()
        self.tip_title:SetText(title)
        self.tip_descrition:SetText(description)
        self.tip_descrition:SizeToContents()
    end)
    button:Subscribe("Press", self, event)

    local unlockstats = Rectangle.Create(button)
    unlockstats:SetVisible(visible)
    unlockstats:SetDock(GwenPosition.Fill)
    unlockstats:SetColor(self.unlocked_clr)
    unlockstats:Subscribe("HoverEnter", self, function()
        self.tip_title:SetText(title)
        self.tip_descrition:SetText(description)
        self.tip_descrition:SizeToContents()
    end)

    local buttonImage = ImagePanel.Create(button)
    buttonImage:SetDock(GwenPosition.Fill)
    buttonImage:SetImage(image)

    local result = {button = button, unlockstats = unlockstats}

    function result:GetPosition()
        if result.button then return result.button:GetPosition() end
    end

    function result:SetEnabled(enabled)
        if result.button then return result.button:SetEnabled(enabled) end
    end

    function result:SetVisible(visible)
        if result.button then return result.button:SetVisible(visible) end
    end

    function result:SetToolTip(text)
        if result.button then return result.button:SetToolTip(text) end
        if result.unlockstats then return result.unlockstats:SetToolTip(text) end
    end

    return result
end

function Abilities:WingsuitUnlocker()
    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 16,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })

    sound:SetParameter(0, 0.75)
    Network:Send("WingsuitUnlock")

    local locStrings = self.locStrings

    self.wingsuitbutton.unlockstats:SetToolTip(locStrings["wingsuit"] .. " ( " .. locStrings["unlocked"] .. " )")
    self.wingsuitbutton.unlockstats:SetVisible(true)

    Events:Fire("OpenWhatsNew", {titletext = locStrings["wingsuit"], text = locStrings["usekey"] .. self.openWingsuitStringKey .. locStrings["wingsuittutorial"]})
end

function Abilities:BoostUnlocker()
    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 16,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })

    sound:SetParameter(0, 0.75)
    Network:Send("BoostUnlock")

    local locStrings = self.locStrings
    local boost = LocalPlayer:GetValue("Boost")

    if not boost then
        self.boost_1button.unlockstats:SetToolTip(locStrings["landvehicleboost"] .. " ( " .. locStrings["unlocked"] .. " )")
        self.boost_1button.unlockstats:SetVisible(true)

        self.boost_2button:SetToolTip(locStrings["watervehicleboost"] .. " ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.Boost_2) .. " )")
        self.boost_2button:SetVisible(true)

        Events:Fire("OpenWhatsNew", {titletext = locStrings["landvehicleboost"], text = locStrings["usekey"] .. self.landBoostStringKey .. locStrings["vehboosttutorial"]})
    elseif boost == self.boostValue_1 then
        self.boost_2button.unlockstats:SetToolTip(locStrings["watervehicleboost"] .. " ( " .. locStrings["unlocked"] .. " )")
        self.boost_2button.unlockstats:SetVisible(true)

        self.boost_3button:SetToolTip(locStrings["airvehicleboost"] .. " ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.Boost_3) .. " )")
        self.boost_3button:SetVisible(true)
    elseif boost == self.boostValue_2 then
        self.boost_3button.unlockstats:SetToolTip(locStrings["airvehicleboost"] .. " ( " .. locStrings["unlocked"] .. " )")
        self.boost_3button.unlockstats:SetVisible(true)

        Events:Fire("OpenWhatsNew", {titletext = locStrings["airvehicleboost"], text = locStrings["usekey"] .. self.planeBoostStringKey .. locStrings["vehboosttutorial"]})
    end
end

function Abilities:MoneyBonusUnlocker()
    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 16,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })

    sound:SetParameter(0, 0.75)
    Network:Send("MoneyBonusUnlock")

    local locStrings = self.locStrings

    self.bonusmoneybutton.unlockstats:SetToolTip(locStrings["bonusmoney"] .. " ( " .. locStrings["unlocked"] .. " )")
    self.bonusmoneybutton.unlockstats:SetVisible(true)

    Events:Fire("OpenWhatsNew", {titletext = locStrings["bonusmoney"], text = "                                              Поздравляем! Теперь вам доступен денежный бонус.\nДенежный бонус выдается каждый час игры. Чтобы его поулчить - зайдите в меню сервера."})
end

function Abilities:MoreC4Unlocker()
    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 16,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })

    sound:SetParameter(0, 0.75)
    Network:Send("MoreC4Unlock")

    local locStrings = self.locStrings
    local moreC4 = LocalPlayer:GetValue("MoreC4")

    if not moreC4 then
        self.moreC4_5button.unlockstats:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_5 .. " " .. locStrings["items"] .. ") ( " .. locStrings["unlocked"] .." )")
        self.moreC4_5button.unlockstats:SetVisible(true)

        self.moreC4_8button:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_8 .. " " .. locStrings["items"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.MoreC4_8) .. " )")
        self.moreC4_8button:SetVisible(true)
    elseif moreC4 == self.moreC4Value_5 then
        self.moreC4_8button.unlockstats:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_8 .. " " .. locStrings["items"] .. ") ( " .. locStrings["unlocked"] .. " )")
        self.moreC4_8button.unlockstats:SetVisible(true)

        self.moreC4_10button:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_10 .. " " .. locStrings["items"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.MoreC4_10) .. " )")
        self.moreC4_10button:SetVisible(true)
    elseif moreC4 == self.moreC4Value_8 then
        self.moreC4_10button.unlockstats:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_10 .. " " .. locStrings["items"] .. ") ( " .. locStrings["unlocked"] .. " )")
        self.moreC4_10button.unlockstats:SetVisible(true)

        self.moreC4_15button:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_15 .. " " .. locStrings["items"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.MoreC4_15) .. " )")
        self.moreC4_15button:SetVisible(true)
    elseif moreC4 == self.moreC4Value_10 then
        self.moreC4_15button.unlockstats:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_15 .. " " .. locStrings["items"] .. ") ( " .. locStrings["unlocked"] .. " )")
        self.moreC4_15button.unlockstats:SetVisible(true)
    end
end

function Abilities:UpdateButtons(money)
    self.wingsuitbutton:SetEnabled(money >= Prices.Wingsuit)
    self.boost_1button:SetEnabled(money >= Prices.Boost_1)
    self.boost_2button:SetEnabled(money >= Prices.Boost_2)
    self.boost_3button:SetEnabled(money >= Prices.Boost_3)
    self.bonusmoneybutton:SetEnabled(money >= Prices.BonusMoney)
    self.moreC4_5button:SetEnabled(money >= Prices.MoreC4_5)
    self.moreC4_8button:SetEnabled(money >= Prices.MoreC4_8)
    self.moreC4_10button:SetEnabled(money >= Prices.MoreC4_10)
    self.moreC4_15button:SetEnabled(money >= Prices.MoreC4_15)
    self.supernuclearbombbutton:SetEnabled(money >= Prices.SuperNuclearBomb)
    self.longergrapple_150button:SetEnabled(money >= Prices.LongerGrapple_150)
    self.longergrapple_200button:SetEnabled(money >= Prices.LongerGrapple_200)
    self.longergrapple_350button:SetEnabled(money >= Prices.LongerGrapple_350)
    self.longergrapple_500button:SetEnabled(money >= Prices.LongerGrapple_500)
    self.jesusmode_button:SetEnabled(money >= Prices.JesusMode)
end

function Abilities:SuperNuclearBombUnlocker()
    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 16,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })

    sound:SetParameter(0, 0.75)
    Network:Send("SuperNuclearBombUnlock")

    local locStrings = self.locStrings

    self.supernuclearbombbutton.unlockstats:SetToolTip(locStrings["supernuclearbomb"] .. " ( " .. locStrings["unlocked"] .. " )")
    self.supernuclearbombbutton.unlockstats:SetVisible(true)

    Events:Fire("OpenWhatsNew", {titletext = locStrings["supernuclearbomb"], text = 'Попробуйте пролистать список гранат, вы обязательно там её найдете :)\n              Используйте клавишу "G", чтобы пролистать список гранат.'})
end

function Abilities:LongerGrappleUnlocker()
    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 16,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })

    sound:SetParameter(0, 0.75)
    Network:Send("LongerGrappleUnlock")

    local locStrings = self.locStrings
    local longerGrapple = LocalPlayer:GetValue("LongerGrapple")

    if not longerGrapple then
        self.longergrapple_150button.unlockstats:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_1 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["unlocked"] .. " )")
        self.longergrapple_150button.unlockstats:SetVisible(true)

        self.longergrapple_200button:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_2 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.LongerGrapple_200) .. " )")
        self.longergrapple_200button:SetVisible(true)
    elseif longerGrapple == self.GrappleLongerValue_1 then
        self.longergrapple_200button.unlockstats:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_2 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["unlocked"] .. " )")
        self.longergrapple_200button.unlockstats:SetVisible(true)

        self.longergrapple_350button:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_3 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.LongerGrapple_350) .. " )")
        self.longergrapple_350button:SetVisible(true)
    elseif longerGrapple == self.GrappleLongerValue_2 then
        self.longergrapple_350button.unlockstats:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_3 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["unlocked"] .. " )")
        self.longergrapple_350button.unlockstats:SetVisible(true)

        self.longergrapple_500button:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_4 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.LongerGrapple_500) .. " )")
        self.longergrapple_500button:SetVisible(true)
    elseif longerGrapple == self.GrappleLongerValue_3 then
        self.longergrapple_500button.unlockstats:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_4 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["unlocked"] .. " )")
        self.longergrapple_500button.unlockstats:SetVisible(true)
    end
end

function Abilities:JesusModeUnlocker()
    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 16,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })

    sound:SetParameter(0, 0.75)
    Network:Send("JesusModeUnlock")

    local locStrings = self.locStrings

    self.jesusmode_button.unlockstats:SetToolTip(locStrings["jesusmode"] .. " ( " .. locStrings["unlocked"] .. " )")
    self.jesusmode_button.unlockstats:SetVisible(true)

    Events:Fire("OpenWhatsNew", {titletext = locStrings["jesusmode"], text = "                Поздравляем, теперь вы можете ходить и ездить по воде!\nЗайдите в меню сервера, чтобы включить или отключить режим Иисуса."})
end

function Abilities:Render()
    local is_visible = Game:GetState() == GUIState.Game
    local window = self.window
    local windowGetVisible = window:GetVisible()

    if windowGetVisible ~= is_visible then
        self.window:SetVisible(is_visible)
        Mouse:SetVisible(is_visible)
    end
end

function Abilities:OpenAbitiliesMenu()
    self:SetWindowVisible(not self.activeWindow, true)
end

function Abilities:UpdateMoneyString(money)
    if money == nil then
        money = LocalPlayer:GetMoney()
    end

    local lang = LocalPlayer:GetValue("Lang")
    if lang then
        self.money_text:SetText(lang == "EN" and "Balance: $" .. formatNumber(money) or "Баланс: $" .. formatNumber(money))
        self.money_text:SizeToContents()
    end
end

function Abilities:LocalPlayerMoneyChange(args)
    self:UpdateMoneyString(args.new_money)

    if self.window then
        self:UpdateButtons(args.new_money)
    end
end

function Abilities:SetWindowVisible(visible, sound)
    if self.activeWindow ~= visible then
        self.activeWindow = visible
        self.window:SetVisible(visible)
        Mouse:SetVisible(visible)
    end

    if self.activeWindow then
        local locStrings = self.locStrings

        if not self.isLoad then
            self.isLoad = true

            self.buttonsSize = 50

            local spaceX, spaceY = 60, 5
            self.wingsuitbutton = self:AbilityButton(true, Vector2(10, spaceY), locStrings["wingsuit"], locStrings["wingsuit_description"], self.WingsuitUnlocker, self.wingsuitIMG)
            local posX = self.wingsuitbutton:GetPosition().x + spaceX
            self.boost_1button = self:AbilityButton(true, Vector2(posX, spaceY), locStrings["landvehicleboost"], locStrings["boost_description"], self.BoostUnlocker, self.boostIMG)
            self.boost_2button = self:AbilityButton(false, Vector2(posX, self.boost_1button:GetPosition().y + self.buttonsSize + spaceY), locStrings["watervehicleboost"], locStrings["boost_description"], self.BoostUnlocker, self.boostIMG)
            self.boost_3button = self:AbilityButton(false, Vector2(posX, self.boost_2button:GetPosition().y + self.buttonsSize + spaceY), locStrings["airvehicleboost"], locStrings["boost_description"], self.BoostUnlocker, self.boostIMG)
            self.bonusmoneybutton = self:AbilityButton(true, Vector2(self.boost_1button:GetPosition().x + spaceX, spaceY), locStrings["bonusmoney"], locStrings["bonusmoney_description"], self.MoneyBonusUnlocker, self.moneyBonusIMG)
            posX = self.bonusmoneybutton:GetPosition().x + spaceX
            self.moreC4_5button = self:AbilityButton(true, Vector2(posX, spaceY), locStrings["morec4"], locStrings["moreC4_description"], self.MoreC4Unlocker, self.moreC4IMG)
            self.moreC4_8button = self:AbilityButton(false, Vector2(posX, self.moreC4_5button:GetPosition().y + self.buttonsSize + spaceY), locStrings["morec4"], locStrings["moreC4_description"], self.MoreC4Unlocker, self.moreC4IMG)
            self.moreC4_10button = self:AbilityButton(false, Vector2(posX, self.moreC4_8button:GetPosition().y + self.buttonsSize + spaceY), locStrings["morec4"], locStrings["moreC4_description"], self.MoreC4Unlocker, self.moreC4IMG)
            self.moreC4_15button = self:AbilityButton(false, Vector2(posX, self.moreC4_10button:GetPosition().y + self.buttonsSize + spaceY), locStrings["morec4"], locStrings["moreC4_description"], self.MoreC4Unlocker, self.moreC4IMG)
            self.supernuclearbombbutton = self:AbilityButton(true, Vector2(self.moreC4_5button:GetPosition().x + spaceX, spaceY), locStrings["supernuclearbomb"], locStrings["supernuclearbomb_description"], self.SuperNuclearBombUnlocker, self.superNuclearBombIMG)
            posX = self.supernuclearbombbutton:GetPosition().x + spaceX
            self.longergrapple_150button = self:AbilityButton(true, Vector2(posX, spaceY), locStrings["longergrapple"], locStrings["longergrapple_description"], self.LongerGrappleUnlocker, self.longerGrappleIMG)
            self.longergrapple_200button = self:AbilityButton(false, Vector2(posX, self.longergrapple_150button:GetPosition().y + self.buttonsSize + spaceY), locStrings["longergrapple"], locStrings["longergrapple_description"], self.LongerGrappleUnlocker, self.longerGrappleIMG)
            self.longergrapple_350button = self:AbilityButton(false, Vector2(posX, self.longergrapple_200button:GetPosition().y + self.buttonsSize + spaceY), locStrings["longergrapple"], locStrings["longergrapple_description"], self.LongerGrappleUnlocker, self.longerGrappleIMG)
            self.longergrapple_500button = self:AbilityButton(false, Vector2(posX, self.longergrapple_350button:GetPosition().y + self.buttonsSize + spaceY), locStrings["longergrapple"], locStrings["longergrapple_description"], self.LongerGrappleUnlocker, self.longerGrappleIMG)
            self.jesusmode_button = self:AbilityButton(true, Vector2(self.longergrapple_150button:GetPosition().x + spaceX, spaceY), locStrings["jesusmode"], locStrings["jesusmode_description"], self.JesusModeUnlocker, self.jesusModeIMG)
        end

        if self.window then
            self:UpdateButtons(LocalPlayer:GetMoney())
        end

        self.tip_title:SetText(locStrings["abilities"])
        self.tip_descrition:SetText(locStrings["noselected_description"])
        self.tip_descrition:SizeToContents()
        self.tip_descrition:SetWrap(true)

        if LocalPlayer:GetValue("SystemFonts") then
            self.money_text:SetFont(AssetLocation.SystemFont, "Impact")
            self.tip_title:SetFont(AssetLocation.SystemFont, "Impact")
        end

        if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
        if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
        if not self.LocalPlayerMoneyChangeEvent then self.LocalPlayerMoneyChangeEvent = Events:Subscribe("LocalPlayerMoneyChange", self, self.LocalPlayerMoneyChange) end

        local lang = LocalPlayer:GetValue("Lang")
        if lang then
            self.money_text:SetText(lang == "EN" and "Balance: $" .. formatNumber(LocalPlayer:GetMoney()) or "Баланс: $" .. formatNumber(LocalPlayer:GetMoney()))
            self.money_text:SizeToContents()
        end

        if LocalPlayer:GetValue("Wingsuit") then
            self.wingsuitbutton.unlockstats:SetToolTip(locStrings["wingsuit"] .. " ( " .. locStrings["unlocked"] .. " )")
            self.wingsuitbutton.unlockstats:SetVisible(true)
        else
            self.wingsuitbutton:SetToolTip(locStrings["wingsuit"] .. " ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.Wingsuit) .. " )")
            self.wingsuitbutton.unlockstats:SetVisible(false)
        end

        local boost = LocalPlayer:GetValue("Boost")

        if boost then
            self.boost_1button.unlockstats:SetToolTip(locStrings["landvehicleboost"] .. " ( " .. locStrings["unlocked"] .. " )")
            self.boost_1button.unlockstats:SetVisible(true)

            if boost == self.boostValue_1 then
                self.boost_2button:SetToolTip(locStrings["watervehicleboost"] .. " ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.Boost_2) .. " )")
                self.boost_2button:SetVisible(true)
            end

            if boost >= self.boostValue_2 then
                self.boost_2button.unlockstats:SetToolTip(locStrings["watervehicleboost"] .. " ( " .. locStrings["unlocked"] .. " )")
                self.boost_2button:SetVisible(true)
                self.boost_2button.unlockstats:SetVisible(true)
            end

            if boost == self.boostValue_2 then
                self.boost_3button:SetToolTip(locStrings["airvehicleboost"] .. " ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.Boost_3) .. " )")
                self.boost_3button:SetVisible(true)
            end

            if boost >= self.boostValue_3 then
                self.boost_3button.unlockstats:SetToolTip(locStrings["airvehicleboost"] .. " ( " .. locStrings["unlocked"] .. " )")
                self.boost_3button:SetVisible(true)
                self.boost_3button.unlockstats:SetVisible(true)
            end
        else
            self.boost_1button:SetToolTip(locStrings["landvehicleboost"] .. " ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.Boost_1) .. " )")
            self.boost_1button.unlockstats:SetVisible(false)

            self.boost_2button.unlockstats:SetToolTip(locStrings["watervehicleboost"] .. " ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.Boost_2) .. " )")
            self.boost_2button:SetVisible(false)
            self.boost_2button.unlockstats:SetVisible(false)

            self.boost_3button.unlockstats:SetToolTip(locStrings["airvehicleboost"] .. " ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.Boost_3) .. " )")
            self.boost_3button:SetVisible(false)
            self.boost_3button.unlockstats:SetVisible(false)
        end

        if LocalPlayer:GetValue("MoneyBonus") then
            self.bonusmoneybutton.unlockstats:SetToolTip(locStrings["bonusmoney"] .. " ( " .. locStrings["unlocked"] .. " )")
            self.bonusmoneybutton.unlockstats:SetVisible(true)
        else
            self.bonusmoneybutton:SetToolTip(locStrings["bonusmoney"] .. " ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.BonusMoney) .. " )")
            self.bonusmoneybutton.unlockstats:SetVisible(false)
        end

        local moreC4 = LocalPlayer:GetValue("MoreC4")

        if moreC4 then
            self.moreC4_5button.unlockstats:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_5 .. " " .. locStrings["items"] .. ") ( " .. locStrings["unlocked"] .. " )")
            self.moreC4_5button.unlockstats:SetVisible(true)

            if moreC4 == self.moreC4Value_5 then
                self.moreC4_8button:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_8 .. " " .. locStrings["items"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.MoreC4_8) .. " )")
                self.moreC4_8button:SetVisible(true)
            end

            if moreC4 >= self.moreC4Value_8 then
                self.moreC4_8button.unlockstats:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_8 .. " " .. locStrings["items"] .. ") ( " .. locStrings["unlocked"] .. " )")
                self.moreC4_8button:SetVisible(true)
                self.moreC4_8button.unlockstats:SetVisible(true)
            end

            if moreC4 == self.moreC4Value_8 then
                self.moreC4_10button:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_10 .. " " .. locStrings["items"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.MoreC4_10) .. " )")
                self.moreC4_10button:SetVisible(true)
            end

            if moreC4 >= self.moreC4Value_10 then
                self.moreC4_10button.unlockstats:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_10 .. " " .. locStrings["items"] .. ") ( " .. locStrings["unlocked"] .. " )")
                self.moreC4_10button:SetVisible(true)
                self.moreC4_10button.unlockstats:SetVisible(true)
            end

            if moreC4 == self.moreC4Value_10 then
                self.moreC4_15button:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_15 .. " " .. locStrings["items"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.MoreC4_15) .. " )")
                self.moreC4_15button:SetVisible(true)
            end

            if moreC4 >= self.moreC4Value_15 then
                self.moreC4_15button.unlockstats:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_15 .. " " .. locStrings["items"] .. ") ( " .. locStrings["unlocked"] .. " )")
                self.moreC4_15button:SetVisible(true)
                self.moreC4_15button.unlockstats:SetVisible(true)
            end
        else
            self.moreC4_5button:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_5 .. " " .. locStrings["items"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.MoreC4_5) .. " )")
            self.moreC4_5button.unlockstats:SetVisible(false)

            self.moreC4_8button:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_8 .. " " .. locStrings["items"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.MoreC4_8) .. " )")
            self.moreC4_8button:SetVisible(false)
            self.moreC4_8button.unlockstats:SetVisible(false)

            self.moreC4_10button:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_10 .. " " .. locStrings["items"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.MoreC4_10) .. " )")
            self.moreC4_10button:SetVisible(false)
            self.moreC4_10button.unlockstats:SetVisible(false)

            self.moreC4_15button:SetToolTip(locStrings["morec4"] .. " (" .. self.moreC4Value_15 .. " " .. locStrings["items"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.MoreC4_15) .. " )")
            self.moreC4_15button:SetVisible(false)
            self.moreC4_15button.unlockstats:SetVisible(false)
        end

        if LocalPlayer:GetValue("SuperNuclearBomb") then
            self.supernuclearbombbutton.unlockstats:SetToolTip(locStrings["supernuclearbomb"] .. " ( " .. locStrings["unlocked"] .. " )")
            self.supernuclearbombbutton.unlockstats:SetVisible(true)
        else
            self.supernuclearbombbutton:SetToolTip(locStrings["supernuclearbomb"] .. " ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.SuperNuclearBomb) .. " )")
            self.supernuclearbombbutton.unlockstats:SetVisible(false)
        end

        local longerGrapple = LocalPlayer:GetValue("LongerGrapple")

        if longerGrapple then
            self.longergrapple_150button.unlockstats:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_1 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["unlocked"] .. " )")
            self.longergrapple_150button.unlockstats:SetVisible(true)

            if longerGrapple == self.GrappleLongerValue_1 then
                self.longergrapple_200button:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_2 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.LongerGrapple_200) .. " )")
                self.longergrapple_200button:SetVisible(true)
            end

            if longerGrapple >= self.GrappleLongerValue_2 then
                self.longergrapple_200button.unlockstats:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_2 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["unlocked"] .. " )")
                self.longergrapple_200button:SetVisible(true)
                self.longergrapple_200button.unlockstats:SetVisible(true)
            end

            if longerGrapple == self.GrappleLongerValue_2 then
                self.longergrapple_350button:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_3 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.LongerGrapple_350) .. " )")
                self.longergrapple_350button:SetVisible(true)
            end

            if longerGrapple >= self.GrappleLongerValue_3 then
                self.longergrapple_350button.unlockstats:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_3 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["unlocked"] .. " )")
                self.longergrapple_350button:SetVisible(true)
                self.longergrapple_350button.unlockstats:SetVisible(true)
            end

            if longerGrapple == self.GrappleLongerValue_3 then
                self.longergrapple_500button:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_4 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.LongerGrapple_500) .. " )")
                self.longergrapple_500button:SetVisible(true)
            end

            if longerGrapple >= self.GrappleLongerValue_4 then
                self.longergrapple_500button.unlockstats:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_4 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["unlocked"] .. " )")
                self.longergrapple_500button:SetVisible(true)
                self.longergrapple_500button.unlockstats:SetVisible(true)
            end
        else
            self.longergrapple_150button:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_1 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.LongerGrapple_150) .. " )")
            self.longergrapple_150button.unlockstats:SetVisible(false)

            self.longergrapple_200button:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_2 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.LongerGrapple_200) .. " )")
            self.longergrapple_200button:SetVisible(false)
            self.longergrapple_200button.unlockstats:SetVisible(false)

            self.longergrapple_350button:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_3 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.LongerGrapple_350) .. " )")
            self.longergrapple_350button:SetVisible(false)
            self.longergrapple_350button.unlockstats:SetVisible(false)

            self.longergrapple_500button:SetToolTip(locStrings["longergrapple"] .. " (" .. self.GrappleLongerValue_4 .. " " .. locStrings["meters"] .. ") ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.LongerGrapple_500) .. " )")
            self.longergrapple_500button:SetVisible(false)
            self.longergrapple_500button.unlockstats:SetVisible(false)
        end

        if LocalPlayer:GetValue("JesusModeEnabled") then
            self.jesusmode_button.unlockstats:SetToolTip(locStrings["jesusmode"] .. " ( " .. locStrings["unlocked"] .. " )")
            self.jesusmode_button.unlockstats:SetVisible(true)
        else
            self.jesusmode_button:SetToolTip(locStrings["jesusmode"] .. " ( " .. locStrings["needed"] .. ": $" .. formatNumber(Prices.JesusMode) .. " )")
            self.jesusmode_button.unlockstats:SetVisible(false)
        end
    else
        if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
        if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
        if self.LocalPlayerMoneyChangeEvent then Events:Unsubscribe(self.LocalPlayerMoneyChangeEvent) self.LocalPlayerMoneyChangeEvent = nil end
    end

    if sound then
        local effect = ClientEffect.Play(AssetLocation.Game, {
            effect_id = self.activeWindow and 382 or 383,

            position = Camera:GetPosition(),
            angle = Angle()
        })
    end
end

function Abilities:LocalPlayerInput(args)
    if args.input == Action.GuiPause then
        self:SetWindowVisible(false)
    end

    if self.actions[args.input] then
        return false
    end
end

local abilities = Abilities()
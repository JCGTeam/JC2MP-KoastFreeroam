class("SettingsTab")

function SettingsTab:__init(...)
    TabBase.__init(self, "Настройки", ...)
    local leftSide = BaseWindow.Create(self.page)
    leftSide:SetDock(GwenPosition.Left)
    leftSide:SetWidth(360)

    local groupBoxBindMenu = RaceMenu.CreateGroupBox(leftSide)
    groupBoxBindMenu:SetDock(GwenPosition.Fill)
    groupBoxBindMenu:SetText("Управление")

    local bindMenu = BindMenu.Create(groupBoxBindMenu)
    bindMenu:SetDock(GwenPosition.Fill)
    -- bindMenu:AddControl("Открыть меню гонок" , nil)
    bindMenu:AddControl("Возродиться", "R")
    bindMenu:AddControl("Поворачивать камеру", "Mouse3")
    bindMenu:AddControl("Следующая цель", "MoveRight")
    bindMenu:AddControl("Предыдущая цель", "MoveLeft")
    bindMenu:RequestSettings()

    local rightSide = BaseWindow.Create(self.page)
    rightSide:SetDock(GwenPosition.Fill)

    local groupBoxOtherSettings = RaceMenu.CreateGroupBox(rightSide)
    groupBoxOtherSettings:SetDock(GwenPosition.Fill)
    groupBoxOtherSettings:SetText("Прочие настройки")

    local base = BaseWindow.Create(groupBoxOtherSettings)
    base:SetDock(GwenPosition.Top)
    base:SetHeight(18)

    local label = Label.Create(base)
    label:SetDock(GwenPosition.Left)
    label:SetTextColor(Color(245, 230, 150))
    label:SetText("Предупреждение: ")
    label:SizeToContents()

    label = Label.Create(base)
    label:SetDock(GwenPosition.Left)
    label:SetText("Данные настройки не сохраняются.")
    label:SizeToContents()

    local CreateButton = function(...)
        local button = Button.Create(...)
        button:SetPadding(Vector2(0, 5), Vector2(0, 5))
        button:SetMargin(Vector2(0, 2), Vector2(0, 2))
        button:SetDock(GwenPosition.Top)
        button:SetTextSize(16)
        button:SizeToContents()

        return button
    end

    local button
    button = CreateButton(groupBoxOtherSettings)
    button:SetText("Настройка спидометра")
    button:Subscribe("Press", function() Events:Fire("OpenSpeedometerMenu") end)

    button = CreateButton(groupBoxOtherSettings)
    button:SetText("Настройка тегов")
    button:Subscribe("Press", function() Events:Fire("OpenNametagsMenu") end)
end
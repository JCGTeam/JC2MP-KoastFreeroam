BindMenu = {}

-- Controls can only be assigned to these if using a gamepad.
BindMenu.blockedMouseActions = {Action.LookUp, Action.LookDown, Action.LookLeft, Action.LookRight, Action.HeliTurnLeft, Action.HeliTurnRight}

BindMenu.Create = function(locStrings)
    local window = SortedList.Create()
    window:SetDock(GwenPosition.Fill)

    -- Array of tables. See Controls.
    window.controls = {}
    window.buttons = {}
    window.resetButtons = {}
    window.labelByName = {}

    window.state = "Idle"
    window.dirtySettings = false
    window.saveTimer = Timer()
    -- These two are used to delay Actions so it prefers keys or mouse buttons.
    window.ticksSinceAction = 0
    -- Used to determine mouse delta.

    -- defaultControl can be an Action name, a Key name, or nil.
    -- Examples: "SoundHornSiren", "LShift", "C", "Mouse3", nil
    function window:AddControl(name, defaultControl, title)
        if not name then
            error("Invalid arguments")
        end

        local control = Controls.Add(name, defaultControl)

        local item = self:AddItem("")
    
        local label = Label.Create(window)
        label:SetAlignment(GwenPosition.CenterV)
        label:SetDock(GwenPosition.Fill)
        label:SetPadding(Vector2(10, 0), Vector2(10, 0))
        if title then
            label:SetText(title)
        end
        label:SetDataObject("control", control)
        label:SetDataObject("defaultControl", defaultControl)

        local baseLabel = label
        self.labelByName[name] = label

        local keyButton = Button.Create(baseLabel)
        keyButton:SetDock(GwenPosition.Fill)
        keyButton:SetPadding(Vector2(10, 0), Vector2(10, 0))
        keyButton:SetText(control.valueString)
        keyButton:Subscribe("Press", self, function() self:ButtonPressed(baseLabel) end)

        baseLabel:SetDataObject("label", keyButton)

        local resetButton = Button.Create(baseLabel)
        resetButton:SetDock(GwenPosition.Fill)
        resetButton:SetText(locStrings["reset"])
        local color = Color(255, 150, 150)
        resetButton:SetTextNormalColor(color)
        resetButton:SetTextPressedColor(color)
        resetButton:SetTextHoveredColor(color)
        resetButton:SetDataObject("activeButton", baseLabel)
        resetButton:Subscribe("Down", self, self.UnassignButtonPressed)
        table.insert(self.resetButtons, resetButton)

        table.insert(self.controls, {
            item = item,
            label = label,
            button = keyButton,
            reset = resetButton
        })

        item:SetHeight(30)

        self:Assign(baseLabel)

        return baseLabel
    end

    function window:SetColumns(locStrings)
        window:AddColumn(locStrings["action"])

        local lsReset = locStrings["reset"]

        window:AddColumn(locStrings["key"], Render:GetTextWidth(InputNames.Key[74]) + 25)
        window:AddColumn(lsReset, Render:GetTextWidth(lsReset) + 15)

        for _, control in ipairs(self.controls) do
            local item = control.item

            item:SetCellContents(0, control.label)
            item:SetCellContents(1, control.button)
            item:SetCellContents(2, control.reset)
        end
    end

    function window:Assign(activeButton)
        self.state = "Idle"

        BindMenu.SetEnabledRecursive(self, true)

        local control = activeButton:GetDataObject("control")
        local label = activeButton:GetDataObject("label")
        label:SetText(control.valueString)

        Controls.Set(control)

        self:ClearSubscriptions()
    end

    function window:ClearSubscriptions()
        if self.PreTickEvent then Events:Unsubscribe(self.PreTickEvent) self.PreTickEvent = nil end
    
        if self.eventKeyUp then
            --Events:Unsubscribe(self.eventInput) self.eventInput = nil
            Events:Unsubscribe(self.eventKeyUp) self.eventKeyUp = nil
            --Events:Unsubscribe(self.eventMouseUp) self.eventMouseUp = nil
            --Events:Unsubscribe(self.eventMouseWheel) self.eventMouseWheel = nil
        end
    end

    -- GWEN events

    function window:ButtonPressed(button)
        if self.state ~= "Idle" then return end

        self.state = "Activated"

        BindMenu.SetEnabledRecursive(self, false)

        local label = button:GetDataObject("label")
        label:SetText("...")

        self.activatedButton = button
        self.activeAction = nil

        --self.eventInput = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
        self.eventKeyUp = Events:Subscribe("KeyUp", self, self.KeyUp)
        --self.eventMouseUp = Events:Subscribe("MouseUp", self, self.MouseButtonUp)
        --self.eventMouseWheel = Events:Subscribe("MouseScroll", self, self.MouseScroll)
    end

    function window:MouseMovementButtonPressed(button)
        if self.state ~= "Idle" then return end

        self.state = "ActivatedMouse"

        BindMenu.SetEnabledRecursive(self, false)

        self.activatedButton = button:GetParent()

        local label = self.activatedButton:GetDataObject("label")
        label:SetText("...")
    end

    function window:UnassignButtonPressed(button)
        if self.state ~= "Idle" then return end

        local activeButton = button:GetDataObject("activeButton")
        local defaultControl = activeButton:GetDataObject("defaultControl")
        local control = Controls.Add(activeButton:GetDataObject("control").name, defaultControl)

        activeButton:SetDataObject("control", control)
        self:Assign(activeButton)

        self.dirtySettings = true

        Controls.UpdateBindings()
    end

    function window:ResetAllControls()
        for name, label in pairs(self.labelByName) do
            local defaultControl = label:GetDataObject("defaultControl")
            local control = Controls.Add(name, defaultControl)

            label:SetDataObject("control", control)
            self:Assign(label)
        end

        self.dirtySettings = true
        Controls.UpdateBindings()
    end

    function window:RequestSettings()
        Network:Send("BindMenuRequestSettings", 12345)
    end

    function window:SaveSettings()
        local settings = {}

        -- Marshal every control into a format that will be stored in the database.
        for index, control in ipairs(Controls.controls) do
            local info = {
                name = control.name,
                type = control.type,
                value = tostring(control.value),
                module = module_name
            }
            table.insert(settings, info)
        end

        Network:Send("BindMenuSaveSettings", settings)
    end

    window._Remove = window.Remove
    function window:Remove()
        Events:Unsubscribe(self.tickEvent)
        Network:Unsubscribe(self.receiveEvent)

        self:_Remove()
    end

    -- Events

    function window:LocalPlayerInput(args)
        -- Block mouse actions if we're not using a gamepad.
        if Game:GetSetting(GameSetting.GamepadInUse) == 0 then
            for index, action in ipairs(BindMenu.blockedMouseActions) do
                if args.input == action then
                    return true
                end
            end
        end

        if args.state > 0.5 then
            -- PostTick handles these later.
            self.activeAction = args.input
            self.ticksSinceAction = 0
        end

        return true
    end

    function window:KeyUp(args)
        if not self.activatedButton then return end

        local control = self.activatedButton:GetDataObject("control")

        if args.key == VirtualKey.Escape then
            local label = self.activatedButton:GetDataObject("label")

            label:SetText(control.valueString)

            self.activatedButton = nil
            self.state = "Idle"

            BindMenu.SetEnabledRecursive(self, true)

            self:ClearSubscriptions()
            return
        end

        local pressedKey = args.key

        self:ClearSubscriptions()

        self.keyDelayTimer = Timer()

        self.PreTickEvent = Events:Subscribe("PreTick", function()
            if self.keyDelayTimer and self.keyDelayTimer:GetSeconds() > 0.1 then
                control.type = "Key"
                control.value = pressedKey
                control.valueString = InputNames.GetKeyName(pressedKey)

                self:Assign(self.activatedButton)
                self.activatedButton = nil
                self.state = "Idle"

                self.dirtySettings = true

                BindMenu.SetEnabledRecursive(self, true)

                self.keyDelayTimer = nil

                Controls.UpdateBindings()

                self:ClearSubscriptions()
            end
        end)
    end

    function window:MouseButtonUp(args)
        local control = self.activatedButton:GetDataObject("control")

        control.type = "MouseButton"
        control.value = args.button
        control.valueString = string.format("Mouse%i", args.button)

        self:Assign(self.activatedButton)
        self.activatedButton = nil

        self.dirtySettings = true

        Controls.UpdateBindings()
    end

    function window:MouseScroll(args)
        local control = self.activatedButton:GetDataObject("control")

        control.type = "MouseWheel"
        control.value = math.clamp(args.delta, -1, 1)
        if control.value == 1 then
            control.valueString = "Mouse wheel up"
        else
            control.valueString = "Mouse wheel down"
        end

        self:Assign(self.activatedButton)
        self.activatedButton = nil

        self.dirtySettings = true

        Controls.UpdateBindings()
    end

    function window:PostTick()
        if self.state == "Activated" then
            -- If we've tried to assign an action a few ticks ago, actually assign it. Actions are
            -- delayed so that keys and mouse buttons have preference.
            if self.activeAction then
                self.ticksSinceAction = self.ticksSinceAction + 1
                if self.ticksSinceAction >= 3 then
                    local control = self.activatedButton:GetDataObject("control")
                    control.type = "Action"
                    control.value = self.activeAction
                    control.valueString = InputNames.GetActionName(self.activeAction)

                    self:Assign(self.activatedButton)
                    self.activatedButton = nil

                    self.dirtySettings = true

                    self.activeAction = nil
                end
            end
        end

        -- Give the server our settings periodically.
        if self.saveTimer:GetSeconds() > 7 then
            self.saveTimer:Restart()

            if self.dirtySettings then
                self.dirtySettings = false
                self:SaveSettings()
            end
        end
    end

    function window:ReceiveSettings(settingsString)
        if settingsString == "Empty" then return end

        local settings = settingsString:split("\n")
        for index, setting in ipairs(settings) do
            local control = {}
            local module, name, type, value = table.unpack(setting:split("|"))
            control.name = name
            control.type = type
            if control.type == "Unassigned" then
                control.valueString = "Unassigned"
            elseif control.type == "Action" then
                control.value = tonumber(value) or -1
                control.valueString = InputNames.GetActionName(control.value)
            elseif control.type == "Key" then
                control.value = tonumber(value) or -1
                control.valueString = InputNames.GetKeyName(control.value)
            elseif control.type == "MouseButton" then
                control.value = tonumber(value) or -1
                control.valueString = ("Mouse%i"):format(value)
            elseif control.type == "MouseWheel" then
                control.value = tonumber(value) or 0
                if control.value == 1 then
                    control.valueString = "Mouse wheel up"
                elseif control.value == -1 then
                    control.valueString = "Mouse wheel down"
                else
                    control.valueString = "Mouse wheel wat"
                end
            elseif control.type == "MouseMovement" then
                control.value = value
                control.valueString = ({
                    [">"] = "Mouse right",
                    ["<"] = "Mouse left",
                    ["v"] = "Mouse down",
                    ["^"] = "Mouse up"
                })[control.value]
            end

            local button = self.labelByName and self.labelByName[control.name]
            if button then
                button:SetDataObject("control", control)
                self:Assign(button)
            end
        end

        Controls.UpdateBindings()
    end

    window.tickEvent = Events:Subscribe("PostTick", window, window.PostTick)
    window.receiveEvent = Network:Subscribe("BindMenuReceiveSettings", window, window.ReceiveSettings)

    function window:SetResetText(text)
        for _, button in ipairs(self.resetButtons) do
            button:SetText(text)
        end
    end

    return window
end

BindMenu.SetEnabledRecursive = function(window, enabled)
    window:SetEnabled(enabled)

    local children = window:GetChildren()
    for index, child in ipairs(children) do
        BindMenu.SetEnabledRecursive(child, enabled)
    end
end
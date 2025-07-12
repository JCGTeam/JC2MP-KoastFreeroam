ModernGUI = {}
ModernGUI.Window = {}
ModernGUI.Button = {}
ModernGUI.TextBox = {}

function ModernGUI.Window.Create(parent)
    local outline = Rectangle.Create(parent or "")
    outline:SetColor(Color(45, 45, 45))

    local padding = Vector2(4, 4)
    outline:SetPadding(padding, padding)

    local window = Rectangle.Create(outline)
    window:SetDock(GwenPosition.Fill)
    window:SetColor(Color(25, 25, 25))

    local result = {outline = outline, window = window}

    function result:SetVisible(visible)
        if result.outline then result.outline:SetVisible(visible) end
    end

    function result:SetDock(gwenPosition)
        if result.outline then result.outline:SetDock(gwenPosition) end
    end

    function result:SetSize(size)
        if result.outline then result.outline:SetSize(size) end
    end

    function result:SetPosition(pos)
        if result.outline then result.outline:SetPosition(pos) end
    end

    function result:GetPosition()
        if result.outline then return result.outline:GetPosition() end
    end

    function result:GetSize()
        if result.outline then return result.outline:GetSize() end
    end

    function result:SetPadding(first, second)
        if result.window then result.window:SetPadding(first, second) end
    end

    function result:Remove()
        if result.outline then result.outline:Remove() result.outline = nil end
        if result.window then result.window:Remove() result.window = nil end
    end

    return result
end

function ModernGUI.Button.Create(parent)
    local defaultAlpha, hoverAlpha, hoverSpeed = 100, 200, 0.1
    local defaultColor = Color(75, 75, 75, defaultAlpha)

    local background = Rectangle.Create(parent or "")
    background:SetColor(defaultColor)

    local button = Button.Create(background)
    button:SetDock(GwenPosition.Fill)
    button:SetBackgroundVisible(false)
    button:SetTextSize(20)

    button:Subscribe("HoverEnter", function()
        Animation:Play(defaultAlpha, hoverAlpha, hoverSpeed, easeIOnut, function(value)
            if IsValid(background) then
                background:SetColor(Color(defaultColor.r, defaultColor.g, defaultColor.b, value))
            end
        end)
    end)

    button:Subscribe("HoverLeave", function()
        Animation:Play(hoverAlpha, defaultAlpha, hoverSpeed, easeIOnut, function(value)
            if IsValid(background) then
                background:SetColor(Color(defaultColor.r, defaultColor.g, defaultColor.b, value))
            end
        end)
    end)

    button:Subscribe("Press", function()
        Animation:Play(0, hoverAlpha, hoverSpeed, easeIOnut, function(value)
            if IsValid(background) then
                background:SetColor(Color(defaultColor.r, defaultColor.g, defaultColor.b, value))
            end
        end)
    end)

    local result = {background = background, button = button}

    function result:SetVisible(visible)
        if result.background then result.background:SetVisible(visible) end
    end

    function result:SetDock(gwenPosition)
        if result.background then result.background:SetDock(gwenPosition) end
    end

    function result:SetMargin(first, second)
        if result.background then result.background:SetMargin(first, second) end
    end

    function result:SetSize(size)
        if result.background then result.background:SetSize(size) end
    end

    function result:SetPosition(pos)
        if result.background then result.background:SetPosition(pos) end
    end

    function result:GetPosition()
        if result.background then return result.background:GetPosition() end
    end

    function result:GetSize()
        if result.background then return result.background:GetSize() end
    end

    function result:SetHeight(height)
        if result.background then result.background:SetHeight(height) end
    end

    function result:SetWidth(height)
        if result.background then result.background:SetWidth(height) end
    end

    function result:SetAlignment(gwenPosition)
        if result.button then result.button:SetAlignment(gwenPosition) end
    end

    function result:SetText(text)
        if result.button then result.button:SetText(text) end
    end

    function result:SetTextSize(size)
        if result.button then result.button:SetTextSize(size) end
    end

    function result:SetTextPadding(first, second)
        if result.button then result.button:SetTextPadding(first, second) end
    end

    function result:SetTextHoveredColor(color)
        if result.button then result.button:SetTextHoveredColor(color) end
    end

    function result:SetTextPressedColor(color)
        if result.button then result.button:SetTextPressedColor(color) end
    end

    function result:SetFont(assetLocation, font)
        if result.button then result.button:SetFont(assetLocation, font) end
    end

    function result:SetEnabled(enabled)
        if result.button then result.button:SetEnabled(enabled) end
    end

    function result:GetText()
        if result.button then return result.button:GetText() end
    end

    function result:GetTextSize()
        if result.button then return result.button:GetTextSize() end
    end

    function result:Remove()
        if result.button then result.button:Remove() result.button = nil end
        if result.background then result.background:Remove() result.background = nil end
    end

    function result:Subscribe(event, first, second)
        if result.button then
            if second then
                return result.button:Subscribe(event, first, second)
            else
                return result.button:Subscribe(event, first)
            end
        end
    end

    return result
end

function ModernGUI.TextBox.Create(parent)
    local defaultAlpha, hoverAlpha, hoverSpeed = 200, 255, 0.1
    local defaultColor = Color(255, 255, 255, defaultAlpha)

    local background = Rectangle.Create(parent or "")
    background:SetColor(defaultColor)
    background:SetHeight(20)

    local textBox = TextBox.Create(background)
    textBox:SetDock(GwenPosition.Fill)
    textBox:SetBackgroundVisible(false)

    textBox:Subscribe("HoverEnter", function()
        Animation:Play(defaultAlpha, hoverAlpha, hoverSpeed, easeIOnut, function(value)
            if IsValid(background) then
                background:SetColor(Color(defaultColor.r, defaultColor.g, defaultColor.b, value))
            end
        end)
    end)

    textBox:Subscribe("HoverLeave", function()
        Animation:Play(hoverAlpha, defaultAlpha, hoverSpeed, easeIOnut, function(value)
            if IsValid(background) then
                background:SetColor(Color(defaultColor.r, defaultColor.g, defaultColor.b, value))
            end
        end)
    end)

    local result = {background = background, textBox = textBox}

    function result:SetDock(gwenPosition)
        if result.background then result.background:SetDock(gwenPosition) end
    end

    function result:SetMargin(first, second)
        if result.background then result.background:SetMargin(first, second) end
    end

    function result:SetSize(size)
        if result.background then result.background:SetSize(size) end
    end

    function result:SetPosition(pos)
        if result.background then result.background:SetPosition(pos) end
    end

    function result:GetPosition()
        if result.background then return result.background:GetPosition() end
    end

    function result:GetSize()
        if result.background then return result.background:GetSize() end
    end

    function result:SetHeight(height)
        if result.background then result.background:SetHeight(height) end
    end

    function result:SetWidth(height)
        if result.background then result.background:SetWidth(height) end
    end

    function result:SetAlignment(gwenPosition)
        if result.textBox then result.textBox:SetAlignment(gwenPosition) end
    end

    function result:InsertText(text)
        if result.textBox then result.textBox:InsertText(text) end
    end

    function result:SetTextColor(color)
        if result.textBox then result.textBox:SetTextColor(color) end
    end

    function result:SetTextPadding(first, second)
        if result.textBox then result.textBox:SetTextPadding(first, second) end
    end

    function result:SetFont(assetLocation, font)
        if result.textBox then result.textBox:SetFont(assetLocation, font) end
    end

    function result:GetText()
        if result.textBox then return result.textBox:GetText() end
    end

    function result:GetTextSize()
        if result.textBox then return result.textBox:GetTextSize() end
    end

    function result:GetTextColor()
        if result.textBox then return result.textBox:GetTextColor() end
    end

    function result:Remove()
        if result.textBox then result.textBox:Remove() result.textBox = nil end
        if result.background then result.background:Remove() result.background = nil end
    end

    function result:Subscribe(event, first, second)
        if result.textBox then
            if second then
                return result.textBox:Subscribe(event, first, second)
            else
                return result.textBox:Subscribe(event, first)
            end
        end
    end

    return result
end

--[[
function ModernGUI.Window.Create()
    local window = Rectangle.Create()
    window:SetColor(Color(0, 0, 0, 200))
    window:SetPadding(Vector2(5, 5), Vector2(5, 5))

    local windowTop = Rectangle.Create(window)
    windowTop:SetDock(GwenPosition.Top)
    windowTop:SetHeight(30)
    windowTop:SetColor(Color(30, 30, 30, 255))
    windowTop:SetMargin(Vector2(-5, -5), Vector2(-5, 5))

    local windowTitle = Label.Create(windowTop)
    windowTitle:SetDock(GwenPosition.Fill)
    windowTitle:SetMargin(Vector2(10, 0), Vector2(0, 0))
    windowTitle:SetAlignment(GwenPosition.CenterV)

    local closeButton = MenuItem.Create(windowTop)
    closeButton:SetDock(GwenPosition.Right)
    closeButton:SetWidth(30)
    closeButton:SetText("x")
    closeButton:SetTextSize(20)

    function window:Subscribe(event, first, second)
        if event == "WindowClosed" then
            closeButton:Subscribe("Press", first, second)
        end
    end

    function window:SetTitle(title)
        windowTitle:SetText(title)
    end

    return window
end
]] -- 
class "GUI"

local textBoxTypes = {
    ["text"] = TextBox,
    ["numeric"] = TextBoxNumeric,
    ["multiline"] = TextBoxMultiline,
    ["password"] = PasswordTextBox
}

function GUI:Window(title, pos, size)
    local window = Window.Create()

    window:SetTitle(title)
    window:SetPositionRel(pos)
    window:SetSizeRel(size)

    return window
end

function GUI:Button(text, pos, size, parent)
    local button = Button.Create()

    button:SetText(text)
    button:SetTextSize(15)

    if parent then
        button:SetParent(parent)
    end

    button:SetPositionRel(pos)
    button:SetSizeRel(size)

    return button
end

function GUI:Label(text, pos, size, parent)
    local label = Label.Create()

    label:SetText(text)

    if parent then
        label:SetParent(parent)
    end

    label:SetPositionRel(pos)
    label:SetSizeRel(size)

    return label
end

function GUI:SortedList(pos, size, parent, columns)
    local list = SortedList.Create()

    if parent then
        list:SetParent(parent)
    end

    list:SetPositionRel(pos)
    list:SetSizeRel(size)

    if type(columns) == "table" and #columns > 0 then
        for _, col in ipairs(columns) do
            if tonumber(col.width) then
                list:AddColumn(tostring(col.name), tonumber(col.width))
            else
                list:AddColumn(tostring(col.name))
            end
        end
    end

    return list
end

function GUI:TextBox(text, pos, size, type, parent)
    local func = textBoxTypes[type]

    if func then
        local textBox = func.Create()

        if parent then
            textBox:SetParent(parent)
        end

        textBox:SetText(text)
        textBox:SetPositionRel(pos)
        textBox:SetSizeRel(size)

        return textBox
    else
        return false
    end
end

function GUI:ScrollControl(pos, size, parent)
    local scroll = ScrollControl.Create()

    if parent then
        scroll:SetParent(parent)
    end

    scroll:SetPositionRel(pos)
    scroll:SetSizeRel(size)

    return scroll
end
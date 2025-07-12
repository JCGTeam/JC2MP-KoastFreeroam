class 'Bind'

function Bind:__init()
    self.binds = {}
    self.unbind = false
    self.color = Color(255, 250, 150)

    self.cooldown = 1
    self.cooltime = 0

    self.tag_clr = Color.White

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            tag = "[Привязка] ",
            command = "Команда ",
            usageexample = "Пример использования:",
            othercommands = "Другие команды:",
            prompted = "Вам будет предложено нажать клавишу для привязки команды.",
            presskeytobind = "Нажмите клавишу, которую вы хотите связать с командой ",
            allkeysunbound = "Все клавиши отвязаны.",
            presstounbound = "Нажмите клавишу, которую вы хотели бы отвязать.",
            does = " делает ",
            boundtokey = " привязана к клавише ",
            bindsloaded = "Привязка клавиш загружена"
        }
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("LocalPlayerChat", self, self.LocalPlayerChat)
    Events:Subscribe("KeyDown", self, self.KeyDown)

    Network:Subscribe("SQLLoad", self, self.SQLLoad)
end

function Bind:Lang()
    self.locStrings = {
        tag = "[Binding] ",
        command = "Command ",
        usageexample = "Usage example:",
        othercommands = "Other commands:",
        prompted = "You will be prompted for a key to bind the command to.",
        presskeytobind = "Press the key you want to bind to the command ",
        allkeysunbound = "All keys unbound.",
        presstounbound = "Press the key you would like to unbind.",
        does = " does ",
        boundtokey = " bound to key ",
        bindsloaded = "Key binding loaded"
    }
end

function Bind:LocalPlayerChat(args)
    if string.sub(args.text, 1, 6) == "/bind " then
        self.toBind = string.sub(args.text, 7)

        if string.sub(self.toBind, 1, 1) == "/" then
            Chat:Print(self.locStrings["tag"], self.tag_clr, self.locStrings["presskeytobind"] .. self.toBind, self.color)
        end
    elseif string.sub(args.text, 1, 5) == "/bind" then
        Chat:Print(self.locStrings["tag"], self.tag_clr, self.locStrings["usageexample"], self.color, " /bind /jesus", Color.White)
        Chat:Print(self.locStrings["tag"], self.tag_clr, self.locStrings["prompted"], self.color)
        Chat:Print(self.locStrings["tag"], self.tag_clr, self.locStrings["othercommands"], self.color, " /unbind, /unbindall, /list", Color.White)
    elseif args.text == "/unbindall" then
        self.binds = {}

        Chat:Print(self.locStrings["tag"], self.tag_clr, self.locStrings["allkeysunbound"], self.color)
        Network:Send("SQLSave", self.binds)
    elseif string.sub(args.text, 1, 7) == "/unbindall" then
        Chat:Print(self.locStrings["tag"], self.tag_clr, "Введите /unbindall, чтобы отвязать все клавиши.", self.color)
    elseif args.text == "/unbind" then
        self.unbind = true

        Chat:Print(self.locStrings["tag"], self.tag_clr, self.locStrings["presstounbound"], self.color)
    elseif string.sub(args.text, 1, 7) == "/unbind" then
        Chat:Print(self.locStrings["tag"], self.tag_clr, "Введите /unbind, чтобы отвязать клавишу", self.color)
    elseif args.text == "/list" then
        for k, v in pairs(self.binds) do
            Chat:Print(self.locStrings["tag"], self.tag_clr, k .. " (" .. string.char(k) .. ")" .. self.locStrings["does"] .. v, self.color)
        end
    end
end

function Bind:KeyDown(args)
    local time = Client:GetElapsedSeconds()

    if self.unbind then
        if self.binds[args.key] then
            Chat:Print(self.locStrings["tag"], self.tag_clr, self.locStrings["command"] .. self.binds[args.key] .. " отвязана от " .. args.key .. " (" .. string.char(args.key) .. ")", self.color)
            self.binds[args.key] = nil
            self.unbind = false
            Network:Send("SQLSave", self.binds)
        else
            Chat:Print(self.locStrings["tag"], self.tag_clr, "Никакая команда не была связана с кнопкой " .. args.key .. " (" .. string.char(args.key) .. ")", self.color)
            self.unbind = false
        end
    elseif self.toBind then
        if string.sub(self.toBind, 1, 1) == "/" then
            local message = ""

            if string.sub(self.toBind, 1, 1) == "/" then
                message = message .. self.locStrings["command"]
            end

            message = message .. self.toBind .. self.locStrings["boundtokey"] .. args.key .. " (" .. string.char(args.key) .. ")"

            if self.binds[args.key] then
                message = message .. ", изменено на " .. self.binds[args.key]
            end

            self.binds[args.key] = self.toBind
            Chat:Print(self.locStrings["tag"], self.tag_clr, message, self.color)
            self.toBind = nil
            Network:Send("SQLSave", self.binds)
        end
    elseif self.binds[args.key] then
        if time < self.cooltime then return end

        Events:Fire("LocalPlayerChat", {text = self.binds[args.key]})
        Network:Send("SimulateCommand", self.binds[args.key])

        self.cooltime = time + self.cooldown
    end
end

function Bind:SQLLoad(args)
    self.binds = args

    if next(self.binds) == nil then
    else
        print(self.locStrings["bindsloaded"])
    end
end

local bind = Bind()
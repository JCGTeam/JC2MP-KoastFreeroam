class 'Messages'

function Messages:__init()
    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            updatefiles = "Обновление файлов! ",
            loadfiles = "Идёт загрузка файлов...",
            err = "Произошла ошибка! ",
            errTw = "Критическая ошибка! ",
            higping = "Высокий пинг! ",
            mblags = "Возможны задержки"
        }
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("ModulesLoad", self, self.ModulesLoad)
    Events:Subscribe("ModuleError", self, self.ModuleError)
    Network:Subscribe("text", self, self.Text)
    Network:Subscribe("textTw", self, self.TextTw)
end

function Messages:Lang()
    self.locStrings = {
        updatefiles = "Updating files! ",
        loadfiles = "Downloading files...",
        err = "Module error! ",
        errTw = "Critical error! ",
        higping = "High ping! ",
        mblags = "Possible delays"
    }
end

function Messages:ModulesLoad()
    Events:Fire("SendNotification", {txt = self.locStrings["updatefiles"], image = "Upgrade", subtxt = self.locStrings["loadfiles"]})
    Events:Fire("LoadUI")
end

function Messages:ModuleError(e)
    Events:Fire("SendNotification", {txt = self.locStrings["err"], image = "Warning", subtxt = "Module: " .. e.module})
    Network:Send("ClientError", {moduletxt = e.module, errortxt = e.error})
end

function Messages:Text()
    Events:Fire("SendNotification", {txt = self.locStrings["higping"], image = "Warning", subtxt = self.locStrings["mblags"]})
end

function Messages:TextTw(args)
    Events:Fire("SendNotification", {txt = self.locStrings["errTw"], image = "Warning", subtxt = "Module: " .. args.error})
end

local messages = Messages()
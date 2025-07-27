class 'AFKSystem'

function AFKSystem:__init()
    self.timer = Timer()
    self.secondsToEnterAFK = 180

    self.tag = "[AFK] "

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            welcomeback = "С возвращением,",
            pausetime = "Время вашей паузы:"
        }
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
    Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
end

function AFKSystem:Lang()
    self.locStrings = {
        welcomeback = "Welcome back,",
        pausetime = "Your pause time:"
    }
end

function AFKSystem:LocalPlayerInput()
    local seconds = self.timer:GetSeconds()

    if seconds >= self.secondsToEnterAFK then
        local locStrings = self.locStrings
        local text = locStrings["welcomeback"] .. " " .. tostring(LocalPlayer:GetName()) .. "! " .. locStrings["pausetime"] .. " " .. self:SecondsToClock(seconds)

        Chat:Print(self.tag, Color.White, text, Color.DarkGray)
    end

    self.timer:Restart()
end

function AFKSystem:ModuleUnload()
    if not IsValid(LocalPlayer) then return end

    self:LocalPlayerInput()
end

function AFKSystem:SecondsToClock(seconds)
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)

    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

local afksystem = AFKSystem()
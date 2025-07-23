class 'Tasks'

local NormVector2 = function(arg1, arg2)
    local x, y

    if arg2 then
        x = arg1
        y = arg2
    else
        x = arg1.x
        y = arg1.y
    end

    return Vector2((x * 0.5 + 0.5) * Render.Width, (y * 0.5 + 0.5) * Render.Height)
end

function Tasks:__init()
    self.taskminimapblimp = Image.Create(AssetLocation.Base64, "iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAAEt0lEQVRogd2aTUxcVRiGnxGpiYFRBldg+Nlop9CtUNMpJC5ItYJIwgbURBKV6EZdNCMslEyDK3eGYNQ0AW2jJCRMHAKJAYohsu4A6kKY1pIGFoQZNi2Bz8VlyL3nnjszd34KzJvcxXn5OOd77plz5vyMR0QoBj110gnkS0UD8rS54PF4cq3vPHAZCAANQB3wHCDALrABrACLwB/A37k0ZhkWInL8ZKkAcBN4iJGwm2cT+AG4lE3DltxzALkCLGWRvNNzB3j1SYJUAr/kEUB9bgMVhQa5BjwoIETyuQ+87gbEYwZIM9g/Bb5JFeDz+ejo6KC1tZWGhgbq6urwer2ICPF4nI2NDVZWVpibm2NycpJ4PJ4u10+Ab1OBaKlS6HNSvMFAICCRSEQODg4kUz1+/FjC4bA0Nzen652PU4G4+Wg5QtTU1Mj09HTGyTspHA5LdXV1KpiPcgW55lR5T0+PJBKJnCGS2t3dle7u7lQwtjGTKcgLGPO8rdKhoaFUOW2IyE8i8oWIvCsib4lIp4i8JyKDIvLzUYxNh4eHMjg46ARyD3g+G5BfdRWGQiEngLsicl1E3szwCYrIiq6iYDDoBHPLCcRp1moB5lWy3t5exsbGVPsR8D0we9SYG3mAq8D7wDlzgt3d3UxMTOj+5xLwZzLuuCIHkCWUZUNtbS3RaJSysjKznQC+Av5xCaDqPPAl8GzSiMfj+P1+Njc31dg7GC/aAqJb/QbQrH1GR0dViEfkBwLgL2AI2E8aXq+XkZERXewV4BXV1IH0qUYgEKCtrU21R8kPRFKrGAvIY7W3t9PU1KSL/UA1dCC2aS4YDKrWXeD3jFPMXNMYvZOqbYA3VEMdIxcw9gvH8vl8bG1tUVJSYravA2vZ55tSF4EbycL+/j6VlZUkEgk17mUROf5EqD1yWY3u7OxUIf6lcBBg9Pb9ZKG0tJSuri5dnCVXFSSgRre2tqrWUlbpuZOljZaWFl2MJVcVpFGNbmy0WatZJOZWUXPB7/frYiymClKrRtfW2qz/skjMrR6YC/X19boYi6mCeNVor9dmpd1E5EGWka18fyVVbi4UzXGQCmJ725pdnK2LCiDL297b29PFWHpNBYmp0bGYzXoxi8TcqtpcWF9f18VYTBUkimpEbdaFLBJzK8tUubam/dqymCrIoho9Pz+vWq7OnrKUpY2FhQVdjCXXtEuUiooKtre3z9wSZRXYNhs7OzvMzs6qlfRibIryLQ/wjtmIRCI6iIcoK2/d9PubagwPD6vWReA1t1lmoKsYm6xUbYMmRx3Ij6qxuLjIzMyMan8IvJRxiunVgLIXmpqaYnl5WRf7nWoU9VYXwLabicVi9Pf3q3Y5xsBsI7sx48HYyIUwQYgIfX19OggwJhqbnEAWANsRxvj4OKFQSLWfwTjWvIHx8chUjcDXGKeI58x/GBgYcDpBuc3RCYpNKc618nVA1ykib8sJHtBBkRyZJvWZU+U1NTUSiURyhgiHw1JVVVXQQ+y0MJySa4WCX/SUl5cjIiQSiVNx0ZPUk7p6u4fLq7fTeBl6C2V2KhRIUgHO+PW0DugmJ/yDATeDPRPpfsLhxUg6TgF/wuHJoSdOlYr2OOjM6n+X5zy6cwk9ewAAAABJRU5ErkJggmCC25+rwtTUVEpKSkwftrY9UxEqIb9C0w5u376dKVOm6PS/Qu4d9GYcBKpVYUZGBvn5+Tr9mchyDIhQmiwXcBHo7yucPXs2paWlurWpK8jRVFOwh/cCJAI/AlJ9hUII5syZQ2mp7Zv0IFfBG9QL4TRZm1HIsCyLt956S0dGK3Ke0RfIAPmef0Ea6HnRXj6aDzwBuQhpRDBCktAYJLz44otMmjRJp38UaTHYl3AZTV85fvx4Vq3SDqyeBwaZEgvWZOUDL/oKEhMTuXjxom5zqRa5BhS9fc2eAwtYiJzVe9HQ0MCIESO4fv26qv8msMxXEGqTtVQVrFq1SkeGAA7RN8kA+d7thhxepKammtb0fmpKKFAN2Qz4LWk6HA6++eYbhg2z7c5+DnwYPN+9HnOReypeuN1uhg0bxs2bN1XdrfiUbyg15H5VkJubqyOjFbmfEYcsB78O3uVykZubq9N9QCc01ZAJyB08P3z55ZeMGTNGFVcA/ww1x30Ac1AMt6urq7n99tt1upOR29VBa8jzquC+++7TkSGQ+xpx/B8nUPqS0aNH88AD2gqxRBWYCLlXFSxevFindwGoC5rFvoUryK0GPzz99NM6XVs565qsJKRVup/88uXLutHV34CqMDPcFzAWpY+4cuUKaWlpOqsVF9AYqMmydeb33HOPjoxmNGs5cQCyXDy+gpSUFDIzM3W6fuWtI+QRVfDggw/qEupsu6mejBY0H+tDDz2k0/UT6gixtWv332+rNGDY0ozDC1s/YihHv/JW+5CBKCY5TqeTa9eukZiYqCb0jqobhx8GAD/xFXg8HgYMGKA7NJQihHCDvYbcoWpOnz5dR0YjcTKC4RrKEeyEhATuvvtuna7X2FklxGYhkZ6uPZza11Z0I4XN2G7atGk6PW9FUAmZrGpOnmwTgVxyjiM4vlUFhm0Lr1AlxGbiMnHiRFUE3WMQ3RNhOyiqWe0A6ZkCsBMyWtUcPdomghh1TxGDsJXTyJEjdXpeoUrIYFVz8GCbCPrOFm1HcUMVDB8+XKfnFaqEDFE1Bw3S7jZ6dMI4bLARMnDgQJ2e125YJcR2xEsz5IV4DQkVtgmHy+XS6XmFKiH9UQX9bSKIExIqbLbMhiN93o0o9aptN16zQQ+Kn604jLDbSbVq7c29yyXqDba+oalJWxm0VtVx2GD7cN1u7QDVK1QJsU1k6uq0+09JYWasr8JWTlevak93e5ehVEJsM/DLl7WT8jghocFWTjU12vNKXqFKiG0Nv7pauwelHSrEYYOtnC5cuKDT8wpVQmwm9pWVNuMTkOe64wgO2zmNs2fP6vS8QpWQU6rmqVM2EWhm9HFoYZtoV1RU6PS8QpWQM6rm6dOndQkMDTNjfRU2q8Ljx4/r9LymVOqOYTLKgpjT6eTGjRv062cbwcV3DAPDtmPY0tJCUlJSWDuGjchzgX6JnDhxQvdA7bJlHF6MUgWffvqpjozjBJiHgLTi9sOHH36oe+Bt4eSuD8JGiKEc/cpbR8hBVXDgwAFdQrcRX0IxwYlmb+n997XOLw75/qGzXByCsmcewHLx78AXEWS4t8NmudjQ0MCgQYN0lovfAWoCWS5+izz264UQgn379ukerN3fjQPbxnlJSYmOjDIUVyMmY2tbP1JUVKTTu5UA5+X6KFKQ5eKH4uJina6tewjrfEhVVRVjx45VxfHzIf7IRKkh586dMxk3hHw+5HOUZgsweeicQHxtqx3JaCx3DE55ymgjwxfxM4bRRaeeMVyNsoPY2trK9u3bdboTCOCnt49gKJraUVhYqCOjGeVjb0fY59QTEhKoqakxnVPfR8/2iRUpLGARykdZX1/PyJEjo3pO3eaH1uPx8Morr+h0hwJ3Bkmvt+IONC3Epk2bTDYJvzQlFIrzmZ2An1NBy7I4deqUzk61FVlL+pIx9hBk7fCzM6isrCQ9PV039/gN8DNVGI7zmTVI03q/m5955hmdBYUDOUPVGnP1QiQi39ePDCEEzz33nI4MD/CLQAmGQogbjfOtI0eOmIbBKcgIazET8q2TYCHfM1W9sGvXLp1rJpBhlLSReryJhuHi718oTswcDgcnTpwwuRE/hWbG34twP5rzNKdPn2bq1Km61uMIoD2tA5G5+LO1e62trSxatMhkazQZ6UWtN2ImGjLcbjcLFiwwGcMt0wlVhEPICeQw2A9VVVU8+eSTpkzcRe8jZRYGr6RPPfUUX3yhXfzegcaBqA7hOlJegcZZ14EDB1i3bp3pnruQ/j96ep/iAO5Deme1IScnh/379+suHUXjWjfQQ8LFM2jOzr3++uts26YNHwLSGcsj9FwDu1uQ58m1TpRfe+01kxPlWuC5cB4Uqe/3HwB/1F0oKCggJyfHdF+v8/2+a9euQO7Vf4jBR76KjoareB9DJ5Wbm8uGDRtM9yUDC5DNWKyHDreQzdMCDGTk5+cHIuMJQiTD76EdDOhiWxFuR1ZWFgUFBSb34yCr8yEMcTq6GUOR/Z52wVQIwerVq9m6davp/p8Tgo9eNU2IToSdQ2jccQAsXLiQ4uLiYBF2ziA9scXCQdKQIuwsXryYkpISUxoRxaKKdgwqY00JIwbVGaTj/u7wv5WGXBidQE+PQeUTpW05MnqCDQ6Hg23btpGTkxMsShvAf5Hbx+fo3KNzCcjz4ROAEQSJ0lZQUMDKlSt7RpQ2n/sDxjHMyMhgz549zJgxI5Skm/l/DMMLaNxzR4BUpMXlrYRoV1ZeXs6SJUs4diygn8+lwG87krFOIaQtjaCRPrOysti0aVO4kT6vIn3Q+0b6vI6M9tmM9FHlQH75tyAPsPpG+hyOYbSkQ319PevXr2fnzp2B1KIe6bNbY+GuWbMmJmPhrl27ttti4cZEtOjc3NxujxZdVVUlVqxY0TujRStpjieMeOpvv/12l8VTr6urE0VFRWLevHmhkNDuTnxCR8ssUDl2OiE+aW9BdsxBX9yyLDFnzhzx6quvisOHD4umpqaoENDU1CRKS0vFxo0bRWZmprAsK1Qi3MAWw3tFBe3pRb1TDwTLslzI2b0tBEYgOJ1OZs6cybRp00hPT2fs2LGMGDECl8tFcnIyAwcOJDU1FY/Hw9WrV3G73dTW1lJdXU1FRQWVlZWcPHmS8vJy3fmMYNgNrBFCaHf6IpxM2+Atx66qIcpzkpB7BFcJ7Qvt6t/1tvz1D+FdooKoNVlRwGbkHkt3kyDa8hEwAk5nIZYIacdE4NfI4WRXkvAxMs6g1vdeVyFqfUgnIQmYDzyMXLicHsW0jyNHSx8gDxxdC6jdRWjnIVYJUZGM3EO5A/klj0EugSQjZ+PJyBl5M3IT7Ary4NE55LpY++8zYmNV2QYtIXF0P2J9167P4X/q3E9SAmwjlAAAAABJRU5ErkJggg==")

	local size = Render.Size.x / 185
    self.taskminimapblimp:SetSize(Vector2(Render.Size.x / 185, Render.Size.x / 185))

    self.jobDistance = 200

    self.markers = true
    self.flooder = true
    self.locationsVisible = true
    self.locationsAutoHide = true

    self.locations = {}
    self.availableJobKey = 0
    self.jobCheckTimer = Timer()

    self.jobcolor = Color(192, 255, 192)
    self.opcolor = Color(251, 184, 41)

    self.targetArrowValue = 1000
    self.targetArrowFlashNum = 3
    self.targetArrowFlashInterval = 7
    self.numTicks = 0

    local args = {path = "Models/TargetArrow", type = OBJLoader.Type.Single}
    OBJLoader.Request(args, self, self.ModelReceive)

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            rewardtip = "Награда: $",
            vehicletip = "Транспорт: ",
            presstostart = "Нажмите X, чтобы начать задание",
            delivto = "Доставить к ",
            target = "● Цель: ",
            taskstarted = "Задание начато!",
            taskfailed = "Задание провалено!",
            taskcompleted = "Задание выполнено!",
            taskcomplatedcount = "Заданий выполнено: "
        }
    end

    self.window = Rectangle.Create()
    self.window:SetColor(Color(0, 0, 0, 200))
    self.window:SetSize(Vector2(Render:GetTextWidth("A") * 28, 110))
    self.window:SetPositionRel(Vector2(0.5, 0.83) - self.window:GetSizeRel() / 2)
    self.window:SetVisible(false)

    self.descriptionContainer = BaseWindow.Create(self.window)
    self.descriptionContainer:SetDock(GwenPosition.Fill)

    self.windowL2 = Label.Create(self.descriptionContainer, "job money")
    self.windowL3 = Label.Create(self.descriptionContainer, "job vehicle")
    self.windowL1 = Label.Create(self.descriptionContainer, "job description")
    self.windowButton = Rectangle.Create(self.window, "job start")
    self.StartJobLabel = Label.Create(self.windowButton, "job start")

    self.descriptionContainer:SetMargin(Vector2(10, 10), Vector2(10, 10))

    local locStrings = self.locStrings
    local textSize = 15

    self.windowL2:SetText(locStrings["rewardtip"] .. "777")
    self.windowL2:SetTextColor(self.opcolor)
    self.windowL2:SetDock(GwenPosition.Top)
    self.windowL2:SetTextSize(textSize)
    self.windowL2:SetHeight(Render:GetTextHeight(self.windowL2:GetText(), textSize))

    self.windowL3:SetText(locStrings["vehicletip"] .. "Lada Granta")
    self.windowL3:SetDock(GwenPosition.Top)
    self.windowL3:SetMargin(Vector2(0, 10), Vector2())
    self.windowL3:SetHeight(Render:GetTextHeight(self.windowL3:GetText()))

    self.windowL1:SetText("-")
    self.windowL1:SetDock(GwenPosition.Top)
    self.windowL1:SetHeight(Render:GetTextHeight(self.windowL1:GetText()))

    self.StartJobLabel:SetText(locStrings["presstostart"])
    self.StartJobLabel:SetDock(GwenPosition.Fill)
    self.StartJobLabel:SetTextSize(textSize)
    self.StartJobLabel:SetMargin(Vector2(0, 8), Vector2(0, 8))
    self.StartJobLabel:SetAlignment(GwenPosition.CenterH)
    self.StartJobLabel:SizeToContents()

    self.windowButton:SetColor(Color(255, 255, 255, 30))
    self.windowButton:SetDock(GwenPosition.Top)
    self.windowButton:SetHeight(Render:GetTextHeight("A") + textSize)

    Network:Subscribe("Locations", self, self.Locations)
    Network:Subscribe("Jobs", self, self.Jobs)
    Network:Subscribe("JobStart", self, self.JobStart)
    Network:Subscribe("JobFinish", self, self.JobFinish)
    Network:Subscribe("JobsUpdate", self, self.JobsUpdate)
    Network:Subscribe("JobFailed", self, self.JobFailed)

    Events:Subscribe("Lang", self, self.Lang)

    self.PostTickEvent = Events:Subscribe("PostTick", self, self.PostTick)
    self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
    self.KeyUpEvent = Events:Subscribe("KeyUp", self, self.KeyUp)
end

function Tasks:Lang()
    self.locStrings = {
        rewardtip = "Reward: $",
        vehicletip = "Vehicle: ",
        presstostart = "Press X to start task",
        delivto = "Deliver to ",
        target = "● Task: ",
        taskstarted = "Task started!",
        taskfailed = "Task failed!",
        taskcompleted = "Task completed!",
        taskcomplatedcount = "Tasks completed: "
    }

    if self.StartJobLabel then
        self.StartJobLabel:SetText(self.locStrings["presstostart"])
    end
end

function Tasks:ModelReceive(model, name)
    self.targetArrowModel = model
end

function Tasks:Locations(args)
    self.locations = args
end

function Tasks:Jobs(args)
    self.jobsTable = args
end

function Tasks:JobsUpdate(args)
    if self.jobsTable then
        self.jobsTable[args[1]] = args[2]
    end
end

function Tasks:JobStart(args)
    self.job = args
    Waypoint:SetPosition(self.locations[self.job.destination].position)

    if self.locationsAutoHide then
        Events:Fire("CastCenterText", {text = self.locStrings["taskstarted"], time = 6, color = Color(0, 255, 0)})
        self.sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 25,
            sound_id = 47,
            position = Camera:GetPosition(),
            angle = Camera:GetAngle()
        })

        self.sound:SetParameter(0, 1)
        self.locationsVisible = false

        if not self.InJobPostTickEvent then
            self.jobCompleteTimer = Timer()
            self.InJobPostTickEvent = Events:Subscribe("PostTick", self, self.InJobPostTick)
        end
    end

    if self.PostTickEvent then
        Events:Unsubscribe(self.PostTickEvent)
        self.PostTickEvent = nil
        self.jobCheckTimer = nil
    end

    if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
    if self.KeyUpEvent then Events:Unsubscribe(self.KeyUpEvent) self.KeyUpEvent = nil end
    if self.GameRenderOpaqueEvent then Events:Unsubscribe(self.GameRenderOpaqueEvent) self.GameRenderOpaqueEvent = nil end
end

function Tasks:JobFinish()
    if not self.job then return end

    local locStrings = self.locStrings

    Events:Fire("CastCenterText", {text = locStrings["taskcompleted"], time = 6, color = Color(0, 255, 0)})

    self.sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 25,
        sound_id = 45,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })
    self.sound:SetParameter(0, 1)

    Game:ShowPopup(locStrings["taskcomplatedcount"] .. (LocalPlayer:GetValue("CompletedTasks") or 0), true)

    self:JobCancel()
end

function Tasks:JobFailed()
    if not self.job then return end

    Events:Fire("CastCenterText", {text = self.locStrings["taskfailed"], time = 6, color = Color.Red})

    self.sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 25,
        sound_id = 46,
        position = Camera:GetPosition(),
        angle = Camera:GetAngle()
    })
    self.sound:SetParameter(0, 1)

    self:JobCancel()
end

function Tasks:JobCancel()
    self.markers = true
    self.flooder = true

    Waypoint:Remove()

    self.job = nil

    if self.locationsAutoHide then
        self.locationsVisible = true
    end

    if self.InJobPostTickEvent then
        Events:Unsubscribe(self.InJobPostTickEvent)
        self.InJobPostTickEvent = nil
        self.jobCompleteTimer = nil
    end

    if not self.PostTickEvent then
        self.jobCheckTimer = Timer()
        self.PostTickEvent = Events:Subscribe("PostTick", self, self.PostTick)
    end

    if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
    if not self.KeyUpEvent then self.KeyUpEvent = Events:Subscribe("KeyUp", self, self.KeyUp) end
    if not self.GameRenderOpaqueEvent then self.GameRenderOpaqueEvent = Events:Subscribe("GameRender", self, self.GameRenderOpaque) end
end

function Tasks:PostTick()
    if self.jobCheckTimer:GetSeconds() < 1 then return end

    self.jobCheckTimer:Restart()

    local jobsTable = self.jobsTable

    if not jobsTable then return end

    local cameraPos = Camera:GetPosition()
    local locations = self.locations

    for k, v in ipairs(locations) do
        local jDist = v.position:Distance2D(cameraPos)
        local jobToRender = jobsTable[k]

        if jDist < 1028 and jobToRender.direction then
            if not self.ResolutionChangeEvent then self.ResolutionChangeEvent = Events:Subscribe("ResolutionChange", self, self.ResolutionChange) end
            if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
            if not self.GameRenderEvent then self.GameRenderEvent = Events:Subscribe("GameRender", self, self.GameRender) end
            if not self.GameRenderOpaqueEvent then self.GameRenderOpaqueEvent = Events:Subscribe("GameRender", self, self.GameRenderOpaque) end

            self.jobsfounded = true
            return false
        end
    end

    if not self.jobsfounded then return end
    if self.ResolutionChangeEvent then Events:Unsubscribe(self.ResolutionChangeEvent) self.ResolutionChangeEvent = nil end
    if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
    if self.GameRenderEvent then Events:Unsubscribe(self.GameRenderEvent) self.GameRenderEvent = nil end
    if self.GameRenderOpaqueEvent then Events:Unsubscribe(self.GameRenderOpaqueEvent) self.GameRenderOpaqueEvent = nil end

    self.jobsfounded = nil
end

function Tasks:InJobPostTick()
    local vehicle = LocalPlayer:GetVehicle()
    local jobCompleteTimer = self.jobCompleteTimer
    local job = self.job

    if jobCompleteTimer and jobCompleteTimer:GetSeconds() > 1 and job and vehicle then
        self.jobCompleteTimer:Restart()

        local destination = job.destination
        local vehiclePos = vehicle:GetPosition()
        local jDist = self.locations[destination].position:Distance(vehiclePos)

        if jDist < 20 then
            Network:Send("CompleteJob", nil)
        end
    end
end

function Tasks:KeyUp(a)
    if Game:GetState() ~= GUIState.Game then return end

    local args = {}
    args.job = self.availableJobKey

    if a.key == string.byte("X") and args.job ~= 0 then
        Network:Send("TakeJob", args)
        self.StartJobLabel:SetTextColor(Color(255, 0, 0))
    else
        self.StartJobLabel:SetTextColor(Color(255, 255, 255))
        self.flooder = true
    end
end

function Tasks:LocalPlayerInput(a)
    if Game:GetState() ~= GUIState.Game then return end

    local args = {}
    args.job = self.availableJobKey

    if Game:GetSetting(GameSetting.GamepadInUse) == 1 then
        if self.flooder then
            if a.input == Action.EquipBlackMarketBeacon and args.job ~= 0 then
                Network:Send("TakeJob", args)
                self.StartJobLabel:SetTextColor(Color(255, 0, 0))
                self.flooder = false
            else
                self.StartJobLabel:SetTextColor(Color(255, 255, 255))
            end
        end
    end
end

function Tasks:DrawShadowedText(pos, text, colour, size, scale)
    if not scale then scale = 1.0 end
    if not size then size = TextSize.Default end

    local shadow_colour = Color(0, 0, 0, colour.a)
    shadow_colour = shadow_colour * 0.4

    Render:DrawText(pos + Vector3(1, 1, 2), text, shadow_colour, size, scale)
    Render:DrawText(pos, text, colour, size, scale)
end

function Tasks:DrawLocation(k, v, dist, dir, jobDistance)
    local locationsVisible = self.locationsVisible
    local job = self.job

    if locationsVisible and not job then
        local pi = math.pi
        local upAngle = Angle(0, pi / 2, 0)
        local jobDistance = self.jobDistance
        local normalizedDist = dist / jobDistance
        local pos = v.position
        local t = Transform3():Translate(pos):Rotate(upAngle)

        local circlePos = Vector3.Zero
        local circleSize = 3

        local textAlpha = 255 - math.clamp(normalizedDist * 255 * 2.25, 0, 255)
        local circleColor = Color(255, 255, 255, textAlpha)

        Render:SetTransform(t)
        Render:DrawCircle(circlePos, circleSize, circleColor)
    end
end

function Tasks:DrawLocation2(k, v, dist, dir, jobDistance)
    local pos = v.position + Vector3(0, 3, 0)
    local cameraAngle = Camera:GetAngle()
    local cameraAngleYaw = cameraAngle.yaw
    local pi = math.pi
    local angle = Angle(cameraAngleYaw, 0, pi) * Angle(pi, 0, 0)

    local textSize = 50
    local textScale = 0.0095
    local normalizedDist = dist / self.jobDistance
    local textAlpha = 255 - math.clamp(normalizedDist * 255 * 2.25, 0, 255)

    local text = v.name
    local textBoxScale = Render:GetTextSize(text, textSize)

    local textBoxScaleDivided = Vector3(textBoxScale.x, textBoxScale.y, 0) / 2
    local t = Transform3():Translate(pos):Scale(textScale):Rotate(angle):Translate(-textBoxScaleDivided)
    Render:SetTransform(t)

    local job = self.job
    local locationsVisible = self.locationsVisible

    if not job and locationsVisible then
        local textPos = Vector3.Zero
        local textColor = Color(255, 255, 255, textAlpha)

        self:DrawShadowedText(textPos, text, textColor, textSize)
    end

    Render:ResetTransform()

    local window = self.window
    local windowGetVisible = window:GetVisible()
    local lpPos = LocalPlayer:GetPosition()
    local lpVehicle = LocalPlayer:GetVehicle()

    if v.position:Distance(lpPos) <= 3.5 and not (job or lpVehicle) then
        local theJob = self.jobsTable[k]

        if not LocalPlayer:GetValue("HiddenHUD") then
            if not windowGetVisible then
                local systemFonts = LocalPlayer:GetValue("SystemFonts")

                if systemFonts then
                    self.windowL2:SetFont(AssetLocation.SystemFont, "Impact")
                    self.StartJobLabel:SetFont(AssetLocation.SystemFont, "Impact")
                end

                local locStrings = self.locStrings
                local delivto_txt = locStrings["delivto"]
                local rewardtip_txt = locStrings["rewardtip"]
                local vehicletip_txt = locStrings["vehicletip"]

                local jobDescription = theJob.description
                local jobReward = tostring(theJob.reward)
                local jobVehicle = Vehicle.GetNameByModelId(theJob.vehicle)

                local jobColor = self.jobcolor
                local opColor = self.opcolor

                self.windowL1:SetText(delivto_txt .. jobDescription)
                self.windowL1:SetTextColor(jobColor)
                self.windowL2:SetText(rewardtip_txt .. jobReward)
                self.windowL2:SetTextColor(opColor)
                self.windowL3:SetText(vehicletip_txt .. jobVehicle)

                self.window:SetVisible(true)
            end
        else
            if windowGetVisible then
                self.window:SetVisible(false)
            end
        end

        self.availableJobKey = k
        self.availableJob = theJob
    else
        local availableJobKey = self.availableJobKey

        if availableJobKey == k and windowGetVisible then
            self.window:SetVisible(false)
        end
    end
end

function Tasks:DrawTargetArrow(args)
    local cameraPos = Camera:GetPosition()
    local position = cameraPos + Render:ScreenToWorldDirection(NormVector2(0, -0.65)) * 8.5
    local lpPos = LocalPlayer:GetPosition()

    local angle = Angle.FromVectors(Vector3(0, 0, -1), args.checkpointPosition - lpPos)
    angle.roll = 0

    local maxValue = self.targetArrowFlashNum * self.targetArrowFlashInterval * 2
    local shouldDraw = (args.targetArrowValue == nil or args.numTicks == nil or args.targetArrowValue == maxValue or math.floor(args.numTicks / self.targetArrowFlashInterval) % 2 == 0)

    if shouldDraw and args.model then
        local transform = Transform3()
        transform:Translate(position)
        transform:Rotate(angle)
        Render:SetTransform(transform)
        args.model:Draw()
        Render:ResetTransform()
    end
end

function Tasks:ResolutionChange(args)
    local size = args.size.x / 185
    self.taskminimapblimp:SetSize(Vector2(size, size))
end

function Tasks:Render()
    if self.sound then
        local cameraPos = Camera:GetPosition()
        local musicVolume = Game:GetSetting(GameSetting.MusicVolume) / 100

        self.sound:SetPosition(cameraPos)
        self.sound:SetParameter(0, musicVolume)
    end

    if LocalPlayer:GetWorld() ~= DefaultWorld or not LocalPlayer:GetValue("JobsVisible") then return end

    local gameAlpha = Game:GetSetting(4)

    if Game:GetState() ~= GUIState.Game or gameAlpha <= 1 or LocalPlayer:GetValue("HiddenHUD") then return end

    local jobsTable = self.jobsTable
    local locations = self.locations

    if jobsTable then
        local markersIsVisible = LocalPlayer:GetValue("JobsMarkersVisible") and self.markers

        if markersIsVisible then
            local cameraPos = Camera:GetPosition()
            local locationsCount = #locations

            self.taskminimapblimp:SetAlpha(gameAlpha / 100)

            local taskminimapblimp = self.taskminimapblimp
            local taskminimapblimpSize = taskminimapblimp:GetSize() / 2

            for i = 1, locationsCount do
                local jPos = locations[i].position
                local jDist = jPos:Distance2D(cameraPos)
                local jobToRender = jobsTable[i]
                local jobToRenderDirection = jobToRender.direction

                if jDist < 1028 and jobToRenderDirection then
                    local mapPos = Render:WorldToMinimap(jPos)

                    self.taskminimapblimp:SetPosition(mapPos - taskminimapblimpSize)
                    self.taskminimapblimp:Draw()
                end
            end
        end
    end

    local job = self.job

    if job then
        self.markers = false

        if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

        local locStrings = self.locStrings
        local target_txt = locStrings["target"]
        local delivto_txt = locStrings["delivto"]

        local textShadow = Color(0, 0, 0, 150)
        local textSize = 15
        local jobDescription = job.description
        local textPos = Vector2(Render.Size.x / 2 - Render:GetTextWidth(target_txt .. delivto_txt .. jobDescription, textSize) / 2, Render.Height * 0.07)

        local jobColor = self.jobcolor
        local defaultColor = Color.White

        Render:DrawShadowedText(textPos, target_txt, jobColor, textShadow, textSize)

        textPos.x = textPos.x + Render:GetTextWidth(target_txt, textSize)
        Render:DrawShadowedText(textPos, delivto_txt .. jobDescription, defaultColor, textShadow, textSize)

        local destPos = locations[job.destination].position
        local lpPos = LocalPlayer:GetPosition()
        local destDist = Vector3.Distance(destPos, lpPos)

        if destDist < 500 then
            local pi = math.pi
            local upAngle = Angle(0, pi / 2, 0)
            local t2 = Transform3():Translate(destPos):Rotate(upAngle)
            local circleColor = Color(64, 255, 64, 64)

            Render:SetTransform(t2)
            Render:DrawCircle(Vector3.Zero, 10, circleColor)
        end

        if LocalPlayer:GetVehicle() then
            self.numTicks = self.numTicks + 1

            local maxValue = self.targetArrowFlashNum * self.targetArrowFlashInterval * 2

            self.targetArrowValue = self.targetArrowValue + 1

            if self.targetArrowValue > maxValue then
                self.targetArrowValue = maxValue
            end

            self:DrawTargetArrow{
                targetArrowValue = self.targetArrowValue,
                numTicks = self.numTicks,
                checkpointPosition = destPos,
                model = self.targetArrowModel
            }
        end
    end
end

function Tasks:GameRender()
    if not LocalPlayer:GetValue("JobsVisible") or Game:GetState() ~= GUIState.Game or LocalPlayer:GetWorld() ~= DefaultWorld then return end

    local jobsTable = self.jobsTable

    if jobsTable then
        if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

        local cameraPos = Camera:GetPosition()
        local jobDistance = self.jobDistance
        local locations = self.locations

        for k, v in ipairs(locations) do
            local vPos = v.position
            local jDist = vPos:Distance(cameraPos)
            local jobToRender = jobsTable[k]
            local direction = jobToRender.direction

            if jDist < jobDistance and direction then
                local jobToRenderDistance = jobToRender.distance

                self:DrawLocation2(k, v, jDist, direction, jobToRenderDistance)
            end
        end
    end
end

function Tasks:GameRenderOpaque()
    if not LocalPlayer:GetValue("JobsVisible") or Game:GetState() ~= GUIState.Game or LocalPlayer:GetWorld() ~= DefaultWorld then return end

    local jobsTable = self.jobsTable

    if jobsTable then
        local cameraPos = Camera:GetPosition()
        local jobDistance = self.jobDistance
        local locations = self.locations

        for k, v in ipairs(locations) do
            local vPos = v.position
            local jDist = vPos:Distance(cameraPos)
            local jobToRender = jobsTable[k]
            local direction = jobToRender.direction

            if jDist < jobDistance and direction then
                local jobToRenderDistance = jobToRender.distance

                self:DrawLocation(k, v, jDist, direction, jobToRenderDistance)
            end
        end
    end
end

local tasks = Tasks()
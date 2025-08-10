class 'Notifications'

function Notifications:__init()
    Events:Subscribe("SendNotification", self, self.GetNotification)
    Events:Subscribe("PostRender", self, self.PostRender)

    self.upgrade = Image.Create(AssetLocation.Resource, "Upgrade")
    self.information = Image.Create(AssetLocation.Resource, "Information")
    self.warning = Image.Create(AssetLocation.Resource, "Warning")

    self.notificationQueue = {}

    self.processTimer = Timer()
end

function Notifications:GetNotification(args)
    self.mainTxt = args.txt
    self.imageType = args.image
    self.subTxt = args.subtxt

    local QueueArgs = {maintxt = args.txt, imagetype = args.image, subtxt = args.subtxt}

    table.insert(self.notificationQueue, QueueArgs)
end

function Notifications:ProcessQueue()
    if table.count(self.notificationQueue) > 0 then
        for k, args in ipairs(self.notificationQueue) do
            self.mainTxt = args.maintxt
            self.imageType = args.imagetype
            self.subTxt = args.subtxt
            self.fadeInTimer = Timer()
            table.remove(self.notificationQueue, k)
        end
    end
end

function Notifications:PostRender()
    if self.fadeInTimer ~= nil or self.delayTimer ~= nil or self.fadeOutTimer ~= nil then
        if self.mainTxt == nil then self.fadeInTimer = nil return end

        local mainTxtSize = 15
        local subTxtSize = 12

        if Render:GetTextWidth(self.mainTxt, mainTxtSize) > 200 then self.fadeInTimer = nil return end

        if self.subTxt ~= nil then
            if Render:GetTextWidth(self.subTxt, subTxtSize) > 230 then self.fadeInTimer = nil return end
        end

        if self.fadeInTimer ~= nil then
            local fadeInTimerSeconds = self.fadeInTimer:GetSeconds()

            self.txtAlpha = math.clamp(0 + (fadeInTimerSeconds * 400), 0, 200)
            self.renderAlpha1 = math.clamp(0 + (fadeInTimerSeconds * 360), 0, 180)
            self.renderAlpha2 = math.clamp(0 + (fadeInTimerSeconds * 340), 0, 170)
            self.imageAlpha = math.clamp(0 + (fadeInTimerSeconds * 2), 0, 1)

            if self.txtAlpha >= 200 or self.renderAlpha1 >= 180 or self.renderAlpha2 >= 170 or self.imageAlpha >= 1 then
                self.txtAlpha = 200
                self.renderAlpha1 = 180
                self.renderAlpha2 = 170
                self.imageAlpha = 1
                self.delayTimer = Timer()
                self.fadeInTimer = nil
            end
        end

        if self.delayTimer ~= nil then
            if self.delayTimer:GetSeconds() >= 1 then
                self.delayTimer = nil
                self.fadeOutTimer = Timer()
            end
        end

        if self.fadeOutTimer ~= nil then
            local fadeOutTimerSeconds = self.fadeOutTimer:GetSeconds()

            self.txtAlpha = math.clamp(200 - (fadeOutTimerSeconds * 66.66666666666667), 0, 200)
            self.renderAlpha1 = math.clamp(180 - (fadeOutTimerSeconds * 60), 0, 180)
            self.renderAlpha2 = math.clamp(170 - (fadeOutTimerSeconds * 56.66666666666667), 0, 170)
            self.imageAlpha = math.clamp(1 - (fadeOutTimerSeconds / 3), 0, 1)

            if self.txtAlpha <= 0 or self.renderAlpha1 <= 0 or self.renderAlpha2 <= 0 or self.imageAlpha <= 0 then
                self.fadeOutTimer = nil
                self:ProcessQueue()
            end
        end

        local backgroundColor = Color(0, 0, 0, self.renderAlpha1)
        local outlinesColor = Color(70, 200, 255, self.renderAlpha2)

        local renderWidth = Render.Width
        local pos = Vector2(renderWidth - 255, 50)
        local size = Vector2(1, 40)
        local size2 = Vector2(250, 1)

        Render:FillArea(pos, Vector2(250, 40), backgroundColor)
        Render:FillArea(pos, size, outlinesColor)
        Render:FillArea(Vector2(renderWidth - 210, 50), size, outlinesColor)
        Render:FillArea(Vector2(renderWidth - 5, 50), size, outlinesColor)
        Render:FillArea(pos, size2, outlinesColor)
        Render:FillArea(Vector2(renderWidth - 255, 90), size2, outlinesColor)

        pos = Vector2(renderWidth - 249, 52.5)
        size = Vector2(35, 35)

        local one = Vector2.One
        local zero = Vector2.Zero

        local imageType = self.imageType
        local imageAlpha = self.imageAlpha

        if imageType == "Upgrade" or imageType == "3" then
            self.upgrade:SetAlpha(imageAlpha)
            self.upgrade:Draw(pos, size, zero, one)
        elseif imageType == "Information" or imageType == "1" then
            self.information:SetAlpha(imageAlpha)
            self.information:Draw(pos, size, zero, one)
        elseif imageType == "Warning" or imageType == "2" then
            self.warning:SetAlpha(imageAlpha)
            self.warning:Draw(pos, size, zero, one)
        else
            self.information:SetAlpha(imageAlpha)
            self.information:Draw(pos, size, zero, one)
        end

        local posX = renderWidth - 107.5
        local txtAlpha = self.txtAlpha

        if self.subTxt ~= nil then
            Render:DrawText(Vector2(posX - (Render:GetTextWidth(self.mainTxt, mainTxtSize) / 2), 56), self.mainTxt, Color(210, 210, 210, txtAlpha), mainTxtSize)
            Render:DrawText(Vector2(posX - (Render:GetTextWidth(self.subTxt, subTxtSize) / 2), 73), self.subTxt, Color(140, 140, 140, txtAlpha), subTxtSize)
        else
            Render:DrawText(Vector2(posX - (Render:GetTextWidth(self.mainTxt, mainTxtSize) / 2), 64), self.mainTxt, Color(210, 210, 210, txtAlpha), mainTxtSize)
        end
    else
        local processTimer = self.processTimer

		if processTimer and processTimer:GetSeconds() >= 1 then
			self:ProcessQueue()
			self.processTimer:Restart()
		end
    end
end

local notifications = Notifications()
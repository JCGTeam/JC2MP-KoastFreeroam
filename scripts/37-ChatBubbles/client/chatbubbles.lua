class "ChatBubbles"

function ChatBubbles:__init()
    self.canSeeOwn = false
    self.timeout = 5
    self.distance = 30

    self.bubbles = {}

    Events:Subscribe("PlayerQuit", self, self.onPlayerQuit)
    Events:Subscribe("Render", self, self.onBubblesRender)

    Network:Subscribe("chatBubbles.receiveMessage", self, self.addMessage)
end

function ChatBubbles:addMessage(args)
    if args.text:sub(1, 1) == '/' then return end
    if args.player:GetValue("ChatMode") ~= 1 then return end
    if args.player == LocalPlayer and not self.canSeeOwn then return end

    self:addBubble(args.player, args.text)
end

function ChatBubbles:onPlayerQuit(args)
    self.bubbles[args.player:GetId()] = nil
end

function ChatBubbles:onBubblesRender()
    if Game:GetState() ~= GUIState.Game then return end

    local cameraPos = Camera:GetPosition()
    local cameraAngle = Camera:GetAngle()
    local cameraAngleYaw = cameraAngle.yaw
    local pi = math.pi
    local bubbles = self.bubbles
    local distance = self.distance
    local timeout = self.timeout
    local height = 0.5
    local fontSize = TextSize.Default
    local textColor = Color(255, 255, 255)
    local backgroundColor = Color(0, 0, 0, 150)

    for pId, pBubbles in pairs(bubbles) do
        local player = Player.GetById(pId)

        if IsValid(player) then
            if type(pBubbles) == "table" then
                local position = player:GetPosition()
                local headPos = player:GetBonePosition("ragdoll_head")
                local pDistance = position:Distance2D(cameraPos)

                if pDistance <= distance then
                    for index = #pBubbles, 1, -1 do
                        local data = pBubbles[index]

                        if type(data) == "table" then
                            if data.timer:GetSeconds() >= timeout then
                                self.bubbles[pId][index] = nil
                            else
                                headPos = headPos + Vector3(0, height, 0)

                                local text_size = Render:GetTextSize(data.msg, fontSize)
                                local width = Render:GetTextWidth(data.msg, fontSize)
                                local width2 = width / 2
                                local position = Render:WorldToScreen(headPos)

                                Render:FillArea(position - Vector2(width2, 0), Vector2(text_size.x + 1, text_size.y), backgroundColor)
                                Render:DrawText(position - Vector2(width2, 0), data.msg, textColor, fontSize)
                            end
                        end
                    end
                end
            end
        end
    end
end

function ChatBubbles:addBubble(player, msg)
    if player and msg then
        local id = player:GetId()
        if not self.bubbles[id] then
            self.bubbles[id] = {}
        else
            if #self.bubbles[id] >= 1 then
                self.bubbles[id][1] = nil
            end
        end

        table.insert(self.bubbles[id], {player = player, msg = msg, timer = Timer()})

        return true
    else
        return false
    end
end

local chatbubbles = ChatBubbles()
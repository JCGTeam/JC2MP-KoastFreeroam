class 'CBoardHud'

function CBoardHud:__init(CBoardClient, width, height, columns)
    local tagTable = {
        ["Creator"] = {status = "[Пошлый Создатель] ", color = Color(63, 153, 255)},
        ["GlAdmin"] = {status = "[Гл. Админ] ", color = Color(255, 48, 48)},
        ["Admin"] = {status = "[Админ] ", color = Color(255, 48, 48)},
        ["AdminD"] = {status = "[Админ $] ", color = Color(255, 48, 48)},
        ["ModerD"] = {status = "[Модератор $] ", color = Color(255, 148, 48)},
        ["Vip"] = {status = "[VIP] ", color = Color(255, 100, 232)},
        ["YouTuber"] = {status = "[YouTube Деятель] ", color = Color(255, 0, 50)}
    }

    local tag = LocalPlayer:GetValue("Tag")
    if tag and tagTable[tag] then
        self.status = tagTable[tag].status
        self.color = tagTable[tag].color
    end

    -- Create an instance of CBoardClient
    self.CBoardClient = CBoardClient

    -- Settings:
    self.fBoardWidth = math.clamp(Render:GetTextWidth("A") / 11 * width, 0, 0.95)
    self.fBoardHeight = height

    self.Color_BordersColor = Color.White

    self.Color_HeaderColor = Color(0, 0, 0, 120)
    self.Color_HeaderTextColor = Color.White
    self.fHeaderRowHeight = Render:GetTextHeight("A") * 2.5
    self.fTextSize = 20

    self.tPlayerRowColor =
	{
		Color(0, 0, 0, 100), -- even rows
    	Color(0, 0, 0, 80) -- odd rows
    }
    self.Color_LocalPlayerRowColor = Color(255, 255, 255, 70)
    self.fPlayerRowHeight = Render:GetTextHeight("A") * 2.5

    self.tBorderCols = columns or {
		{name = "ID:", width = 0.1, getter = function(CBoardClientInstance, p) return p:GetId() end},
		{name = "Игрок:", width = 0.8, getter = function(CBoardClientInstance, p) return p:GetName() end}
	}
    self:ScalecolumnsWidth()

    self.fScrollLineWidth = 10
    self.Color_ScrollLineColor = {
        default = Color(0, 0, 0, 130),
        hover = Color(0, 0, 0, 180)
    }
    self.fScrollLinePadding = 5

    self.Color_SlotsInfo = Color.White
    self.iSlotsInfoTextSize = 20
    self.tSlotsInfoTextPadding = {
        right = 10,
        top = 10
    }

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.players_txt = "Игроки: "
    end

    self:SharedObjectValueChange()
    self:Update()

    -- self.admin_pic = Image.Create(AssetLocation.Resource, "admin_PIC")

    -- Attach events handlers
    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("SharedObjectValueChange", self, self.SharedObjectValueChange)
    Events:Subscribe("PostRender", self, self.Render)
end

function CBoardHud:Lang()
    self.players_txt = "Players: "
end

function CBoardHud:SharedObjectValueChange(args)
    if args and args.object.__type ~= "LocalPlayer" then return end

    self.SystemFontsEvent = LocalPlayer:GetValue("SystemFonts")
end

function CBoardHud:Update()
    self.CBoardClient:Update()

    self.ScreenSize = Render:GetScreenSize()
    self.BoardPosition = self:getPosition()
    self.BoardSize = self:getSize()
    self.iAvailibleRows = self:getAvailibleRows()

    self:ResetBoardRealHeight()
    self:ResetRowsCounter()
end

function CBoardHud:ScalecolumnsWidth()
    local fWidth = 0

    for i, v in ipairs(self.tBorderCols) do
        fWidth = fWidth + v.width
    end

    for i, v in ipairs(self.tBorderCols) do
        self.tBorderCols[i].width = self.tBorderCols[i].width / fWidth
    end

    return self
end

-- Setters/Getters:
function CBoardHud:getSize()
    return {
        width = math.max(math.floor(self.ScreenSize.width * self.fBoardWidth), 500),
        height = math.floor(self.ScreenSize.height * self.fBoardHeight)
    }
end

function CBoardHud:getPosition()
    local size = self:getSize()

    return {
        x = math.floor((self.ScreenSize.width / 2) - (size.width / 2)),
        y = math.floor((self.ScreenSize.height / 2) - (size.height / 2))
    }
end

function CBoardHud:getAvailibleRows()
    return math.floor(math.min(((self.BoardSize.height - self.fHeaderRowHeight) / self.fPlayerRowHeight), #self.CBoardClient:getPlayers()))
end

function CBoardHud:ResetRowsCounter()
    self._rows = 0
    return self
end

function CBoardHud:IncreaseRowsCounter(num)
    num = num or 1
    self._rows = self._rows + num
    return self
end

function CBoardHud:getRowsCounter()
    return self._rows or 0
end

function CBoardHud:ResetBoardRealHeight()
    self.fBoardRealHeight = 0
    return self
end

function CBoardHud:IncreaseBoardRealHeight(num)
    num = num or 1
    self.fBoardRealHeight = self.fBoardRealHeight + num
    return self
end

function CBoardHud:getBoardRealHeight()
    return self.fBoardRealHeight or 0
end

-- Draw functions:
function CBoardHud:DrawHeader(boardPosition, boardSize, fHeaderRowHeight, fTextSize)
    local boardPositionX = boardPosition.x
    local boardSizeWidth = boardSize.width
    local color_HeaderColor = self.Color_HeaderColor

    Render:FillArea(Vector2(boardPositionX - 1, boardPosition.y), Vector2(boardSizeWidth + 1, fHeaderRowHeight), color_HeaderColor)

    -- Header columns:
    local w = 0
    local headerTextColor = self.Color_HeaderTextColor
    local textSize = Render.Size.x / 90

    for i, v in ipairs(self.tBorderCols) do
        local text = v.name .. ""
        local height = Render:GetTextHeight(text, fTextSize)

        Render:DrawText(Vector2(w + boardPositionX + 10, boardPosition.y + (fHeaderRowHeight / 2 - height / 2)), text, headerTextColor, textSize)
        w = w + math.floor(boardSizeWidth * v.width)
    end

    self:IncreaseBoardRealHeight(fHeaderRowHeight)
    self:IncreaseRowsCounter()

    return self
end

function CBoardHud:DrawCanvas(boardPosition, boardSize, fHeaderRowHeight)
    -- Under Header line
    local boardPositionX = boardPosition.x
    local color_BordersColor = self.Color_BordersColor

    Render:DrawLine(Vector2(boardPositionX - 1, boardPosition.y + fHeaderRowHeight), Vector2(boardPositionX + boardSize.width, boardPosition.y + fHeaderRowHeight), color_BordersColor)
    return self
end

function CBoardHud:DrawPlayerRow(player, boardPosition, boardSize, fTextSize, systemFonts)
    local row = self:getRowsCounter() - 1
    local y = math.floor(boardPosition.y + self:getBoardRealHeight())
    local color = (player == LocalPlayer) and self.Color_LocalPlayerRowColor or self.tPlayerRowColor[(row % 2) + 1]
    local fPlayerRowHeight = self.fPlayerRowHeight
    local boardPositionX = boardPosition.x
    local boardSizeWidth = boardSize.width

    Render:FillArea(Vector2(boardPositionX - 1, y), Vector2(boardSizeWidth + 1, fPlayerRowHeight), color)

    -- if player:GetValue("Tag") and player:GetValue("Tag") == "Creator" then
    --	Render:FillArea(Vector2(boardPositionX - 3, y + 1), Vector2(3, fPlayerRowHeight - 1), self.color)
    -- end

    if LocalPlayer:IsFriend(player) then
        Render:SetFont(AssetLocation.Disk, "FontAwesome.ttf")
        Render:DrawBorderedText(Vector2(boardPositionX - fPlayerRowHeight + 5, y + 5), "", Color.White, fPlayerRowHeight - 10, 1)

        if systemFonts then
            Render:SetFont(AssetLocation.SystemFont, "Impact")
        else
            Render:ResetFont()
        end
    end

    player:GetAvatar():Draw(Vector2(boardPositionX, y + 1), Vector2(fPlayerRowHeight - 2, fPlayerRowHeight - 2), Vector2.Zero, Vector2.One)

    -- Player columns:
    local w = 0
    local pColor = player:GetColor()

    for i, v in ipairs(self.tBorderCols) do
        local text = tostring(v.getter(self.CBoardClient, player))
        local height = Render:GetTextHeight(text, fTextSize)

        Render:DrawBorderedText(Vector2(w + boardPositionX + 10, y + (height / 2)), text, pColor, fTextSize)
        w = w + math.floor(boardSizeWidth * v.width)
    end

    self:IncreaseBoardRealHeight(fPlayerRowHeight)
    self:IncreaseRowsCounter()
    return self
end

function CBoardHud:DrawPlayersRows(boardPosition, boardSize, fTextSize, systemFonts)
    local CBCPlaers = self.CBoardClient:getPlayers()

    for i = 1, self.iAvailibleRows do
        local player = CBCPlaers[i + self.CBoardClient:getStartShowRow()]

        if self.CBoardClient:isPlayerAllowedForDraw(player) then
            self:DrawPlayerRow(player, boardPosition, boardSize, fTextSize, systemFonts)
        end
    end

    return self
end

function CBoardHud:DrawScrollLine(boardPosition, boardSize, fHeaderRowHeight)
    local CBCPlaers = self.CBoardClient:getPlayers()

    if #CBCPlaers <= self:getAvailibleRows() then return end

    local boardHeight = self:getBoardRealHeight()
    local scrollHeight = math.floor((boardHeight - fHeaderRowHeight) * (self:getAvailibleRows() / #CBCPlaers))
    local scrollPosY = math.floor((boardPosition.y + fHeaderRowHeight) + ((boardHeight - fHeaderRowHeight) * (self.CBoardClient:getStartShowRow() / #CBCPlaers)))
    local color_ScrollLineColorDefault = self.Color_ScrollLineColor.default

    Render:FillArea(Vector2(boardPosition.x + boardSize.width + self.fScrollLinePadding, scrollPosY), Vector2(self.fScrollLineWidth, scrollHeight), color_ScrollLineColorDefault)

    return self
end

function CBoardHud:DrawSlotsInfo(boardPosition, boardSize)
    local text = self.players_txt .. tostring(self.CBoardClient:getPlayersCount()) .. "/" .. tostring(self.CBoardClient:getServerSlots())
    local width = Render:GetTextWidth(text, self.iSlotsInfoTextSize, 1)
    local color_SlotsInfo = self.Color_SlotsInfo

    Render:DrawBorderedText(Vector2(boardPosition.x + boardSize.width - self.tSlotsInfoTextPadding.right - width, boardPosition.y + self:getBoardRealHeight() + self.tSlotsInfoTextPadding.top), text, color_SlotsInfo, self.iSlotsInfoTextSize, 1)
    return self
end

-- Event Handlers:
function CBoardHud:Render()
    local cBoardClient = self.CBoardClient

    if not cBoardClient:isHudVisible() then return end

    local systemFonts = self.SystemFontsEvent

    if systemFonts then Render:SetFont(AssetLocation.SystemFont, "Impact") end

    self:Update()

    local boardPosition = self.BoardPosition
    local boardSize = self.BoardSize
    local fHeaderRowHeight = self.fHeaderRowHeight
    local fTextSize = self.fTextSize

    self:DrawHeader(boardPosition, boardSize, fHeaderRowHeight, fTextSize)
    self:DrawCanvas(boardPosition, boardSize, fHeaderRowHeight)
    self:DrawPlayersRows(boardPosition, boardSize, fTextSize, systemFonts)
    self:DrawScrollLine(boardPosition, boardSize, fHeaderRowHeight)
    self:DrawSlotsInfo(boardPosition, boardSize)
end
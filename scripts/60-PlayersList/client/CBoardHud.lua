class 'CBoardHud'

function CBoardHud:__init( CBoardClient, width, height, columns )
	local tagTable = {
		["Creator"] = { status = "[Пошлый Создатель] ", color = Color( 63, 153, 255 ) },
		["GlAdmin"] = { status = "[Гл. Админ] ", color = Color( 255, 48, 48 ) },
		["Admin"] = { status = "[Админ] ", color = Color( 255, 48, 48 ) },
		["AdminD"] = { status = "[Админ $] ", color = Color( 255, 48, 48 ) },
		["ModerD"] = { status = "[Модератор $] ", color = Color( 255, 148, 48 ) },
		["Vip"] = { status = "[VIP] ", color = Color( 255, 100, 232 ) },
		["YouTuber"] = { status = "[YouTube Деятель] ", color = Color( 255, 0, 50 ) }
	}
	
	local tag = LocalPlayer:GetValue( "Tag" )
	if tag and tagTable[tag] then
		self.status = tagTable[tag].status
		self.color = tagTable[tag].color
	end

	-- Create an instance of CBoardClient
	self.CBoardClient = CBoardClient

	-- Settings:
	self.fBoardWidth = width
	self.fBoardHeight = height

	self.Color_BordersColor = Color.White

	self.Color_HeaderColor = Color( 0, 0, 0, 120 )
	self.Color_HeaderTextColor = Color.White
	self.fHeaderRowHeight = Render:GetTextHeight( "A" ) * 2.5
	self.fTextSize = 20

	self.tPlayerRowColor = {
							    Color( 0, 0, 0, 100 ); -- even rows
							    Color( 0, 0, 0, 80 ) ; -- odd rows
						   };
	self.Color_LocalPlayerRowColor = Color( 255, 255, 255, 70 )
	self.fPlayerRowHeight = Render:GetTextHeight( "A" ) * 2.5

	self.tBorderCols = columns or
	{
		{name = "ID:", width = 0.1, getter = function(CBoardClientInstance, p) return p:GetId(); end },
		{name = "Игрок:", width = 0.8, getter = function(CBoardClientInstance, p) return p:GetName(); end},
	};
	self:ScalecolumnsWidth()

	self.fScrollLineWidth = 10
	self.Color_ScrollLineColor = {
									default = Color( 0, 0, 0, 130) ,
									hover 	= Color( 0, 0, 0, 180 )
								 }
	self.fScrollLinePadding = 5

	self.Color_SlotsInfo = Color.White
	self.iSlotsInfoTextSize = 20
	self.tSlotsInfoTextPadding = {right = 10, top = 10}

	self:Update()

	self.admin_pic = Image.Create( AssetLocation.Resource, "admin_PIC" )
	-- Attach events handlers
	Events:Subscribe( "PostRender", self, self.Render )
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
		   };
end

function CBoardHud:getPosition()
	local size = self:getSize();
	return { 
				x = math.floor((self.ScreenSize.width / 2) - (size.width / 2)),
				y = math.floor((self.ScreenSize.height / 2) - (size.height / 2)) 
		   };
end

function CBoardHud:getAvailibleRows()
	return math.floor(math.min(((self.BoardSize.height - self.fHeaderRowHeight) / self.fPlayerRowHeight), #self.CBoardClient:getPlayers()));
end 

function CBoardHud:ResetRowsCounter()
	self._rows = 0
	return self
end 

function CBoardHud:IncreaseRowsCounter( num )
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

function CBoardHud:IncreaseBoardRealHeight( num )
	num = num or 1
	self.fBoardRealHeight = self.fBoardRealHeight + num
	return self
end

function CBoardHud:getBoardRealHeight()
	return self.fBoardRealHeight or 0
end

-- Draw functions:
function CBoardHud:DrawHeader()
	Render:FillArea( Vector2( self.BoardPosition.x-1, self.BoardPosition.y ), Vector2( self.BoardSize.width + 1, self.fHeaderRowHeight ), self.Color_HeaderColor )

	-- Header columns:
	local w = 0;
	for i, v in ipairs(self.tBorderCols) do
		local text = v.name..""
		local height = Render:GetTextHeight( text, self.fTextSize, 1 )
		Render:DrawText( Vector2( w + self.BoardPosition.x + 10, self.BoardPosition.y + (self.fHeaderRowHeight / 2 - height / 2) ), text, self.Color_HeaderTextColor, Render.Size.x / 90, 1 )
		w = w + math.floor(self.BoardSize.width * v.width)
	end

	self:IncreaseBoardRealHeight( self.fHeaderRowHeight )
	self:IncreaseRowsCounter()

	return self
end

function CBoardHud:DrawCanvas()
	-- Under Header line
	Render:DrawLine( Vector2( self.BoardPosition.x - 1, self.BoardPosition.y + self.fHeaderRowHeight ), Vector2( self.BoardPosition.x + self.BoardSize.width, self.BoardPosition.y + self.fHeaderRowHeight ), self.Color_BordersColor )

	return self
end

function CBoardHud:DrawPlayerRow( player )
	local row = self:getRowsCounter() - 1
	local y =  math.floor(self.BoardPosition.y + self:getBoardRealHeight())
	local color = (player == LocalPlayer) and self.Color_LocalPlayerRowColor or self.tPlayerRowColor[(row % 2) + 1]
	Render:FillArea( Vector2( self.BoardPosition.x - 1, y ), Vector2( self.BoardSize.width + 1, self.fPlayerRowHeight ), color )

	--if player:GetValue( "Tag" ) and player:GetValue( "Tag" ) == "Creator" then
	--	Render:FillArea( Vector2(self.BoardPosition.x - 3, y + 1), Vector2(3, self.fPlayerRowHeight - 1), self.color )
	--end

	if LocalPlayer:IsFriend( player ) then
		Render:SetFont( AssetLocation.Disk, "FontAwesome.ttf" )
		Render:DrawBorderedText( Vector2( self.BoardPosition.x - self.fPlayerRowHeight + 5, y + 5 ), "", Color.White, self.fPlayerRowHeight - 10, 1 )
		if LocalPlayer:GetValue( "SystemFonts" ) then
			Render:SetFont( AssetLocation.SystemFont, "Impact" )
		else
			Render:ResetFont()
		end
	end

	player:GetAvatar():Draw( Vector2( self.BoardPosition.x, y + 1 ), Vector2( self.fPlayerRowHeight-2, self.fPlayerRowHeight-2 ), Vector2.Zero, Vector2.One )

	-- Player columns:
	local w = 0;
	for i, v in ipairs(self.tBorderCols) do
		local text = tostring( v.getter(self.CBoardClient, player) )
		local text2 = ""
		local height = Render:GetTextHeight( text, self.fTextSize, 1 )

		Render:DrawBorderedText( Vector2( w + self.BoardPosition.x + 10, y + (height / 2) ), text, player:GetColor(), self.fTextSize, 1 )
		w = w + math.floor(self.BoardSize.width * v.width)
	end

	self:IncreaseBoardRealHeight( self.fPlayerRowHeight )
	self:IncreaseRowsCounter()
	return self
end

function CBoardHud:DrawPlayersRows()
	for i = 1, self.iAvailibleRows do
		local player = self.CBoardClient:getPlayers()[i + self.CBoardClient:getStartShowRow()]
		if (self.CBoardClient:isPlayerAllowedForDraw(player)) then
			self:DrawPlayerRow(player)
		end
	end
	return self
end

function CBoardHud:DrawScrollLine()
	if (#self.CBoardClient:getPlayers() <= self:getAvailibleRows()) then
		return end

	local boardHeight = self:getBoardRealHeight()
	local scrollHeight = math.floor((boardHeight - self.fHeaderRowHeight) * (self:getAvailibleRows() / #self.CBoardClient:getPlayers()))
	local scrollPosY = math.floor((self.BoardPosition.y + self.fHeaderRowHeight) + ((boardHeight - self.fHeaderRowHeight) * (self.CBoardClient:getStartShowRow() / #self.CBoardClient:getPlayers())))

	Render:FillArea( Vector2( self.BoardPosition.x + self.BoardSize.width + self.fScrollLinePadding, scrollPosY ), Vector2( self.fScrollLineWidth, scrollHeight ), self.Color_ScrollLineColor.default )

	return self
end

function CBoardHud:DrawSlotsInfo()
	local text = "Игроки: " .. tostring( self.CBoardClient:getPlayersCount() ) .. "/" .. tostring( self.CBoardClient:getServerSlots() )
	local width = Render:GetTextWidth( text, self.iSlotsInfoTextSize, 1 )
	Render:DrawBorderedText( Vector2( self.BoardPosition.x + self.BoardSize.width - self.tSlotsInfoTextPadding.right - width, self.BoardPosition.y + self:getBoardRealHeight() + self.tSlotsInfoTextPadding.top ), text, self.Color_SlotsInfo, self.iSlotsInfoTextSize, 1 )
	return self
end

-- Event Handlers:
function CBoardHud:Render()
	if (not self.CBoardClient:isHudVisible()) then return end
	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	self:Update()
	self:DrawHeader()
	self:DrawCanvas()
	self:DrawPlayersRows()
	self:DrawScrollLine()
	self:DrawSlotsInfo()
end
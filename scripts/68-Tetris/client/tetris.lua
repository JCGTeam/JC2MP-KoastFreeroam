class 'Tetris'

function Tetris:__init()
	self.inTetrisMode = false
	self.gridNotCurrent = {}

	self.moveDownTimer = Client:GetElapsedSeconds()
	self.moving = false

	self.current = {}
	self.currentLoc = Vector2.Zero
	self.currentRot = 1
	self.currentPiece = 0

	self.currentLeaderboard = {}
	self.rows = {}

	--levels				1		2		3		4		5		6		7		8		9		10
	self.levelScore = 		{30,	50,		70,		100,	150,	200,	500,	750,	1000,	5000}
	self.dropTimeLevel = 	{1,		0.9,	0.75,	0.5,	0.4,	0.3,	0.2,	0.1,	0.075,	0.05}

	self.firstGo = true
	self.score = 0
	self.level = 1

	self.dropTime = self.dropTimeLevel[self.level]
	self.inGame = false

	self.pieces = {
		{
			{
				{x = 1, y = 1, c = Color(255,0,0)},
				{x = 1, y = 2, c = Color(255,0,0)},
				{x = 2, y = 1, c = Color(255,0,0)},
				{x = 2, y = 2, c = Color(255,0,0)}
			},
			{
				{x = 1, y = 1, c = Color(255,0,0)},
				{x = 1, y = 2, c = Color(255,0,0)},
				{x = 2, y = 1, c = Color(255,0,0)},
				{x = 2, y = 2, c = Color(255,0,0)}
			},
			{
				{x = 1, y = 1, c = Color(255,0,0)},
				{x = 1, y = 2, c = Color(255,0,0)},
				{x = 2, y = 1, c = Color(255,0,0)},
				{x = 2, y = 2, c = Color(255,0,0)}
			},
			{
				{x = 1, y = 1, c = Color(255,0,0)},
				{x = 1, y = 2, c = Color(255,0,0)},
				{x = 2, y = 1, c = Color(255,0,0)},
				{x = 2, y = 2, c = Color(255,0,0)}
			}
		},
		{
			{
				{x = 1, y = 1, c = Color(0,255,0)},
				{x = 1, y = 2, c = Color(0,255,0)},
				{x = 1, y = 3, c = Color(0,255,0)},
				{x = 2, y = 3, c = Color(0,255,0)}
			},
			{
				{x = 1, y = 2, c = Color(0,255,0)},
				{x = 2, y = 2, c = Color(0,255,0)},
				{x = 3, y = 2, c = Color(0,255,0)},
				{x = 3, y = 1, c = Color(0,255,0)}
			},
			{
				{x = 1, y = 1, c = Color(0,255,0)},
				{x = 2, y = 1, c = Color(0,255,0)},
				{x = 2, y = 2, c = Color(0,255,0)},
				{x = 2, y = 3, c = Color(0,255,0)}
			},
			{
				{x = 1, y = 1, c = Color(0,255,0)},
				{x = 2, y = 1, c = Color(0,255,0)},
				{x = 3, y = 1, c = Color(0,255,0)},
				{x = 1, y = 2, c = Color(0,255,0)}
			}
		},
		{
			{
				{x = 2, y = 1, c = Color(0,0,255)},
				{x = 2, y = 2, c = Color(0,0,255)},
				{x = 2, y = 3, c = Color(0,0,255)},
				{x = 1, y = 3, c = Color(0,0,255)}
			},
			{
				{x = 1, y = 1, c = Color(0,0,255)},
				{x = 2, y = 1, c = Color(0,0,255)},
				{x = 3, y = 1, c = Color(0,0,255)},
				{x = 3, y = 2, c = Color(0,0,255)}
			},
			{
				{x = 2, y = 1, c = Color(0,0,255)},
				{x = 1, y = 1, c = Color(0,0,255)},
				{x = 1, y = 2, c = Color(0,0,255)},
				{x = 1, y = 3, c = Color(0,0,255)}
			},
			{
				{x = 1, y = 1, c = Color(0,0,255)},
				{x = 1, y = 2, c = Color(0,0,255)},
				{x = 2, y = 2, c = Color(0,0,255)},
				{x = 3, y = 2, c = Color(0,0,255)}
			}
		},
		{
			{
				{x = 1, y = 1, c = Color(0,255,255)},
				{x = 1, y = 2, c = Color(0,255,255)},
				{x = 1, y = 3, c = Color(0,255,255)},
				{x = 1, y = 4, c = Color(0,255,255)}
			},
			{
				{x = 0, y = 2, c = Color(0,255,255)},
				{x = 1, y = 2, c = Color(0,255,255)},
				{x = 2, y = 2, c = Color(0,255,255)},
				{x = 3, y = 2, c = Color(0,255,255)}
			},
			{
				{x = 1, y = 1, c = Color(0,255,255)},
				{x = 1, y = 2, c = Color(0,255,255)},
				{x = 1, y = 3, c = Color(0,255,255)},
				{x = 1, y = 4, c = Color(0,255,255)}
			},
			{
				{x = 0, y = 2, c = Color(0,255,255)},
				{x = 1, y = 2, c = Color(0,255,255)},
				{x = 2, y = 2, c = Color(0,255,255)},
				{x = 3, y = 2, c = Color(0,255,255)}
			}
		},
		{
			{
				{x = 1, y = 1, c = Color(255,255,0)},
				{x = 2, y = 1, c = Color(255,255,0)},
				{x = 3, y = 1, c = Color(255,255,0)},
				{x = 2, y = 2, c = Color(255,255,0)}
			},
			{
				{x = 2, y = 0, c = Color(255,255,0)},
				{x = 2, y = 1, c = Color(255,255,0)},
				{x = 2, y = 2, c = Color(255,255,0)},
				{x = 3, y = 1, c = Color(255,255,0)}
			},
			{
				{x = 1, y = 1, c = Color(255,255,0)},
				{x = 2, y = 1, c = Color(255,255,0)},
				{x = 3, y = 1, c = Color(255,255,0)},
				{x = 2, y = 0, c = Color(255,255,0)}
			},
			{
				{x = 2, y = 0, c = Color(255,255,0)},
				{x = 2, y = 1, c = Color(255,255,0)},
				{x = 2, y = 2, c = Color(255,255,0)},
				{x = 1, y = 1, c = Color(255,255,0)}
			}
		},
		{
			{
				{x = 3, y = 1, c = Color(255,0,255)},
				{x = 2, y = 1, c = Color(255,0,255)},
				{x = 2, y = 2, c = Color(255,0,255)},
				{x = 1, y = 2, c = Color(255,0,255)}
			},
			{
				{x = 1, y = 1, c = Color(255,0,255)},
				{x = 1, y = 2, c = Color(255,0,255)},
				{x = 2, y = 2, c = Color(255,0,255)},
				{x = 2, y = 3, c = Color(255,0,255)}
			},
			{
				{x = 3, y = 1, c = Color(255,0,255)},
				{x = 2, y = 1, c = Color(255,0,255)},
				{x = 2, y = 2, c = Color(255,0,255)},
				{x = 1, y = 2, c = Color(255,0,255)}
			},
			{
				{x = 1, y = 1, c = Color(255,0,255)},
				{x = 1, y = 2, c = Color(255,0,255)},
				{x = 2, y = 2, c = Color(255,0,255)},
				{x = 2, y = 3, c = Color(255,0,255)}
			}
		},
		{
			{
				{x = 1, y = 1, c = Color(255,165,0)},
				{x = 2, y = 1, c = Color(255,165,0)},
				{x = 2, y = 2, c = Color(255,165,0)},
				{x = 3, y = 2, c = Color(255,165,0)}
			},
			{
				{x = 2, y = 1, c = Color(255,165,0)},
				{x = 2, y = 2, c = Color(255,165,0)},
				{x = 1, y = 2, c = Color(255,165,0)},
				{x = 1, y = 3, c = Color(255,165,0)}
			},
			{
				{x = 1, y = 1, c = Color(255,165,0)},
				{x = 2, y = 1, c = Color(255,165,0)},
				{x = 2, y = 2, c = Color(255,165,0)},
				{x = 3, y = 2, c = Color(255,165,0)}
			},
			{
				{x = 2, y = 1, c = Color(255,165,0)},
				{x = 2, y = 2, c = Color(255,165,0)},
				{x = 1, y = 2, c = Color(255,165,0)},
				{x = 1, y = 3, c = Color(255,165,0)}
			}
		}
	}

	local minLeftSpacing = 1/4
	local minTopSpacing = 1/8
	local makeThemSquares = math.min(Render.Size.x / 10 * (1 - 2 * minLeftSpacing), Render.Size.y / 20 * (1 - 2 * minTopSpacing))

	self.tileWidthV = Vector2( makeThemSquares, 0 )
	self.tileHeightV = Vector2( 0, makeThemSquares )
	self.tileSize = self.tileWidthV + self.tileHeightV
	self.offset = Render.Size / 2 - self.tileWidthV * 5 - self.tileHeightV * 10

	self.settingsVisible = false

	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.5, 0.6 ) )
	self.window:SetPositionRel( Vector2( 0.5, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetVisible( self.settingsVisible )
	self.window:Subscribe( "WindowClosed", self, self.Close )

	self.list = SortedList.Create( self.window )
	self.list:SetDock( GwenPosition.Fill )
	self.list:SetMargin( Vector2.Zero, Vector2.Zero )
	self.list:SetBackgroundVisible( false )
	self.list:AddColumn( "Игрок" )
	self.list:AddColumn( "Счет" )
	self.list:SetButtonsVisible( true )

	self.globalOpacity = 200

	self.backgroundCol = Color( 10, 10, 10, self.globalOpacity / 3 )
	self.borderCol = Color( 0, 0, 0, self.globalOpacity )
	self.tileOpacity = Color( 0, 0, 0, self.globalOpacity )

	self:PopulateGrid()

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.window:SetTitle( "▧ Тетрис - Список лидеров" )

		self.locStrings = {
			tRecord = "Личный рекорд по тетрису: ",
			tDied = "ПОТРАЧЕНО!\n\n\n",
			tScores = "Счёт: ",
			tSetHelp = "[Space] - Запустить игру",
			tSetHelp2 = " \n\n\n[Ctrl] - Список лидеров",
			tSetGOver = "Финальный счёт: ",
			tSetGOver2 = " \n\n\n\n[Space] - Повторить попытку",
			tSetGOver3 = " \n\n\n\n\n\n\n[Ctrl] - Список лидеров",
			controltip = "[←→] - Перемещение фигуры\n[↑] - Повернуть фигуру\n[↓] - Опустить фигуру ниже\n[End] - Опустить фигуру вниз\n[Esc] - Закрыть тетрис"
		}
	end

	Events:Subscribe( "LocalPlayerChat", self, self.LocalPlayerChat )
	Events:Subscribe( "TetrisToggle", self, self.Toggle )
	Network:Subscribe( "NewLeaderboard", self, self.NewLeaderboard )

	Events:Subscribe( "Lang", self, self.Lang )

	Network:Subscribe( "003", self, self.onTetrisAttempt )
end

function Tetris:Lang()
	self.window:SetTitle( "▧ Tetris - Leaderboard" )

	self.locStrings = {
		tRecord = "Personal tetris record: ",
		tDied = "GAME OVER\n\n\n",
		tScores = "Score: ",
		tSetHelp = "[Space] - Start Game",
		tSetHelp2 = " \n\n\n[Ctrl] - Leaderboard",
		tSetGOver = "Final Score: ",
		tSetGOver2 = " \n\n\n\n[Space] - Try again",
		tSetGOver3 = " \n\n\n\n\n\n\n[Ctrl] - Leaderboard",
		controltip = "[←→] - Move block\n[↑] - Rotate block\n[↓] - Soft drop block\n[End] - Hard drop block\n[Esc] - Close tetris"
	}
end

function Tetris:LocalPlayerChat( args )
	local cmd_args = args.text:split( " " )

	if cmd_args[1] == "/tetris" then self:Toggle() end
end

function Tetris:Toggle()
	self.firstGo = true
	self:PopulateGrid()
	self.inTetrisMode = not self.inTetrisMode

	if self.inTetrisMode then
		if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
		if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end
		if not self.KeyDownEvent then self.KeyDownEvent = Events:Subscribe( "KeyDown", self, self.KeyDown ) end
	else
		if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
		if self.KeyDownEvent then Events:Unsubscribe( self.KeyDownEvent ) self.KeyDownEvent = nil end
	end
end

function Tetris:Render()
	if Game:GetState() ~= GUIState.Game then return end

	Render:FillArea( self.offset, Vector2( self.tileWidthV.x * 10, self.tileHeightV.y * 20 ), self.backgroundCol )

	if self.inGame then
		if (Client:GetElapsedSeconds() - self.moveDownTimer) > self.dropTime then
			self.moveDownTimer = Client:GetElapsedSeconds()
			self:MoveCurrent(0,1)
		end

		self:CheckTiles()
	end
	self:RenderTiles()
	self:ShowScore()

	self.window:SetVisible( self.settingsVisible )
end

function Tetris:onTetrisAttempt( data )
	self.attempt = data
	self.attempt[3] = 4
end

function Tetris:RenderTiles()
	for i = 1, 10 do
		local tilePos = self.offset + self.tileWidthV * (i-1) + self.tileHeightV * (-1)
		for j = 1, 20 do
			tilePos = tilePos + self.tileHeightV
			if self.gridNotCurrent[i][j] then
				local tilePos = self.offset + self.tileWidthV * (i-1) + self.tileHeightV * (j-1)
				Render:FillArea(tilePos, self.tileSize, self.gridNotCurrent[i][j] + self.tileOpacity)
			end
		end
	end

	if self.current[self.currentRot] then
		for _, v in pairs(self.current[self.currentRot]) do
			local tilePos = self.offset + self.tileWidthV * (v.x+self.currentLoc.x-1) + self.tileHeightV * (v.y+self.currentLoc.y-1)
			Render:FillArea(tilePos, self.tileSize, v.c + self.tileOpacity)
		end
	end

	Render:FillArea( self.offset - self.tileWidthV, self.tileWidthV * (10+2) - self.tileHeightV, self.borderCol ) --top
	Render:FillArea( self.offset - self.tileWidthV, self.tileWidthV + self.tileHeightV * 20, self.borderCol ) --left
	Render:FillArea( self.offset + 10 * self.tileWidthV, self.tileWidthV + self.tileHeightV * 20, self.borderCol ) --right
	Render:FillArea( self.offset + 20 * self.tileHeightV - self.tileWidthV, self.tileWidthV * (10+2) + self.tileHeightV, self.borderCol ) --bottom
end

function Tetris:PopulateGrid()
	self.inGame = false
	self.score = 0
	Network:Send( "UpdateTotalScore", { score = 0 } )
	self.level = 1
	self.dropTime = self.dropTimeLevel[self.level]

	self.gridNotCurrent = {}

	for i = 1, 10 do
		self.gridNotCurrent[i] = {}
	end
end

function Tetris:NewBlock()
	if self.inGame and self.current[self.currentRot] then
		for _, v in pairs(self.current[self.currentRot]) do
			self.gridNotCurrent[v.x+self.currentLoc.x][v.y+self.currentLoc.y] = v.c
		end
	end
	self.firstGo = false
	self.currentRot = 1
	self.currentLoc = Vector2(math.ceil(10 / 2) - 1,0)
	self.currentPiece = math.random(1,#self.pieces)
	self.current = {}
	self.current = self.pieces[self.currentPiece]
	for _, v in pairs(self.current[self.currentRot]) do
		if self.gridNotCurrent[v.x+self.currentLoc.x][v.y+self.currentLoc.y] then
			self:GameOver()
			return
		end
	end
	self.inGame = true
end

function Tetris:MoveCurrent( x, y )
	local canMove = true

	for _, v in pairs(self.current[self.currentRot]) do
		if (v.x+self.currentLoc.x+x)<1 or (v.x+self.currentLoc.x+x)>10 then
			self.moving = false
			return
		elseif y==0 and self.gridNotCurrent[v.x+self.currentLoc.x+x][v.y+self.currentLoc.y] then
			self.moving = false
			return
		elseif (v.y+self.currentLoc.y+y)>20 or self.gridNotCurrent[v.x+self.currentLoc.x+x][v.y+self.currentLoc.y+y] then
			canMove = false
		end
	end
	if canMove then
		self.currentLoc.x = self.currentLoc.x + x
		self.currentLoc.y = self.currentLoc.y + y
	else
		self:NewBlock()
	end
end

function Tetris:Rotate()
	local newRot = self.currentRot % 4 + 1

	for _, v in pairs(self.current[newRot]) do
		if (v.x+self.currentLoc.x)<1 or (v.x+self.currentLoc.x)>10 then
			return
		elseif (v.y+self.currentLoc.y)>20 or self.gridNotCurrent[v.x+self.currentLoc.x][v.y+self.currentLoc.y] then
			return
		end
	end
	self.currentRot = newRot
end

function Tetris:FindMaxDropDistance()
	local distance = 20

	for _, v in pairs(self.current[self.currentRot]) do
		for y = 1, 20 do
			if (v.y+self.currentLoc.y+y)>20 or self.gridNotCurrent[v.x+self.currentLoc.x][v.y+self.currentLoc.y+y] then
				if y < distance then
					distance = y
				end
			end
		end
	end

	return distance
end

function Tetris:CheckTiles()
	for y = 1, 20 do
		local full = true

		for x = 1, 10 do
			if not self.gridNotCurrent[x][y] then
				full = false
			end
		end

		if full then
			for x = 1, 10 do
				for y2 = y, 2, -1 do
					self.gridNotCurrent[x][y2] = self.gridNotCurrent[x][y2-1]
					self.gridNotCurrent[x][y2-1] = nil
				end
			end

			self.score = self.score + 10

			Network:Send( "UpdateTotalScore" )

			self:CheckTiles()
		end
	end

	if self.levelScore[self.level] and self.score >= self.levelScore[self.level] then
		self.score = self.score - self.levelScore[self.level]
		self.level = self.level + 1
		if self.dropTimeLevel[self.level] then
			self.dropTime = self.dropTimeLevel[self.level]
		end
	end
end

function Tetris:ShowScore()
	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end

	local text_clr = Color.White
	local shadow_clr = Color( 25, 25, 25 )
	local totalScore = tostring( LocalPlayer:GetValue( "TetrisTotalScore" ) )

	if not self.inGame then
		local text_size = 32

		if self.firstGo then
			local pos = ( Render.Size - Render:GetTextSize( self.locStrings["tSetHelp"], text_size ) ) / 2
			Render:DrawShadowedText( pos, self.locStrings["tSetHelp"], text_clr, shadow_clr, text_size )
			pos = ( Render.Size - Render:GetTextSize( self.locStrings["tSetHelp2"], text_size ) ) / 2
			Render:DrawShadowedText( pos, self.locStrings["tSetHelp2"], text_clr, shadow_clr, text_size )
		else
			local pos = ( Render.Size - Render:GetTextSize( self.locStrings["tDied"], text_size ) ) / 2
			Render:DrawShadowedText( pos, self.locStrings["tDied"], Color.Red, shadow_clr, text_size )
			local msg = self.locStrings["tSetGOver"] .. totalScore
			pos = ( Render.Size - Render:GetTextSize( msg, text_size ) ) / 2
			Render:DrawShadowedText( pos, msg, text_clr, shadow_clr, text_size )
			pos = ( Render.Size - Render:GetTextSize( self.locStrings["tSetGOver2"], text_size ) ) / 2
			Render:DrawShadowedText( pos, self.locStrings["tSetGOver2"], text_clr, shadow_clr, text_size )
			pos = ( Render.Size - Render:GetTextSize( self.locStrings["tSetGOver3"], text_size ) ) / 2
			Render:DrawShadowedText( pos, self.locStrings["tSetGOver3"], text_clr, shadow_clr, text_size )
		end
	end

	local score = self.locStrings["tScores"] .. totalScore
	local pos = Vector2( self.offset.x + 11.5 * self.tileWidthV.x, self.offset.y - self.tileHeightV.y + 40 )
	local text_size = 20
	local text_size2 = 15
	local padding = 10

	Render:FillArea( pos, Vector2( Render:GetTextWidth( self.locStrings["controltip"], text_size2 ) * 1.15, ( Render:GetTextHeight( score, text_size ) + 5 + Render:GetTextHeight( self.locStrings["controltip"], text_size2 ) ) + padding * 2 ), self.backgroundCol )

	pos = pos + Vector2( padding, padding )
	Render:DrawShadowedText( pos, self.locStrings["tScores"], text_clr, shadow_clr, text_size )
	Render:DrawShadowedText( pos + Vector2( Render:GetTextWidth( self.locStrings["tScores"], text_size ), 0 ), totalScore, Color( 185, 215, 255 ), shadow_clr, text_size )

	Render:SetFont( AssetLocation.Disk, "Archivo.ttf" )
	Render:DrawShadowedText( pos + Vector2( 0, Render:GetTextHeight( score, text_size ) + 5 ), self.locStrings["controltip"], text_clr, shadow_clr, text_size2 )
end

function Tetris:GameOver()
	self.inGame = false
	for _, v in pairs(self.current[self.currentRot]) do
		self.gridNotCurrent[v.x+self.currentLoc.x][v.y+self.currentLoc.y] = v.c
	end

	local object = NetworkObject.GetByName("Tetris")
	local totalScore = LocalPlayer:GetValue( "TetrisTotalScore" )

	if not object or totalScore > (object:GetValue("S") or 0) then
		if LocalPlayer:GetWorld() == DefaultWorld then
			Network:Send("001")
		end
	elseif totalScore > ((object:GetValue("S") or 0) * 0.6) and (object:GetValue("N") or "None") ~= LocalPlayer:GetName() then
		Network:Send("002")
	end

	local shared = SharedObject.Create("Tetris")
	if totalScore > (shared:GetValue("Record") or 0) then
		shared:SetValue( "Record", totalScore )
		Game:ShowPopup( self.locStrings["tRecord"] .. totalScore, true )
	end

	Network:Send( "NewScore" )
end

function Tetris:KeyDown( args )
	if self.inTetrisMode and self.inGame then
		if args.key == VirtualKey.Left then
			self:MoveCurrent(-1,0)
		elseif args.key == VirtualKey.Right then
			self:MoveCurrent(1,0)
		elseif args.key == VirtualKey.Down then
			self:MoveCurrent(0,1)
		elseif args.key == VirtualKey.Up then
			self:Rotate()
		elseif args.key == VirtualKey.End then
			for i = 1, self:FindMaxDropDistance() do
				self:MoveCurrent(0,1)
			end
		end
	elseif self.inTetrisMode and (args.key == VirtualKey.Space) and not self.inGame then
		self:PopulateGrid()
		self.moveDownTimer = Client:GetElapsedSeconds()
		self:NewBlock()
	end

	if self.inTetrisMode and (args.key == VirtualKey.Control) and not self.settingsVisible and not self.inGame then
		Network:Send( "TopScores", LocalPlayer:GetValue( "TetrisTotalScore" ) )
		self.settingsVisible = true
		Mouse:SetVisible( self.settingsVisible )

		local effect = ClientEffect.Play( AssetLocation.Game, {
			effect_id = 382,

			position = Camera:GetPosition(),
			angle = Angle()
		} )
	end
end

function Tetris:Close()
	self.settingsVisible = false
	Mouse:SetVisible( self.settingsVisible )

	local effect = ClientEffect.Play( AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

function Tetris:NewLeaderboard( tData )
	self.list:Clear()

	self.currentLeaderboard = tData

	for _, v in pairs(self.currentLeaderboard) do
		self.list:AddItem( v.name ):SetCellText( 1, tostring(v.score) )
	end
end

function Tetris:LocalPlayerInput( args )
	if args.input == Action.GuiPause then
		self:Toggle()
	end
	if self.settingsVisible then
		return false
	end
end

tetris = Tetris()
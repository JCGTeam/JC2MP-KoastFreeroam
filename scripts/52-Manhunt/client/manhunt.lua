class 'Manhunt'

function Manhunt:__init()
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "GoHunt", self, self.GoHunt )

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.yourscorestxt = "Ваши очки: "
		self.leaderboardtxt = "[Лидеры]"
		self.nameTh = "Ухади, аташол!"
	end

	Network:Subscribe( "ManhuntEnter", self, self.Enter )
	Network:Subscribe( "ManhuntExit", self, self.Exit )
	Network:Subscribe( "ManhuntEnterBorder", self, self.EnterBorder )
	Network:Subscribe( "ManhuntExitBorder", self, self.ExitBorder )
	Network:Subscribe( "ManhuntUpdateIt", self, self.UpdateIt )
	Network:Subscribe( "ManhuntUpdateItPos", self, self.UpdateItPos )
	Network:Subscribe( "ManhuntUpdatePoints", self, self.UpdatePoints )
	Network:Subscribe( "ManhuntUpdateScores", self, self.UpdateScores )

	self.oob = false
	self.pts = 0
	self.scores = {}
	self.inMode = false
	self.isIt = false
end

function Manhunt:Lang()
	self.yourscorestxt = "Your points: "
	self.leaderboardtxt = "[Leaders]"
	self.nameTh = "You're leaving the island!"
end

function Manhunt:GoHunt()
	Network:Send( "GoHunt" )
end

function Manhunt:Enter()
	if not self.EventRender then self.EventRender = Events:Subscribe( "Render", self, self.Render ) end
	self.inMode = true
	Game:FireEvent("ply.grappling.disable")
	Game:FireEvent("parachute00.pickup.execute")
	--Game:FireEvent("ply.parachute.disable")
end

function Manhunt:Exit()
	if self.EventRender then Events:Unsubscribe( self.EventRender ) self.EventRender = nil end
	Waypoint:Remove()
	self.inMode = false
	Game:FireEvent("ply.grappling.enable")
	Events:Fire( "RestoreParachute" )
	--Game:FireEvent("ply.parachute.enable")
end

function Manhunt:EnterBorder()
	self.oob = true
end

function Manhunt:ExitBorder()
	self.oob = false
end

function Manhunt:UpdateIt(it)
	if it then
		--Game:FireEvent("ply.grappling.disable")
		--Game:FireEvent("ply.parachute.disable")
	else
		--Game:FireEvent("ply.grappling.enable")
		--Game:FireEvent("ply.parachute.enable")
	end
	self.isIt = it
end

function Manhunt:UpdateItPos( pos )
	Waypoint:Remove()
	Waypoint:SetPosition(pos)
end

function Manhunt:UpdatePoints( pts )
	self.pts = pts
end

function Manhunt:UpdateScores( scores )
	self.scores = scores
end

function Manhunt:RightText( msg, y, color )
	local w = Render:GetTextWidth( msg )
	Render:DrawShadowedText( Vector2( Render.Width - w - 5, y ), msg, color, Color.Black )
end

function Manhunt:Render()
	--if not self.inMode then return end 
	if Game:GetState() ~= GUIState.Game then return end

	local color = Color.White

	self:RightText( self.yourscorestxt .. self.pts, Render:GetTextHeight( "A" ) * 3.5, Color( 255, 255, 0 ) )
	self:RightText( self.leaderboardtxt, Render:GetTextHeight( self.yourscorestxt .. self.pts ) * 5, Color( 255, 255, 0 ) )

	for i = 1, math.min(#self.scores, 10), 1 do
		self:RightText( ""..i..". "..self.scores[i].name..": "..self.scores[i].pts, Render:GetTextHeight( self.leaderboardtxt ) * 5 + i * 16, self.scores[i].it and Color( 255, 170, 0 ) or color )
	end

	if not self.oob then return end

	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end

	local text = self.nameTh
	local text_width = Render:GetTextWidth( text, TextSize.Gigantic )
	local text_height = Render:GetTextHeight( text, TextSize.Gigantic )

	local pos = Vector2( (Render.Width - text_width)/2, (Render.Height - text_height)/2 )

	Render:DrawShadowedText( pos, text, Color.Red, shadowColor, TextSize.Gigantic )
end

manhunt = Manhunt()
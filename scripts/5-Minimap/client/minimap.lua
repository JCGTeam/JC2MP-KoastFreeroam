class "BetterMinimap"

function BetterMinimap:__init()
	self.playerPositions = {}
	self.currentPlayerId = LocalPlayer:GetId()

	self.size = Render.Size.x / 350
	self.sSize = Render.Size.x / 300

	Network:Subscribe( "BMPlayerPositions", self, self.PlayerPositions )

	Events:Subscribe( "Render", self, self.Render )
end

function BetterMinimap:PlayerPositions( positions )
	self.playerPositions = positions

	local localPlayerPos = LocalPlayer:GetPosition()

	for playerId, data in pairs(self.playerPositions) do
		local posp = data.position.y + 30
		local posm = data.position.y - 30

		if localPlayerPos.y > posp then
			data.triangle = -1
		elseif localPlayerPos.y < posm then
			data.triangle = 1
		else
			triangle = 0
		end
	end
end

function Vector3:IsNaN()
	return (self.x ~= self.x) or (self.y ~= self.y) or (self.z ~= self.z)
end

function BetterMinimap:Render()
	if Game:GetState() ~= GUIState.Game then return end
	if not LocalPlayer:GetValue( "PlayersMarkersVisible" ) or LocalPlayer:GetValue( "HiddenHUD" ) then return end

	if Game:GetSetting(4) >= 1 then
		local localPlayerPos = LocalPlayer:GetPosition()
		local updatedPlayers = {}

		for player in Client:GetStreamedPlayers() do
			local position = player:GetPosition()

			if not position:IsNaN() then
				updatedPlayers[player:GetId()] = true
				local posp = position.y + 30
				local posm = position.y - 30
				
				if localPlayerPos.y > posp then
					triangle = -1
				elseif localPlayerPos.y < posm then
					triangle = 1
				else
					triangle = 0
				end

				self:DrawPlayer( position, triangle, player:GetColor() )
			end
		end

		local localPlayerWorldId = LocalPlayer:GetWorld():GetId()

		for playerId, data in pairs(self.playerPositions) do
			if not updatedPlayers[playerId] and self.currentPlayerId ~= playerId and localPlayerWorldId == data.worldId then
				self:DrawPlayer( data.position, data.triangle, data.color )
			end
		end
	end
end

function BetterMinimap:DrawPlayer( position, triangle, color )
	local pos, ok = Render:WorldToMinimap( position )
	local playerPosition = LocalPlayer:GetPosition()
	local distance = Vector3.Distance( playerPosition, position )

	if distance <= 5000 then
		local sett_alpha = Game:GetSetting(4) * 2.25
		local color = Color( color.r, color.g, color.b, sett_alpha )
		local shadowColor = Color( 0, 0, 0, sett_alpha )

		if triangle == 1 then
			Render:FillTriangle( Vector2( pos.x, pos.y - self.sSize-3 ), Vector2( pos.x - self.sSize-1, pos.y + self.sSize-1 ), Vector2( pos.x + self.sSize, pos.y + self.sSize-1 ), shadowColor )
			Render:FillTriangle( Vector2( pos.x, pos.y - self.size-2 ), Vector2( pos.x - self.size-1, pos.y + self.size-1 ), Vector2( pos.x + self.size, pos.y + self.size-1 ), color )
		elseif triangle == -1 then
			Render:FillTriangle( Vector2( pos.x, pos.y + self.sSize-0 ), Vector2( pos.x - self.sSize-1, pos.y - self.sSize-1 ), Vector2( pos.x + self.sSize-1, pos.y - self.sSize-1 ), shadowColor )
			Render:FillTriangle( Vector2( pos.x, pos.y + self.size-1 ), Vector2( pos.x - self.size-1, pos.y - self.size-1 ), Vector2( pos.x + self.size-1, pos.y - self.size-1 ), color )
		else
			Render:FillCircle( pos, self.size, color )
			Render:DrawCircle( pos, self.size, shadowColor )
		end
	end
end

betterminimap = BetterMinimap()
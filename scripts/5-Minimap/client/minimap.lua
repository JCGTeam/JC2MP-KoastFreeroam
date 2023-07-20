class "BetterMinimap"

function BetterMinimap:__init()
	self.playerPositions = {}
	self.currentPlayerId = LocalPlayer:GetId()

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

	local localPlayerPos = LocalPlayer:GetPosition()
	local updatedPlayers = {}

	for player in Client:GetStreamedPlayers() do
		local position = player:GetPosition()
		local tringle = 0 -- 0 = none, 1 = up, -1 = down
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

			BetterMinimap.DrawPlayer( position, triangle, player:GetColor() )
		end
	end

	local localPlayerWorldId = LocalPlayer:GetWorld():GetId()

	for playerId, data in pairs(self.playerPositions) do
		if not updatedPlayers[playerId] and self.currentPlayerId ~= playerId and localPlayerWorldId == data.worldId then
			BetterMinimap.DrawPlayer( data.position, data.triangle, data.color )
		end
	end
end

function BetterMinimap.DrawPlayer( position, triangle, color )
	local pos, ok = Render:WorldToMinimap( position )
	local playerPosition = LocalPlayer:GetPosition()
	local distance = Vector3.Distance( playerPosition, position )

	if Game:GetSetting(4) >= 1 then
		if distance <= 5000 then
			local size = Render.Size.x / 350
			local sSize = Render.Size.x / 300

			if triangle == 1 then
				Render:FillTriangle( Vector2( pos.x,pos.y - sSize-3 ), Vector2( pos.x - sSize-1,pos.y + sSize-1 ), Vector2( pos.x + sSize,pos.y + sSize-1 ), Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ) )
				Render:FillTriangle( Vector2( pos.x,pos.y - size-2 ), Vector2( pos.x - size-1,pos.y + size-1 ), Vector2( pos.x + size,pos.y + size-1 ), Color( color.r, color.g, color.b, Game:GetSetting(4) * 2.25 ) )
			elseif triangle == -1 then
				Render:FillTriangle( Vector2( pos.x,pos.y + sSize-0 ), Vector2( pos.x - sSize-1,pos.y - sSize-1 ), Vector2( pos.x + sSize-1,pos.y - sSize-1 ), Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ) )
				Render:FillTriangle( Vector2( pos.x,pos.y + size-1 ), Vector2( pos.x - size-1,pos.y - size-1 ), Vector2( pos.x + size-1,pos.y - size-1 ), Color( color.r, color.g, color.b, Game:GetSetting(4) * 2.25 ) )
			else
				Render:FillCircle( pos, size, Color( color.r, color.g, color.b, Game:GetSetting(4) * 2.25 ) )
				Render:DrawCircle( pos, size, Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ) )
			end
		end
	end
end

betterminimap = BetterMinimap()
class 'Hook'

function Hook:__init()
	Events:Subscribe( "GameRenderOpaque", self, self.GameRenderOpaque )
end

function Hook:GameRenderOpaque()
	local cameraPos = Camera:GetPosition()

	for player in Client:GetStreamedPlayers() do
		if player:GetVehicle() and player:GetSeat() ~= 8 then return end

		local bs = player:GetBaseState()
		local las = player:GetLeftArmState()

		if bs == 207 or las == 400 or bs == 208 and player:GetAimTarget() and player:GetAimTarget().position then
			hookAimTarget = player:GetAimTarget()
		end

		if bs == 207 or las == 400 then
			if not effect_played then
				effect_played = true
				local effect = ClientEffect.Play( AssetLocation.Game, {
					effect_id = 11,
					position = player:GetBonePosition( "ragdoll_AttachHandLeft" ),
					angle = player:GetBoneAngle( "ragdoll_AttachHandLeft" )
				})
				if hookAimTarget and hookAimTarget.player or hookAimTarget.entity and hookAimTarget.entity.__type == 'ClientActor' then
					local effect = ClientEffect.Play( AssetLocation.Game, {
						effect_id = 421,
						position = hookAimTarget.entity:GetBonePosition( "ragdoll_Spine" ),
						angle = Angle()
					})
					--[[if not hookAimTarget.entity:GetVehicle() and not hookAimTarget.entity:GetValue( "Passive" ) and not player:GetValue( "Passive" ) then
						hookAimTarget.entity:SetBaseState( AnimationState.SHitreactStumbleHead )
					end]]--
				elseif hookAimTarget and hookAimTarget.position then
					local effect = ClientEffect.Play( AssetLocation.Game, {
						effect_id = 212,
						position = hookAimTarget.position,
						angle = Angle()
					})
				end
			end
		else
			if effect_played then effect_played = nil end
		end

		if IsValid( player ) then
			if bs == 208 and hookAimTarget and hookAimTarget.position then
				Render:DrawLine( player:GetBonePosition( "ragdoll_AttachHandLeft" ), hookAimTarget.position, Color( 100, 100, 100, 255 * math.max( 0, 1 - ( Vector3.Distance( player:GetPosition(), cameraPos ) / 1024 ) ) ) )
			elseif las == 400 and hookAimTarget and hookAimTarget.entity and hookAimTarget.entity.__type ~= "Vehicle" and hookAimTarget.entity.__type == "ClientActor" then
				Render:DrawLine( player:GetBonePosition( "ragdoll_AttachHandLeft" ), hookAimTarget.entity:GetBonePosition( "ragdoll_Spine" ), Color( 100, 100, 100, 255 * math.max( 0, 1 - ( Vector3.Distance( player:GetPosition(), cameraPos ) / 1024 ) ) ) )
			end
		end
	end
end

hook = Hook()
class 'Hook'

function Hook:__init()
    Events:Subscribe("GameRenderOpaque", self, self.GameRenderOpaque)
end

function Hook:GameRenderOpaque()
    local cameraPos = Camera:GetPosition()
    local streamedPlayers = Client:GetStreamedPlayers()

    for p in streamedPlayers do
        local pVehicle = p:GetVehicle()
        local pSeat = p:GetSeat()

        if pVehicle and pSeat ~= 8 then return end

        local bs = p:GetBaseState()
        local las = p:GetLeftArmState()

        local effect_played
        local hookAimTarget

        if bs == 207 or las == 400 or bs == 208 and p:GetAimTarget() and p:GetAimTarget().position then
            hookAimTarget = p:GetAimTarget()
        end

        if bs == 207 or las == 400 then
            if not effect_played then
                effect_played = true

                local effect = ClientEffect.Play(AssetLocation.Game, {
                    effect_id = 11,
                    position = p:GetBonePosition("ragdoll_AttachHandLeft"),
                    angle = p:GetBoneAngle("ragdoll_AttachHandLeft")
                })

                if hookAimTarget and hookAimTarget.player or hookAimTarget.entity and hookAimTarget.entity.__type == 'ClientActor' then
                    local effect = ClientEffect.Play(AssetLocation.Game, {
                        effect_id = 421,
                        position = hookAimTarget.entity:GetBonePosition("ragdoll_Spine"),
                        angle = Angle()
                    })

                    --[[if not hookAimTarget.entity:GetVehicle() and not (hookAimTarget.entity:GetValue("Passive") or p:GetValue("Passive")) then
						hookAimTarget.entity:SetBaseState(AnimationState.SHitreactStumbleHead)
					end]] --
                elseif hookAimTarget and hookAimTarget.position then
                    local effect = ClientEffect.Play(AssetLocation.Game, {
                        effect_id = 212,
                        position = hookAimTarget.position,
                        angle = Angle()
                    })
                end
            end
        else
            if effect_played then effect_played = nil end
        end

        if IsValid(p) then
            if bs == 208 and hookAimTarget and hookAimTarget.position then
                Render:DrawLine(p:GetBonePosition("ragdoll_AttachHandLeft"), hookAimTarget.position, Color(100, 100, 100, 255 * math.max(0, 1 - (Vector3.Distance(p:GetPosition(), cameraPos) / 1024))))
            elseif las == 400 and hookAimTarget and hookAimTarget.entity and hookAimTarget.entity.__type ~= "Vehicle" and
                hookAimTarget.entity.__type == "ClientActor" then
                Render:DrawLine(p:GetBonePosition("ragdoll_AttachHandLeft"), hookAimTarget.entity:GetBonePosition("ragdoll_Spine"), Color(100, 100, 100, 255 * math.max(0, 1 - (Vector3.Distance(p:GetPosition(), cameraPos) / 1024))))
            end
        end
    end
end

local hook = Hook()
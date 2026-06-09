class 'Hook'

function Hook:__init()
    self.effect_played = {}

    Events:Subscribe("GameRenderOpaque", self, self.GameRenderOpaque)
    Events:Subscribe("EntityDespawn", self, self.EntityDespawn)
end

function Hook:GameRenderOpaque()
    local cameraPos = Camera:GetPosition()
    local streamedPlayers = Client:GetStreamedPlayers()

    for p in streamedPlayers do
        local pVehicle = p:GetVehicle()
        local pSeat = p:GetSeat()

        if not (pVehicle and pSeat ~= 8) then
            local pId = p:GetId()
            local bs = p:GetBaseState()
            local las = p:GetLeftArmState()
            local hookAimTarget

            if (bs == 207 or bs == 208) or (las == 400 or las == 402 or las == 408) and p:GetAimTarget() and p:GetAimTarget().position then
                hookAimTarget = p:GetAimTarget()

                if not self.effect_played[pId] then
                    self.effect_played[pId] = true

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
                if self.effect_played[pId] then 
                    self.effect_played[pId] = nil 
                end
            end

            if IsValid(p) and hookAimTarget then
                local targetPos

                if hookAimTarget.position then
                    targetPos = hookAimTarget.position
                elseif hookAimTarget.entity and hookAimTarget.entity.__type == "ClientActor" then
                    targetPos = hookAimTarget.entity:GetBonePosition("ragdoll_Spine")
                end

                if targetPos then
                    local alpha = 255 * math.max(0, 1 - (Vector3.Distance(p:GetPosition(), cameraPos) / 1024))
                    Render:DrawLine(p:GetBonePosition("ragdoll_AttachHandLeft"), targetPos, Color(100, 100, 100, alpha))
                end
            end
        end
    end
end

function Hook:EntityDespawn(args)
    if args.entity.__type == "Player" then
        self.effect_played[args.entity:GetId()] = nil
    end
end

local hook = Hook()
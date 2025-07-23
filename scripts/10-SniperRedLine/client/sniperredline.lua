class 'SniperRedLine'

function SniperRedLine:__init()
    Events:Subscribe("GameRender", self, self.GameRender)
end

function SniperRedLine:GameRender()
    local steamedPlayers = Client:GetStreamedPlayers()

    for p in steamedPlayers do
        local ubs = p:GetUpperBodyState()
        local equippedWeapon = p:GetEquippedWeapon()

        if ubs == 347 and equippedWeapon == Weapon(Weapon.Sniper) then
            local ahr_bonepos = p:GetBonePosition("ragdoll_AttachHandRight") + Vector3(0, 0.1, 0)
            local rfa_bonepos = p:GetBonePosition("ragdoll_RightForeArm")
            local rfa_boneangle = p:GetBoneAngle("ragdoll_RightForeArm")

            if ahr_bonepos and p:GetAimTarget() and p:GetAimTarget().position then
                local aimPos = p:GetAimTarget().position
                local distance = Vector3.Distance(ahr_bonepos, aimPos)
                local linecolor = Color(255, 0, 0, 50)

                if distance <= 250 then
                    Render:DrawLine(ahr_bonepos, aimPos, linecolor)
                else
                    Render:DrawLine(ahr_bonepos, rfa_bonepos + rfa_boneangle * Vector3(250, -1.2, 0.1), linecolor)
                end
            end
        end
    end
end

local sniperredline = SniperRedLine()
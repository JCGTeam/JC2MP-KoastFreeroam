class 'SniperRedLine'

function SniperRedLine:__init()
    Events:Subscribe( "GameRender", self, self.GameRender )

    self.maxdist = 250
end

function SniperRedLine:GameRender()
    for p in Client:GetStreamedPlayers() do
        if p:GetUpperBodyState() == 347 and p:GetEquippedWeapon() == Weapon( Weapon.Sniper ) then
            local ahr_bonepos = p:GetBonePosition( "ragdoll_AttachHandRight" ) + Vector3( 0, 0.1, 0 )
            local rfa_bonepos = p:GetBonePosition( "ragdoll_RightForeArm" )
            local rfa_boneangle = p:GetBoneAngle( "ragdoll_RightForeArm" )

            if ahr_bonepos and p:GetAimTarget() and p:GetAimTarget().position then
                local distance = Vector3.Distance( ahr_bonepos, p:GetAimTarget().position )

                if distance <= self.maxdist then
                    Render:DrawLine( ahr_bonepos, p:GetAimTarget().position, Color( 255, 0, 0, 50 ) )
                else
                    Render:DrawLine( ahr_bonepos, rfa_bonepos + rfa_boneangle * Vector3( 250, -1.2, 0.1 ), Color( 255, 0, 0, 50  ) )
                end
            end
        end
    end
end

sniperredline = SniperRedLine()
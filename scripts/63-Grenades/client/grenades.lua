class "Grenades"

Grenades.OverThrowTime = 0.36
Grenades.UnderThrowTime = 0.48
Grenades.GrenadeOffset = Vector3( 0.3, -0.06, -0.02 )

function Grenades:__init()
    self.womanskins = { 14, 31, 41, 46, 47, 62, 72, 82, 92, 102, 60, 86, 90, 65, 25 }

    self.blacklist = {
        animations = { 
            [AnimationState.SReelFlight] = true,
            [AnimationState.SIdlePassengerVehicle] = true,
            [AnimationState.SReeledInIdle] = true,
            [AnimationState.SHangstuntIdle] = true
        },

        animations2 = {
            [AnimationState.SSkydive] = true,
            [AnimationState.SSkydiveDash] = true,
            [AnimationState.SUnfoldParachuteVertical] = true,
            [AnimationState.SUnfoldParachuteHorizontal] = true,
            [AnimationState.SPullOpenParachuteVertical] = true,
            [AnimationState.SParachuteDetachToFreefall] = true,
            [AnimationState.SFallToSkydive] = true
        }
    }

    Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
    Events:Subscribe( "InputPoll", self, self.InputPoll )
    Events:Subscribe( "FireGrenade", self, self.FireGrenade )
    Events:Subscribe( "PostTick", self, self.PostTick )
    Events:Subscribe( "Render", self, self.Render )
    Network:Subscribe( "GrenadeTossed", self, self.GrenadeTossed )

    self.object = false
end

function Grenades:ModuleLoad()
    self.grenades = {}
    self.dummies = {}
    self.thrown = true
    self.thrownType = false
    self.thrownPosition = Vector3()
    self.thrownVelocity = Vector3()
    self.thrownTimer = Timer()
end

function Grenades:ModuleUnload()
    for k, grenade in ipairs(self.grenades) do
        grenade:Remove()
    end

    for k, dummy in ipairs(self.dummies) do
        dummy:Remove()
    end
end

function Grenades:InputPoll()
    if not self.thrown then
        if not self.thrownTimer then
            self.thrownTimer = Timer()
        end

        local bs = LocalPlayer:GetBaseState()

        if LocalPlayer:GetBaseState() ~= AnimationState.SParachute then
            Input:SetValue( Action.TurnLeft, 0 )
            Input:SetValue( Action.TurnRight, 0 )
            Input:SetValue( Action.LookLeft, 0 )
            Input:SetValue( Action.LookUp, 0 )
            Input:SetValue( Action.LookRight, 0 )
            Input:SetValue( Action.LookDown, 0 )

            if not self.blacklist.animations2[bs] and not self.blacklist.animations[bs] then
                LocalPlayer:SetAngle( Angle( Camera:GetAngle().yaw, LocalPlayer:GetAngle().pitch, LocalPlayer:GetAngle().roll ) )
            end
        end

        if not LocalPlayer:InVehicle() and not self.blacklist.animations[bs] then
            if self.thrownUnder then
                LocalPlayer:SetLeftArmState( AnimationState.LaSUnderThrowGrenade )
            else
                LocalPlayer:SetLeftArmState( AnimationState.LaSOverThrowGrenade )
            end
        end
    end
end

function Grenades:FireGrenade( args )
    if args.type == "Frag" then
        self:TossGrenade(Grenade.Types.Frag)
    elseif args.type == "Smoke" then
        self:TossGrenade(Grenade.Types.Smoke)
    elseif args.type == "MichaelBay" then
        if LocalPlayer:GetWorld() ~= DefaultWorld then return end

        self:TossGrenade( Grenade.Types.MichaelBay )

        if not table.find( self.womanskins, LocalPlayer:GetModelId() ) then
            Game:FireEvent( "ply.predator.awesomeness" )
        end
    end

    if LocalPlayer:GetValue("SuperNuclearBomb") then
        if args.type == "Atom" then
            if LocalPlayer:GetWorld() ~= DefaultWorld then return end

            self:TossGrenade( Grenade.Types.Atom )

			if not table.find( self.womanskins, LocalPlayer:GetModelId() ) then
            	Game:FireEvent( "ply.predator.awesomeness" )
			end
        end
    end
end

function Grenades:PostTick( args )
    if not self.thrown then
        local position = LocalPlayer:GetBonePosition( "ragdoll_LeftForeArm" ) + LocalPlayer:GetBoneAngle( "ragdoll_LeftForeArm" ) * Grenades.GrenadeOffset

        self.thrownVelocity = (Camera:GetAngle() * Vector3.Forward * 25) * ((Camera:GetAngle().pitch + (math.pi / 2)) / (math.pi / 2))
        self.thrownPosition = position

        if self.thrownTimer and self.thrownTimer:GetSeconds() > (self.thrownUnder and Grenades.UnderThrowTime or Grenades.OverThrowTime) then
            local grenade = {
                ["position"] = self.thrownPosition,
                ["velocity"] = self.thrownVelocity,
                ["type"] = self.thrownType
            }

            Network:Send("GrenadeTossed", grenade)
            self:GrenadeTossed(grenade)

            self.thrown = true
            self.object = false
        end
    end

    for k, grenade in ipairs(self.grenades) do
        grenade:Update()

        if not IsValid(grenade.object) or not IsValid(grenade.effect) then
            table.remove(self.grenades, k)
        end
    end
end

function Grenades:Render()
    for player in Client:GetStreamedPlayers() do
        self:ApplyDummy(player)
    end

    self:ApplyDummy(LocalPlayer)
end

function Grenades:ApplyDummy( player )
    local state = player:GetLeftArmState()
    local dummy = self.dummies[player:GetId()]

    if table.find({AnimationState.LaSUnderThrowGrenade, AnimationState.LaSOverThrowGrenade}, state) then
        if self.object then
            if not dummy then
                dummy = ClientStaticObject.Create({
                    model = "wea33-wea33.lod",
                    position = Vector3(),
                    angle = Angle()
                })

                self.dummies[player:GetId()] = dummy
            end

            dummy:SetAngle( player:GetBoneAngle("ragdoll_LeftForeArm") )
            dummy:SetPosition( player:GetBonePosition("ragdoll_LeftForeArm") + dummy:GetAngle() * Grenades.GrenadeOffset )
        end
    elseif dummy then
        dummy:Remove()
        self.dummies[player:GetId()] = nil
    end
end

function Grenades:TossGrenade( type )
    if self.thrown and
        not table.find({AnimationState.LaSUnderThrowGrenade, AnimationState.LaSOverThrowGrenade}, LocalPlayer:GetLeftArmState()) then
        self.thrown = false
        self.thrownUnder = Camera:GetAngle().pitch < -math.pi / 12
        self.thrownType = type
        self.object = true
        self.thrownTimer = false
    end
end

function Grenades:GrenadeTossed( args )
    table.insert(self.grenades, Grenade(args.position, args.velocity, args.type))
end

grenades = Grenades()
class "Claymores"

function Claymores:__init()
	self:initVars()
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "PostTick", self, self.onPostTick )
	Events:Subscribe( "WorldNetworkObjectCreate", self, self.onWorldNetworkObjectCreate )
	Events:Subscribe( "WorldNetworkObjectDestroy", self, self.onWorldNetworkObjectDestroy )
	Events:Subscribe( "ModuleUnload", self, self.onModuleUnload )

	Network:Subscribe( "EffectClay", self, self.EffectClay )
end

function Claymores:initVars()
	self.claymores = {}
	self.delay = 800 -- Time to place a claymore in ms
	self.cooldown = 1000 -- Time between placing claymores in ms
	self.ignore = 500 -- Time to ignore triggers in ms
	self.timer = Timer()
end

function Claymores:EffectClay( args )
	ClientEffect.Play(AssetLocation.Game,
	{
		effect_id = 33,
		position = args.position,
		angle = args.angle
	})
	ClientEffect.Play(AssetLocation.Game,
	{
		effect_id = 19,
		position = args.position,
		angle = args.angle
	})
end

function Claymores:LocalPlayerInput( args )
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetValue( "Freeze" ) then return end
	if LocalPlayer:GetValue( "Passive" ) then return end
	if LocalPlayer:GetValue( "ServerMap" ) then return end

	if not LocalPlayer:GetValue("Passive") then
		if args.input == Action.ThrowGrenade and LocalPlayer:GetValue("exp") == 3 then
			if self.placing then return end
			if self.timer:GetMilliseconds() < self.cooldown then return end
			if LocalPlayer:GetBaseState() ~= AnimationState.SUprightIdle then return end
			LocalPlayer:SetBaseState(AnimationState.SCoverEntering)
			self.placing = Timer()
			local sound = ClientSound.Create(AssetLocation.Game, {
					bank_id = 18,
					sound_id = 5,
					position = LocalPlayer:GetPosition(),
					angle = Angle()
			})

			sound:SetParameter(0,1)
		end
	end
end

function Claymores:onPostTick()
	if not self.placing then return end
	if self.placing:GetMilliseconds() < self.delay then return end
	LocalPlayer:SetBaseState(AnimationState.SUprightIdle)
	Network:Send( "01" )
	self.timer:Restart()
	self.placing = nil
end

function Claymores:onWorldNetworkObjectCreate( args )
	local class = args.object:GetValue("C")
	if class == Class.ClaymoreTrigger then
		if self.timer:GetMilliseconds() < self.ignore then return end
		local position = args.object:GetPosition()
		local angle = args.object:GetAngle()
		Network:Send("02", {id = args.object:GetId(), position = position, angle = angle})
		return
	end
	if class ~= Class.ClaymoreObject then return end
	local object = ClientStaticObject.Create({
		model = "km05.blz/gp703-a.lod",
		collision = "",
		position = args.object:GetPosition(),
		angle = args.object:GetAngle(),
		fixed = true
	})
	self.claymores[args.object:GetId()] = object
end

function Claymores:onWorldNetworkObjectDestroy( args )
	local class = args.object:GetValue("C")
	if class ~= Class.ClaymoreObject then return end
	local object = self.claymores[args.object:GetId()]
	if not object then return end
	object:Remove()
end

function Claymores:onModuleUnload()
	for _, claymore in pairs(self.claymores) do
		if IsValid(claymore) then claymore:Remove() end
	end
end

claymores = Claymores()
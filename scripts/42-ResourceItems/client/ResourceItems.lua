class "ResourceItems"

function ResourceItems:__init()
	self.timer = Timer()
	self.numcrates = 0

	self.crates = {}

	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )

	Network:Subscribe( "CrateTaken", self, self.CrateTaken )
	Network:Subscribe( "SyncTriggers", self, self.SyncTriggers )
	Network:Subscribe( "SyncTriggersRemove", self, self.SyncTriggersRemove )
end

function ResourceItems:ModuleLoad()
	Network:Send( "SyncReq", LocalPlayer )
end

function ResourceItems:PostTick()
	if self.timer:GetSeconds() > 1 then
		local playerPosition = LocalPlayer:GetPosition()

		for i = 1, #self.crates do
			if self.crates[i] then
				local ent = StaticObject.GetById( self.crates[i].id )
				if ent and IsValid( ent ) then
					local radius = ent:GetPosition():Distance( playerPosition )
					if radius <= 100 then
						if not ent:GetOutlineEnabled() then
							ent:SetOutlineEnabled( true )
							ent:SetOutlineColor( Color.White )
						end
					else
						if ent:GetOutlineEnabled() then
							ent:SetOutlineEnabled( false )
						end
					end
				end
			end
		end
		self.timer:Restart()
	end
end

function ResourceItems:CrateTaken()
	self.numcrates = self.numcrates + 1

	local sound = ClientSound.Create(AssetLocation.Game, {
		bank_id = 19,
		sound_id = 3,
		position = LocalPlayer:GetPosition(),
		angle = Angle()

	})
	sound:SetParameter(0,1)

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "РУС" then
		Game:ShowPopup( "Ящики: " .. self.numcrates .. "/3754", true )
	else
		Game:ShowPopup( "Resource items: " .. self.numcrates .. "/3754", true )
	end
end

function ResourceItems:SyncTriggers( args )
	for i = 1, #args do
		table.insert( self.crates, { radius = 1, id = args[i].id} )
	end
end

function ResourceItems:SyncTriggersRemove( args )
	for i = 1, #self.crates do
		if self.crates[i] and self.crates[i].id == args.id then
			self.crates[i] = nil
			break
		end
	end
end

resourceitems = ResourceItems()
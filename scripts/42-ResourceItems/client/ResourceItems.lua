class "ResourceItems"

function ResourceItems:__init()
	self.timer = Timer()
	self.numcrates = 0

	self.outline_clr = Color.White

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
				if IsValid( ent ) then
					local radius = ent:GetPosition():Distance( playerPosition )

					if radius <= 100 then
						if not ent:GetOutlineEnabled() then
							ent:SetOutlineEnabled( true )
							ent:SetOutlineColor( self.outline_clr )
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

	local sound = ClientSound.Create( AssetLocation.Game, {
		bank_id = 19,
		sound_id = 3,
		position = LocalPlayer:GetPosition(),
		angle = Angle()

	})
	sound:SetParameter(0,1)

	local lang = LocalPlayer:GetValue( "Lang" )
	Game:ShowPopup( ( ( lang and lang == "RU" ) and "Ящики: " or "Resource items: " ) .. self.numcrates .. "/" .. #self.crates, true )
end

function ResourceItems:SyncTriggers( args )
	for i = 1, #args do
		table.insert( self.crates, { radius = 1, id = args[i].id} )
	end
end

function ResourceItems:SyncTriggersRemove( args )
	for i = 1, #self.crates do
		if self.crates[i] and self.crates[i].id == args.id then
			table.remove( self.crates, i )
			break
		end
	end
end

resourceitems = ResourceItems()
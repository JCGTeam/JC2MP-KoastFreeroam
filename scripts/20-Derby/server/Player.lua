class "Player"

function Player:__init( player )
	self.player = player
	self.playerId = player:GetId()
    self.start_pos = player:GetPosition()
    self.start_world = player:GetWorld()
    self.inventory = player:GetInventory()
    self.health = player:GetHealth()

    self.derbyPosition = nil
    self.derbyAngle = nil
    self.derbyVehicle = nil

    self.hijackCount = 0
end

function Player:Leave()
    self.player:SetWorld( self.start_world )
    self.player:SetNetworkValue( "GameMode", "FREEROAM" )
    self.player:SetPosition( self.start_pos )
    self.player:SetHealth( self.health )

    self.player:ClearInventory()
    for k,v in pairs(self.inventory) do
        self.player:GiveWeapon(k, v)
    end
end
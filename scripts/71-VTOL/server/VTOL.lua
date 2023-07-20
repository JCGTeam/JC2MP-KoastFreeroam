class 'VTOL'

function VTOL:__init()
	Network:Subscribe( "ActivateThrust", self, self.ActivateThrust )
	Network:Subscribe( "ActivateAngularThrust", self, self.ActivateAngularThrust )
end

function VTOL:ActivateThrust( infoTable )
	if IsValid(infoTable.Vehicle) then
		infoTable.Vehicle:SetLinearVelocity(infoTable.Thrust)
	end
end

function VTOL:ActivateAngularThrust( infoTable )
	if IsValid(infoTable.Vehicle) then
		infoTable.Vehicle:SetAngularVelocity(infoTable.Thrust)
	end
end

vtol = VTOL()
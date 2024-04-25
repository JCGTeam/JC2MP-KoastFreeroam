class "Jetpack"

function Jetpack:__init()
	self:initMessages()
	Network:Subscribe( "EnableJetpack", self, self.EnableJetpack )
end

function Jetpack:initMessages()
	self.messages = {}
	self.messages["Prefix"] = "[Реактивный Ранец] "
end

function Jetpack:EnableJetpack( args, sender )
	if sender:GetWorld() ~= DefaultWorld then
        Chat:Send( sender, self.messages["Prefix"], Color.White, sender:GetValue( "Lang" ) == "EN" and "Can't use it here!" or "Невозможно использовать это здесь!", Color.DarkGray )
        return
    end

	sender:SetNetworkValue( "JP", not sender:GetValue( "JP" ) )
end

jetpack = Jetpack()
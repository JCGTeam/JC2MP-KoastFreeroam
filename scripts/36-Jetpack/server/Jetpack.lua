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
        Chat:Send( sender, self.messages["Prefix"], Color.White, sender:GetValue( "Lang" ) == "ENG" and "Can't use it here!" or "Невозможно использовать это здесь!", Color.DarkGray )
        return
    end

	if not sender:GetValue( "JP" ) then
		sender:SetNetworkValue( "JP", true )
	else
		sender:SetNetworkValue( "JP", nil )
	end
end

jetpack = Jetpack()
class 'Menu'

function Menu:__init()
	self.languageslist = { 
        ["RU"] = true,
		["UK"] = true,
		["BY"] = true,
		["KZ"] = true,
		["MD"] = true,
        ["N/A"] = true
    }

	Network:Subscribe( "IsChecked", self, self.IsChecked )

	Network:Subscribe( "SetFreeroam", self, self.SetFreeroam )
	Network:Subscribe( "SetEng", self, self.SetEng )
	Network:Subscribe( "SetRus", self, self.SetRus )
	Network:Subscribe( "Exit", self, self.Exit )
	Network:Subscribe( "GoMenu", self, self.GoMenu )
end

function Menu:IsChecked( args, sender )
	sender:SetNetworkValue( "Warned", 1 )
end

function Menu:SetFreeroam( args, sender )
	sender:SetNetworkValue( "GameMode", "FREEROAM" )
end

function Menu:SetEng( args, sender )
	sender:SetNetworkValue( "Warned", 1 )

	sender:SetNetworkValue( "Lang", "ENG" )

	local pcountry = sender:GetValue( "Country" )

	if sender:GetValue( "Country" ) and self.languageslist[pcountry] then
		Chat:Send( sender, "Welcome to Koast Freeroam! Have a good game :3", Color( 200, 120, 255 ) )
		Chat:Send( sender, "==============", Color( 255, 255, 255 ) )
		Chat:Send( sender, "> Server Menu: ", Color.White, "B", Color.Yellow )
		Chat:Send( sender, "> Actions Menu: ", Color.White, "V", Color.Yellow )
		Chat:Send( sender, "> Server Map: ", Color.White, "F2", Color.Yellow, " / ", Color.White, "M", Color.Yellow )
		Chat:Send( sender, "> Players List: ", Color.White, "F5", Color.Yellow )
		Chat:Send( sender, "==============", Color( 255, 255, 255 ) )
	end
end

function Menu:SetRus( args, sender )
	if sender:GetMoney() <= 1 then
		sender:SetNetworkValue( "Warned", 1 )
	end

	sender:SetNetworkValue( "Lang", "РУС" )

	if sender:GetValue( "Country" ) and sender:GetValue( "Country" ) == "N/A" then
		sender:SetNetworkValue( "Country", "RU" )
	end
end

function Menu:Exit( args, sender )
	sender:Kick()
end

function Menu:GoMenu( args, sender )
	Network:Send( sender, "BackMe" )
end

menu = Menu()
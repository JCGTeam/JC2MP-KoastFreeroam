class 'FontCheck'

function FontCheck:__init()
	self.ModuleLoadEvent = Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Console:Subscribe( "font", self, self.FontToggle )
end

function FontCheck:ModuleLoad()
	self.checkFont = Label.Create()
	self.checkFont:SetFont( AssetLocation.SystemFont, "Impact" )
	self.checkFont:SetVisible( false )
	self.checkFont:SetText( "" )

	self:LoadFonts()
end

function FontCheck:LoadFonts()
	if self.checkFont then self.checkFont:Remove() self.checkFont = nil end
	if self.ModuleLoadEvent then Events:Unsubscribe( self.ModuleLoadEvent ) self.ModuleLoadEvent = nil end

	Network:Send( "ToggleSystemFonts", { enabled = true } )
end

function FontCheck:FontToggle( args )
	local print_txt = "Font set:"

	if args.text == "default" then
		Network:Send( "ToggleSystemFonts", { enabled = nil } )
		print( print_txt .. " " .. "Default" )
	elseif args.text == "server" then
		Network:Send( "ToggleSystemFonts", { enabled = true } )
		print( print_txt .. " " .. "Server" )
	end
end

fontcheck = FontCheck()
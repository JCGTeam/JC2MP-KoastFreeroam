class 'LoadNews'

function LoadNews:__init()
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )

	Network:Subscribe( "LoadNews", self, self.LoadNews )
end

function LoadNews:Lang()
	Network:Send( "GetENGNews" )
end

function LoadNews:ModuleLoad()
	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		Network:Send( "GetRUSNews" )
	end
end

function LoadNews:LoadNews( args )
	Events:Fire( "NewsAddItem", { name = "Новости", text = args.ntext } )
end

function LoadNews:ModuleUnload()
    Events:Fire( "NewsRemoveItem" )
end

loadnews = LoadNews()
class 'LoadNews'

function LoadNews:__init()
	self.ENGNewsFilePath = "newsENG.txt"
	self.RUSNewsFilePath = "newsRUS.txt"

	Network:Subscribe( "GetENGNews", self, self.GetENGNews )
	Network:Subscribe( "GetRUSNews", self, self.GetRUSNews )
end

function LoadNews:GetENGNews( args, sender )
	local getnewsfile = io.open( self.ENGNewsFilePath, "r" )
	if getnewsfile then
		s = getnewsfile:read( "*a" )

		if s then
			Network:Send( sender, "LoadNews", { text = s } )
		end
		getnewsfile:close()
	else
		Network:Send( sender, "LoadNews", { text = "LOAD ERROR\nNews file not found. Path: " .. self.ENGNewsFilePath } )
	end
end

function LoadNews:GetRUSNews( args, sender )
	local getnewsfile = io.open( self.RUSNewsFilePath, "r" )
	if getnewsfile then
		s = getnewsfile:read( "*a" )

		if s then
			Network:Send( sender, "LoadNews", { text = s } )
		end
		getnewsfile:close()
	else
		Network:Send( sender, "LoadNews", { text = "ОШИБКА ЗАГРУЗКИ\nФайл новостей не найден. Путь: " .. self.RUSNewsFilePath } )
	end
end

loadnews = LoadNews()
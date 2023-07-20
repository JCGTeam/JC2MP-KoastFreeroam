class 'Messages'

function Messages:__init()
	Network:Subscribe( "ClientError", self, self.ClientError )

	self.err_prefix = "[Смэрть] "

	Events:Subscribe( "ModuleError", self, self.ModuleError )
	Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
end

function Messages:ClientError( args )
	Events:Fire( "ToDiscordConsole", { text = "**[Error] Client error has occurred! Module: " .. args.moduletxt .. "**" .. "\nERROR CODE:\n```" .. args.errortxt .. "```" } )
end

function Messages:ModuleError( e )
	Chat:Broadcast( self.err_prefix, Color.White, "Произошла критическая ошибка сервера, сообщите администрации!", Color.Red )
	Chat:Broadcast( self.err_prefix, Color.White, "Discord: [empty_link]", Color.Red )
	Chat:Broadcast( self.err_prefix, Color.White, "Steam: [empty_link]", Color.Red )
	Chat:Broadcast( self.err_prefix, Color.White, "VK: [empty_link]", Color.Red )
	Events:Fire( "ToDiscord", { text = "**[Error] Critical server error has occurred! Module: " .. e.module .. "**" })
	Events:Fire( "ToDiscordConsole", { text = "**[Error] Critical server error has occurred! Module: " .. e.module .. "**" .. "\nERROR CODE:\n```" .. e.error .. "```" } )
	for p in Server:GetPlayers() do
		Network:Send( p, "textTw", { error = e.module } )
	end
end

function Messages:ModulesLoad()
	Events:Fire( "ToDiscordConsole", { text = "[Status] Module(s) loaded." } )
end

messages = Messages()

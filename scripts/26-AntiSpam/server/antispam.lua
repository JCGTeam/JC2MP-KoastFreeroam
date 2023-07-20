class "AntiSpam"

function AntiSpam:__init()
	self.kickMessage = "был автоматически кикнут за флуд :("
	self.kickReason = "\n\nВы были отключены системой Анти-Флуд.\n\n" .. 
					"Кикнуло просто так? - Возможо у вас привязаны команды к клавишам. Ипользуйте /unbindall, чтобы отвязать их.\n\n" ..
					"Поддержка в VK - [empty_link]\nПоддержка в Steam - [empty_link]\nПоддержка в Дисководе - [empty_link]"
	self.messageColor = Color( 255, 0, 0 )
	self.maxWarnings = 2
	self.messagesResetInterval = 5
	self.messagesForWarning = 3
	self.warningsResetInterval = 180

	-- Don't touch below this:
	self.messagesSent = { }
	self.playerWarnings = { }
	self.resetTableTick = 0
	self.resetWarningsTick = 0

	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
	Events:Subscribe( "PostTick", self, self.ResetTable )
end

function AntiSpam:PlayerChat( args )
	if ( args.text:len() > 0 ) then
		local steamID = args.player:GetSteamId().id
		if ( not self.messagesSent [ steamID ] ) then
			self.messagesSent [ steamID ] = 1
		elseif ( self.messagesSent [ steamID ] >= self.messagesForWarning ) then
			local warnings = tonumber ( self.playerWarnings [ steamID ] ) or 0
			if ( warnings < self.maxWarnings ) then
				self.playerWarnings [ steamID ] = ( warnings + 1 )
				if args.player:GetValue( "Lang" ) == "ENG" then
					args.player:SendChatMessage ( "[Anti-Flood] ", Color.White, "Please do not flood. Warnings: ".. tostring ( self.playerWarnings [ steamID ] ) .."/".. tostring ( self.maxWarnings ), Color.Yellow )
				else
					args.player:SendChatMessage ( "[Анти-Флуд] ", Color.White, "Пожалуйста, не флудите. Предупреждений: ".. tostring ( self.playerWarnings [ steamID ] ) .."/".. tostring ( self.maxWarnings ), Color.Yellow )
				end
				self.messagesSent [ steamID ] = 0
			else
				args.player:Kick ( self.kickReason )
				Chat:Broadcast ( tostring ( args.player:GetName() ) .." ".. tostring ( self.kickMessage ), self.messageColor )
				self.messagesSent [ steamID ] = nil
				self.playerWarnings [ steamID ] = nil
			end
		else
			self.messagesSent [ steamID ] = ( self.messagesSent [ steamID ] + 1 )
		end
	end
end

function AntiSpam:ResetTable()
	if ( Server:GetElapsedSeconds() - self.resetTableTick >= self.messagesResetInterval ) then
		self.messagesSent = {}
		self.resetTableTick = Server:GetElapsedSeconds()
	end

	if ( Server:GetElapsedSeconds() - self.resetWarningsTick >= self.warningsResetInterval ) then
		self.playerWarnings = {}
		self.resetWarningsTick = Server:GetElapsedSeconds()
	end
end

antispam = AntiSpam()

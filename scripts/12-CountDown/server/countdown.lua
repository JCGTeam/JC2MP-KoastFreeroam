class 'Countdown'

function Countdown:__init()
	self.activeCountdowns = false
	self.countdownTimer = Timer()
	self.secondsToGo = 4
	self.timeOfLastCount = 0
	self.tickSubscription = nil
	self.timeouts = {}
	self.prefix = "[Отсчет] "

	self.countdownMin = 3
	self.countdownMax = 5
	self.countdownDefault = self.countdownMin
	self.playerTimeout = 30

	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function Countdown:PlayerChat( args )
	local msg = args.text
	local player = args.player

	if ( msg:sub(1, 1) ~= "/" ) then
		return true
	end

	local cmdargs = {}
	for word in string.gmatch(msg, "[^%s]+") do
		table.insert(cmdargs, word)
	end

	if (cmdargs[1] == "/cd") then

	if self.activeCountdowns then
		Chat:Send( args.player, self.prefix, Color.White, "Обратный отсчет продолжается.", Color.DarkGray )
		return false
	end

	if cmdargs[2] ~= nil then
		local secondsCommandNumber = tonumber(cmdargs[2])
		if secondsCommandNumber == nil then
			Chat:Send( args.player, self.prefix, Color.White, "Не является доступным числом!", Color.DarkGray )
			return false
		elseif secondsCommandNumber < self.countdownMin or secondsCommandNumber > self.countdownMax then
			Chat:Send( args.player, self.prefix, Color.White, "Вы можете указать только число начиная с " .. self.countdownMin .. " заканчивая " .. self.countdownMax .. " секундами.", Color.DarkGray )
			return false
		end
		self.secondsToGo = secondsCommandNumber
	else
		self.secondsToGo = self.countdownDefault
	end

	local seconds = self.countdownTimer:GetSeconds()

	local timeout = self.timeouts[args.player:GetId()]
	if timeout ~= nil then
		if seconds - timeout < self.playerTimeout then
			Chat:Send( args.player, self.prefix, Color.White, "Вы не можете запустить отсчет в течении: " .. self.playerTimeout .. " секунд!", Color.DarkGray )
			return false
		end
	end

	self.timeouts[args.player:GetId()] = seconds
	self.activeCountdowns = true
	self.timeOfLastCount = 0

	self.tickSubscription = Events:Subscribe( "PreTick", self, self.PreTick )
	Chat:Broadcast( self.prefix, Color.White, player:GetName() .. " запустил отсчет.", Color.DarkGray )
	Events:Fire( "ToDiscordConsole", { text = self.prefix .. player:GetName() .. " запустил отсчет." } )

	return false
	end
end

function Countdown:PreTick( args )
	local milliseconds = self.countdownTimer:GetMilliseconds()
	if milliseconds - self.timeOfLastCount >= 1000 then
		if self.secondsToGo < 0 then
			self.activeCountdowns = false
			if self.tickSubscription ~= nil then Events:Unsubscribe( self.tickSubscription ) end
			return
		end

		self.timeOfLastCount = milliseconds

		if self.secondsToGo > 0 then
			Chat:Broadcast( self.prefix .. "> ", Color.White, tostring(self.secondsToGo), Color.Yellow, " <", Color.White )
		else
			Chat:Broadcast( self.prefix .. "> ", Color.White, "Го!", Color.Yellow, " <", Color.White )
			Events:Unsubscribe(self.tickSubscription)
			self.activeCountdowns = false
		end

		self.secondsToGo = self.secondsToGo - 1
	end
end

countdown = Countdown()
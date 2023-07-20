class 'Victorins'

local rewards = { 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 }

function Victorins:__init()
	self.timer = Timer()
	self.reward = nil
	self.quizAnswer = nil
	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function Victorins:PostTick( args )
	if self.timer:GetMinutes() <= 15 then return end
	local first, second = math.random( 100, 999 ), math.random( 100, 999 )
	self.quizAnswer = first + second
	self.reward = rewards[math.random(#rewards)]

	for p in Server:GetPlayers() do
		if p:GetValue( "Lang" ) == "ENG" then
			p:SendChatMessage( "[Quiz] ", Color.White, "Who first write reply right will get $" .. self.reward .. "!", Color.Yellow )
			p:SendChatMessage( "[Quiz] ", Color.White, first .. " + " .. second .. " = ???", Color.Yellow )
		else
			p:SendChatMessage( "[Викторина] ", Color.White, "Первый, кто напишет ответ - получит $" .. self.reward .. "!", Color.Yellow )
			p:SendChatMessage( "[Викторина] ", Color.White, first .. " + " .. second .. " = ???", Color.Yellow )
		end
	end
	self.timer:Restart()
end

function Victorins:PlayerChat( args )
	if string.find( args.text, tostring( self.quizAnswer ) ) then
		if self.quizAnswer then
			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "ENG" then
					p:SendChatMessage( "[Quiz] ", Color.White, args.player:GetName() .. " the first written right reply, and won $" .. self.reward .. "! Right reply: " .. self.quizAnswer, Color.Yellow )
				else
					p:SendChatMessage( "[Викторина] ", Color.White, args.player:GetName() .. " первым написал правильный ответ, и выиграл $" .. self.reward .. "! Ответ был: " .. self.quizAnswer, Color.Yellow )
				end
			end
		end
		args.player:SetMoney( args.player:GetMoney() + self.reward )
		self.quizAnswer = nil
	end
end

victorins = Victorins()
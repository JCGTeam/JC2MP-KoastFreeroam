class 'Victorins'

function Victorins:__init()
	self.timer = Timer()

	self.rewards = { 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 }

	self.tag_ru = "[Викторина] "
	self.tag_en = "[Quiz] "

	self.text_clr = Color.White
	self.text2_clr = Color.Yellow

	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function Victorins:PostTick()
	if self.timer:GetMinutes() <= 15 then return end

	local first, second = math.random( 100, 999 ), math.random( 100, 999 )
	self.quizAnswer = first + second
	self.reward = self.rewards[math.random(#self.rewards)]

	for p in Server:GetPlayers() do
		if p:GetValue( "Lang" ) == "EN" then
			p:SendChatMessage( self.tag_en, self.text_clr, "Who first write reply right will get $" .. self.reward .. "!", self.text2_clr )
			p:SendChatMessage( self.tag_en, self.text_clr, first .. " + " .. second .. " = ???", self.text2_clr )
		else
			p:SendChatMessage( self.tag_ru, self.text_clr, "Первый, кто напишет ответ - получит $" .. self.reward .. "!", self.text2_clr )
			p:SendChatMessage( self.tag_ru, self.text_clr, first .. " + " .. second .. " = ???", self.text2_clr )
		end
	end
	self.timer:Restart()
end

function Victorins:PlayerChat( args )
	if string.find( args.text, tostring( self.quizAnswer ) ) then
		if self.quizAnswer then
			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "EN" then
					p:SendChatMessage( self.tag_en, self.text_clr, args.player:GetName() .. " the first written right reply, and won $" .. self.reward .. "! Right reply: " .. self.quizAnswer, self.text2_clr )
				else
					p:SendChatMessage( self.tag_ru, self.text_clr, args.player:GetName() .. " первым написал правильный ответ, и выиграл $" .. self.reward .. "! Ответ был: " .. self.quizAnswer, self.text2_clr )
				end
			end
		end
		args.player:SetMoney( args.player:GetMoney() + self.reward )
		self.quizAnswer = nil
	end
end

victorins = Victorins()
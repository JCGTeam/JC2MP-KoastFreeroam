class 'WordFilter'

function WordFilter:__init()
	self.blockedWords = {}

	self:LoadWords( "words.txt" )

	Events:Subscribe( "EnableWF", self, self.EnableWF )
	Events:Subscribe( "DisableWF", self, self.DisableWF )
end

function WordFilter:LoadWords(filename)
	print("Opening " .. filename)

	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "Words.txt were not found" )
		return
	end

	local timer = Timer()

	for line in file:lines() do
		i = i + 1

		if string.sub(filename, 1, 2) ~= "--" then
			self.blockedWords[i] = line
		end
	end

    print( string.format( "Loaded words, %.02f seconds", timer:GetSeconds() ) )

	timer = nil
    file:close()
end

function WordFilter:EnableWF()
	if not self.PlayerChatEvent then
		self.PlayerChatEvent = Events:Subscribe( "PlayerChat", self, self.PlayerChat )
	end
end

function WordFilter:DisableWF()
	if self.PlayerChatEvent then
		Events:Unsubscribe( self.PlayerChatEvent )
		self.PlayerChatEvent = nil
	end
end

function WordFilter:PlayerChat( input )
	local filter = input.text:lower()

	for i, word in ipairs(self.blockedWords) do
		if filter:find(self.blockedWords[i]) then
			input.player:Kick( "[Анти-Спам] Вы не можете употреблять слово " .. "'" .. self.blockedWords[i] .. "' на этом сервере." )
			return false
		end
	end
end

wordfilter = WordFilter()
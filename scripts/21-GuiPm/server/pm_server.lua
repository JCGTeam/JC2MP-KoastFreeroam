class "PM"

function PM:__init()
	self.tag_ru = "[Сообщения] "
	self.tag_en = "[Messages] "
	self.tag2_ru = "[ЛС]"
	self.tag2_en = "[PM]"

	self.tag_clr = Color.White
	self.text_clr = Color.Yellow
	self.text2_clr = Color.DarkGray

	Network:Subscribe( "ChangePmMode", self, self.ChangePmMode )
	Network:Subscribe( "PM.send", self, self.send )

	Events:Subscribe( "PlayerChat", self, self.playerChat )
end

function PM:ChangePmMode( args, sender )
	sender:SetNetworkValue( "PMDistrub", args.dvalue )
end

function PM:send( data, player )
	if IsValid ( data.player ) then
		local pName = player:GetName()
		local pLang = player:GetValue( "Lang" )

		if not data.player:GetValue( "PMDistrub" ) then
			data.player:SendChatMessage ( data.pLang == "EN" and self.tag2_en or self.tag2_ru, self.text_clr, data.pLang == "EN" and " from " or " от ", Color.White, tostring ( pName ), player:GetColor(), ": ".. tostring ( data.text ), self.text_clr )
			player:SendChatMessage ( pLang == "EN" and self.tag2_en or self.tag2_ru, self.text_clr, pLang == "EN" and " to " or " для ", Color.White, ( data.player:GetName() ), data.player:GetColor(), ": ".. tostring ( data.text ), self.text_clr)

			Network:Send ( player, "PM.addMessage", { player = data.player, text = os.date ( "[%X] " ) .. pName .. ": ".. data.text } )
			Network:Send ( data.player, "PM.notification", { msgsender = pName } )
			Network:Send ( data.player, "PM.addMessage", { player = player, text = os.date ( "[%X] " ) .. pName .. ": ".. data.text } )
		else
			player:SendChatMessage ( pLang == "EN" and self.tag_en or self.tag_ru, self.tag_clr, "Игрок в режиме не беспокоить!", self.text2_clr )

			Network:Send ( player, "PM.addMessage", { player = data.player, text = os.date ( "[%X] " ) .. pName .. ": ".. data.text } )
			Network:Send ( data.player, "PM.addMessage", { player = player, text = os.date ( "[%X] " ) .. pName .. ": ".. data.text } )
		end
	else
		player:SendChatMessage ( pLang == "EN" and self.tag_en or self.tag_ru, self.tag_clr, pLang == "EN" and "Player is offline!" or "Игрок не в сети!", self.text2_clr )
	end
end

function PM:playerChat( args )
	local msg = args.text
	local split_msg = msg:split ( " " )

	if ( split_msg [ 1 ] == "/pm" ) then
		local pLang = args.player:GetValue( "Lang" )

		if ( not split_msg [ 2 ] ) then
			args.player:SendChatMessage ( pLang == "EN" and self.tag_en or self.tag_ru, self.tag_clr, pLang == "EN" and "Format: /pm <name> <message>" or "Формат: /pm <имя> <сообщение>", self.text2_clr )
			return
		end

		local results = Player.Match ( split_msg [ 2 ] )
		table.remove ( split_msg, 1 )
		table.remove ( split_msg, 1 )
		local message = table.concat ( split_msg, " " )
		local to = results[ 1 ]

		if ( not to ) then
			args.player:SendChatMessage( pLang == "EN" and self.tag_en or self.tag_ru, self.tag_clr, pLang == "EN" and "Enter a valid player name!" or "Укажите допустимое имя игрока!", self.text2_clr )
			return
		elseif ( to == args.player ) then
			args.player:SendChatMessage( pLang == "EN" and self.tag_en or self.tag_ru, self.tag_clr, pLang == "EN" and "You can't send a message to yourself!" or "Вы не можете отправить сообщение самому себе!", self.text2_clr )
			return
		else
			self:send ( { player = to, text = message }, args.player )
		end
	end
end

pm = PM()
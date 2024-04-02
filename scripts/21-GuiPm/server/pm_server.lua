class "PM"

function PM:__init()
	self.tag_ru = "[Сообщения] "
	self.tag_en = "[Messages] "
	self.tag2_ru = "[ЛС]"
	self.tag2_en = "[PM]"

	Network:Subscribe( "ChangePmMode", self, self.ChangePmMode )
	Network:Subscribe( "PM.send", self, self.send )

	Events:Subscribe( "PlayerChat", self, self.playerChat )
end

function PM:ChangePmMode( args, sender )
	sender:SetNetworkValue( "PMDistrub", args.dvalue )
end

function PM:send( data, player )
	if IsValid ( data.player ) then
		if not data.player:GetValue( "PMDistrub" ) then
			data.player:SendChatMessage ( data.player:GetValue( "Lang" ) == "EN" and self.tag2_en or self.tag2_ru, Color.Yellow, data.player:GetValue( "Lang" ) == "EN" and " from " or " от ", Color.White, tostring ( player:GetName() ), player:GetColor(), ": ".. tostring ( data.text ), Color.Yellow )
			player:SendChatMessage ( player:GetValue( "Lang" ) == "EN" and self.tag2_en or self.tag2_ru, Color.Yellow, player:GetValue( "Lang" ) == "EN" and " to " or " для ", Color.White, ( data.player:GetName() ), data.player:GetColor(), ": ".. tostring ( data.text ), Color.Yellow )

			Network:Send ( player, "PM.addMessage", { player = data.player, text = os.date ( "[%X] " ) .. player:GetName() .. ": ".. data.text } )
			Network:Send ( data.player, "PM.notification", { msgsender = player:GetName() } )
			Network:Send ( data.player, "PM.addMessage", { player = player, text = os.date ( "[%X] " ) .. player:GetName() .. ": ".. data.text } )
		else
			player:SendChatMessage ( player:GetValue( "Lang" ) == "EN" and self.tag_en or self.tag_ru, Color.White, "Игрок в режиме не беспокоить!", Color.DarkGray )

			Network:Send ( player, "PM.addMessage", { player = data.player, text = os.date ( "[%X] " ) .. player:GetName() .. ": ".. data.text } )
			Network:Send ( data.player, "PM.addMessage", { player = player, text = os.date ( "[%X] " ) .. player:GetName() .. ": ".. data.text } )
		end
	else
		player:SendChatMessage ( player:GetValue( "Lang" ) == "EN" and self.tag_en or self.tag_ru, Color.White, player:GetValue( "Lang" ) == "EN" and "Player is offline!" or "Игрок не в сети!", Color.DarkGray )
	end
end

function PM:playerChat( args )
	local msg = args.text
	local split_msg = msg:split ( " " )

	if ( split_msg [ 1 ] == "/pm" ) then
		if ( not split_msg [ 2 ] ) then
			args.player:SendChatMessage ( args.player:GetValue( "Lang" ) == "EN" and self.tag_en or self.tag_ru, Color.White, args.player:GetValue( "Lang" ) == "EN" and "Format: /pm <name> <message>" or "Формат: /pm <имя> <сообщение>", Color.DarkGray )
			return
		end

		local results = Player.Match ( split_msg [ 2 ] )
		table.remove ( split_msg, 1 )
		table.remove ( split_msg, 1 )
		local message = table.concat ( split_msg, " " )
		local to = results[ 1 ]

		if ( not to ) then
			args.player:SendChatMessage( args.player:GetValue( "Lang" ) == "EN" and self.tag_en or self.tag_ru, Color.White, args.player:GetValue( "Lang" ) == "EN" and "Enter a valid player name!" or "Укажите допустимое имя игрока!", Color.DarkGray )
			return
		elseif ( to == args.player ) then
			args.player:SendChatMessage( args.player:GetValue( "Lang" ) == "EN" and self.tag_en or self.tag_ru, Color.White, args.player:GetValue( "Lang" ) == "EN" and "You can't send a message to yourself!" or "Вы не можете отправить сообщение самому себе!", Color.DarkGray )
			return
		else
			self:send ( { player = to, text = message }, args.player )
		end
	end
end

pm = PM()
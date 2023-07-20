class "PM"

function PM:__init()
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
			data.player:SendChatMessage ( "[ЛС]", Color.Yellow, " от ", Color.White, tostring ( player:GetName() ), player:GetColor(), ": ".. tostring ( data.text ), Color.Yellow )
			player:SendChatMessage ( "[ЛС]", Color.Yellow, " для ", Color.White, ( data.player:GetName() ), data.player:GetColor(), ": ".. tostring ( data.text ), Color.Yellow )
			Network:Send ( player, "PM.addMessage", { player = data.player, text = os.date ( "[%X] " ) .. player:GetName() .. ": ".. data.text } )
			Network:Send ( data.player, "PM.notification", { msgsender = player:GetName() } )
			Network:Send ( data.player, "PM.addMessage", { player = player, text = os.date ( "[%X] " ) .. player:GetName() .. ": ".. data.text } )
		else
			player:SendChatMessage ( "[Сообщения] ", Color.White, "Игрок в режиме не беспокоить!", Color ( 255, 0, 0 ) )
			Network:Send ( player, "PM.addMessage", { player = data.player, text = os.date ( "[%X] " ) .. player:GetName() .. ": ".. data.text } )
			Network:Send ( data.player, "PM.addMessage", { player = player, text = os.date ( "[%X] " ) .. player:GetName() .. ": ".. data.text } )
		end
	else
		player:SendChatMessage ( "[Сообщения] ", Color.White, "Игрок не в сети!", Color ( 255, 0, 0 ) )
	end
end

function PM:playerChat( args )
	local msg = args.text
	local split_msg = msg:split ( " " )
	if ( split_msg [ 1 ] == "/pm" ) then
		if ( not split_msg [ 2 ] ) then
			args.player:SendChatMessage ( "[Сообщения] ", Color.White, "Формат: /pm <имя> <сообщение>", Color ( 255, 0, 0 ) )
			return
		end

		local results = Player.Match ( split_msg [ 2 ] )
		table.remove ( split_msg, 1 )
		table.remove ( split_msg, 1 )
		local message = table.concat ( split_msg, " " )
		local to = results [ 1 ]
		if ( not to ) then
			args.player:SendChatMessage( "[Сообщения] ", Color.White, "Укажите допустимое имя игрока!", Color ( 255, 0, 0 ) )
			return
		elseif ( to == args.player ) then
			args.player:SendChatMessage( "[Сообщения] ", Color.White, "Вы не можете отправить сообщение самому себе!", Color ( 255, 0, 0 ) )
			return
		else
			self:send ( { player = to, text = message }, args.player )
		end
	end
end

pm = PM()
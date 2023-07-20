class 'GotoPos'

function GotoPos:__init()
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
	self.prefix = "[Телепорт] "
end

function GotoPos:PlayerChat( args )
    if string.find(args.text, "/gotopos") then
		if args.text == "/gotopos" then
			Chat:Send( args.player, self.prefix, Color.White, "Телепортация по координатам должна быть в формате X, Y, Z.", Color.DarkGray )
			Chat:Send( args.player, self.prefix, Color.White, "Пример использования: /gotopos -11949, 240, 5912", Color.Yellow )
			return false
		end

		local coordString = string.gsub(args.text, "/gotopos ", "")
		local coordTable = coordString:split(",")

		if string.len(coordString) < 3 then
			Chat:Send( args.player, "Телепортация по координатам должна быть в формате X, Y, Z.", Color.DarkGray )
			Chat:Send( args.player, self.prefix, Color.White, "Пример использования: /gotopos -11949, 240, 5912", Color.Yellow )
			return false
		else
			local coordTable = coordString:split(",")
			local xCoord = tonumber(coordTable[1])
			local yCoord = tonumber(coordTable[2])
			local zCoord = tonumber(coordTable[3])

			if xCoord and (xCoord > 16000 or xCoord < -16000) then
				Chat:Send( args.player, self.prefix, Color.White, "Координата X вне допустимого диапазона! (от -16000 до 16000)", Color.DarkGray )
				return false
			elseif yCoord and (yCoord > 4000 or yCoord < 0) then
				Chat:Send( args.player, self.prefix, Color.White, "Координата Y вне допустимого диапазона! (от 0 до 4000)", Color.DarkGray )
				return false
			elseif zCoord and (zCoord > 16000 or zCoord < -16000) then
				Chat:Send( args.player, self.prefix, Color.White, "Координата Z вне допустимого диапазона! (от -16000 до 16000)", Color.DarkGray )
				return false
			end

			local myName = args.player:GetName()

			if xCoord and yCoord and zCoord then
				args.player:SetPosition( Vector3( xCoord, yCoord, zCoord ) )
				Chat:Send( args.player, self.prefix, Color.White, "Вы были успешно телепортированы.", Color.DarkGray )
			else
				Chat:Send( args.player, self.prefix, Color.White, "Не удалось телепортироваться на координаты.", Color.DarkGray )
			end
			return false
		end
    end
    return true
end

gotopos = GotoPos()
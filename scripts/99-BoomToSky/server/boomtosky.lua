class 'BoomToSky'

local warning = "Вы не можете использовать это здесь!"
local inVehicle = "Вы должны находиться внутри транспорта и быть водителем!"

function confirmationMessage( player, message )
	Chat:Send( player, "[Сервер] ", Color.White, message, Color( 124, 242, 0 ) )
end

function deniedMessage( player, message )
	Chat:Send( player, "[Сервер] ", Color.White, message, Color.DarkGray )
end

function BoomToSky:__init()
	Network:Subscribe( "EffectPlay", self, self.EffectPlay )

	Events:Subscribe( "BoomToSky", self, self.BoomToSky )
end

function BoomToSky:EffectPlay( args, sender )
	Network:SendNearby( sender, "BoomToSkyEffect", { targerp = sender } )
end

function BoomToSky:BoomToSky( args )
	if not args.sender and args.player:GetValue( "PVPMode" ) then
		deniedMessage( args.player, "Вы не можете использовать это во время боя!" )
		return
	end

	if args.type == 1 then
		if args.player:GetWorld() ~= DefaultWorld then
			deniedMessage( args.player, warning )
			return
		end

		if not args.player:GetVehicle() or args.player:GetVehicle() and args.player:GetVehicle():GetDriver() == args.player then
			Network:Send( args.player, "StartBoomToSky", { boomvelocity = 100 } )
			if args.sender then
				confirmationMessage( args.player, args.sender:GetName() .. " запустил тебя в небо." )
				confirmationMessage( args.sender, "Вы отправили " .. args.player:GetName() .. " в небо." )
			end
		else
			if not args.sender then
				deniedMessage( args.player, inVehicle )
			else
				deniedMessage( args.sender, "Невозможно отправить " .. args.player:GetName() .. " в небо. Он в тачке и не водитель." )
			end
		end
	elseif args.type == 2 then
		if args.player:GetWorld() ~= DefaultWorld then
			deniedMessage( args.player, warning )
			return
		end

		if not args.player:GetVehicle() or args.player:GetVehicle() and args.player:GetVehicle():GetDriver() == args.player then
			Network:Send( args.player, "StartBoomToSky", { boomvelocity = -100 } )
			if args.sender then
				confirmationMessage( args.player, args.sender:GetName() .. " отправил тебя вниз." )
				confirmationMessage( args.sender, "Вы отправили " .. args.player:GetName() .. " вниз." )
			end
		else
			if not args.sender then
				deniedMessage( args.player, inVehicle )
			else
				deniedMessage( args.sender, "Невозможно отправить " .. args.player:GetName() .. " вниз. Он в тачке и не водитель." )
			end
		end
	end
end

boomtosky = BoomToSky()
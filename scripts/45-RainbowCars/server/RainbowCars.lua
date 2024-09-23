class "RainbowCars"

function RainbowCars:__init()
    self.prefix = "[Радуга] "
    self.plrs = {}

    self.permissions = {
        ["Creator"] = true,
        ["GlAdmin"] = true,
        ["Admin"] = true,
        ["AdminD"] = true,
        ["ModerD"] = true,
        ["Organizer"] = true,
		["Parther"] = true
    }

    Events:Subscribe( "PlayerChat", self, self.PlayerChat )

    for p in Server:GetPlayers() do
        if p:GetValue( "RainbowCar" ) then
            self.plrs[#self.plrs+1] = true
            if not self.PreTickEvent then
                self.rTimer = Timer()

                self.PreTickEvent = Events:Subscribe( "PreTick", self, self.PreTick )
            end
        end
    end
end

function RainbowCars:PlayerChat( args )
    local gettag = args.player:GetValue( "Tag" )

    if self.permissions[gettag] then
        if args.text == "/rnb" then
            if args.player:GetValue( "RainbowCar" ) then
                args.player:SetNetworkValue( "RainbowCar", nil )
                self.plrs[#self.plrs] = nil
                Chat:Send( args.player, self.prefix, Color.White, "Переливание цветов для транспорта отключено.", Color.Pink )
            else
                args.player:SetNetworkValue( "RainbowCar", 1 )
                self.plrs[#self.plrs+1] = true
                Chat:Send( args.player, self.prefix, Color.White, "Переливание цветов для транспорта включено.", Color.Pink )
            end

            if #self.plrs > 0 then
                if not self.PreTickEvent then
                    self.rTimer = Timer()

                    self.PreTickEvent = Events:Subscribe( "PreTick", self, self.PreTick )
                end
            else 
                if self.PreTickEvent then
                    self.rTimer = nil

                    self.PreTickEvent = Events:Unsubscribe( self.PreTickEvent ) self.PreTickEvent = nil
                end
            end
        end
    end
end

function RainbowCars:PreTick()
    local ms = self.rTimer:GetMilliseconds()

    for p in Server:GetPlayers() do
        if p:InVehicle() and p:GetValue( "RainbowCar" ) then
            local h = ( 0.01 * ms - string.len( p:GetName() ) ) * 10
            local color = Color.FromHSV( h % 360, 1, 1 )

            p:GetVehicle():SetColors( color, color )
        end
    end 
end

rainbowcars = RainbowCars()
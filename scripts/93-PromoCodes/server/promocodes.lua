class 'PromoCodes'

function PromoCodes:__init()
    Events:Subscribe( "ClientModuleLoad", self, self.ClientModuleLoad )
    Network:Subscribe( "GetMoney", self, self.GetMoney )
    Console:Subscribe( "setpromocode", self, self.SetPromocode )
end

function PromoCodes:ClientModuleLoad( args )
    if self.promocode then
        Network:Send( args.player, "SetPromoCode", { promocode = self.promocode } )
    end
end

function PromoCodes:GetMoney( args, sender )
    if self.promocode then
        sender:SetMoney( sender:GetMoney() + 10000 )

        local successfully_txt = "PromoCode has been activated. Player: " .. sender:GetName()
        print( successfully_txt )

        Events:Fire( "ToDiscordConsole", { text = successfully_txt } )

        self.promocode = nil
    end
end

function PromoCodes:SetPromocode( args )
    local successfully_txt = "Successfully. PromoCode: " .. args.text

    print( successfully_txt )
    Events:Fire( "ToDiscordConsole", { text = successfully_txt } )

    Network:Broadcast( "SetPromoCode", { promocode = args.text } )

    self.promocode = args.text
end

promocodes = PromoCodes()
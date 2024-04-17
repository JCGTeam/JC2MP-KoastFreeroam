class 'PromoCodes'

function PromoCodes:__init()
    Network:Subscribe( "SetPromoCode", self, self.SetPromoCode )
end

function PromoCodes:SetPromoCode( args )
    if not self.PromoCodeEvent then
        self.PromoCodeEvent = Console:Subscribe( args.promocode, self, self.GetMoney )
    else
        Console:Unsubscribe( self.PromoCodeEvent )
        self.PromoCodeEvent = nil
        self.PromoCodeEvent = Console:Subscribe( args.promocode, self, self.GetMoney )
    end
end

function PromoCodes:GetMoney()
    print( "Промокод успешно активирован." )
    Network:Send( "GetMoney" )

    if self.PromoCodeEvent then Console:Unsubscribe( self.PromoCodeEvent ) self.PromoCodeEvent = nil end
end

promocodes = PromoCodes()
class 'CoinFlip'

function CoinFlip:__init()
    Network:Subscribe( "Coinflip", self, self.Coinflip )

    self.prefix = "[Монетка] "
end

function CoinFlip:Coinflip( args, sender )
    local amount = args.stavka
    if amount == nil then
        sender:SendChatMessage( self.prefix, Color.White, "Это недействительная сумма денег для ставки!", Color.DarkGray )
        return false
    end

    if amount <= 0 then
        Network:Send( sender, "TextBox", { text = "Это недействительная сумма денег для ставки!" } )
        return false
    end

    if amount > CASINO_CONFIGURATION.COINFLIPLIMIT then
        Network:Send( sender, "TextBox", { text = "Вы не можете поставить более $" .. CASINO_CONFIGURATION.COINFLIPLIMIT .. "!" } )
        return false
    end

    if sender:GetMoney() < amount then 
        Network:Send( sender, "TextBox", { text = "У вас недостаточно денег для ставки :c" } )
        return false
    end

    if math.random( 0, 100 ) < CASINO_CONFIGURATION.CHANCE then
        sender:SetMoney( sender:GetMoney() + amount * 2 )

        local wintext = "Вы выиграли "
        if sender:GetValue( "Lang" ) and sender:GetValue( "Lang" ) == "EN" then
            wintext = "You won "
        end

        Network:Send( sender, "TextBox", { text = wintext .. "$" .. formatNumber( amount * 2 ) .. "!", color = Color.Lime } )
    else
        sender:SetMoney( sender:GetMoney() - amount )

        local losetext = "Вы проиграли "
        if sender:GetValue( "Lang" ) and sender:GetValue( "Lang" ) == "EN" then
            losetext = "You lost "
        end

        Network:Send( sender, "TextBox", { text = losetext .. "$" .. formatNumber( amount ) .. "!", color = Color.Red } )
    end
end

coinflip = CoinFlip()
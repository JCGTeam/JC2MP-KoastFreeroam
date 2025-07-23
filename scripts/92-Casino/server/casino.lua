class 'CoinFlip'

function CoinFlip:__init()
    Network:Subscribe("Coinflip", self, self.Coinflip)
    Network:Subscribe("SendRequest", self, self.SendRequest)
    Network:Subscribe("AcceptRequest", self, self.AcceptRequest)
    Network:Subscribe("DestroyLobby", self, self.DestroyLobby)
    Network:Subscribe("UpdateStavka", self, self.UpdateStavka)
    Network:Subscribe("ReadyCoinflip", self, self.ReadyCoinflip)
    Network:Subscribe("FinalReadyCoinflip", self, self.FinalReadyCoinflip)

    self.tag_clr = Color.White
    self.text_clr = Color(255, 250, 150)
    self.text2_clr = Color.DarkGray

    self.tag_ru = "[Казино] "
    self.tag_en = "[Casino] "
end

function CoinFlip:CheckAmount(amount, sender)
    if amount == nil then
        Network:Send(sender, "TextBox", {text = "Это недействительная сумма денег для ставки!"})
        return false
    end

    if amount <= 0 then
        Network:Send(sender, "TextBox", {text = "Это недействительная сумма денег для ставки!"})
        return false
    end

    if amount > CASINO_CONFIGURATION.COINFLIPLIMIT then
        Network:Send(sender, "TextBox", {text = "Вы не можете поставить более $" .. CASINO_CONFIGURATION.COINFLIPLIMIT .. "!"})
        return false
    end

    if sender:GetMoney() < amount then
        Network:Send(sender, "TextBox", {text = "У вас недостаточно денег для ставки :c"})
        return false
    end

    return true
end

function CoinFlip:Coinflip(args, sender)
    local amount = args.stavka

    if not self:CheckAmount(amount, sender) then
        return false
    end

    if math.random(0, 100) < CASINO_CONFIGURATION.CHANCE then
        if args.secondPlayer then
            local secondStavka = args.secondPlayer:GetValue("Stavka")

            sender:SetMoney(sender:GetMoney() + secondStavka)
            args.secondPlayer:SetMoney(args.secondPlayer:GetMoney() - secondStavka)

            Network:Send(sender, "TextBox", {text = (sender:GetValue("Lang") == "EN" and "You won " or "Вы выиграли ") .. "$" .. formatNumber(secondStavka) .. "!", color = Color.Lime})
            Network:Send(args.secondPlayer, "TextBox", {text = (args.secondPlayer:GetValue("Lang") == "EN" and "You lost " or "Вы проиграли ") .. "$" .. formatNumber(secondStavka) .. "!", color = Color.Red})
        else
            sender:SetMoney(sender:GetMoney() + amount * 2)

            Network:Send(sender, "TextBox", {text = (sender:GetValue("Lang") == "EN" and "You won " or "Вы выиграли ") .. "$" .. formatNumber(amount * 2) .. "!", color = Color.Lime})
        end
    else
        if args.secondPlayer then
            sender:SetMoney(sender:GetMoney() - amount)
            args.secondPlayer:SetMoney(args.secondPlayer:GetMoney() + amount)

            Network:Send(sender, "TextBox", {text = (sender:GetValue("Lang") == "EN" and "You lost " or "Вы проиграли ") .. "$" .. formatNumber(amount) .. "!", color = Color.Red})
            Network:Send(args.secondPlayer, "TextBox", {text = (args.secondPlayer:GetValue("Lang") == "EN" and "You won " or "Вы выиграли ") .. "$" .. formatNumber(amount) .. "!", color = Color.Lime})
        else
            sender:SetMoney(sender:GetMoney() - amount)

            Network:Send(sender, "TextBox", {text = (sender:GetValue("Lang") == "EN" and "You lost " or "Вы проиграли ") .. "$" .. formatNumber(amount) .. "!", color = Color.Red})
        end
    end

    if args.secondPlayer then
        Network:Send(args.secondPlayer, "FinishCoinflip")
    end

    Network:Send(sender, "FinishCoinflip")
end

function CoinFlip:SendRequest(args, sender)
    local tag = sender:GetValue("Lang") == "EN" and self.tag_en or self.tag_ru

    sender:SendChatMessage(tag, self.tag_clr, "Приглашение отправлено игроку " .. args.selectedplayer:GetName(), self.text_clr)
    args.selectedplayer:SendChatMessage(tag, self.tag_clr, sender:GetName() .. " приглашает вас в казино. Сыграем?", self.text_clr)
    args.selectedplayer:SendChatMessage(tag, self.tag_clr, "Меню сервера > Развлечения > Казино", self.text2_clr)

    Network:Send(args.selectedplayer, "EnableAccept", sender)
end

function CoinFlip:AcceptRequest(args, sender)
    local tag = sender:GetValue("Lang") == "EN" and self.tag_en or self.tag_ru
    sender:SendChatMessage(tag, self.tag_clr, "Вы приняли приглашение игрока " .. args.selectedplayer:GetName(), self.text_clr)
    args.selectedplayer:SendChatMessage(tag, self.tag_clr, sender:GetName() .. " принял ваше приглашение.", self.text_clr)

    Network:Send(sender, "CreateLobby", {firstPlayer = sender, secondPlayer = args.selectedplayer})
    Network:Send(args.selectedplayer, "CreateLobby", {firstPlayer = args.selectedplayer, secondPlayer = sender})
end

function CoinFlip:DestroyLobby(args, sender)
    Network:Send(sender, "DestroyLobby")

    if args.secondPlayer then
        Network:Send(args.secondPlayer, "DestroyLobby")
    end
end

function CoinFlip:UpdateStavka(args, sender)
    local amount = args.stavka

    if not self:CheckAmount(amount, sender) then
        return false
    end

    Network:Send(sender, "UpdateSecondStavka")

    if args.secondPlayer then
        Network:Send(args.secondPlayer, "UpdateSecondStavka", args.stavka)
    end

    sender:SetValue("Stavka", args.stavka)
end

function CoinFlip:ReadyCoinflip(args, sender)
    Network:Send(sender, "UpdateReady", {isReady = args.isReady, secondPlayer = args.secondPlayer})
    Network:Send(args.secondPlayer, "UpdateReady", {isReady = args.isReady, secondPlayer = sender})
end

function CoinFlip:FinalReadyCoinflip(args, sender)
    Network:Send(sender, "FinalReadyCoinflip")
    Network:Send(args.secondPlayer, "FinalReadyCoinflip")
end

local coinflip = CoinFlip()
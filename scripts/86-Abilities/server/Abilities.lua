class 'Abilities'

function Abilities:__init()
    SQL:Execute( "CREATE TABLE IF NOT EXISTS players_abilities (steamid VARCHAR UNIQUE, wings INTEGER, boost INTEGER, moneybonus INTEGER, morec4 INTEGER, supernuclearbomb INTEGER, longergrapple INTEGER, jesusmode INTEGER)" )

    self.boostValue_1 = 1
    self.boostValue_2 = 2
    self.boostValue_3 = 3

    self.GrappleLongerValue_1 = 150
    self.GrappleLongerValue_2 = 180
    self.GrappleLongerValue_3 = 200
    self.GrappleLongerValue_4 = 250

    Network:Subscribe( "Clear", self, self.Clear )
    Network:Subscribe( "WingsuitUnlock", self, self.WingsuitUnlock )
    Network:Subscribe( "BoostUnlock", self, self.BoostUnlock )
    Network:Subscribe( "MoneyBonusUnlock", self, self.MoneyBonusUnlock )
    Network:Subscribe( "MoreC4Unlock", self, self.MoreC4Unlock )
    Network:Subscribe( "SuperNuclearBombUnlock", self, self.SuperNuclearBombUnlock )
    Network:Subscribe( "LongerGrappleUnlock", self, self.LongerGrappleUnlock )
    Network:Subscribe( "JesusModeUnlock", self, self.JesusModeUnlock )

    Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
end

function Abilities:Clear( args, sender )
    sender:SetNetworkValue( "PlayerLevel", 1 )

    sender:SetNetworkValue( "Boost", nil )
    sender:SetNetworkValue( "Wingsuit", nil )
    sender:SetNetworkValue( "MoneyBonus", nil )
    sender:SetNetworkValue( "MoreC4", nil )
    sender:SetNetworkValue( "SuperNuclearBomb", nil )
    sender:SetNetworkValue( "LongerGrapple", nil )
    sender:SetNetworkValue( "JesusModeEnabled", nil )

    local cmd = SQL:Command( "DELETE FROM players_abilities WHERE steamid = (?)" )
    cmd:Bind( 1, sender:GetSteamId().id )
    cmd:Execute()
end

function Abilities:WingsuitUnlock( args, sender )
    if sender:GetMoney() >= Prices.Wingsuit then
        sender:SetMoney( sender:GetMoney() - Prices.Wingsuit )
        sender:SetNetworkValue( "Wingsuit", 1 )

        self:SaveToDB( args, sender )
        Events:Fire( "SaveLevels" )
    end
end

function Abilities:BoostUnlock( args, sender )
    if not sender:GetValue( "Boost" ) then
        if sender:GetMoney() >= Prices.Boost_1 then
            sender:SetMoney( sender:GetMoney() - Prices.Boost_1 )
            sender:SetNetworkValue( "Boost", self.boostValue_1 )

            self:SaveToDB( args, sender )
            Events:Fire( "SaveLevels" )
        end
    elseif sender:GetValue( "Boost" ) == self.boostValue_1 then
        if sender:GetMoney() >= Prices.Boost_2 then
            sender:SetMoney( sender:GetMoney() - Prices.Boost_2 )
            sender:SetNetworkValue( "Boost", self.boostValue_2 )

            self:SaveToDB( args, sender )
            Events:Fire( "SaveLevels" )
        end
    elseif sender:GetValue( "Boost" ) == self.boostValue_2 then
        if sender:GetMoney() >= Prices.Boost_3 then
            sender:SetMoney( sender:GetMoney() - Prices.Boost_3 )
            sender:SetNetworkValue( "Boost", self.boostValue_3 )

            self:SaveToDB( args, sender )
            Events:Fire( "SaveLevels" )
        end
    end
end

function Abilities:MoneyBonusUnlock( args, sender )
    if sender:GetMoney() >= Prices.BonusMoney then
        sender:SetMoney( sender:GetMoney() - Prices.BonusMoney )
        sender:SetNetworkValue( "MoneyBonus", 1 )

        self:SaveToDB( args, sender )
        Events:Fire( "SaveLevels" )
    end
end

function Abilities:MoreC4Unlock( args, sender )
    if not sender:GetValue( "MoreC4" ) then
        if sender:GetMoney() >= Prices.MoreC4_5 then
            sender:SetMoney( sender:GetMoney() - Prices.MoreC4_5 )
            sender:SetNetworkValue( "MoreC4", 5 )

            self:SaveToDB( args, sender )
            Events:Fire( "SaveLevels" )
        end
    elseif sender:GetValue( "MoreC4" ) == 5 then
        if sender:GetMoney() >= Prices.MoreC4_8 then
            sender:SetMoney( sender:GetMoney() - Prices.MoreC4_8 )
            sender:SetNetworkValue( "MoreC4", 8 )

            self:SaveToDB( args, sender )
            Events:Fire( "SaveLevels" )
        end
    elseif sender:GetValue( "MoreC4" ) == 8 then
        if sender:GetMoney() >= Prices.MoreC4_10 then
            sender:SetMoney( sender:GetMoney() - Prices.MoreC4_10 )
            sender:SetNetworkValue( "MoreC4", 10 )

            self:SaveToDB( args, sender )
            Events:Fire( "SaveLevels" )
        end
    elseif sender:GetValue( "MoreC4" ) == 10 then
        if sender:GetMoney() >= Prices.MoreC4_15 then
            sender:SetMoney( sender:GetMoney() - Prices.MoreC4_15 )
            sender:SetNetworkValue( "MoreC4", 15 )

            self:SaveToDB( args, sender )
            Events:Fire( "SaveLevels" )
        end
    end
end

function Abilities:SuperNuclearBombUnlock( args, sender )
    if sender:GetMoney() >= Prices.SuperNuclearBomb then
        sender:SetMoney( sender:GetMoney() - Prices.SuperNuclearBomb )
        sender:SetNetworkValue( "SuperNuclearBomb", 1 )

        self:SaveToDB( args, sender )
        Events:Fire( "SaveLevels" )
    end
end

function Abilities:LongerGrappleUnlock( args, sender )
    if not sender:GetValue( "LongerGrapple" ) then
        if sender:GetMoney() >= Prices.LongerGrapple_150 then
            sender:SetMoney( sender:GetMoney() - Prices.LongerGrapple_150 )
            sender:SetNetworkValue( "LongerGrapple", self.GrappleLongerValue_1 )

            self:SaveToDB( args, sender )
            Events:Fire( "SaveLevels" )
        end
    elseif sender:GetValue( "LongerGrapple" ) == self.GrappleLongerValue_1 then
        if sender:GetMoney() >= Prices.LongerGrapple_200 then
            sender:SetMoney( sender:GetMoney() - Prices.LongerGrapple_200 )
            sender:SetNetworkValue( "LongerGrapple", self.GrappleLongerValue_2 )

            self:SaveToDB( args, sender )
            Events:Fire( "SaveLevels" )
        end
    elseif sender:GetValue( "LongerGrapple" ) == self.GrappleLongerValue_2 then
        if sender:GetMoney() >= Prices.LongerGrapple_350 then
            sender:SetMoney( sender:GetMoney() - Prices.LongerGrapple_350 )
            sender:SetNetworkValue( "LongerGrapple", self.GrappleLongerValue_3 )

            self:SaveToDB( args, sender )
            Events:Fire( "SaveLevels" )
        end
    elseif sender:GetValue( "LongerGrapple" ) == self.GrappleLongerValue_3 then
        if sender:GetMoney() >= Prices.LongerGrapple_500 then
            sender:SetMoney( sender:GetMoney() - Prices.LongerGrapple_500 )
            sender:SetNetworkValue( "LongerGrapple", self.GrappleLongerValue_4 )

            self:SaveToDB( args, sender )
            Events:Fire( "SaveLevels" )
        end
    end
end

function Abilities:JesusModeUnlock( args, sender )
    if sender:GetMoney() >= Prices.JesusMode then
        sender:SetMoney( sender:GetMoney() - Prices.JesusMode )
        sender:SetNetworkValue( "JesusModeEnabled", 1 )

        self:SaveToDB( args, sender )
        Events:Fire( "SaveLevels" )
    end
end

function Abilities:SaveToDB( args, sender )
    if sender:GetValue( "PlayerLevel" ) and sender:GetValue( "PlayerLevel" ) < 16 then
        sender:SetNetworkValue( "PlayerLevel", sender:GetValue( "PlayerLevel" ) + 1 )
    end

    local cmd = SQL:Command( "insert or replace into players_abilities (steamid, wings, boost, moneybonus, morec4, supernuclearbomb, longergrapple, jesusmode) values (?, ?, ?, ?, ?, ?, ?, ?)" )
    cmd:Bind( 1, sender:GetSteamId().id )
    if sender:GetValue( "Wingsuit" ) then
        cmd:Bind( 2, sender:GetValue( "Wingsuit" ) )
    end
    if sender:GetValue( "Boost" ) then
        cmd:Bind( 3, sender:GetValue( "Boost" ) )
    end
    if sender:GetValue( "MoneyBonus" ) then
        cmd:Bind( 4, sender:GetValue( "MoneyBonus" ) )
    end
    if sender:GetValue( "MoreC4" ) then
        cmd:Bind( 5, sender:GetValue( "MoreC4" ) )
    end
    if sender:GetValue( "SuperNuclearBomb" ) then
        cmd:Bind( 6, sender:GetValue( "SuperNuclearBomb" ) )
    end
    if sender:GetValue( "LongerGrapple" ) then
        cmd:Bind( 7, sender:GetValue( "LongerGrapple" ) )
    end
    if sender:GetValue( "JesusModeEnabled" ) then
        cmd:Bind( 8, sender:GetValue( "JesusModeEnabled" ) )
    end
    cmd:Execute()
end

function Abilities:PlayerJoin( args )
    --args.player:SetNetworkValue( "Boost", 3 )

    local qry = SQL:Query( "select wings, boost, moneybonus, morec4, supernuclearbomb, longergrapple, jesusmode from players_abilities where steamid = (?)" )
    qry:Bind( 1, args.player:GetSteamId().id )
    local result = qry:Execute()

	if #result > 0 then
        args.player:SetNetworkValue( "Wingsuit", tonumber(result[1].wings) )
        args.player:SetNetworkValue( "Boost", tonumber(result[1].boost) )
        args.player:SetNetworkValue( "MoneyBonus", tonumber(result[1].moneybonus) )
        args.player:SetNetworkValue( "MoreC4", tonumber(result[1].morec4) )
        args.player:SetNetworkValue( "SuperNuclearBomb", tonumber(result[1].supernuclearbomb) )
        args.player:SetNetworkValue( "LongerGrapple", tonumber(result[1].longergrapple) )
        args.player:SetNetworkValue( "JesusModeEnabled", tonumber(result[1].jesusmode) )
    end
end

abilities = Abilities()
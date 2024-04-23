class 'Bank'

function Player:SteamId()
    return self:GetSteamId().id
end

function Bank:__init()
    Network:Subscribe( "SendMoney", self, self.SendMoney )

    Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
    Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
    Events:Subscribe( "PlayerMoneyChange", self, self.PlayerMoneyChange )
    Events:Subscribe( "PostTick", self, self.PostTick )
    Events:Subscribe( "ModuleUnload", self, self.CommitChanges )
    Console:Subscribe( "bank", self, self.Console )

    -- Map of player money changes that need to be committed to the database
    self.money_queue    = {}
    -- List of players who have had their first update on join from bank
    self.updated        = {}
    -- Used to determine whether the bank should be updated
    self.timer          = Timer()

    for p in Server:GetPlayers() do
        self:MarkUpdated( p )
    end

    SQL:Execute( "create table if not exists bank_players (steamid VARCHAR UNIQUE, money INTEGER)" )
end

function Bank:SendMoney( args, sender )
    if not args.selectedplayer and not args.money then return end

    local player = Player.GetById( args.selectedplayer )
    local amount = args.money

    if not player then return end

    if not IsValid( player ) then
        Events:Fire( "CastCenterText", { target = sender, text = "Игрок " .. player:GetName() .. " не существует!", time = 3, color = Color.Red } )
        return false
    end

    if player == sender then
        Events:Fire( "CastCenterText", { target = sender, text = "Вы не можете отправить деньги самому себе!", time = 3, color = Color.Red } )
        return false
    end

    if amount == nil then
        Events:Fire( "CastCenterText", { target = sender, text = "Это недействительная сумма денег для отправки!", time = 3, color = Color.Red } )
        return false
    end

    if amount <= 0 then
        Events:Fire( "CastCenterText", { target = sender, text = "Это недействительная сумма денег для отправки!", time = 3, color = Color.Red } )
        return false
    end

    if amount > 10000 then
        Events:Fire( "CastCenterText", { target = sender, text = "Вы не можете отправить более $10.000!", time = 3, color = Color.Red } )
        return false
    end

    if sender:GetMoney() < amount then
        Events:Fire( "CastCenterText", { target = sender, text = "Недостаточно средств для отправки!", time = 3, color = Color.Red } )
        return false
    end

    player:SetMoney( player:GetMoney() + args.money )
    sender:SetMoney( sender:GetMoney() - args.money )

    Events:Fire( "CastCenterText", { target = sender, text = "Успешно отправлено $" .. formatNumber(args.money) .. " игроку " .. player:GetName(), time = 3, color = Color( 0, 255, 0 ) } )
    Events:Fire( "CastCenterText", { target = player, text = "Получено $" .. formatNumber(args.money) .. " от " .. sender:GetName(), time = 3, color = Color( 0, 255, 0 ) } )

    local log_msg = sender:GetName() .. " send " .. tostring( args.money ) .. "$ to " .. player:GetName()
    print( log_msg )
    Events:Fire( "ToDiscordConsole", { text = "[Bank] " .. log_msg } )
end

-- Utility
function Bank:IsUpdated( player )
    return (self.updated[player:SteamId()] == true)
end

function Bank:MarkUpdated( player )
    self.updated[player:SteamId()] = true
end

function Bank:UnmarkUpdated( player )
    self.updated[player:SteamId()] = false
end

function Bank:AddToQueue( player, money )
    if not IsValid(player) then return end

    self.money_queue[player:SteamId()] = money
end

-- Events
function Bank:PlayerJoin( args )
    local qry = SQL:Query( "select money from bank_players where steamid = (?)" )
    qry:Bind( 1, args.player:SteamId() )
    local result = qry:Execute()

    if #result > 0 then
        args.player:SetMoney( tonumber(result[1].money) )
    end

    self:MarkUpdated( args.player )
end

function Bank:PlayerQuit( args )
    self:AddToQueue( args.player, args.player:GetMoney() )
    self:UnmarkUpdated( args.player )
end

function Bank:PlayerMoneyChange( args )
    if self:IsUpdated( args.player ) then
        self:AddToQueue( args.player, args.new_money )
    end
end

function Bank:PostTick()
    if self.timer:GetSeconds() >= 30 then
        self:CommitChanges()
        self.timer:Restart()
    end
end

function Bank:CommitChanges( )
    local count = table.count(self.money_queue)
    if count > 0 then
        print( "Committing " .. tostring(count) .. " changes to db" )
        Events:Fire( "ToDiscordConsole", { text = "[Bank] Committing " .. tostring(count) .. " changes to db" } )

        local transaction = SQL:Transaction()
        do
            for k, v in pairs(self.money_queue) do
                local cmd = SQL:Command( "insert or replace into bank_players (steamid, money) values (?, ?)" )
                cmd:Bind( 1, k )
                cmd:Bind( 2, v )
                cmd:Execute()
            end
        end
        transaction:Commit()

        self.money_queue = {}
    end
end

-- Console event
function Bank:Console( args )
    local cmd_name = args[1]
    table.remove( args, 1 )

    if cmd_name == "list" then
        local result = SQL:Query( "select * from bank_players" ):Execute()

        if #result > 0 then
            for i, v in ipairs(result) do
                print( v.steamid .. ": " .. v.money )
            end
        end
    end
end

bank = Bank()
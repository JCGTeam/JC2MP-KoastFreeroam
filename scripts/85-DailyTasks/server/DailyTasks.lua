class 'DailyTasks'

function DailyTasks:__init()
    SQL:Execute( "DROP TABLE IF EXISTS dedmoroz_tasks" )
    SQL:Execute( "CREATE TABLE IF NOT EXISTS dedmoroz_tasks (steamid VARCHAR UNIQUE, huntkills INTEGER, tronwins INTEGER, tetrisrecord INTEGER, driftrecord INTEGER, flyingrecord INTEGER, bloozing INTEGER, fireworkstossed INTEGER, prize INTEGER)" )

    self.huntkillsneeded = math.random( 2, 10 )
    self.fireworksneeded = math.random( 5, 30 )

    local flyingrecordneeded = { 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 300 }
    self.flyingrecordneeded = flyingrecordneeded[math.random(#flyingrecordneeded)]

    local tetrisrecordneeded = { 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 300, 310, 320, 330, 340, 350, 360, 370, 380, 390, 400, 410, 420, 430, 440, 450, 460, 470, 480, 490, 500 }
    self.tetrisrecordneeded = tetrisrecordneeded[math.random(#tetrisrecordneeded)]

    local driftrecordneeded = { 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 20000, 30000, 40000, 50000, 60000, 70000, 80000, 90000, 100000 }
    self.driftrecordneeded = driftrecordneeded[math.random(#driftrecordneeded)]

    self.tronwinsneeded = math.random( 2, 4 )

    Network:Subscribe( "GetNeededs", self, self.GetNeededs )
    Network:Subscribe( "GetPrize", self, self.GetPrize )

    self:initVars()
    Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
    Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
    Events:Subscribe( "PostTick", self, self.PostTick )
end

function DailyTasks:GetNeededs( args, sender )
    Network:Send( sender, "NewNeededs", { huntkillsneeded = self.huntkillsneeded, fireworksneeded =  self.fireworksneeded, flyingrecordneeded = self.flyingrecordneeded, tetrisrecordneeded = self.tetrisrecordneeded, driftrecordneeded = self.driftrecordneeded, tronwinsneeded = self.tronwinsneeded } )
end

function DailyTasks:GetPrize( args, sender )
    sender:SetMoney( sender:GetMoney() + 10000 )
    sender:SetNetworkValue( "Prize", 0 )

    print( sender:GetName() .. " get $10.000" )
    Events:Fire( "ToDiscordConsole", { text = "[Daily Tasks] " .. sender:GetName() .. " get $10.000" } )
end

function DailyTasks:initVars()
	self.timer = Timer()
	self.delay = 24
end

function DailyTasks:PostTick()
    if self.timer:GetHours() < self.delay then return end
    self.timer:Restart()
    SQL:Execute( "DROP TABLE IF EXISTS dedmoroz_tasks" )
    SQL:Execute( "CREATE TABLE IF NOT EXISTS dedmoroz_tasks (steamid VARCHAR UNIQUE, huntkills INTEGER, tronwins INTEGER, tetrisrecord INTEGER, driftrecord INTEGER, flyingrecord INTEGER, bloozing INTEGER, fireworkstossed INTEGER, prize INTEGER)" )
end

function DailyTasks:PlayerJoin( args )
    local qry = SQL:Query( "select huntkills, tronwins, tetrisrecord, driftrecord, flyingrecord, bloozing, fireworkstossed, prize from dedmoroz_tasks where steamid = (?)" )
    qry:Bind( 1, args.player:GetSteamId().id )
    local result = qry:Execute()

	if #result > 0 then
        args.player:SetNetworkValue( "HuntKills", tonumber(result[1].huntkills) )
        args.player:SetNetworkValue( "TronWins", tonumber(result[1].tronwins) )
        args.player:SetNetworkValue( "TetrisRecord", tonumber(result[1].tetrisrecord) )
        args.player:SetNetworkValue( "DriftRecord", tonumber(result[1].driftrecord) )
        args.player:SetNetworkValue( "FlyingRecord", tonumber(result[1].flyingrecord) )
        args.player:SetNetworkValue( "Bloozing", tonumber(result[1].bloozing) )
        args.player:SetNetworkValue( "FireworksTossed", tonumber(result[1].fireworkstossed) )
        args.player:SetNetworkValue( "Prize", tonumber(result[1].prize) )
    else
        args.player:SetNetworkValue( "HuntKills", 0 )
        args.player:SetNetworkValue( "TronWins", 0 )
        args.player:SetNetworkValue( "TetrisRecord", 0 )
        args.player:SetNetworkValue( "DriftRecord", 0 )
        args.player:SetNetworkValue( "FlyingRecord", 0 )
        args.player:SetNetworkValue( "Bloozing", 0 )
        args.player:SetNetworkValue( "FireworksTossed", 0 )
        args.player:SetNetworkValue( "Prize", 1 )
    end
end

function DailyTasks:PlayerQuit( args )
    local cmd = SQL:Command( "INSERT OR REPLACE INTO dedmoroz_tasks (steamid, huntkills, tronwins, tetrisrecord, driftrecord, flyingrecord, bloozing, fireworkstossed, prize) values (?, ?, ?, ?, ?, ?, ?, ?, ?)" )
    cmd:Bind( 1, args.player:GetSteamId().id )
    if args.player:GetValue( "HuntKills" ) then
        cmd:Bind( 2, args.player:GetValue( "HuntKills" ) )
    end
    if args.player:GetValue( "TronWins" ) then
        cmd:Bind( 3, args.player:GetValue( "TronWins" ) )
    end
    if args.player:GetValue( "TetrisRecord" ) then
        cmd:Bind( 4, args.player:GetValue( "TetrisRecord" ) )
    end
    if args.player:GetValue( "DriftRecord" ) then
        cmd:Bind( 5, args.player:GetValue( "DriftRecord" ) )
    end
    if args.player:GetValue( "FlyingRecord" ) then
        cmd:Bind( 6, args.player:GetValue( "FlyingRecord" ) )
    end
    if args.player:GetValue( "Bloozing" ) then
        cmd:Bind( 7, args.player:GetValue( "Bloozing" ) )
    end
    if args.player:GetValue( "FireworksTossed" ) then
        cmd:Bind( 8, args.player:GetValue( "FireworksTossed" ) )
    end
    if args.player:GetValue( "Prize" ) then
        cmd:Bind( 9, args.player:GetValue( "Prize" ) )
    end
    cmd:Execute()
end

tasks = DailyTasks()
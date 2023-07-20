class 'Version'

function Version:__init()
    self.ver = "N/A"
    self.build = "N/A"

    self:GetVersion()

    Events:Subscribe( "ServerStart", self, self.ServerStart )
    Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
    Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
end

function Version:ServerStart()
    local message = "KMod Version: " .. self.ver .. " | Build: " .. self.build

    print( message )
    Events:Fire( "ToDiscordConsole", { text = "[Status] " .. message } )
end

function Version:PlayerJoin( args )
    self:GetVersion()

    args.player:SetNetworkValue( "KoastBuild", self.ver .. " | Build: " .. self.build )
end

function Version:GetVersion()
    local file = io.open( "version.txt", "r" )
    if file then
        s = file:read( "*a" )

        if s then
            local ver, build = string.match( s, "(.-),%s*(.*)" )
            self.ver = ver or "N/A"
            self.build = build or "N/A"
        end
        file:close()
    else
        print( "Version file not found!" )
    end
end

function Version:ModulesLoad()
    self:GetVersion()

    for p in Server:GetPlayers() do
        if p:GetValue( "KoastBuild" ) then
            if p:GetValue( "KoastBuild" ) ~= self.ver then
                p:SetNetworkValue( "KoastBuild", self.ver .. " | Build: " .. self.build )
            end
        end
    end
end

version = Version()
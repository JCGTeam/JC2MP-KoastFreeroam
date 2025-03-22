class 'ChatAdv'

function ChatAdv:__init()
	self.timer = Timer()
	self.delay = 15

	Network:Subscribe( "GetAds", self, self.GetAds )

	Events:Subscribe( "PostTick", self, self.PostTick )
end

function ChatAdv:GetAds( args, sender )
	local file = io.open( args.file, "r" )

    if file then
        local lines = {}

        for line in file:lines() do
            table.insert( lines, line )
        end

        Network:Send( sender, "LoadAds", lines )

        file:close()
		file = nil

		lines = nil
    end
end

function ChatAdv:PostTick()
	if self.timer:GetMinutes() > self.delay then Network:Broadcast( "SendMessage" ) self.timer:Restart() end
end

chatadv = ChatAdv()
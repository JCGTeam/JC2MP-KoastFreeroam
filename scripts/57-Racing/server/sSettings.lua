settings.debugLevel = 1

settings.raceManager = RaceManagerJoinable
settings.playerFinishRemoveDelay = 12

settings.coursesPath = "Courses/"

settings.statsCommitInterval = 10 -- Seconds

settings.prizeMoneyDefault = 200
settings.prizeMoneyMultiplier = 0.75

settings.collisionChance = 1.0
settings.collisionChanceFunc = function()
	return math.random() >= 1 - settings.collisionChance
end

settings.admins = {
	SteamId("STEAM_0:0:90087002") ,
}
-- If you're using an admin manager script, plug it in here. Or just edit the list above.
settings.GetIsAdmin = function(player)
	return table.find(settings.admins , player:GetSteamId()) ~= nil
end
math.randomseed(os.time())
math.tau = math.pi * 2

Stats = {}
class("CourseCheckpoint")
class("RaceManagerMode")
class("RaceManagerJoinable")

ModuleLoad = function()
    Stats.Init()

    -- Initialize the race manager. If the race manager class has a static initializeDelay variable,
    -- wait for that many seconds.
    if settings.raceManager then
        if settings.raceManager.initializeDelay then
            DelayedFunction(function() raceManager = settings.raceManager() end, settings.raceManager.initializeDelay)
        else
            raceManager = settings.raceManager()
        end
    end
end

Events:Subscribe("ModuleLoad", ModuleLoad)
class("StateFinished")

function StateFinished:__init(race, args)
    EGUSM.SubscribeUtility.__init(self)
    self.race = race
    self.place = args.place

    local message = Utility.NumberToPlaceString(args.place) .. settings.locStrings["place"]
    self.largeMessage = LargeMessage(message, 7.5)

    Events:Fire("RaceFinish")

    self:EventSubscribe("Render")
    self:EventSubscribe("LocalPlayerInput")
    self:NetworkSubscribe("UpdateRacePositions")
    self:NetworkSubscribe("RacerFinish")
end

function StateFinished:End()
    self.largeMessage:Destroy()
    self:Destroy()
end

-- Events

function StateFinished:Render()
    -- Draw GUI.
    if Game:GetState() == GUIState.Game then
        RaceGUI.DrawVersion()

        RaceGUI.DrawCourseName(self.race.course.name)

        RaceGUI.DrawLapCounter {
            courseType = self.race.course.type,
            currentLap = 1,
            totalLaps = self.race.numLaps,
            numCheckpoints = #self.race.course.checkpoints,
            targetCheckpoint = 1,
            isFinished = true
        }

        RaceGUI.DrawRacePosition {
            position = self.place,
            numPlayers = self.race.numPlayers
        }

        RaceGUI.DrawTimers {
            recordTime = self.race.recordTime,
            recordTimePlayerName = self.race.recordTimePlayerName,
            courseType = self.race.course.type,
            previousTime = self.race.lapTimes[#self.race.lapTimes - 1] or nil,
            currentTime = self.race.lapTimes[#self.race.lapTimes]
        }

        RaceGUI.DrawLeaderboard {
            leaderboard = self.race.leaderboard,
            playerIdToInfo = self.race.playerIdToInfo
        }

        RaceGUI.DrawPositionTags {
            leaderboard = self.race.leaderboard
        }

        RaceGUI.DrawMinimapIcons {
            targetCheckpoint = #self.race.course.checkpoints,
            checkpoints = self.race.course.checkpoints,
            courseType = self.race.course.type,
            currentLap = self.race.numLaps,
            numLaps = self.race.numLaps
        }
    end
end

function StateFinished:LocalPlayerInput(args)
    -- Block actions.
    if args.state ~= 0 then
        -- Block racing actions.
        for index, input in ipairs(settings.blockedInputsRacing) do
            if args.input == input then
                return false
            end
        end
        -- Block parachuting if the course disabled it.
        if self.race.course.parachuteEnabled == false and parachuteActions[args.input] then
            return false
        end
        -- Block grappling if the course disabled it or if we're aiming at someone else's vehicle.
        if args.input == Action.FireGrapple then
            local targetEntity = LocalPlayer:GetAimTarget().entity
            local targetEntityType

            if targetEntity then
                targetEntityType = targetEntity.__type
            end

            if self.race.course.grappleEnabled == false or targetEntityType == "Player" or (targetEntityType == "Vehicle" and targetEntity:GetId() ~= self.race.assignedVehicleId) then
                return false
            end
        end
        -- If we're in a vehicle, block some vehicle actions.
        if LocalPlayer:InVehicle() then
            for index, input in ipairs(settings.blockedInputsInVehicle) do
                if args.input == input then
                    return false
                end
            end
        end
    end

    return true
end

-- Network events

function StateFinished:UpdateRacePositions(racePosInfo)
    self.race:UpdateLeaderboard(racePosInfo)
end

function StateFinished:RacerFinish(args)
    local playerId = args[1]
    local place = args[2]

    local player = Player.GetById(playerId)
    if player then
        Game:ShowPopup(player:GetName() .. " заканчивает " .. Utility.NumberToPlaceString(place), place == 1)
    end
end
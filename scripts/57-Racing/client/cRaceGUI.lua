RaceGUI = {}

-- Draw version at the top right.
RaceGUI.DrawVersion = function()
	local textHeight = Render:GetTextHeight("|" , TextSize.Default)
	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end
end

-- Draw small course name at the top.
function RaceGUI.DrawCourseName( courseName )
	local textHeight = Render:GetTextHeight("|" , TextSize.Default)
	DrawText(
		Vector2( 0.5 * Render.Width , textHeight * 3.5 + 1 ) ,
		courseName ,
		settings.textColor2 ,
		TextSize.Default ,
		"center"
	)
end

function RaceGUI.DrawPlayerCount( args )
	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	local textHeight = Render:GetTextHeight("|" , TextSize.Large)
	DrawText(
		Vector2( 0.5 * Render.Width , textHeight * 2 + 1 ) ,
		string.format(settings.racePlayersLabel , args.numPlayers , args.maxPlayers) ,
		settings.textColor ,
		TextSize.Large ,
		"center"
	)
end

-- Draws a 3D arrow at the top of the screen that points to the target checkpoint.
function RaceGUI.DrawTargetArrow( args )
	-- Temporary hack that compensates for the fact that Camera functions return the pos/angle of
	-- the next frame.
	lastCameraPosition = cameraPosition or Vector3.Zero
	cameraPosition = Camera:GetPosition()
	
	-- Calculate position.
	local position = Camera:GetPosition() + Render:ScreenToWorldDirection(NormVector2(0 , -0.65)) * 8.5
	-- Calculate angle.
	local angle = Angle.FromVectors(
		Vector3(0 , 0 , -1) ,
		args.checkpointPosition - LocalPlayer:GetPosition()
	)
	angle.roll = 0
	-- Conditionally render, it blinks when you hit a checkpoint.
	local maxValue = settings.targetArrowFlashNum * settings.targetArrowFlashInterval * 2
	local shouldDraw = (
		args.targetArrowValue == nil or
		args.numTicks == nil or
		args.targetArrowValue == maxValue or
		math.floor(args.numTicks / settings.targetArrowFlashInterval) % 2 == 0
	)
	if shouldDraw and args.model then
		local transform = Transform3()
		transform:Translate(position)
		transform:Rotate(angle)
		Render:SetTransform(transform)
		args.model:Draw()
		Render:ResetTransform()
	end
end

function RaceGUI.DrawLapCounter(args)
	local label
	local count
	local total

	-- If the course is a circuit, draw the laps.
	-- If the course is linear, draw checkpoint counter.
	if args.courseType == "Circuit" then
		label = settings.raceLapLabel
		count = args.currentLap
		total = args.totalLaps
	elseif args.courseType == "Linear" then
		label = settings.raceCPLabel
		count = args.targetCheckpoint - 1
		total = args.numCheckpoints
	end

	if args.isFinished then
		count = total
	end

	-- "Lap/Checkpoint" label
	DrawText(
		NormVector2(settings.lapLabelPos.x , settings.lapLabelPos.y) ,
		label ,
		settings.textColor ,
		settings.lapLabelSize ,
		"center"
	)
	-- Counter (ie "1/3")
	DrawText(
		NormVector2(settings.lapCounterPos.x , settings.lapCounterPos.y) ,
		string.format("%i/%i" , count , total) ,
		settings.textColor2 ,
		settings.lapCounterSize ,
		"center"
	)
end

function RaceGUI.DrawRacePosition(args)
	-- "Pos" label
	DrawText(
		NormVector2(settings.racePosLabelPos.x , settings.racePosLabelPos.y) ,
		settings.racePosLabel ,
		settings.textColor ,
		settings.racePosLabelSize ,
		"center"
	)
	-- Race position (ie "5/21")
	DrawText(
		NormVector2(settings.racePosPos.x , settings.racePosPos.y) ,
		string.format("%i/%i" , args.position , args.numPlayers) ,
		settings.textColor2 ,
		settings.racePosSize ,
		"center"
	)
end

function RaceGUI.DrawTimers(args)
	local currentY = settings.timerLabelsStart.y
	local advanceY = Render:GetTextHeight("|" , settings.timerLabelsSize) / (Render.Size.y) * 2
	local leftX = (
		settings.timerLabelsStart.x -
		(Render:GetTextWidth("-00:00:00" , settings.timerLabelsSize) / Render.Width) * 2
	)
	
	local AddLine = function(label , value)
		DrawText(
			NormVector2(leftX , currentY) ,
			label ,
			settings.textColor ,
			settings.timerLabelsSize ,
			"right"
		)
		DrawText(
			NormVector2(settings.timerLabelsStart.x , currentY) ,
			value ,
			settings.textColor2 ,
			settings.timerLabelsSize ,
			"right"
		)
		currentY = currentY + advanceY
	end
	
	AddLine(
		args.recordTimePlayerName..":" ,
		Utility.LapTimeString(args.recordTime)
	)
	
	if args.courseType == "Circuit" and args.previousTime then
		AddLine(settings.PreviousLabel , Utility.LapTimeString(args.previousTime))
	end
	if args.currentTime then
		AddLine(settings.CurrentLabel , Utility.LapTimeString(args.currentTime))
	end
end

function RaceGUI.DrawLeaderboard(args)
	local currentPos = Vector2( (Render.Width - 90), 80 )
	local charWidth = Render:GetTextWidth("W" , settings.leaderboardTextSize)
	local charHeight = Render:GetTextHeight("W" , settings.leaderboardTextSize)
	
	for n = 1 , math.min(#args.leaderboard , settings.leaderboardMaxPlayers) do
		local playerId = args.leaderboard[n].playerId
		local isFinished = args.leaderboard[n].isFinished
		local playerInfo = args.playerIdToInfo[playerId]
		local playerName = playerInfo.name
		
		-- Clamp their name length.
		playerName = playerName:sub(1 , settings.maxPlayerNameLength)
		local playerNameWidth = Render:GetTextWidth(playerName , settings.leaderboardTextSize)
		
		local currentX = 0
		
		DrawText(
			currentPos + Vector2( charHeight * 4 , 0 ) ,
			Utility.NumberToPlaceString(n) ,
			settings.textColor ,
			settings.leaderboardTextSize ,
			"right"
		)
		currentX = currentX + charWidth * 2.25
		DrawText(
			currentPos + Vector2( charHeight * 1 , 0 ) ,
			string.format("%s", playerName) ,
			playerInfo.color ,
			settings.leaderboardTextSize ,
			"right"
		)
		currentX = currentX + playerNameWidth
		-- If this is us, point out our name with arrows.
		if playerId == LocalPlayer:GetId() then
			DrawText(
				currentPos + Vector2( charHeight * 2 , 0 ) ,
				"<" ,
				settings.textColor ,
				settings.leaderboardTextSize ,
				"right"
			)
		end
		
		currentPos.y = currentPos.y + charHeight + 2
	end
end

function RaceGUI.DrawPositionTags(args)
	for index , entry in ipairs(args.leaderboard) do
		if entry.playerId ~= LocalPlayer:GetId() then
			RaceGUI.DrawPositionTag(entry.playerId , index)
		end
	end
end

function RaceGUI.DrawMinimapIcons(args)
	for n = 1 , #args.checkpoints do
		local pos , success = Render:WorldToMinimap(args.checkpoints[n][1])
		if success then
			
			pos = Vector2(math.floor(pos.x + 0.5) , math.floor(pos.y + 0.5))
			local nextCheckpoint = args.targetCheckpoint + 1
			-- Check if target checkpoint is the start/finish.
			if args.targetCheckpoint == #args.checkpoints then
				-- If this is the last lap, don't draw CP after it.
				if args.courseType == "Circuit" and args.currentLap >= args.numLaps then
					nextCheckpoint = 0
				else
					nextCheckpoint = 1
				end
			end
			if n == args.targetCheckpoint then
				Minimap.DrawTargetCheckpoint(pos)
			elseif n == nextCheckpoint then
				Minimap.DrawNextTargetCheckpoint(pos)
			else
				Minimap.DrawGreyCheckpoint(pos)
			end
			
		end
	end
end

-- Draws position tag above someone. ("1st", for example)
function RaceGUI.DrawPositionTag(playerId , position)
	local worldPos
	
	local player = Player.GetById(playerId)
	if not IsValid(player) then
		return
	end
	
	local worldPos = player:GetBonePosition("ragdoll_Head") + 
	(player:GetAngle() * Vector3( 0, 0.68, 0 ))
	local screenPos , onScreen = Render:WorldToScreen(worldPos)
	if not onScreen then
		return
	end
	screenPos = screenPos + Vector2(0 , -24)
	
	local size = TextSize.Default
	
	local scale = 1
	if position == 1 then
		scale = 1.25
	end
	
	DrawText(
		screenPos ,
		Utility.NumberToPlaceString(position) ,
		player:GetColor() ,
		size ,
		"center" ,
		scale
	)
end

function RaceGUI.DrawNextCheckpointArrow(args)
	-- Don't draw for finish lines.
	if args.targetCheckpoint == #args.checkpoints then
		if args.courseType == "Linear" then
			return
		elseif
			args.courseType == "Circuit" and
			args.numLaps == args.currentLap
		then
			return
		end
	end
	
	local nextCheckpointIndex = args.targetCheckpoint + 1
	-- Check if target checkpoint is the start/finish.
	if
		args.courseType == "Circuit" and
		args.targetCheckpoint == #args.checkpoints
	then
		nextCheckpointIndex = 1
	end
	
	local cpTarget = args.checkpoints[args.targetCheckpoint][1]
	local cpNext = args.checkpoints[nextCheckpointIndex][1]
	
	local angle = Angle.FromVectors(
		Vector3(0 , 0 , -1) ,
		(cpNext - cpTarget):Normalized()
	)
	angle.roll = 0
	
	local triangles = Models.nextCPArrowTriangles
	
	local distance = Vector3.Distance(Camera:GetPosition() , cpTarget)
	
	local color = Copy(settings.nextCheckpointArrowColor)
	local alpha = (140 - distance) / 140 -- From 0 to 1
	alpha = 1 - alpha -- magic
	alpha = alpha ^ 4
	alpha = 1 - alpha
	alpha = alpha * 512 -- From 0 to 512
	alpha = math.clamp(alpha , 0 , color.a) -- From 0 to color's alpha.
	
	local dotMod = Vector3.Dot(
		(cpTarget - Camera:GetPosition()):Normalized() ,
		(cpNext - cpTarget):Normalized()
	)
	dotMod = math.clamp(dotMod , 0 , 1) ^ 1.5 -- 0 to 1
	dotMod = math.clamp(dotMod - 0.6 , 0 , 0.4) -- 0 to 0.4
	dotMod = dotMod * 2.5 -- 0 to 1
	dotMod = 1 - dotMod -- 0 to 1
	
	color.a = alpha * dotMod
	
	local pos = cpTarget + Vector3(0 , 1.5 , 0)
	
	for n = 1 , #triangles do
		Render:FillTriangle(
			angle * triangles[n][1] + cpTarget ,
			angle * triangles[n][2] + cpTarget ,
			angle * triangles[n][3] + cpTarget ,
			color
		)
	end
end

function RaceGUI.DrawRaceProgress(args)
	local percent = (args.currentCheckpoint / args.checkpointCount) * 100
	local text = string.format("Прогресс гонки: %i%%" , percent)
	
	DrawText(
		NormVector2(0 , -0.75) ,
		text ,
		settings.textColor ,
		24 ,
		"center"
	)
end

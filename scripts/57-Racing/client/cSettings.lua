math.randomseed(os.time())
math.random()

settings.debugLevel = 1

settings.countDownNumMessages = 3
settings.countDownInterval = 2

settings.blockedInputsRacing = {
	Action.FireLeft , -- Blocks firing weapons on foot.
	Action.FireRight , -- Blocks firing weapons on foot.
	Action.McFire , -- Blocks firing one-handed weapons on bike/ATV.
	Action.VehicleFireLeft , -- Blocks firing vehicle weapons.
	Action.VehicleFireRight , -- Blocks firing vehicle weapons.
	Action.NextWeapon , -- Blocks switching weapons.
	Action.PrevWeapon , -- Blocks switching weapons.
}
settings.blockedInputsStartingGrid = {
	Action.FireLeft ,
	Action.FireRight ,
	Action.McFire ,
	Action.VehicleFireLeft ,
	Action.VehicleFireRight ,
	Action.NextWeapon ,
	Action.PrevWeapon ,
	Action.Reverse ,
	Action.HeliIncAltitude ,
	Action.HeliDecAltitude ,
	Action.PlaneIncTrust ,
	Action.PlaneDecTrust ,
}
settings.blockedInputsStartingGridOnFoot = {
	Action.FireLeft ,
	Action.FireRight ,
	Action.NextWeapon ,
	Action.PrevWeapon ,
	Action.MoveForward ,
	Action.MoveBackward ,
	Action.MoveLeft ,
	Action.MoveRight ,
	Action.FireGrapple ,
	Action.Jump ,
	Action.Evade ,
	Action.Kick ,
}
settings.blockedInputsInVehicle = {
	Action.StuntJump ,
	Action.ParachuteOpenClose ,
}

-- Make sure everyone doesn't send their distance at the same time.
settings.sendCheckpointDistanceInterval = 0.4 + math.random() * 0.027

settings.motdText =
	"Добро пожаловать в гонки!\n"..
	"Вы можете ввести /"..tostring(settings.command).." в чате, чтобы открыть это меню."

settings.gamemodeName = "Гонки"
settings.gamemodeDescription = [====[Введите /race, чтобы зайти в меню гонок]====]

----------------------------------------------------------------------------------------------------
-- GUI
----------------------------------------------------------------------------------------------------

settings.shadowColor = Color( 25, 25, 25, 150 )
settings.textColor = Color( 255, 255, 255, 250 )
settings.textColor2 = Color( 165, 165, 165, 250 )
settings.winColor = Color( 185, 215, 255 )

settings.targetArrowFlashNum = 3
settings.targetArrowFlashInterval = 7

settings.nextCheckpointArrowColor = Color(228 , 142 , 56 , 128)

-- Normalized positions.
settings.lapLabelPos = Vector2( 0.33 , -0.68 )
settings.lapLabelSize = 30
settings.lapCounterPos = Vector2( 0.33 , -0.58 )
settings.lapCounterSize = 35

settings.racePosLabel = "Позиция"
settings.racePosLabelPos = Vector2( -0.33 , -0.68 )
settings.racePosLabelSize = 30
settings.racePosPos = Vector2( -0.33 , -0.58 )
settings.racePosSize = 35

settings.raceLapLabel = "Круг"

settings.raceCPLabel = "Чекпоинты"

settings.PreviousLabel = "Предыдущий:"

settings.CurrentLabel = "Текущий:"

settings.racePlayersLabel = "Игроки: %s/%s"

settings.timerLabelsStart = Vector2( 0.95 , -0.39 )
settings.timerLabelsSize = TextSize.Default

settings.minimapCheckpointColor1 = Color( 245, 25, 19 )
settings.minimapCheckpointColor2 = Color( 245, 100 ,19, 112 )
settings.minimapCheckpointColorGrey1 = Color( 180, 170, 150 ) -- Inside
settings.minimapCheckpointColorGrey2 = Color( 130, 70, 60, 220 ) -- Border

-- Normalized.
settings.leaderboardPos = Vector2(-0.95 , -0.39)
settings.leaderboardTextSize = TextSize.Default
settings.leaderboardMaxPlayers = 8
settings.maxPlayerNameLength = 16

settings.largeMessageTextSize = TextSize.Huge
settings.largeMessageBlendRatio = 0.1
settings.largeMessagePos = Vector2( 0 , -0.2 )

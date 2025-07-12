settings = {}
local S = settings

S.name = "Jet HUD"

S.colorHUD = Color(10, 255, 4) -- Green
-- S.colorHUD = Color(240 , 12 , 5) -- red

S.colorChat = Color(160, 220, 150)

-- Distance in front of the player the hud is drawn in 3D.
S.distanceHUD = 50
-- Scales all hud elements.
S.scaleHUD = 0.5

-- km/h or m/s
S.useKPH = true

S.clampPitch = math.rad(89.0)

-- All military jets.
-- S.supportedVehicles = {24 , 30 , 34}
-- All air vehicles.
S.supportedVehicles = {3, 14, 24, 30, 34, 37, 39, 51, 57, 59, 62, 64, 65, 67, 81, 85}
do
    -- Translate table supportedVehicles from an array into a map.
    local supportedVehiclesOld = S.supportedVehicles

    S.supportedVehicles = {}

    for index, modelId in ipairs(supportedVehiclesOld) do
        S.supportedVehicles[modelId] = true
    end
end
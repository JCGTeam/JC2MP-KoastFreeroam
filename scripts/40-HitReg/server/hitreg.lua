class 'HitReg'

function HitReg:__init()
    self.explodedVehicles = {}
    self.damage = {
        [2] = .0075,
        [4] = .075,
        [5] = .0045,
        [6] = .17,
        [13] = .25,
        [11] = .075,
        [14] = .3334,
        [26] = .25,
        [28] = .03,
        [43] = 0.00001,
        [100] = .15,
        [103] = .2,
        [129] = .3
    }

    Events:Subscribe("PostTick", self, self.PostTick)
    Network:Subscribe("Shoot", self, self.Shoot)
end

function HitReg:PostTick()
    local currentTime = os.time()
    local removedIndices = {}

    for i, vehicleInfo in ipairs(self.explodedVehicles) do
        local vehicle = vehicleInfo.vehicle
        local explosionTime = vehicleInfo.explosionTime

        if currentTime - explosionTime >= Config:GetValue("Vehicle", "DeathRespawnTime") then
            if IsValid(vehicle) then
                vehicle:Respawn()
            end

            table.insert(removedIndices, i)
        end
    end

    for i = #removedIndices, 1, -1 do
        table.remove(self.explodedVehicles, removedIndices[i])
    end
end

function HitReg:Shoot(args, player)
    if not args.target then return end
    if args.target:GetWorld() ~= DefaultWorld then return end
    if args.target:GetDriver() then return end

    local distance = Vector3.Distance(args.target:GetPosition(), player:GetPosition()) * 0.01
    local myWeapon = args.weapon
    local targetHealth = args.target:GetHealth()

    if not self.damage[myWeapon] then
        self.damage[myWeapon] = 0
    end

    args.target:SetHealth(targetHealth - ((1 - distance) * self.damage[myWeapon]))

    if targetHealth <= 0.2 and args.target.__type == "Vehicle" then
        local alreadyExploded = false

        for _, vehicleInfo in ipairs(self.explodedVehicles) do
            if vehicleInfo and vehicle and vehicleInfo.vehicle and vehicleInfo.vehicle == args.target then
                alreadyExploded = true
                break
            end
        end

        if not alreadyExploded then
            table.insert(self.explodedVehicles, {vehicle = args.target, explosionTime = os.time()})
        end
    end
end

local hitreg = HitReg()
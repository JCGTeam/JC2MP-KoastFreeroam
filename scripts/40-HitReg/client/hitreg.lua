class 'HitReg'

function HitReg:__init()
    self.cooldownTable = { [2] = 400, [4] = 2000, [5] = 15, [6] = 1500, [11] = 250, [13] = 1750, [14] = 6500, [26] = 250, [28] = 150, [43] = 15, [100] = 250, [103] = 1000, [129] = 250 }
    self.continuousFireTable = { [11] = true, [5] = true, [26] = true, [43] = true, [28] = true }

    self.myTimer = Timer()
    self.animTimer = Timer()

    if LocalPlayer:GetWorld() == DefaultWorld then
        self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
        self.MouseUpEvent = Events:Subscribe( "MouseUp", self, self.MouseUp )
	end

    Events:Subscribe( "LocalPlayerWorldChange", self, self.LocalPlayerWorldChange )
end

function HitReg:LocalPlayerWorldChange( args )
    if args.new_world == DefaultWorld then
        if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end
        if not self.MouseUpEvent then self.MouseUpEvent = Events:Subscribe( "MouseUp", self, self.MouseUp ) end
    else
        if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
        if self.MouseUpEvent then Events:Unsubscribe( self.MouseUpEvent ) self.MouseUpEvent = nil end
    end
end

function HitReg:Fire()
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    local myWeapon = LocalPlayer:GetEquippedWeapon()
    local cooldownTime = self.cooldownTable[myWeapon.id]

    if not cooldownTime then
        cooldownTime = 1000
    end

    local results = LocalPlayer:GetAimTarget()

    if self.myTimer:GetMilliseconds() > cooldownTime then
        self.animTimer:Restart()
        self.myTimer:Restart()

        if results.entity then
			if results.entity.__type == "Vehicle" then
				if myWeapon.ammo_clip > 0 then
					local args = {}
                    args.weapon = myWeapon.id
                    args.target = results.entity
                    args.aimPosition = results.position
                    args.closest = 1

					Network:Send( "Shoot", args )
				end
			end
		end
	end
end

function HitReg:LocalPlayerInput( args )
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    if args.input == Action.FireRight or args.input == Action.FireLeft or args.input == Action.McFire then
        local ubs = LocalPlayer:GetUpperBodyState()

        if ubs == 347 or ubs == 377 or ubs == 346 then
            if self.continuousFireTable[LocalPlayer:GetEquippedWeapon().id] then
                self:Fire()
            else
                if not self.isFiring then
                    self:Fire()
                    self.isFiring = true
                end
            end
        end
    end
end

function HitReg:MouseUp( args )
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    if args.button == 1 or args.button == 2 then
        if self.isFiring then
            self.isFiring = nil
        end
    end
end

hitreg = HitReg()
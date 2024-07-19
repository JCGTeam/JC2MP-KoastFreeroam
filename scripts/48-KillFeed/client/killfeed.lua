class 'Killfeed'

function Killfeed:__init()
	self.list = {}
	self.removal_time = 18

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self:CreateKillStringsRUS()
	end

	Network:Subscribe( "PlayerDeath", self, self.PlayerDeath )

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "Render", self, self.Render )
end

function Killfeed:Lang()
	self:CreateKillStringsENG()
end

function Killfeed:PlayerDeath( args )
	if not IsValid( args.player ) then return end
	local reason = args.reason

	if args.killer then
		if not self.killer_msg[reason] then
			reason = DamageEntity.None
		end
	else
		if not self.no_killer_msg[reason] then
			reason = DamageEntity.None
		end
	end

	if args.killer then
		args.message = string.format( self.killer_msg[reason][args.id], args.player:GetName(), args.killer:GetName() )

		args.killer_name   = args.killer:GetName()
		args.killer_colour = args.killer:GetColor()
	else
		args.message = string.format( self.no_killer_msg[reason][args.id], args.player:GetName() )
	end

	args.player_name   = args.player:GetName()
	args.player_colour = args.player:GetColor()

	args.time = os.clock()

	table.insert( self.list, args )
end

function Killfeed:CreateKillStringsRUS()
	self.no_killer_msg = {
		[DamageEntity.None] = { 
			"%s умер от инфаркта",
			"%s отдал душу дьяволу",
			"%s скопытился"
		},

		[DamageEntity.Physics] = { 
			"%s помер",
			"%s ушатался",
			"%s чет сдох"
		},

		[DamageEntity.Bullet] = { 
			"%s застрелен",
			"%s был смертельно ранен",
			"%s поймал маслину"
		},

		[DamageEntity.Explosion] = { 
			"%s взорвался",
			"%s подорвался",
			"%s сделал бум!"
		},

		[DamageEntity.Vehicle] = {
			"%s забыл надеть ремень безопасности",
			"%s попал под машину",
			"%s сделал селфи за рулем"
		}
	}

	self.killer_msg = {
		[DamageEntity.None] = { 
			"%s каким-то образом убит %s",
			"%s тронут магией %s",
			"%s поздоровался с %s"
		},

		[DamageEntity.Physics] = { 
			"%s был убит %s",
			"%s получил леща %s",
			"%s встретился с %s"
		},

		[DamageEntity.Bullet] = { 
			"%s был убит %s",
			"%s был измельчен %s",
			"%s поймал маслину от %s"
		},

		[DamageEntity.Explosion] = { 
			"%s подорван %s",
			"%s оснащен взрывами %s",
			"%s взорван %s"
		},

		[DamageEntity.Vehicle] = {
			"%s поцеловал бампер %s",
			"%s попал в ярость дороги %s",
			"%s сбит %s"
		}
	}
end

function Killfeed:CreateKillStringsENG()
	self.no_killer_msg = {
		[DamageEntity.None] = { 
			"%s got a heart attack",
			"%s sold his soul to the devil",
			"%s is dead"
		},

		[DamageEntity.Physics] = { 
			"%s died",
			"%s didn't learn physics very well",
			"%s fell from a high place"
		},

		[DamageEntity.Bullet] = { 
			"%s was shot",
			"%s was brutally murdered",
			"%s was one-tapped, ez"
		},

		[DamageEntity.Explosion] = { 
			"%s exploded",
			"%s blew up",
			"%s bought expired fireworks"
		},

		[DamageEntity.Vehicle] = {
			"%s was roadraged",
			"%s was hit by a vehicle",
			"%s didn't look around"
		}
	}

	self.killer_msg = {
		[DamageEntity.None] = { 
			"%s was somehow killed by %s",
			"%s was touched by the magic of %s",
			"%s said hello to %s"
		},

		[DamageEntity.Physics] = { 
			"%s was killed by %s",
			"%s was slapped by %s",
			"%s met physics, and its messenger was %s"
		},

		[DamageEntity.Bullet] = { 
			"%s was killed by %s",
			"%s was clapped by %s",
			"%s got headshot from %s"
		},

		[DamageEntity.Explosion] = { 
			"%s was blowed up by %s",
			"%s was undermined by %s",
			"%s was exploded by %s"
		},

		[DamageEntity.Vehicle] = {
			"%s was run over by %s",
			"%s got caught in a roadrage by %s",
			"%s was killed in a carmageddon by %s"
		}
	}
end

function Killfeed:CalculateAlpha( time )
	local difftime = os.clock() - time
	local removal_time_gap = self.removal_time - 1

	if difftime < removal_time_gap then
		return 255
	elseif difftime >= removal_time_gap and difftime < self.removal_time then
		local interval = difftime - removal_time_gap
		return 255 * (1 - interval)
	else
		return 1
	end
end

function Killfeed:Render()
	if Game:GetState() ~= GUIState.Game then return end
	if not LocalPlayer:GetValue( "KillFeedVisible" ) or LocalPlayer:GetValue( "HiddenHUD" ) then return end

	local center_hint = Vector2( Render.Width - 25, Render.Height / 4.8 )
	local height_offset = 0

	for i,v in ipairs( self.list ) do
		if os.clock() - v.time < self.removal_time then
			local text_width = Render:GetTextWidth( v.message )
			local text_height = Render:GetTextHeight( v.message )

			local pos = center_hint + Vector2( -text_width, height_offset )
			local alpha = self:CalculateAlpha( v.time )

			local color = Color( 255, 255, 255, alpha )
			local shadow = Color( 20, 20, 20, alpha * 0.5 )

			Render:DrawShadowedText( pos, v.message, color, shadow )

			local player_colour = v.player_colour
			player_colour.a = alpha

			Render:DrawText( pos, v.player_name, player_colour )

			if v.killer_name then
				local killer_colour = v.killer_colour
				killer_colour.a = alpha
				local name_text = v.killer_name
				local name_width = Render:GetTextWidth( name_text )

				Render:DrawText( center_hint + Vector2( -name_width, height_offset ), v.killer_name, killer_colour )
			end

			height_offset = height_offset + text_height + 4
		else
			table.remove( self.list, i )
		end
	end
end

killfeed = Killfeed()
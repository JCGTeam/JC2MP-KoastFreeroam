class 'AchievementUnlock'

function AchievementUnlock:__init()
	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.tag = "[Достижения] "
		self.unlocktext = " получил достижение "
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "PlayerAchievementUnlock", self, self.PlayerAchievementUnlock )
end

function AchievementUnlock:Lang()
	self.tag = "[Achievements] "
	self.unlocktext = " has unlocked the achievement "
end

function AchievementUnlock:PlayerAchievementUnlock( args )
	Chat:Print( self.tag, Color.White, args.player:GetName(), args.player:GetColor(), self.unlocktext, Color.White, args.name, Color( 255, 215, 0 ) )
	return false
end

achievementunlock = AchievementUnlock()
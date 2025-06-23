class 'AchievementUnlock'

function AchievementUnlock:__init()
	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.locStrings = {
			tag = "[Достижения] ",
			unlock = " получил достижение "
		}
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "PlayerAchievementUnlock", self, self.PlayerAchievementUnlock )
end

function AchievementUnlock:Lang()
	self.locStrings = {
		tag = "[Achievements] ",
		unlock = " has unlocked the achievement "
	}
end

function AchievementUnlock:PlayerAchievementUnlock( args )
	Chat:Print( self.locStrings["tag"], Color.White, args.player:GetName(), args.player:GetColor(), self.locStrings["unlock"], Color.White, args.name, Color( 255, 215, 0 ) )
	return false
end

achievementunlock = AchievementUnlock()
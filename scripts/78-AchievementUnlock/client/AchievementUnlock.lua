class 'AchievementUnlock'

function AchievementUnlock:__init()
	self.unlocktext = " получил достижение "
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "PlayerAchievementUnlock", self, self.PlayerAchievementUnlock )
end

function AchievementUnlock:Lang( args )
	self.unlocktext = " has unlocked the achievement "
end

function AchievementUnlock:PlayerAchievementUnlock(args)
	Chat:Print( args.player:GetName(), args.player:GetColor(), self.unlocktext, Color.White, args.name, Color( 255, 215, 0 ) )
	return false
end

achievementunlock = AchievementUnlock()
class 'Woet'

function Woet:__init()
	Events:Subscribe( "KeyUp", self, self.KeyUp )
end

function Woet:KeyUp( args )
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetValue( "Freeze" ) then return end

	if not LocalPlayer:GetValue("Passive") then
    	if LocalPlayer:GetValue( "EnhancedWoet" ) and args.key == string.byte( "Y" ) then
    		if LocalPlayer:GetValue( "EnhancedWoet" ) == "Roll" then
    			Network:Send( "EnhancedWoet", "roll" )
			elseif LocalPlayer:GetValue( "EnhancedWoet" ) == "Spin" then
    			Network:Send( "EnhancedWoet", "spin" )
			elseif LocalPlayer:GetValue( "EnhancedWoet" ) == "Flip" then
    			Network:Send( "EnhancedWoet", "flip" )
			end
		end
	end
end

woet = Woet()
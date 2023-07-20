--
-- Pretty much anything not part of the HUD class or cMathFunctions.lua goes in here.
--
globals = {}
local G = globals

G.printCount = 0

--
-- Create the core of the script.
--
Events:Subscribe(
	"ModuleLoad" ,
	function()
		local hud = HUD()
	end
)
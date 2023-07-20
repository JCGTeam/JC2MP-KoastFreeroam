settings = {
	debug = false,
	delay = 3, -- server update interval in seconds
	count = 1024, -- number of boats to initially spawn
	speeds = { -- Boat top speeds (defaults in parentheses)
		[5] = 17, -- Pattani Gluay (17)
		[6] = 9, -- Orque Grandois 21TT (9)
		[16] = 31, -- YP-107 Phoenix (31) 
		[19] = 25, -- Orque Living 42T (25)
		[25] = 13, -- Trat Tang-mo (13)
		[27] = 65, -- SnakeHead T20 (65)
		[28] = 25, -- TextE Charteu 52CT (25)
		[38] = 13, -- Kuang Sunrise (13)
		[45] = 25, -- Orque Bon Ton 71FT (25)
		[50] = 7, -- Zhejiang 6903 (7)
		[53] = 31, -- Agency Hovercraft, (31)
		[69] = 28, -- Winstons Amen 69 (28)
		[80] = 50, -- Frisco Catshark S-38 (50)
		[88] = 33 -- MTA Powerrun 77 (33)
	},
	speed_gain = 0.5, -- Multiplier for actual speed settings
	pool = {5, 6, 19, 25, 27, 28, 38, 45, 50, 80} -- which boats to spawn randomly
}

function math.bezier(p1, p2, p3, p4, t)
	
	local position = (1 - t)^3 * p1 + 3 * (1 - t)^2 * t * p2 + 3 * (1 - t) * t^2 * p3 + t^3 * p4
	local direction = 3 * (1 - t)^2 * (p2 - p1) + 6 * (1 - t) * t * (p3 - p2) + 3 * t^2 * (p4 - p3)
	return position, Angle.FromVectors(Vector3.Forward, direction)

end
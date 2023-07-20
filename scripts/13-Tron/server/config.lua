class "TronConfig"

TronConfig.Dev = false

TronConfig.Defaults = {
	Radius = 10,
	MaxRadius = 400,
	Vehicles = {
		{
			model_id = 43
		}
	},
	MinPlayers = 2,
	MaxPlayers = 8
}

TronConfig.Maps = {
	{
		name = "Блюдо",
		position = Vector3(6922.432129, 718.890442, 1037.218994),
		radius = 35,
		maxRadius = 150,
		maxPlayer = 16
	},
	{
		name = "Пляж Бездорожья",
		position = Vector3(12361.725, 204, -4705.848),
		maxRadius = 800,
		vehicles = { -- Offroad vehicles
			{
				model_id = 11,
				template = "FullyUpgraded"
			},
			{
				model_id = 61
			},
			{
				model_id = 90
			}
		},
		maxPlayers = 12,
		props = { -- Pillar of barrels
			{
				position = Vector3(12361.725, 202, -4705.848),
				angle = Angle(),
				model = "34x09.flz/go001-a.lod",
				collision = "34x09.flz/go001_lod1-a_col.pfx"
			},
			{
				position = Vector3(12361.725, 203, -4705.848),
				angle = Angle(),
				model = "34x09.flz/go001-a.lod",
				collision = "34x09.flz/go001_lod1-a_col.pfx"
			},
			{
				position = Vector3(12361.725, 204, -4705.848),
				angle = Angle(),
				model = "34x09.flz/go001-a.lod",
				collision = "34x09.flz/go001_lod1-a_col.pfx"
			},
			{
				position = Vector3(12361.725, 205, -4705.848),
				angle = Angle(),
				model = "34x09.flz/go001-a.lod",
				collision = "34x09.flz/go001_lod1-a_col.pfx"
			},
			{
				position = Vector3(12361.725, 206, -4705.848),
				angle = Angle(),
				model = "34x09.flz/go001-a.lod",
				collision = "34x09.flz/go001_lod1-a_col.pfx"
			}
		}
	},
	{
		name = "Ледник",
		position = Vector3(16254, 201, 4727),
		maxRadius = 300,
		vehicles = { -- Offroad vehicles
			{
				model_id = 43,
			}
		},
		maxPlayers = 12,
		props = { -- Pillar of barrels
			{
				position = Vector3(16254, 200, 4727),
				angle = Angle(),
				model = "f2m07.ice.flz/key028_02-i.lod",
				collision = "f2m07.ice.flz/key028_02_lod1-i_col.pfx"
			}
		}
	},
	{
		name = "Дрифт Остров",
		position = Vector3(9877.809, 204, 8118.64),
		vehicles = { -- ATVs!
			{
				model_id = 11,
				template = "FullyUpgraded",
				tone2 = Color.White -- Okay overriding tones is kinda cool, just don't override tone1
			}
		},
		maxPlayers = 10
	},
	{
		name = "Пустынная гора",
		position = Vector3(-9067, 587, 4197),
		radius = 5,
		maxRadius = 120,
		vehicles = { -- ATVs!
			{
				model_id = 11,
				template = "FullyUpgraded",
				tone2 = Color.White -- Okay overriding tones is kinda cool, just don't override tone1
			}
		},
		maxPlayers = 5
	},
	{
		name = "Озеро",
		-- position = Vector3(-76.311607, 202.039856, 6425.246582),
		position = Vector3(5047.809082, 202.096558, 2640.722656),
		radius = 4,
		maxRadius = 250,
		maxPlayers = 4,
		vehicles = {
			{
				model_id = 80
			}
		}
	},
	{
		name = "Храм",
		position = Vector3(14278.492188, 204.469284, -9626.247070),
		radius = 5,
		maxRadius = 120,
		maxPlayers = 5,
		vehicles = { -- Dirt bikes
			{
				model_id = 61
			},
			{
				model_id = 90
			}
		}
	},
	{
		name = "Watch Out For That Tree",
		position = Vector3(4620.187988, 205.466141, -12525.660156),
		radius = 10,
		maxRadius = 1000,
		maxPlayers = 8,
		vehicles = { -- Dirt bikes
			{
				model_id = 61
			},
			{
				model_id = 90
			}
		}
	},
	{
		name = "Dunia",
		position = Vector3(-14879.807617, 204.398346, -8963.131836),
		radius = 10,
		maxRadius = 500,
		maxPlayers = 8,
		vehicles = { -- Dirt bikes
			{
				model_id = 61
			},
			{
				model_id = 90
			}
		}
	},
	{
		name = "Падающие Башни",
		position = Vector3(-498.362152, 800, -12066.586914),
		radius = 50,
		maxRadius = 75,
		props = {
			{
				position = Vector3(-493.171906, 790.709412, -12114.683594),
				angle = Angle(1.445133, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-487.435822, 790.709412, -12113.588867),
				angle = Angle(1.319469, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-481.882111, 790.709412, -12111.784180),
				angle = Angle(1.193805, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-476.598358, 790.709412, -12109.297852),
				angle = Angle(1.068141, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-471.667908, 790.709412, -12106.168945),
				angle = Angle(0.942478, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-467.168457, 790.709412, -12102.447266),
				angle = Angle(0.816814, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-463.171021, 790.709412, -12098.190430),
				angle = Angle(0.691150, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-459.738647, 790.709412, -12093.465820),
				angle = Angle(0.565486, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-456.925446, 790.709412, -12088.348633),
				angle = Angle(0.439823, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-454.775787, 790.709412, -12082.918945),
				angle = Angle(0.314159, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-453.323547, 790.709412, -12077.262695),
				angle = Angle(0.188496, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-452.591675, 790.709412, -12071.469727),
				angle = Angle(0.062832, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-452.591675, 790.709412, -12065.629883),
				angle = Angle(-0.062832, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-453.323547, 790.709412, -12059.836914),
				angle = Angle(-0.188496, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-454.775787, 790.709412, -12054.180664),
				angle = Angle(-0.314159, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-456.925446, 790.709412, -12048.750977),
				angle = Angle(-0.439823, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-459.738678, 790.709412, -12043.633789),
				angle = Angle(-0.565487, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-463.171021, 790.709412, -12038.909180),
				angle = Angle(-0.691150, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-467.168457, 790.709412, -12034.652344),
				angle = Angle(-0.816814, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-471.667908, 790.709412, -12030.930664),
				angle = Angle(-0.942478, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-476.598358, 790.709412, -12027.801758),
				angle = Angle(-1.068141, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-481.882111, 790.709412, -12025.315430),
				angle = Angle(-1.193805, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-487.435822, 790.709412, -12023.510742),
				angle = Angle(-1.319469, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-493.171906, 790.709412, -12022.416016),
				angle = Angle(-1.445133, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-498.999908, 790.709412, -12022.049805),
				angle = Angle(-1.570796, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-504.827911, 790.709412, -12022.416016),
				angle = Angle(-1.696460, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-510.563995, 790.709412, -12023.510742),
				angle = Angle(-1.822124, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-516.117676, 790.709412, -12025.315430),
				angle = Angle(-1.947788, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-521.401489, 790.709412, -12027.801758),
				angle = Angle(-2.073451, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-526.331909, 790.709412, -12030.930664),
				angle = Angle(-2.199115, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-530.831360, 790.709412, -12034.652344),
				angle = Angle(-2.324779, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-534.828796, 790.709412, -12038.909180),
				angle = Angle(-2.450442, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-538.261169, 790.709412, -12043.633789),
				angle = Angle(-2.576106, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-541.074341, 790.709412, -12048.750977),
				angle = Angle(-2.701770, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-543.224060, 790.709412, -12054.180664),
				angle = Angle(-2.827433, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-544.676270, 790.709412, -12059.836914),
				angle = Angle(-2.953097, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-545.408142, 790.709412, -12065.629883),
				angle = Angle(-3.078761, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-545.408142, 790.709412, -12071.469727),
				angle = Angle(3.078761, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-544.676270, 790.709412, -12077.262695),
				angle = Angle(2.953097, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-543.224060, 790.709412, -12082.918945),
				angle = Angle(2.827433, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-541.074341, 790.709412, -12088.348633),
				angle = Angle(2.701770, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-538.261169, 790.709412, -12093.465820),
				angle = Angle(2.576106, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-534.828796, 790.709412, -12098.190430),
				angle = Angle(2.450442, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-530.831360, 790.709412, -12102.447266),
				angle = Angle(2.324779, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-526.331909, 790.709412, -12106.168945),
				angle = Angle(2.199115, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-521.401428, 790.709412, -12109.297852),
				angle = Angle(2.073451, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-516.117676, 790.709412, -12111.784180),
				angle = Angle(1.947787, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-510.563995, 790.709412, -12113.588867),
				angle = Angle(1.822124, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-504.827911, 790.709412, -12114.683594),
				angle = Angle(1.696460, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-498.999908, 790.709412, -12115.049805),
				angle = Angle(1.570796, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			}
		}
	},
	{
		name = "Двойной купол",
		position = Vector3(-6756.504395, 339.996552, -3717.548340),
		radius = 15,
		maxRadius = 55,
		props = {
			{
				position = Vector3(-6754.307129, 337.897400, -3748.884766),
				angle = Angle(-1.633628, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6752.368652, 337.897400, -3748.701416),
				angle = Angle(-1.696460, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6750.444824, 337.897400, -3748.396729),
				angle = Angle(-1.759292, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6748.544434, 337.897400, -3747.971924),
				angle = Angle(-1.822124, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6746.674316, 337.897400, -3747.428711),
				angle = Angle(-1.884956, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6744.841797, 337.897400, -3746.769043),
				angle = Angle(-1.947787, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6743.054688, 337.897400, -3745.995605),
				angle = Angle(-2.010619, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6741.319824, 337.897400, -3745.111328),
				angle = Angle(-2.073451, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6739.643555, 337.897400, -3744.120117),
				angle = Angle(-2.136283, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6738.032227, 337.897400, -3743.025146),
				angle = Angle(-2.199115, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6736.493652, 337.897400, -3741.831543),
				angle = Angle(-2.261947, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6735.033203, 337.897400, -3740.543701),
				angle = Angle(-2.324779, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6733.655762, 337.897400, -3739.166748),
				angle = Angle(-2.387610, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6732.367676, 337.897400, -3737.705811),
				angle = Angle(-2.450443, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6731.174316, 337.897400, -3736.166992),
				angle = Angle(-2.513274, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6730.080078, 337.897400, -3734.556396),
				angle = Angle(-2.576106, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6729.088379, 337.897400, -3732.880127),
				angle = Angle(-2.638937, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6728.204590, 337.897400, -3731.145020),
				angle = Angle(-2.701770, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6727.431152, 337.897400, -3729.357666),
				angle = Angle(-2.764601, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6726.771484, 337.897400, -3727.525391),
				angle = Angle(-2.827433, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6726.227539, 337.897400, -3725.655029),
				angle = Angle(-2.890265, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6725.802734, 337.897400, -3723.754639),
				angle = Angle(-2.953097, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6725.498047, 337.897400, -3721.831299),
				angle = Angle(-3.015929, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6725.315430, 337.897400, -3719.892334),
				angle = Angle(-3.078761, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6725.253906, 337.897400, -3717.945801),
				angle = Angle(3.141593, 0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6725.315430, 337.897400, -3715.999268),
				angle = Angle(3.078761, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6725.498047, 337.897400, -3714.060303),
				angle = Angle(3.015929, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6725.802734, 337.897400, -3712.136963),
				angle = Angle(2.953097, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6726.227539, 337.897400, -3710.236572),
				angle = Angle(2.890265, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6726.771484, 337.897400, -3708.366211),
				angle = Angle(2.827433, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6727.431152, 337.897400, -3706.533936),
				angle = Angle(2.764601, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6728.204590, 337.897400, -3704.746582),
				angle = Angle(2.701770, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6729.088379, 337.897400, -3703.011475),
				angle = Angle(2.638937, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6730.080078, 337.897400, -3701.335205),
				angle = Angle(2.576106, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6731.174316, 337.897400, -3699.724609),
				angle = Angle(2.513274, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6732.367676, 337.897400, -3698.185791),
				angle = Angle(2.450443, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6733.655762, 337.897400, -3696.724854),
				angle = Angle(2.387610, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6735.033203, 337.897400, -3695.347900),
				angle = Angle(2.324779, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6736.493652, 337.897400, -3694.060059),
				angle = Angle(2.261947, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6738.032227, 337.897400, -3692.866455),
				angle = Angle(2.199115, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6739.643555, 337.897400, -3691.771484),
				angle = Angle(2.136283, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6741.319824, 337.897400, -3690.780273),
				angle = Angle(2.073451, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6743.054688, 337.897400, -3689.895996),
				angle = Angle(2.010619, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6744.841797, 337.897400, -3689.122559),
				angle = Angle(1.947787, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6746.674316, 337.897400, -3688.462891),
				angle = Angle(1.884956, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6748.544434, 337.897400, -3687.919678),
				angle = Angle(1.822124, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6750.444824, 337.897400, -3687.494873),
				angle = Angle(1.759292, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6752.368652, 337.897400, -3687.190186),
				angle = Angle(1.696460, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6754.307129, 337.897400, -3687.006836),
				angle = Angle(1.633628, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6756.253906, 337.897400, -3686.945801),
				angle = Angle(1.570796, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6758.200684, 337.897400, -3687.006836),
				angle = Angle(1.507964, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6760.139160, 337.897400, -3687.190186),
				angle = Angle(1.445133, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6762.062988, 337.897400, -3687.494873),
				angle = Angle(1.382301, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6763.963379, 337.897400, -3687.919678),
				angle = Angle(1.319469, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6765.833496, 337.897400, -3688.462891),
				angle = Angle(1.256637, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6767.666016, 337.897400, -3689.122559),
				angle = Angle(1.193805, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6769.453125, 337.897400, -3689.895996),
				angle = Angle(1.130973, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6771.187988, 337.897400, -3690.780273),
				angle = Angle(1.068141, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6772.864258, 337.897400, -3691.771484),
				angle = Angle(1.005310, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6774.475586, 337.897400, -3692.866211),
				angle = Angle(0.942478, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6776.014160, 337.897400, -3694.060059),
				angle = Angle(0.879646, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6777.474609, 337.897400, -3695.347900),
				angle = Angle(0.816814, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6778.852051, 337.897400, -3696.724854),
				angle = Angle(0.753982, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6780.140137, 337.897400, -3698.185791),
				angle = Angle(0.691150, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6781.333496, 337.897400, -3699.724609),
				angle = Angle(0.628318, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6782.427734, 337.897400, -3701.335205),
				angle = Angle(0.565487, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6783.419434, 337.897400, -3703.011475),
				angle = Angle(0.502655, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6784.303223, 337.897400, -3704.746582),
				angle = Angle(0.439823, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6785.076660, 337.897400, -3706.533936),
				angle = Angle(0.376991, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6785.736328, 337.897400, -3708.366211),
				angle = Angle(0.314159, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6786.280273, 337.897400, -3710.236572),
				angle = Angle(0.251327, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6786.705078, 337.897400, -3712.136963),
				angle = Angle(0.188496, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6787.009766, 337.897400, -3714.060303),
				angle = Angle(0.125664, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6787.192383, 337.897400, -3715.999268),
				angle = Angle(0.062832, 0.000000, -0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6787.253906, 337.897400, -3717.945801),
				angle = Angle(0.000000, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6787.192383, 337.897400, -3719.892334),
				angle = Angle(-0.062832, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6787.009766, 337.897400, -3721.831299),
				angle = Angle(-0.125664, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6786.705078, 337.897400, -3723.754639),
				angle = Angle(-0.188496, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6786.280273, 337.897400, -3725.655029),
				angle = Angle(-0.251327, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6785.736328, 337.897400, -3727.525146),
				angle = Angle(-0.314159, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6785.076660, 337.897400, -3729.357666),
				angle = Angle(-0.376991, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6784.303223, 337.897400, -3731.145020),
				angle = Angle(-0.439823, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6783.419434, 337.897400, -3732.880127),
				angle = Angle(-0.502655, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6782.427734, 337.897400, -3734.556396),
				angle = Angle(-0.565487, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6781.333496, 337.897400, -3736.166992),
				angle = Angle(-0.628318, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6780.140137, 337.897400, -3737.705811),
				angle = Angle(-0.691150, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6778.852051, 337.897400, -3739.166748),
				angle = Angle(-0.753982, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6777.474609, 337.897400, -3740.543701),
				angle = Angle(-0.816814, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6776.014160, 337.897400, -3741.831543),
				angle = Angle(-0.879646, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6774.475586, 337.897400, -3743.025146),
				angle = Angle(-0.942478, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6772.864258, 337.897400, -3744.120117),
				angle = Angle(-1.005310, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6771.187988, 337.897400, -3745.111328),
				angle = Angle(-1.068141, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6769.453125, 337.897400, -3745.995605),
				angle = Angle(-1.130973, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6767.666016, 337.897400, -3746.769043),
				angle = Angle(-1.193805, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6765.833496, 337.897400, -3747.428711),
				angle = Angle(-1.256637, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6763.963379, 337.897400, -3747.971924),
				angle = Angle(-1.319469, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6762.062988, 337.897400, -3748.396729),
				angle = Angle(-1.382301, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6760.139160, 337.897400, -3748.701416),
				angle = Angle(-1.445133, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6758.200684, 337.897400, -3748.884766),
				angle = Angle(-1.507964, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			},
			{
				position = Vector3(-6756.253906, 337.897400, -3748.945801),
				angle = Angle(-1.570796, -0.000000, 0.000000),
				model = "17x48.fl/go666-b.lod",
				collision = "17x48.fl/go666_lod1-b_col.pfx"
			}
		}
	}
}
settings = { -- Set default display units here
	["distance"] = 1,
	["speed"] = 2,
	["angle"] = 1
}

units = {
	["distance"] = { -- Do not change these
		{" м", 1}, -- 1
		{" футов", 3.281} -- 2
	},
	["speed"] = { -- Do not change these
		{" м/с", 0.278}, -- 1
		{" км/ч", 1}, -- 2
		{" миль/ч", 0.621}, -- 3
		{" фт/с", 0.911}, -- 4
		{" kts", 0.540} -- 5
	},
	["angle"] = { -- Do not change these
		{"°", 1} -- 1
	}
}

config = {
	[1] = {
		["name"] = "Автопилот",
		["on"] = false
	},
	[2] = {
		["name"] = "Вращение",
		["on"] = false,
		["setting"] = 0,
		["units"] = "angle",
		["min_setting"] = -60, -- Do not set less than -180
		["max_setting"] = 60, -- Do not set greater than 180
		["gain"] = 0.20, -- 0.20 default
		["input"] = 0.7, -- Percentage from 0 to 1
		["quick"] = "Ноль"
	},
	[3] = {
		["name"] = "Наклон",
		["on"] = false,
		["setting"] = 0,
		["units"] = "angle",
		["min_setting"] = -60, -- Do not set less than -90
		["max_setting"] = 60, -- Do not set greater than 90
		["gain"] = 0.50, -- 0.50 default
		["input"] = 0.8, -- Percentage from 0 to 1
		["quick"] = "Ноль"
	},
	[4] = {
		["name"] = "Направление",
		["on"] = false,
		["setting"] = 0,
		["units"] = "angle",
		["min_setting"] = 0, -- Do not change
		["max_setting"] = 360, -- Do not change
		["gain"] = 2.00, -- 2.00 default
		["input"] = 45, -- Maximum roll angle while HH is active, 30 to 60 recommended
		["quick"] = "Авто"
	},
	[5] = {
		["name"] = "Высота",
		["on"] = false,
		["setting"] = 0,
		["units"] = "distance",
		["min_setting"] = 0, -- Do not set less than 0
		["max_setting"] = 5000, -- Planes do not maneuver properly above 5000 m
		["gain"] = 0.30, -- 0.30 default
		["input"] = 45, -- Maximum pitch angle while AH is active, 30 to 60 recommended
		["bias"] = 5, -- Correction for gravity
		["step"] = 50, -- Step size for changing setting
		["quick"] = "Авто"
	},
	[6] = {
		["name"] = "Скорость",
		["on"] = false,
		["setting"] = 0,
		["units"] = "speed",
		["min_setting"] = 0, -- Do not set less than 0
		["max_setting"] = 500, -- Planes rarely exceed 500 km/h
		["gain"] = 0.04, -- 0.04 default
		["input"] = 1, -- Percentage from 0 to 1, needs to be exactly 1 for take-off
		["step"] = 5, -- Step size for changing setting
		["quick"] = "Круиз"
	},
	[7] = {
		["name"] = "К точке",
		["on"] = false
	},
	[8] = {
		["name"] = "Сближение",
		["on"] = false
	},
	[9] = {
		["name"] = "Цель",
		["on"] = false
	},
	[10] = {
		["name"] = "Параметры",
		["on"] = false
	}
}

planes = {
	[24] = { -- F-33 DragonFly
		["available"] = true,
		["landing_speed"] = 160,
		["cruise_speed"] = 296,
		["max_speed"] = 406,
		["slow_distance"] = 1000,
		["flare_distance"] = 50,
		["flare_pitch"] = 3,
		["cone_angle"] = 90,
	},
	[30] = { -- Si-47 Leopard
		["available"] = true,
		["landing_speed"] = 160,
		["cruise_speed"] = 277,
		["max_speed"] = 340,
		["slow_distance"] = 1000,
		["flare_distance"] = 100,
		["flare_pitch"] = 3,
		["cone_angle"] = 90,
	},
	[34] = { -- G9 Eclipse
		["available"] = true,
		["landing_speed"] = 190,
		["cruise_speed"] = 341,
		["max_speed"] = 401,
		["slow_distance"] = 1500,
		["flare_distance"] = 150,
		["flare_pitch"] = 3,
		["cone_angle"] = 75,
	},
	[39] = { -- Aeroliner 474
		["available"] = true,
		["landing_speed"] = 180,
		["cruise_speed"] = 324,
		["max_speed"] = 352,
		["slow_distance"] = 1000,
		["flare_distance"] = 100,
		["flare_pitch"] = -1,
		["cone_angle"] = 60,
	},
	[51] = { -- Cassius 192
		["available"] = true,
		["landing_speed"] = 120,
		["cruise_speed"] = 250,
		["max_speed"] = 314,
		["slow_distance"] = 1000,
		["flare_distance"] = 100,
		["flare_pitch"] = 3,
		["cone_angle"] = 75,
	},
	[59] = { -- Peek Airhawk 225
		["available"] = true,
		["landing_speed"] = 130,
		["cruise_speed"] = 207,
		["max_speed"] = 242,
		["slow_distance"] = 1000,
		["flare_distance"] = 20,
		["flare_pitch"] = 0,
		["cone_angle"] = 90,
	},
	[81] = { -- Pell Silverbolt 6
		["available"] = true,
		["landing_speed"] = 150,
		["cruise_speed"] = 262,
		["max_speed"] = 343,
		["slow_distance"] = 1000,
		["flare_distance"] = 20,
		["flare_pitch"] = 3,
		["cone_angle"] = 90,
	},
	[85] = { -- Bering I-86DP
		["available"] = true,
		["landing_speed"] = 180,
		["cruise_speed"] = 313,
		["max_speed"] = 339,
		["slow_distance"] = 1000,
		["flare_distance"] = 200,
		["flare_pitch"] = 3,
		["cone_angle"] = 60,
	}
}

airports = {
	["PIA"] = {
		["27"] = {
			["near_marker"] = Vector3(-5842.51, 208.97, -3009.23),
			["far_marker"] = Vector3(-6816.68, 208.97, -2994.51),
			["glide_length"] = 4000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		},
		["09"] = {
			["near_marker"] = Vector3(-6816.68, 208.97, -2994.51),
			["far_marker"] = Vector3(-5842.51, 208.97, -3009.23),
			["glide_length"] = 1500,
			["glide_pitch"] = 5,
			["cone_angle"] = 5
		},
		["05"] = {
			["near_marker"] = Vector3(-6398.21, 208.90, -3176.93),
			["far_marker"] = Vector3(-5998.58, 208.90, -3576.45),
			["glide_length"] = 2500,
			["glide_pitch"] = 5,
			["cone_angle"] = 5
		},
		["23"] = {
			["near_marker"] = Vector3(-5998.58, 208.90, -3576.45),
			["far_marker"] = Vector3(-6398.21, 208.90, -3176.93),
			["glide_length"] = 3000,
			["glide_pitch"] = 3,
			["cone_angle"] = 10
		}
	},
	["Kem Sungai Sejuk"] = {
		["04"] = {
			["near_marker"] = Vector3(601.69, 298.84, -3937.16),
			["far_marker"] = Vector3(882.20, 298.84, -4246.67),
			["glide_length"] = 5000,
			["glide_pitch"] = 4,
			["cone_angle"] = 10
		}
	},
	["Pulau Dayang Terlena"] = {
		["03L"] = {
			["near_marker"] = Vector3(-12238.39, 610.94, 4664.57),
			["far_marker"] = Vector3(-11970.58, 610.94, 4162.33),
			["glide_length"] = 5000,
			["glide_pitch"] = 5,
			["cone_angle"] = 10
		},
		["21R"] = {
			["near_marker"] = Vector3(-11970.58, 610.94, 4162.33),
			["far_marker"] = Vector3(-12238.39, 610.94, 4664.57),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 10
		},
		["03R"] = {
			["near_marker"] = Vector3(-12101.96, 611.10, 4737.54),
			["far_marker"] = Vector3(-11834.03, 611.10, 4236.06),
			["glide_length"] = 5000,
			["glide_pitch"] = 5,
			["cone_angle"] = 10
		},
		["21L"] = {
			["near_marker"] = Vector3(-11834.03, 611.10, 4236.06),
			["far_marker"] = Vector3(-12101.96, 611.10, 4737.54),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 10
		},
		["12"] = {
			["near_marker"] = Vector3(-12196.25, 611.22, 4874.13),
			["far_marker"] = Vector3(-11693.96, 611.22, 5142.52),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		},
		["30"] = {
			["near_marker"] = Vector3(-11693.96, 611.22, 5142.52),
			["far_marker"] = Vector3(-12196.25, 611.22, 4874.13),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		},
	},
	["Kem Jalan Merpati"] = {
		["30"] = {
			["near_marker"] = Vector3(-6643.80, 1050.34, 11950.66),
			["far_marker"] = Vector3(-7131.25, 1050.34, 11658.72),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		}
	},
	["Kem Udara Wau Pantas"] = {
		["27"] = {
			["near_marker"] = Vector3(6140.61, 251.00, 7158.83),
			["far_marker"] = Vector3(5573.50, 251.00, 7158.61),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		},
		["09"] = {
			["near_marker"] = Vector3(5573.50, 251.00, 7158.61),
			["far_marker"] = Vector3(6140.61, 251.00, 7158.83),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		},
		["36"] = {
			["near_marker"] = Vector3(6044.50, 251.00, 6996.85),
			["far_marker"] = Vector3(6044.50, 251.00, 6428.61),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		},
		["18"] = {
			["near_marker"] = Vector3(6044.50, 251.00, 6428.61),
			["far_marker"] = Vector3(6044.50, 251.00, 6996.85),
			["glide_length"] = 1500,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		}
	},
	["Pulau Dongeng"] = {
		["12"] = {
			["near_marker"] = Vector3(5696.48, 264.18, 10363.78),
			["far_marker"] = Vector3(5863.38, 264.18, 10460.01),
			["glide_length"] = 2000,
			["glide_pitch"] = 4,
			["cone_angle"] = 15
		}
	},
	["Tanah Lebar"] = {
		["28R"] = {
			["near_marker"] = Vector3(-160.40, 295.36, 7089.45),
			["far_marker"] = Vector3(-351.18, 295.36, 7060.66),
			["glide_length"] = 5000,
			["glide_pitch"] = 5,
			["cone_angle"] = 6
		},
		["28L"] = {
			["near_marker"] = Vector3(-169.66, 295.35, 7148.39),
			["far_marker"] = Vector3(-358.35, 295.35, 7119.41),
			["glide_length"] = 5000,
			["glide_pitch"] = 5,
			["cone_angle"] = 6
		}
	},
	["Kampung Tujuh Telaga"] = {
		["14"] = {
			["near_marker"] = Vector3(595.28, 207.06, -98.16),
			["far_marker"] = Vector3(748.07, 208.15, 58.73),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		}
	},
	["Teluk Permata"] = {
		["14"] = {
			["near_marker"] = Vector3(-7123.66, 207.01, -10822.38),
			["far_marker"] = Vector3(-6837.64, 207.01, -10636.57),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		}
	},
	["Banjaran Gundin"] = {
		["23"] = {
			["near_marker"] = Vector3(-4610.55, 405.64, -11649.26),
			["far_marker"] = Vector3(-5012.30, 405.64, -11247.39),
			["glide_length"] = 5000,
			["glide_pitch"] = 5,
			["cone_angle"] = 15
		},
		["45"] = {
			["near_marker"] = Vector3(-5012.30, 405.64, -11247.39),
			["far_marker"] = Vector3(-4610.55, 405.64, -11649.26),
			["glide_length"] = 5000,
			["glide_pitch"] = 5,
			["cone_angle"] = 12
		}
	},
	["Sungai Cengkih Besar"] = {
		["20"] = {
			["near_marker"] = Vector3(4706.35, 208.40, -10989.74),
			["far_marker"] = Vector3(4477.04, 208.40, -10467.98),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		},
		["29"] = {
			["near_marker"] = Vector3(4667.72, 208.44, -10624.48),
			["far_marker"] = Vector3(4147.00, 208.44, -10853.32),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		},
		["11"] = {
			["near_marker"] = Vector3(4147.00, 208.44, -10853.32),
			["far_marker"] = Vector3(4667.72, 208.44, -10624.48),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		}
	},
	["Paya Luas"] = {
		["27"] = {
			["near_marker"] = Vector3(12011.65, 206.88, -10715.07),
			["far_marker"] = Vector3(11440.75, 206.88, -10715.09),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		},
		["09"] = {
			["near_marker"] = Vector3(11440.75, 206.88, -10715.09),
			["far_marker"] = Vector3(12011.65, 206.88, -10715.07),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		},
		["36"] = {
			["near_marker"] = Vector3(12171.29, 206.88, -10243.73),
			["far_marker"] = Vector3(12171.29, 206.88, -10812.65),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		},
		["18"] = {
			["near_marker"] = Vector3(12171.26, 206.88, -10812.65),
			["far_marker"] = Vector3(12171.26, 206.88, -10243.73),
			["glide_length"] = 1500,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		}
	},
	["Lemabah Delima"] = {
		["13"] = {
			["near_marker"] = Vector3(9460.27, 204.78, 3661.23),
			["far_marker"] = Vector3(9890.33, 204.78, 4031.97),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		},
		["31"] = {
			["near_marker"] = Vector3(9890.33, 204.78, 4032.38),
			["far_marker"] = Vector3(9460.27, 204.78, 3661.23),
			["glide_length"] = 5000,
			["glide_pitch"] = 3,
			["cone_angle"] = 15
		}
	}
}

local deg = math.deg

function DegreesDifference(theta1, theta2)
	return (theta2 - theta1 + 180) % 360 - 180
end

function OppositeDegrees(theta)
	return (theta + 180) % 360
end

function YawToHeading(yaw)
	return yaw < 0 and -yaw or 360 - yaw
end

function HeadingToYaw(heading)
	return heading < 180 and -heading or 360 - heading
end

function Vehicle:GetRoll()
	return deg(self:GetAngle().roll)
end

function Vehicle:GetPitch()
	return deg(self:GetAngle().pitch)
end

function Vehicle:GetYaw()
	return deg(self:GetAngle().yaw)
end

function Vehicle:GetHeading()
	return YawToHeading(self:GetYaw())
end

function Vehicle:GetAltitude()
	return self:GetPosition().y - 200
end

function Vehicle:GetAirSpeed()
	return self:GetLinearVelocity():Length() * 3.6
end

function Vehicle:GetVerticalSpeed()
	return self:GetLinearVelocity().y * 3.6
end

function Vehicle:GetGroundSpeed()
	local velocity = self:GetLinearVelocity()
	return Vector2( velocity.x, velocity.z ):Length() * 3.6
end
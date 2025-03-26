class "Location"

Location.Type = {
	Comm        = "Comm",
	CivCity     = "CivCity",
	CivVil      = "CivVil",
	MilLocation = "MilLocation",
	MilAir      = "MilAir",
	MilHarb     = "MilHarb",
	MilStrong   = "MilStrong",
	OilRig      = "OilRig",
	Waypoint    = "Waypoint"
}

Location.TypeName = {
	Comm        = "Communication Outpost",
	CivCity     = "Civilian City",
	CivVil      = "Civilian Village",
	MilLocation = "Military Location",
	MilAir      = "Military AirLocation",
	MilHarb     = "Military Harbor",
	MilStrong   = "Military Stronghold",
	OilRig      = "Oil Rig",
	Waypoint    = "Waypoint"
}

Location.Icon = {
	Sheet  = Image.Create( AssetLocation.Game, "pda_icons_dif.dds" ),
	Size   = Vector2.One * 64,
	UVSize = Vector2.One * 0.125,
	UV     = {
		Comm        = Vector2( 0.125 * 6, 0.125 * 1 ),
		CivCity     = Vector2( 0.125 * 6, 0.125 * 2 ),
		CivVil      = Vector2( 0.125 * 4, 0.125 * 2 ),
		MilLocation = Vector2( 0.125 * 1, 0.125 * 1 ),
		MilAir      = Vector2( 0.125 * 5, 0.125 * 1 ),
		MilHarb     = Vector2( 0.125 * 1, 0.125 * 2 ),
		MilStrong   = Vector2( 0.125 * 3, 0.125 * 3 ),
		OilRig      = Vector2( 0.125 * 2, 0.125 * 2 ),
		Waypoint    = Vector2( 0.125 * 7, 0.125 * 3 )
	}
}

function Location:__init( name, position, type )
	self.name     = name
	self.position = position
	self.type     = type
end

function Location:GetTypeName()
	return Location.TypeName[self.type]
end

function Location:IsActive( position, scale )
	local position0 = PDA:IsUsingGamepad() and (Render.Size / 2) or Mouse:GetPosition()
	local iconSize = (Location.Icon.Size * scale / 2)
	local position1 = position - iconSize
	local position2 = position + iconSize

	if position0.x >= position1.x and position0.y >= position1.y and position0.x <= position2.x and position0.y <= position2.y then
		return true
	end

	return false
end

function Location:DrawIcon( position, scale )
	local iconSize = Location.Icon.Size * scale
	Location.Icon.Sheet:Draw( position - (iconSize / 2), iconSize, Location.Icon.UV[self.type], Location.Icon.UV[self.type] + Location.Icon.UVSize )
end

function Location:Draw( position, scale )
	self:DrawIcon( position, scale )
end

function Location:DrawTitle(position, scale)
	Render:SetFont( AssetLocation.Disk, "Archivo.ttf" )

	local textSize = 21
	Render:DrawShadowedText( position - (Render:GetTextSize(self.name, textSize) / 2) + (Vector2.Down * (Location.Icon.Size.y / 2) * scale) + (Vector2.Down * textSize / 2), self.name, Color.White, Color.Black, textSize )
end

Map = {
	Heli  = Image.Create( AssetLocation.Game, "hud_icon_heli_orange_dif.dds" ),
	Marker = Image.Create( AssetLocation.Base64, "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" ),
	Image = Image.Create( AssetLocation.Game, "pda_map_dif.dds" ),
	Zoom = 1,
	Offset = Vector2(),
	IconScale = 0.4,
	Ramka = true,
	Border = true,
	RamkaAlpha = 1,
	WaypointScale = 1.5,
	ActiveLocation = nil,
	LocationsVisible = false,
	Players = {},
	Waypoint = Location( "Waypoint", Vector3(), Location.Type.Waypoint ),
	Locations = {
		Location("Kepulauan", Vector3(-1396.228, 276.0449, 10460.26), Location.Type.Comm),
		Location("Negeri Gunung Berawn", Vector3(7826.969, 254.5643, 8466.012), Location.Type.MilLocation),
		Location("Pekan Belalang", Vector3(-1775.918, 199.2626, 12071.51), Location.Type.CivVil),
		Location("Kampung Tiga Kelapa", Vector3(-6475.682, 272.5664, -9362.973), Location.Type.CivVil),
		Location("Kampung Jelantur", Vector3(-6304.328, 209.6773, -6151.631), Location.Type.CivVil),
		Location("Bandar Kayu Buaya", Vector3(1436.405, 205.3391, 952.2224), Location.Type.CivVil),
		Location("Tanah Raya Timur Beta", Vector3(11634.37, 366.0744, -2124.131), Location.Type.Comm),
		Location("Gunung Lapik", Vector3(3901.989, 221.1246, 6189.263), Location.Type.MilAir),
		Location("Lengkok Sungai Gambler's Den", Vector3(-7737.874, 202.6088, 6749.43), Location.Type.CivVil),
		Location("Koji Kuasa Panau Utara", Vector3(5512.42, 269.3309, -9919.016), Location.Type.CivVil),
		Location("Pelantar Minyuk Gerudi Besar", Vector3(-15586.53, 236.3287, 6106.84), Location.Type.OilRig),
		Location("Kastelo Singa Military Location", Vector3(4728.367, 489.014, -6854.222), Location.Type.MilLocation),
		Location("Bandar Baru Indah", Vector3(-2554.385, 244.3287, 13115.53), Location.Type.CivVil),
		Location("Port Rodrigo", Vector3(-985.8657, 202.5112, 6073.594), Location.Type.CivVil),
		Location("Negeri Selatan", Vector3(7794.858, 205.7129, 3781.995), Location.Type.CivVil),
		Location("Tanah Raya Timur Epsilon", Vector3(14306.61, 227.2343, 1006.777), Location.Type.Comm),
		Location("Pulau Tiga Gunung", Vector3(-1861.242, 212.6986, 9970.456), Location.Type.MilLocation),
		Location("Kampung Sawah Pantai", Vector3(5311.938, 228.8296, 5508.45), Location.Type.CivVil),
		Location("Tanah Raya Timur Eta", Vector3(6001.72, 715.5078, 2396.118), Location.Type.Comm),
		Location("Kampung Langit Berasap", Vector3(10386.85, 282.8154, -9689.815), Location.Type.CivVil),
		Location("Banjaran Berawan Besar lota", Vector3(1543.674, 347.7799, -6945.772), Location.Type.Comm),
		Location("Tanah Raya Timur Kappa", Vector3(12046.09, 279.7711, 148.2282), Location.Type.Comm),
		Location("Bandar Lubuk Paya", Vector3(-3749.142, 204.4543, 9594.421), Location.Type.CivVil),
		Location("Pekan Lengkon", Vector3(8324.834, 214.1691, 4202.597), Location.Type.CivVil),
		Location("Pekan Keris Perak", Vector3(-6014.297, 342.1775, 6380.154), Location.Type.MilLocation),
		Location("Pekan Pondok Getah", Vector3(1080.739, 201.8781, 1114.203), Location.Type.CivVil),
		Location("Kuala Rajang", Vector3(-1632.041, 203.8008, 9308.408), Location.Type.CivVil),
		Location("Teluk Panau Tengah Beta", Vector3(-4559.895, 609.1249, 4416.43), Location.Type.Comm),
		Location("Pekan Ular Sawa", Vector3(-12484.68, 609.5613, 3776.653), Location.Type.MilLocation),
		Location("Kem Serigala Kelabu", Vector3(2761.386, 584.049, -667.3429), Location.Type.MilLocation),
		Location("Paya Keras", Vector3(2148.528, 497.9752, -9337.318), Location.Type.CivVil),
		Location("Kem Hutan Supply Depot", Vector3(-3000.255, 245.3961, 12743.33), Location.Type.MilStrong),
		Location("Pekan Badak Bermandi", Vector3(1823.334, 230.1996, 5159.33), Location.Type.CivVil),
		Location("Bandar Tokong Kecil", Vector3(9219.15, 247.0397, -10916.27), Location.Type.CivVil),
		Location("Pekan Pakis", Vector3(12765.27, 303.8687, -1806.861), Location.Type.CivVil),
		Location("Tanah Raya Timur Gamma", Vector3(10638.28, 435.3674, 3317.785), Location.Type.Comm),
		Location("Rumah Hartawan", Vector3(138.8727, 202.0234, -13069.55), Location.Type.CivVil),
		Location("Seabreeeze Sawmill", Vector3(-1017.106, 249.7261, 9481.964), Location.Type.CivVil),
		Location("Kampung Orkid Riak", Vector3(1299.751, 220.5759, 8944.248), Location.Type.CivVil),
		Location("Kampung Rencong Berkarat", Vector3(4186.12, 1240.772, -2946.137), Location.Type.MilLocation),
		Location("Kem General Yahya", Vector3(12027.38, 548.421, 14939.02), Location.Type.MilLocation),
		Location("Teluk Panau Tengah Delta", Vector3(-3215.103, 314.7845, 7536.873), Location.Type.Comm),
		Location("Kem Udara Wau Pantas", Vector3(5779.773, 250.0282, 6881.557), Location.Type.MilAir),
		Location("Pekan Batu Karang", Vector3(-14102.74, 195.4277, 15094.42), Location.Type.CivVil),
		Location("Kota Kuala Delima", Vector3(11290.49, 195.906, -2812.753), Location.Type.CivVil),
		Location("Pekan Kemilau", Vector3(11278.61, 197.2382, -8259.751), Location.Type.CivVil),
		Location("Kampung Tanah Besar", Vector3(11982.59, 268.657, -7810.277), Location.Type.CivVil),
		Location("Tanah Luas", Vector3(-7457.915, 236.7682, -8496.596), Location.Type.MilLocation),
		Location("Kampung Sekam Padi", Vector3(7935.71, 212.7354, 9628.264), Location.Type.CivVil),
		Location("Loji Kuasa Pantai Tokong", Vector3(2134.114, 210.8542, 3802.061), Location.Type.CivVil),
		Location("Kem Jalan Kilang Lama", Vector3(2914.492, 549.9413, -2106.099), Location.Type.MilLocation),
		Location("Kampung Kilang Papan", Vector3(-11170.14, 228.1407, 15282.13), Location.Type.CivVil),
		Location("Sungai Jernih", Vector3(-4097.059, 206.3477, 8817.395), Location.Type.MilAir),
		Location("Bandar Baru Cina", Vector3(878.0835, 201.4454, 1806.557), Location.Type.CivVil),
		Location("Kepulauan Selatan Gamma", Vector3(3834.26, 322.9113, 9413.578), Location.Type.Comm),
		Location("Kuala Cherah", Vector3(7563.726, 214.5822, 11719.92), Location.Type.CivVil),
		Location("Kampung Tasik Lembah", Vector3(-13883.48, 228.336, 14808.05), Location.Type.CivVil),
		Location("Kampung Kolam Gelap", Vector3(-3145.493, 203.8477, 14829.09), Location.Type.CivVil),
		Location("Gunung Jarandua", Vector3(11800.52, 244.9696, -6826.338), Location.Type.CivVil),
		Location("Kampung Datuk Tua", Vector3(7211.391, 197.1746, 9851.854), Location.Type.CivVil),
		Location("Kem Jalan Padang Luas", Vector3(9081.021, 717.7153, 14910.88), Location.Type.MilLocation),
		Location("Bandar Besar", Vector3(-419.4079, 624.4611, -4505.107), Location.Type.CivVil),
		Location("Bandar Selekeh", Vector3(-7213.708, 222.02, -4970.013), Location.Type.CivVil),
		Location("Kampung Dataran Nipah", Vector3(-9890.419, 603.3173, 3513.115), Location.Type.CivVil),
		Location("Pekan Jambatan Batu", Vector3(-12790.24, 217.823, 8320.614), Location.Type.CivVil),
		Location("Kepulauan Selatan Eta", Vector3(9559.628, 453.5287, 12508.2), Location.Type.Comm),
		Location("Kampung Lembah Danau", Vector3(8131.163, 179.8953, 14065.25), Location.Type.CivVil),
		Location("Gurun Lautan Lama Gamma", Vector3(-11838.34, 391.1608, 8776.109), Location.Type.Comm),
		Location("Kampung Kosa Besar", Vector3(9772.639, 205.5803, 3688.464), Location.Type.CivVil),
		Location("Kampung Kerang Hitam", Vector3(-4083.97, 424.1904, -7119.934), Location.Type.CivVil),
		Location("Panau International Airport", Vector3(-6635.814, 207.7974, -3585.474), Location.Type.MilAir),
		Location("Kampung Sawah Basah", Vector3(-12043.88, 339.811, 15013.85), Location.Type.CivVil),
		Location("Fasility Gunung Timur", Vector3(14201.5, 528.8898, 12442.37), Location.Type.MilLocation),
		Location("Port Kepulauan Pelaut", Vector3(9755.877, 202.1912, -11597.89), Location.Type.MilHarb),
		Location("Gunung Gila Pangkat Facility", Vector3(557.3547, 1179.563, -7246.511), Location.Type.MilStrong),
		Location("Tanjung Putih", Vector3(-13480.81, 215.5418, 4673.613), Location.Type.CivVil),
		Location("Kepulauan Senjakala Beta", Vector3(-13961.91, 339.755, 12156.74), Location.Type.Comm),
		Location("Kem Pekan Selamat", Vector3(-9278.248, 227.8146, 9638.767), Location.Type.MilLocation),
		Location("Sungai Cerah", Vector3(-5474.185, 205.3512, 12185.38), Location.Type.CivVil),
		Location("Pekan Hutan Buluh", Vector3(11122.52, 330.4616, -9854.38), Location.Type.CivVil),
		Location("Bandar Kayu Manis", Vector3(6538.834, 1340.75, -2611.821), Location.Type.CivVil),
		Location("Pelantar Gas Panau Utara", Vector3(-4790.765, 236.3287, -15357.58), Location.Type.OilRig),
		Location("Bandar Pertama", Vector3(214.0416, 202.3046, 108.9023), Location.Type.CivVil),
		Location("Bandar Jernih", Vector3(5368.005, 205.1688, 13338.65), Location.Type.CivVil),
		Location("Kem Gunung Dataran Tinggi", Vector3(-1052.722, 1625.267, -7010.672), Location.Type.MilLocation),
		Location("Kepulauan Selatan Kappa", Vector3(7255.745, 315.0965, 12576.37), Location.Type.Comm),
		--Location("Kem Komodor Da Silva", Vector3(-7829.07, 200.9365, -7073.327), Location.Type.MilHarb),
		Location("Kem Komodor Da Silva", Vector3(-7674.010254, 203.999985, -6887.556152), Location.Type.MilHarb),
		Location("Negeri Tenggara", Vector3(9213.208, 220.8273, 4055.901), Location.Type.MilLocation),
		Location("Kampung Tokong Tua", Vector3(-5916.205, 317.8293, -10349.15), Location.Type.CivVil),
		Location("Kampung Ketam Laut", Vector3(-7874.091, 207.2763, -2346.648), Location.Type.CivVil),
		Location("Sungai Geneng", Vector3(-2237.429, 285.9816, 11397.98), Location.Type.MilLocation),
		Location("Panau City - Docks District", Vector3(-15315.65, 202.9297, -2818.928), Location.Type.CivCity),
		Location("Kampung Nelayan-Nelayan", Vector3(958.4824, 204.2445, -12187.5), Location.Type.CivVil),
		Location("Sungai Madu Leleh", Vector3(-9840.547, 208.627, 4986.521), Location.Type.CivVil),
		Location("Pulau Naga", Vector3(-589.0225, 200.9491, 11536.25), Location.Type.CivVil),
		Location("Kampung Sawah Luas", Vector3(2909.846, 224.1102, 5672.293), Location.Type.CivVil),
		Location("Kem Rajang Floodgates", Vector3(-7962.754, 192.2301, 4686.348), Location.Type.MilLocation),
		Location("Kampung Curah Dalam", Vector3(-2680.948, 886.1861, -8557.208), Location.Type.MilLocation),
		Location("Pekan Buaya Tidur", Vector3(-1827.005, 204.411, -4825.341), Location.Type.CivVil),
		Location("Sungai Curah", Vector3(-4889.065, 260.8042, 7683.73), Location.Type.MilLocation),
		Location("Tanjung Rumah Api", Vector3(-2730.374, 203.1819, 4622.708), Location.Type.CivVil),
		Location("Pulau Delima", Vector3(3463.677, 208.0659, 10952), Location.Type.CivVil),
		Location("Kampung Cicak Hitam", Vector3(-11936.1, 209.1374, 13935), Location.Type.CivVil),
		Location("Tasik Permata", Vector3(-11694.89, 196.3864, 5689.833), Location.Type.CivVil),
		Location("Kampung Monyet Lena", Vector3(4803.865, 224.2397, 5607.749), Location.Type.CivVil),
		Location("Tanah Raya Timur Theta", Vector3(4768.498, 422.0737, 3125.267), Location.Type.Comm),
		Location("Bandar Bukit Rata", Vector3(7721.802, 1056.846, -5474.075), Location.Type.CivVil),
		Location("Bukit Matahari", Vector3(-3391.638, 621.3101, -9115.026), Location.Type.CivVil),
		Location("Kampung Anjing Gila", Vector3(-5817.864, 211.0201, 692.0035), Location.Type.CivVil),
		Location("Negeri Cabang", Vector3(4361.908, 360.8893, 4292.739), Location.Type.MilLocation),
		Location("Three Kings Hotel", Vector3(-12674.22, 220.0386, 15098.26), Location.Type.CivVil),
		Location("Kampung Tokong Purba", Vector3(-9369.879, 248.9204, 7508.161), Location.Type.CivVil),
		Location("Kampung Desa Lena", Vector3(-11692.09, 300.8188, 14414.19), Location.Type.CivVil),
		Location("Bukit Tinggi", Vector3(3640.378, 1346.957, -5475.135), Location.Type.MilLocation),
		Location("Kem Jurang Gurun", Vector3(-5450.435, 363.2871, 4847.299), Location.Type.MilLocation),
		Location("Bandar Gereja Guruun", Vector3(-10318.24, 449.2608, 9632.378), Location.Type.CivVil),
		Location("Bandar Sungai Rajang", Vector3(-7757.264, 206.3257, 4180.161), Location.Type.CivVil),
		--Location("Paya Luas", Vector3(12028.47, 187.8509, -10679.78), Location.Type.MilAir),
		Location("Paya Luas", Vector3(12028.47, 206.8509, -10679.78), Location.Type.MilAir),
		Location("Kampung Sri Puteri", Vector3(-5166.081, 338.7373, -7321.45), Location.Type.CivVil),
		Location("Wajah Ramah Fortress", Vector3(13803.25, 368.3176, 14003.32), Location.Type.MilLocation),
		Location("Gunung Rata", Vector3(860.4727, 287.4586, 11726.06), Location.Type.MilLocation),
		Location("Kem Harimau Putih", Vector3(11212.44, 399.179, 848.4565), Location.Type.MilLocation),
		--Location("Palau Dayang Terlena", Vector3(-11911.88, 609.6496, 4799.679), Location.Type.MilAir),
		Location("Palau Dayang Terlena", Vector3(-12196.875977, 617.640747, 4740.500977), Location.Type.MilAir),
		Location("Sungai Remaja", Vector3(-6609.62, 342.446, 5237.658), Location.Type.MilLocation),
		Location("Pekan Jati Besar", Vector3(1738.605, 245.0061, -506.7159), Location.Type.CivVil),
		Location("Pekan Desa", Vector3(-5400.887, 620.5599, -8678.451), Location.Type.CivVil),
		Location("Pekan Buah Melambak", Vector3(1045.374, 200.7141, -1621.509), Location.Type.CivCity),
		Location("Kepulauan Selatan Beta", Vector3(5406.526, 320.6592, 12944.88), Location.Type.Comm),
		Location("Kampang Penggali", Vector3(5445.612, 880.9538, -5355.422), Location.Type.CivVil),
		Location("Hutan Dalam Military Location", Vector3(6688.904, 258.0707, 10654.67), Location.Type.MilLocation),
		Location("Tasik Cerah", Vector3(-4856.042, 219.0852, 3190.218), Location.Type.CivVil),
		Location("Kepulauan Selatan Lambda", Vector3(-661.8287, 301.4908, 7971.487), Location.Type.Comm),
		Location("Kampung Danau Lengkong", Vector3(-5954.689, 207.2628, 9765.063), Location.Type.CivVil),
		Location("Kampung Perigi Lumpur", Vector3(-10375.29, 537.3588, 10606.9), Location.Type.CivVil),
		Location("Kampung Tiang Emas", Vector3(1205.297, 203.5143, -432.0274), Location.Type.CivVil),
		Location("Kampung Batang Reput", Vector3(857.994, 203.6558, 500.1631), Location.Type.CivVil),
		Location("Pekan Teluk Tengah", Vector3(686.2754, 222.0673, -2595.312), Location.Type.CivCity),
		Location("Bukit Dengkang", Vector3(-4754.458, 289.3721, -6376.033), Location.Type.MilLocation),
		Location("Gunung Hotel Ski Resort", Vector3(8190.717, 496.8336, -1597.438), Location.Type.CivVil),
		Location("Pekan Tupai Merah", Vector3(10795.88, 206.1189, -845.1679), Location.Type.CivVil),
		--Location("Kem General Abidin", Vector3(-14128.39, 336.8656, 13485.81), Location.Type.MilLocation),
		Location("Kem General Abidin", Vector3(-14298.575195, 320.221771, 13486.273438), Location.Type.MilLocation),
		Location("Kuala Gandin", Vector3(5414.445, 254.2245, 3397.661), Location.Type.MilLocation),
		Location("Kuala Geneng", Vector3(6800.176, 204.0914, 4685.739), Location.Type.CivVil),
		Location("Bandar Gunung Belakang Patah", Vector3(5903.735, 1019.538, 346.6127), Location.Type.CivVil),
		Location("Kampung Bunga Raya", Vector3(-5299.124, 447.9942, 8321.99), Location.Type.CivVil),
		Location("Pantai Kelapa Resort", Vector3(8241.961, 202.9519, 10185.73), Location.Type.CivVil),
		Location("Pekan Merdeka Silam", Vector3(782.7711, 197.7495, 841.8615), Location.Type.CivVil),
		Location("Teluk Panau Tengah Gamma", Vector3(-3793.139, 284.7395, 10017.39), Location.Type.Comm),
		Location("Kem Harimau Bintang", Vector3(12218.26, 619.968, 14088.2), Location.Type.MilLocation),
		Location("Bukit Rendah", Vector3(82.44434, 1122.303, -9012.872), Location.Type.MilLocation),
		Location("Loji Bahan Bakar Fossin", Vector3(9516.775, 209.9794, -10177.47), Location.Type.MilLocation),
		Location("Pulau Ketam Besar", Vector3(3825.969, 209.4087, 10260.54), Location.Type.MilLocation),
		Location("Kem Lembah Hutan", Vector3(11215.5, 295.0118, 13618.05), Location.Type.MilLocation),
		Location("Bandar Pekan Lama", Vector3(12355.14, 236.5235, 1199.771), Location.Type.CivVil),
		Location("Pekan Ayer Gilang", Vector3(1240.302, 205.4475, -1055.192), Location.Type.CivVil),
		Location("Pulau Ombak Ribut", Vector3(8198.346, 214.0749, 2235.842), Location.Type.MilLocation),
		Location("Kampung Padi Hilang", Vector3(12326.94, 338.3674, -761.413), Location.Type.CivVil),
		Location("Banjaran Berawan Besar Theta", Vector3(9186.163, 494.1146, -5302.568), Location.Type.Comm),
		Location("Kem Sungai Sejuk", Vector3(757.4424, 298.3252, -4014.411), Location.Type.MilLocation),
		Location("Pasir Putih", Vector3(-3389.278, 206.0516, 2862.404), Location.Type.MilHarb),
		Location("Bandar Koperasi", Vector3(-3813.054, 358.4707, -12355.99), Location.Type.CivVil),
		Location("Pekan Hujung", Vector3(-11032.57, 472.3613, 7393.208), Location.Type.MilLocation),
		Location("Kampung Lembah Gurun", Vector3(-8413.657, 315.5773, 9254.735), Location.Type.CivVil),
		Location("Lembah Firdaus Compound", Vector3(2722.232, 210.1208, 9486.71), Location.Type.MilStrong),
		Location("Kem General Hong", Vector3(-3268.039, 675.9688, -9598.611), Location.Type.MilLocation),
		Location("Kampung Kayu Keras", Vector3(8076.139, 307.7526, 11644.47), Location.Type.CivVil),
		--Location("Pulau Berendam", Vector3(9494.373, 245.6784, -12923.39), Location.Type.MilHarb),
		Location("Pulau Berendam", Vector3(9471.735352, 202.862061, -13158.911133), Location.Type.MilHarb),
		Location("Telok Ayer Batang", Vector3(486.7163, 263.6576, 5150.679), Location.Type.MilLocation),
		Location("Kem Port Pelangi", Vector3(-10552.46, 198.7463, 13246.9), Location.Type.MilHarb),
		--Location("Pasir Hitam", Vector3(1793.183, 207.1591, 2219.146), Location.Type.MilLocation),
		Location("Pasir Hitam", Vector3(1770.504395, 202.291901, 2274.141357), Location.Type.MilLocation),
		Location("Gunung Merah Radar Facility", Vector3(-9013.44, 709.2638, 11348.13), Location.Type.MilLocation),
		Location("Banjaran Berawan Besar Delta", Vector3(3848.382, 898.8663, -6544.056), Location.Type.Comm),
		Location("Kampug Ayer Lama", Vector3(-7821.273, 198.1511, 2572.126), Location.Type.MilHarb),
		Location("Pekan Pinggir Jalan", Vector3(2073.858, 220.4868, 2690.451), Location.Type.CivVil),
		Location("Banjaran Berawan Besar Alpha", Vector3(7482.525, 1021.973, -7577.403), Location.Type.Comm),
		--Location("Banjaran Gundin", Vector3(-4684.034, 415.1115, -11277.62), Location.Type.MilAir),
		Location("Banjaran Gundin", Vector3(-4515.668945, 432.914185, -11271.915039), Location.Type.MilAir),
		Location("Tanah Raya Timur lota", Vector3(9404.302, 1151.02, -4025.884), Location.Type.Comm),
		Location("Emas Hitam Oil Refinery", Vector3(11577.3, 228.0705, -9371.375), Location.Type.MilStrong),
		--Location("Emas Hitam Oil Refinery", Vector3(11577.3, 228.0705, -9371.375), Location.Type.U_Stronghold),
		Location("Banjaran Berawan Besar Eta", Vector3(761.4179, 487.6692, -5165.993), Location.Type.Comm),
		Location("Bandar Dataran Sawah", Vector3(10690.31, 313.1415, 291.9846), Location.Type.CivVil),
		Location("Negeri Gandin", Vector3(-6166.084, 230.4234, -11983.46), Location.Type.MilLocation),
		Location("Kampung Cahaya Bulan", Vector3(4236.331, 929.988, 50.61683), Location.Type.CivVil),
		Location("Mile High Club", Vector3(13200.32, 1082.615, -4948.071), Location.Type.CivVil),
		Location("Palau Kait", Vector3(7092.424, 203.3305, -11352.28), Location.Type.MilHarb),
		Location("Kem Kucing Belang Hitam", Vector3(4684.504, 1716.655, -2496.598), Location.Type.MilLocation),
		Location("Bandar Padang Besar", Vector3(13579.18, 291.94, 736.6122), Location.Type.CivVil),
		Location("Pekan Salamat", Vector3(-8935.036, 244.6116, 9433.986), Location.Type.CivVil),
		Location("Gurun Lautan Lama Alpha", Vector3(-11023.6, 838.9669, 9253.015), Location.Type.Comm),
		Location("Kampung Nahkoda", Vector3(11940.76, 261.6443, -7474.008), Location.Type.CivVil),
		Location("Kepulauan Selatan Theta", Vector3(6418.299, 576.3608, 14644.53), Location.Type.Comm),
		Location("Bandar Gunung Raya", Vector3(4740.157, 1522.664, -4237.625), Location.Type.CivVil),
		Location("Tanah Raya Timur Mu", Vector3(5694.994, 239.4494, 7434.886), Location.Type.Comm),
		Location("Bandar Baru Bukit Kuprum", Vector3(5343.008, 1240.739, -4125.098), Location.Type.CivVil),
		Location("Kampung Perigi Hitam", Vector3(12337.46, 270.573, -7537.716), Location.Type.CivVil),
		Location("Kampung Phon Reput", Vector3(-6859.892, 229.049, 1892.154), Location.Type.CivVil),
		Location("Sungai Cengkih Besar", Vector3(4520.471, 205.963, -10814.01), Location.Type.MilAir),
		Location("Sungai Tapai", Vector3(4017.216, 202.2688, 8580.282), Location.Type.CivVil),
		Location("Kampung Gunung Merah", Vector3(-7544.855, 324.7808, 9767.752), Location.Type.CivVil),
		Location("Bandar Pantai Sunyi", Vector3(8331.996, 201.1841, 3349.719), Location.Type.CivVil),
		Location("Pulau Dongeng", Vector3(5899.748, 264.3262, 10342.58), Location.Type.MilLocation),
		Location("Pelantar Gas Tiang Geneng", Vector3(15033.91, 236.3287, -9070.873), Location.Type.OilRig),
		Location("Panau City - Park District", Vector3(-12667.85, 221.4292, -4854.635), Location.Type.CivCity),
		Location("Kem Kuala Rajang", Vector3(-7886.755, 202.9644, 5405.252), Location.Type.MilLocation),
		Location("Kem Jalan Merpati", Vector3(-6949.718, 1049.964, 11804.01), Location.Type.MilAir),
		Location("Kem Singa Menerkam", Vector3(3015.158, 678.9998, -10125.51), Location.Type.MilLocation),
		Location("Kem Jalan Padang Tembak", Vector3(9398.924, 437.0459, 13769.9), Location.Type.MilLocation),
		Location("Bandar Serigala Kelabu", Vector3(13975.98, 198.9285, 2288.007), Location.Type.CivVil),
		Location("Teluk Panau Tengah Alpha", Vector3(379.2417, 481.0895, 6017.621), Location.Type.Comm),
		Location("Bandar Batu Besar", Vector3(-12324.84, 197.995, 13986.77), Location.Type.CivVil),
		Location("Panau City - Financial District", Vector3(-10307.16, 203.1312, -3048.375), Location.Type.CivCity),
		Location("Kem Lubang Dalam", Vector3(5422.6, 1190.86, 991.5297), Location.Type.MilLocation),
		Location("Tasik Kasuari", Vector3(1589.584, 215.8808, 6726.625), Location.Type.CivVil),
		Location("Kem Tentera Timur", Vector3(-5335.1, 437.6166, -8090.85), Location.Type.MilLocation),
		Location("Kampung Tok Dalang", Vector3(-8870.853, 233.3776, 8595.328), Location.Type.CivVil),
		Location("Banjaran Berawan Besar Epsilon", Vector3(9126.746, 963.3487, -6843.384), Location.Type.Comm),
		Location("Kampung Ekor Bengkok", Vector3(-8873.11, 1485.185, 12322.43), Location.Type.CivVil),
		Location("Kota Kersik", Vector3(-5658.505, 367.7077, 3482.761), Location.Type.CivVil),
		Location("Pelantar Gas Panau Barat", Vector3(-15234.85, 236.3287, 6915.199), Location.Type.OilRig),
		Location("Kepulauan Pelaut Alpha", Vector3(7336.418, 240.0916, -12408.51), Location.Type.Comm),
		Location("Pelantar Gas Panau Selatan", Vector3(13466.77, 236.3287, 8369.213), Location.Type.OilRig),
		Location("Tanjung Intan", Vector3(-5837.049, 213.8395, -12813.25), Location.Type.CivVil),
		Location("Pelantar Gas Telok Panau", Vector3(-4903.697, 236.3287, -1400.066), Location.Type.OilRig),
		Location("Pekan Sempit", Vector3(-10796.94, 211.1486, 14614.73), Location.Type.CivVil),
		Location("Pemainan Racun Facility", Vector3(-3392.792, 190.8312, 8814.813), Location.Type.MilStrong),
		Location("Pekan Juku-Juku", Vector3(-1412.271, 201.5011, -13407.59), Location.Type.CivVil),
		Location("Kepulauan Selatan lota", Vector3(7914.223, 501.735, 11139.74), Location.Type.Comm),
		Location("Tanah Raya Timur Alpha", Vector3(6631.838, 994.809, 393.8506), Location.Type.Comm),
		Location("Kampung Lima Batu", Vector3(-10496.3, 422.2416, 8544.266), Location.Type.MilLocation),
		Location("Tanah Raya Timur Delta", Vector3(9184.236, 726.4515, -242.5264), Location.Type.Comm),
		Location("Kem Kapitan Mohideen", Vector3(857.1829, 220.9492, 4754.494), Location.Type.MilLocation),
		Location("Bandar Arang Batu Besar", Vector3(8369.285, 201.1048, 10815.38), Location.Type.CivVil),
		Location("Jalan Lompat", Vector3(3136.017, 578.758, -502.3345), Location.Type.CivVil),
		Location("Tanah Raya Barat Alpha", Vector3(-5048.611, 376.8909, -6701.489), Location.Type.Comm),
		Location("Kem Gereja Merah", Vector3(13845.57, 280.4701, 11361.63), Location.Type.MilLocation),
		Location("Kem Helang Merah", Vector3(-3368.166, 205.6319, -4907.256), Location.Type.MilHarb),
		Location("Bukit Ketot", Vector3(8173.99, 1005.82, -5897.144), Location.Type.MilLocation),
		Location("Kampung Bunga Kertas", Vector3(-3180.754, 304.8342, -12980.27), Location.Type.CivVil),
		Location("Pekan Rusa Pantas", Vector3(-3671.027, 333.1158, -5993.409), Location.Type.CivVil),
		Location("Lembah Genting Tinggi", Vector3(-451.7679, 836.5936, -8860.411), Location.Type.MilLocation),
		Location("Port Rajang Selatan", Vector3(-7951.542, 203.5004, 7720.742), Location.Type.CivVil),
		Location("Kepulauan Pelaut Beta", Vector3(7275.744, 241.37, -10821.89), Location.Type.Comm),
		Location("Kem Gunung Gurun Supply Depot", Vector3(-10699.12, 381.8536, 11071.68), Location.Type.MilStrong),
		Location("Rajang Temple", Vector3(-4325.398, 497.1956, 6872.245), Location.Type.CivVil),
		Location("Bandar Lengkok Sungai", Vector3(-8217.518, 212.195, 6501.447), Location.Type.CivVil),
		Location("Kem Jalan Gurun", Vector3(-8934.59, 239.7559, 7473.34), Location.Type.MilLocation),
		Location("Pulau Ombak Merah", Vector3(-2981.661, 262.8177, 13857.47), Location.Type.MilLocation),
		--Location("Bukit Bura", Vector3(2753.385, 424.2416, -7322.649), Location.Type.MilLocation),
		Location("Bukit Bura", Vector3(2848.076416, 403.071289, -7414.663574), Location.Type.MilLocation),
		Location("Kampung Jalan Gunung", Vector3(3390.594, 490.7922, 1909.7), Location.Type.CivVil),
		Location("Kem Kuala Utara", Vector3(13869.81, 189.4279, 10606.23), Location.Type.MilHarb),
		Location("Kampung Bahari Village", Vector3(-6953.055, 229.9818, -9774.106), Location.Type.MilStrong),
		Location("Pekan Dusun Rambutan", Vector3(1031.712, 254.3053, 10127.8), Location.Type.CivVil),
		--Location("Panau Falls Casino", Vector3(2181.745, 696.8648, 1371.177), Location.Type.CivVil),
		Location("Panau Falls Casino", Vector3(2181.745, 645.841858, 1371.177), Location.Type.CivVil),
		Location("Kampung Tokong Dalam", Vector3(3503.015, 702.4131, -458.8622), Location.Type.CivVil),
		Location("Kem Port Rodrigo", Vector3(-4664.661, 190.5764, 11762.42), Location.Type.MilHarb),
		Location("Kota Pantai Kuala", Vector3(189.7178, 205.481, -12526.7), Location.Type.CivCity),
		Location("Kepulauan Pelaut Gamma", Vector3(12532.1, 260.5356, -6872.014), Location.Type.Comm),
		Location("Tasik Jernih", Vector3(-186.1156, 206.6427, 5653.479), Location.Type.CivVil),
		Location("Kampung Pokok Ru", Vector3(10022.48, 204.4316, -10956.25), Location.Type.CivVil),
		Location("Desa Kuda Lari", Vector3(10820.66, 295.2787, 3669.629), Location.Type.CivVil),
		Location("Kampung Batu Tiga", Vector3(-5867.176, 236.8017, 2473.622), Location.Type.MilLocation),
		Location("Pulau Panau Kecil", Vector3(11225.62, 260.3678, -7528.702), Location.Type.MilLocation),
		Location("Port Kuala Besar", Vector3(-268.0635, 209.98, -3604.553), Location.Type.MilHarb),
		Location("Kampung Sawah Hijau", Vector3(9568.072, 207.6889, 3271.098), Location.Type.CivVil),
		Location("Gunung Hutan Merah", Vector3(-8503.434, 239.8902, 2171.95), Location.Type.MilLocation),
		Location("Kampung Bunga Mawar", Vector3(13568.29, 197.9329, 3252.776), Location.Type.MilHarb),
		Location("Kampung Sawah Hutan", Vector3(-2830.986, 220.6546, 9919.413), Location.Type.CivVil),
		Location("Bandar Baru Nipah", Vector3(-499.1229, 242.4776, -12096.36), Location.Type.CivCity),
		Location("Awan Cendawan Power Plant", Vector3(9078.66, 202.9968, 1485.909), Location.Type.MilStrong),
		Location("Kampung Tukang Besi", Vector3(12354.82, 271.382, -1650.81), Location.Type.CivVil),
		Location("Kampung Kepulauan Selatan", Vector3(2184.427, 196.5946, 7002.66), Location.Type.CivVil),
		Location("Banjaran Berawan Besar Beta", Vector3(-1570.055, 527.3829, -11711.6), Location.Type.Comm),
		Location("Gunung Condong", Vector3(9350.65, 306.0321, 9314.123), Location.Type.MilLocation),
		Location("Kampung Papan Tanda", Vector3(2637.957, 245.1643, 4867.09), Location.Type.CivVil),
		Location("Bandar Jeti Batu", Vector3(7286.844, 202.1595, 3302.721), Location.Type.CivVil),
		Location("Pekan Kesuma", Vector3(5374.749, 204.2978, 13954.49), Location.Type.CivCity),
		--Location("Gunung Tasik Facility", Vector3(3164.62, 1296.626, -3777.025), Location.Type.MilLocation),
		Location("Gunung Tasik Facility", Vector3(3164.62, 1234, -3777.025), Location.Type.MilLocation),
		Location("Gurun Lautan Lama Beta", Vector3(-10360.72, 334.369, 5189.125), Location.Type.Comm),
		Location("Kampung Negeri Sawah", Vector3(12692.07, 295.3927, -2382.073), Location.Type.CivVil),
		Location("Kampung Kala Merah", Vector3(-5301.203, 651.0872, 5774.312), Location.Type.MilLocation),
		Location("Pekan Lalang Liar", Vector3(-405.5977, 212.5643, -13008.34), Location.Type.CivCity),
		Location("Pekan Putra Gunung", Vector3(2186.499, 238.1986, 9866.725), Location.Type.CivVil),
		Location("Pelantar Gas Kepulauan Pelaut", Vector3(9997.194, 236.3287, -14187.47), Location.Type.OilRig),
		Location("Pekan Gua Cina", Vector3(10808.48, 284.0437, -9597.311), Location.Type.CivVil),
		Location("Lembah Delima", Vector3(9536.905, 204.4068, 3845.705), Location.Type.MilAir),
		Location("Pekan Labah Hitam", Vector3(7225.047, 822.8594, -1187.798), Location.Type.CivVil),
		Location("Kem Pulau Kerbau", Vector3(10230.77, 209.9794, 10824.36), Location.Type.MilHarb),
		Location("Kota Tinggi", Vector3(4734.563, 1069.41, -1415.875), Location.Type.CivVil),
		Location("Kem Kapitan Luk Ya Sian", Vector3(74.19531, 1392.88, -6291.536), Location.Type.MilLocation),
		Location("Kuala Cengkih", Vector3(7210.072, 202.9297, -12004.09), Location.Type.MilHarb),
		Location("Pelantar Gas Panau Timur", Vector3(13096.18, 236.3287, 4871.582), Location.Type.OilRig),
		Location("Kampung Nur Cahaya", Vector3(-7031.882, 315.3552, 5390.055), Location.Type.CivCity),
		Location("Pekan Cahaya Matahari", Vector3(11393.25, 258.5214, -6938.114), Location.Type.CivVil),
		Location("Kepulauan Selatan Zeta", Vector3(14619.25, 612.9855, 12576.75), Location.Type.Comm),
		Location("Gunung Pawang Tua", Vector3(10953.24, 251.841, 2082.581), Location.Type.MilLocation),
		Location("Kampung Tujuh Telaga", Vector3(624.0022, 207.0588, 19.56255), Location.Type.MilAir),
		Location("Lembah Cerah", Vector3(-9609.995, 289.1035, 9135.464), Location.Type.CivVil),
		Location("Pelantar Gas Pandak Panay", Vector3(-7495.57, 236.3287, -15060.68), Location.Type.OilRig),
		Location("Pekan Buah Melimpah", Vector3(-1647.285, 361.0127, -5425.193), Location.Type.CivVil),
		Location("Kampung Relau Merah", Vector3(-10898.58, 598.2291, 3424.263), Location.Type.CivVil),
		Location("Kem Komander Williamson", Vector3(12473.27, 897.62, 11692.63), Location.Type.MilLocation),
		Location("Kuala Merah", Vector3(-7174.39, 265.2337, -7468.055), Location.Type.CivVil),
		Location("Banjaran Berawan Besar Gamma", Vector3(-2182.56, 1125.015, -6808.325), Location.Type.Comm),
		Location("Kota Istana Purba", Vector3(2942.261, 1068.958, -4965.979), Location.Type.CivVil),
		Location("Pekan Jalan Pokok", Vector3(-6852.027, 268.8942, 9524.576), Location.Type.CivVil),
		Location("Bandar Bukit Kuprum Lama", Vector3(-3056.877, 196.7899, 8511.983), Location.Type.CivVil),
		Location("Tanah Lebar", Vector3(-319.7852, 294.9111, 7073.771), Location.Type.MilAir),
		Location("Bandar Bukit Tahan", Vector3(8868.021, 209.9794, -10892.06), Location.Type.CivVil),
		Location("Kem Komander Sutherland", Vector3(-9019.082, 486.125, 2830.436), Location.Type.MilLocation),
		Location("Teluk Putih", Vector3(5359.699, 203.4622, 9757.354), Location.Type.CivVil),
		Location("Negeri Cengkih", Vector3(-2776.455, 258.1857, 6473.779), Location.Type.MilLocation),
		Location("Kem Gunung Kudus", Vector3(6884.855, 1453.407, -3508.609), Location.Type.MilLocation),
		Location("Bandar Lembah Raja", Vector3(7329.622, 206.4881, 10797.03), Location.Type.CivVil),
		Location("Teluk Permata", Vector3(-6929.283, 206.2196, -10623.56), Location.Type.MilAir),
		Location("Kampung Redup", Vector3(3111.436, 698.4831, -8113.143), Location.Type.CivVil),
		Location("Pelantar Gas Ledakan Besar", Vector3(13410.08, 236.3287, -13485.48), Location.Type.OilRig),
		Location("Kuala Jernih", Vector3(-6426.869, 358.8262, 4094.197), Location.Type.MilLocation),
		Location("Hutan Nenas", Vector3(7776.102, 413.3456, 14798.38), Location.Type.MilLocation),
		Location("Pekan Kuil", Vector3(7040.314, 285.2112, 11993.44), Location.Type.CivVil),
		Location("Kepulauan Selatan Mu", Vector3(2309.107, 352.5917, 9014.055), Location.Type.Comm),
		Location("Bandar Kolam Dalam", Vector3(9983.953, 212.7729, -9679.302), Location.Type.CivVil),
		Location("Pelantar Gas Telok Beting Timur", Vector3(15525.08, 236.3287, -4305.083), Location.Type.OilRig),
		--Location("PAN MILSAT", Vector3(7056.561, 776.8174, 1036.695), Location.Type.MilLocation),
		Location("PAN MILSAT", Vector3(6923.709473, 716.891052, 1037.186035), Location.Type.MilLocation),
		Location("Cape Carnival", Vector3(13788.11, 222.02, -2315.564), Location.Type.MilLocation),
		Location("Port Gurun Lautan Lama", Vector3(-13579.83, 209.6284, 6453.933), Location.Type.MilHarb),
		Location("Kampung Padang Luas", Vector3(10851.88, 200.9827, -8668.016), Location.Type.MilHarb),
		Location("Kampung Nipah", Vector3(12970.27, 265.3497, 606.3408), Location.Type.CivVil),
		Location("Pekan Air Hangat", Vector3(-5188.821, 215.822, -5287.935), Location.Type.CivVil),
		Location("Pekan Sri Vijaya", Vector3(-12415.79, 196.842, 13460.16), Location.Type.CivVil),
		Location("Kampung Pantai Berangin", Vector3(11505.94, 202.0262, -4135.216), Location.Type.CivVil),
		Location("Kampung Tanah Runtuh", Vector3(11445.87, 365.0813, 2291.908), Location.Type.CivVil),
		Location("Pekan Hutan Lama", Vector3(-6903.773, 206.2867, -2117.86), Location.Type.CivVil),
		Location("Hutan Besar", Vector3(7587.743, 375.185, 13662.37), Location.Type.MilLocation),
		Location("Pekan Kuala Kering", Vector3(1741.547, 202.2776, 7494.624), Location.Type.CivVil),
		Location("Kampung Tanah Bernilai", Vector3(11262.32, 245.0957, 3103.462), Location.Type.CivVil),
		Location("Kem Sungai Floodgates", Vector3(-8053.476, 185.5706, 3221.842), Location.Type.MilLocation),
		Location("Kampung Sirip Tajam", Vector3(-6937.369, 212.0635, -11319.59), Location.Type.CivVil),
		Location("Pulau Berapi", Vector3(-1549.777, 208.8105, 939.5184), Location.Type.MilHarb),
		Location("Fasility Gunung Hutan Tinggi", Vector3(12864.55, 595.9291, 12905.51), Location.Type.MilLocation),
		Location("Kampung Pasir Panjang", Vector3(-11559.06, 591.258, 3106.423), Location.Type.CivVil),
		Location("Kampung Tanjung Luas", Vector3(2414.036, 202.7877, 4478.184), Location.Type.CivVil),
		Location("Kem Hang Johan", Vector3(9937.966, 222.119, 14220.43), Location.Type.MilLocation),
		Location("Bandar Lombong Besi", Vector3(12526.27, 240.1035, -8533.578), Location.Type.MilLocation),
		Location("Tanah Raya Timur Zeta", Vector3(2708.759, 561.2208, 3081.291), Location.Type.Comm),
		Location("Pekan Batang Kelepek", Vector3(5379.945, 1459.97, -3364.222), Location.Type.CivVil),
		Location("Panau City - Residential District", Vector3(-12686.05, 203.1647, -884.1532), Location.Type.CivCity),
		Location("Bandar Suralaya", Vector3(-1815.607, 684.4924, -9356.023), Location.Type.CivVil),
		Location("Tanah Raya Timur Lambda", Vector3(12035.46, 342.4796, -1216.77), Location.Type.Comm),
		Location("Kem Gunung Belakang Patah", Vector3(5756.884, 1215.732, -106.0478), Location.Type.MilLocation),
		Location("Kem Sungai Cerah", Vector3(-9493.446, 554.9537, 5582.951), Location.Type.MilLocation),
		Location("Pulau Penjala", Vector3(-4887.8, 200.9248, -3919.574), Location.Type.CivVil),
		Location("Kampung Hutan Hijau", Vector3(1862.522, 201.0226, 2763.639), Location.Type.CivVil),
		Location("Kepulauan Selatan Alpha", Vector3(1854.942, 216.5591, 10318.19), Location.Type.Comm),
		Location("Bukit Marmar Pecah", Vector3(-4334.824, 410.3914, -7919.773), Location.Type.MilLocation),
		Location("Kepulauan Selatan Epsilon", Vector3(11393.91, 763.5576, 12989.54), Location.Type.Comm),
		Location("Banjaran Berawan Besar Zeta", Vector3(5412.214, 1416.178, -2099.084), Location.Type.Comm),
		Location("Kepulauan Selatan Delta", Vector3(2251.685, 592.3736, 12041.24), Location.Type.Comm),
		Location("Kem Gunung Raya", Vector3(4703.085, 1652.525, -4738.075), Location.Type.MilLocation),
		Location("Gurun Lautan Lama Delta", Vector3(-9093.51, 399.3805, 6926.042), Location.Type.Comm),
		Location("Pelabuhan Saudagar Harbor", Vector3(-14871.19, 196.2978, -2944.443), Location.Type.MilStrong),
		Location("Pekan Tanjung", Vector3(1404.5, 203.6984, 6744.877), Location.Type.CivVil),
		Location("Kem General Vikneshwaran", Vector3(1285.233, 227.4771, 404.9492), Location.Type.MilLocation),
		Location("Pulau Ketam Kecil", Vector3(11682.66, 187.1396, -5123.087), Location.Type.MilHarb),
		Location("Kampung Pantai Kelabu", Vector3(7815.744, 205.503, 2978.539), Location.Type.CivVil),
		Location("Tanjung Besar", Vector3(8738.647, 231.0613, -9127.161), Location.Type.MilLocation),
		Location("Pekan Bukit Nenas", Vector3(-4462.093, 316.0937, -5898.807), Location.Type.CivVil),
		Location("Paya Dalam", Vector3(3694.802, 657.6589, 2357.78), Location.Type.MilLocation),
		Location("Telok Berlian", Vector3(7586.304, 215.7644, 12441.57), Location.Type.CivVil),
		Location("Kampung Teratai Putih", Vector3(-7175.5, 204.3399, -6330.171), Location.Type.CivVil),
		Location("Kota Buluh", Vector3(8432.64, 201.4412, -12844.17), Location.Type.CivVil),
		-- NON-SETTLEMENTS
		Location("Hantu Island", Vector3(-14091.01, 688.75, -14145.97), Location.Type.MilStrong),
		Location("Pie Island", Vector3(8068.52, 204.97, -15463.15), Location.Type.Comm)
	}
}

function Map:ScreenToWorld( position )
	position = ((((position - (Render.Size / 2)) / Map.Zoom) - Map.Offset) / Render.Height) * 32768

	return Vector3( position.x, Physics:GetTerrainHeight(position), position.y )
end

function Map:WorldToScreen( position )
	return (Render.Size / 2) + ((Map.Offset + ((Vector2(position.x, position.z) / 32768) * Render.Height)) * Map.Zoom)
end

function Map:ToggleWaypoint( position )
	local wPosition, waypoint = Waypoint:GetPosition()

	if waypoint then
		Waypoint:Remove()
		if self.soundRemove then
			self.soundRemove:Play()
			self.soundRemove:SetParameter(0,1)
		else
			self.soundRemove = ClientSound.Create(AssetLocation.Game, {
						bank_id = 20,
						sound_id = 13,
						position = Camera:GetPosition(),
						angle = Angle()
			})

			self.soundRemove:SetParameter(0,1)
		end
	else
		Waypoint:SetPosition( position )
		if self.soundSet then
			self.soundSet:Play()
			self.soundSet:SetParameter(0,1)
		else
			self.soundSet = ClientSound.Create(AssetLocation.Game, {
				bank_id = 20,
				sound_id = 12,
				position = Camera:GetPosition(),
				angle = Angle()
			})

			self.soundSet:SetParameter(0,1)
		end
	end
end

function Map:Draw()
	if Map.Border then
		Render:FillArea( Vector2.Zero, Render.Size, Color( 10, 10, 10, math.lerp( 0, 200, animationValue ) ) )
	end

	Map.Heli:SetSize( Vector2.One * 30 )
	Map.Image:SetSize( Vector2.One * Render.Height * Map.Zoom )
	Map.Image:SetPosition( Map:WorldToScreen( Vector3( 16384, 0, 16384 ) ) - Map.Image:GetSize() )

	if self.soundSet then
		self.soundSet:SetPosition( Camera:GetPosition() )
	end

	if self.soundRemove then
		self.soundRemove:SetPosition( Camera:GetPosition() )
	end

	if Map.Ramka then
		local ramkaSize = Vector2( 3, 3 )
		Render:FillArea( Map.Image:GetPosition() - ramkaSize, Map.Image:GetSize() + ramkaSize * 2, Color( 185, 215, 255, 100 * Map.RamkaAlpha ) )
	end

	Map.Image:Draw()

	local scale = Map.IconScale
	local locations = Map.Locations
	local isUsingGamepad = PDA:IsUsingGamepad()
	local scaleFactor = scale * (isUsingGamepad and 2 or 1)

	if Map.LocationsVisible then
		Map.ActiveLocation = nil

		for i = 1, #locations do
			local location = locations[i]
			local position = Map:WorldToScreen( location.position )

			if position.x > 0 and position.y > 0 and position.x < Render.Width and position.y < Render.Height then
				if location:IsActive( position, scaleFactor ) then
					Map.ActiveLocation = location
				end

				location:Draw( position, scale )
			end
		end
	end

	local text_clr = Color( 255, 255, 255, math.lerp( 0, 255, animationValue ) )
	local text_shadow = Color( 0, 0, 0, math.lerp( 0, 255, animationValue ) )

	if rendermap then
		local text_size = 14
		local pId = LocalPlayer:GetId()
		local pWorldId = LocalPlayer:GetWorld():GetId()
		local background_clr = Color( 0, 0, 0, math.lerp( 0, 150, animationValue ) )

		for _, player in pairs( Map.Players ) do
			if player.id ~= pId and player.worldId == pWorldId then
				local position = Map:WorldToScreen( player.pos )
				local str = player.name

				Render:DrawCircle( position, Render.Size.y * 0.0055, text_shadow )
				Render:FillCircle( position, Render.Size.y * 0.005, player.col )

				if labels ~= 0 then
					Render:FillArea( position + Render.Size * 0.003, Vector2( Render:GetTextWidth( str, text_size ), Render:GetTextHeight( str, text_size ) ), background_clr )
					Render:DrawShadowedText( position + Render.Size * 0.003, str, player.col, text_shadow, text_size )
				end
			end
		end

		local Transform = Transform2()
		Transform:Translate( Map:WorldToScreen( LocalPlayer:GetPosition() ) - Map.Marker:GetSize() / 2 + Map.Marker:GetSize() / 2 )
		Transform:Rotate( -LocalPlayer:GetAngle().yaw )

		Render:SetTransform( Transform )

		Map.Marker:SetSize( Vector2( Render.Height * 0.027, Render.Height * 0.027 ) )
		Map.Marker:Draw( - Map.Marker:GetSize() / 2, Map.Marker:GetSize(), Vector2.Zero, Vector2.One )

		Render:ResetTransform()

		local frac = math.sin( Client:GetElapsedSeconds() * 15 ) * 0.5 + 0.5
		marker_animation = math.lerp( 0.5, 1, frac )
		Map.Marker:SetAlpha( marker_animation )

		local position, waypoint = Waypoint:GetPosition()

		if waypoint then
			Map.Waypoint.position = position
			Map.Waypoint:Draw( Map:WorldToScreen(position), scale * Map.WaypointScale )
		end

		if Map.ActiveLocation then
			Map.ActiveLocation:DrawTitle( Map:WorldToScreen(Map.ActiveLocation.position), scale )
		end

		if isUsingGamepad then
			local center = ( Render.Size / 2 )
			local width = Vector2.Right * ( Render.Width / 2.5 )
			local offsetWidth = Vector2.Right * ( Location.Icon.Size.x * scale )

			Render:DrawLine( center - width, center - offsetWidth, text_clr )
			Render:DrawLine( center + width, center + offsetWidth, text_clr )

			local height = Vector2.Down * ( Render.Height / 2.5 )
			local offsetHeight = Vector2.Down * ( Location.Icon.Size.y * scale )

			Render:DrawLine( center - height, center - offsetHeight, text_clr )
			Render:DrawLine( center + height, center + offsetHeight, text_clr )
		end

		Render:SetFont( AssetLocation.Disk, "Archivo.ttf" )

		local mpos = Mouse:GetPosition()
		local position = Map:ScreenToWorld( mpos )
		local txtx = "X: " .. string.format( "%.0f", tonumber( position.x ) )
		local txty = "Y: " .. string.format( "%.0f", tonumber( position.z ) )
		local tips_pos = Vector2( 41, 46 )

		Render:DrawShadowedText( tips_pos - Vector2.One, txtx .. "\n" .. txty, text_clr, text_shadow, 15 )

		local height = Render:GetTextHeight("A") * 2.5
		tips_pos.y = tips_pos.y + height

		Render:DrawShadowedText( tips_pos - Vector2.One, MTSetWp .. "\n" .. MTPToggle .. "\n" .. MTExtract, text_clr, text_shadow, 15 )
	end

	if extraction_timer then
		local position = math.lerp( Map:WorldToScreen(previous_position), Map:WorldToScreen(next_position), extraction_timer:GetSeconds() / extraction_delay )
		Map.Heli:SetPosition( position - 0.5 * Map.Heli:GetSize() )
		Map.Heli:Draw()
	end

	collectgarbage()
end
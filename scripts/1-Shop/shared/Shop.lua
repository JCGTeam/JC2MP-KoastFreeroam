class 'Shop'
class 'BuyMenuEntry'

function BuyMenuEntry:__init( model_id, entry_type, template, decal )
    self.model_id = model_id
    self.entry_type = entry_type
	self.template = template
	self.decal = decal
end

function BuyMenuEntry:GetModelId()
    return self.model_id
end

function BuyMenuEntry:GetTemplate()
    return self.template
end

function BuyMenuEntry:GetDecal()
    return self.decal
end

function BuyMenuEntry:GetListboxItem()
    return self.listbox_item
end

function BuyMenuEntry:SetListboxItem( item )
    self.listbox_item = item
end

class 'VehicleBuyMenuEntry' ( BuyMenuEntry )

function VehicleBuyMenuEntry:__init( model_id, template, decal, name, rank )
    BuyMenuEntry.__init( self, model_id, 1, template, decal )
    self.name = name
	self.rank = rank
end

function VehicleBuyMenuEntry:GetName()
	local modelName = Vehicle.GetNameByModelId( self.model_id )
	local DisplayName = modelName
	if self.name ~= nil and self.name ~= "" then
		DisplayName = modelName .. " - " .. self.name
	end
	if self.template ~= nil and self.template ~= "" then
		DisplayName = DisplayName .. " [" .. self.template .. "]"
	end
	if self.decal ~= nil and self.decal ~= "" then
		DisplayName = DisplayName .. " (" .. self.decal .. ")"
	end
    return DisplayName
end

function VehicleBuyMenuEntry:GetRank()
    return self.rank
end

class 'WeaponBuyMenuEntry' ( BuyMenuEntry )

function WeaponBuyMenuEntry:__init( model_id, slot, name, rank )
    BuyMenuEntry.__init( self, model_id, 2 )
    self.slot = slot
    self.name = name
	self.rank = rank
end

function WeaponBuyMenuEntry:GetSlot()
    return self.slot
end

function WeaponBuyMenuEntry:GetName()
    return self.name
end

function WeaponBuyMenuEntry:GetRank()
    return self.rank
end

class 'ModelBuyMenuEntry' ( BuyMenuEntry )

function ModelBuyMenuEntry:__init( model_id, name, rank )
    BuyMenuEntry.__init( self, model_id, 2 )
    self.name = name
	self.rank = rank
end

function ModelBuyMenuEntry:GetName()
    return self.name
end

function ModelBuyMenuEntry:GetRank()
    return self.rank
end

class 'AppearanceBuyMenuEntry' ( BuyMenuEntry )

function AppearanceBuyMenuEntry:__init( model_id, itemtype, name, rank )
    BuyMenuEntry.__init( self, model_id, itemtype, 2 )
    self.name = name
    self.itemtype = itemtype
	self.rank = rank
end

function AppearanceBuyMenuEntry:GetName()
    return self.name
end

function AppearanceBuyMenuEntry:GetType()
    return self.itemtype
end

function AppearanceBuyMenuEntry:GetRank()
    return self.rank
end

class 'ParachutesBuyMenuEntry' ( BuyMenuEntry )

function ParachutesBuyMenuEntry:__init( model_id, name, rank )
    BuyMenuEntry.__init( self, model_id, event, 2 )
    self.name = name
	self.rank = rank
end

function ParachutesBuyMenuEntry:GetName()
    return self.name
end

function ParachutesBuyMenuEntry:GetRank()
    return self.rank
end

function Shop:CreateItems()
    self.types = {
        vehicles = 1,
        weapon = 2,
        character = 3,
		appearance = 4
    }

    self.id_types = {}

    for k, v in pairs( self.types ) do
        self.id_types[v] = k
    end

    self.items = {
         [self.types.vehicles] = {
            { "cars", "bikes", "jeeps", "pickups", "buses", "heavy", "tractors", "helicopters", "planes", "boats", "DLC" },

			["cars"] = {
				VehicleBuyMenuEntry( 44, "Softtop", nil, "" ),
				-- ^ Hamaya Oldman Softtop
				VehicleBuyMenuEntry( 44, "Cab", nil, "" ),
				-- ^ Hamaya Oldman Opentop
				VehicleBuyMenuEntry( 44, "Hardtop", nil, "" ),
				-- ^ Hamaya Oldman Hardtop
				VehicleBuyMenuEntry( 29, nil, nil, "" ),
				-- ^ Sakura Aquila City
				VehicleBuyMenuEntry( 15, nil, nil, "" ),
				-- ^ Sakura Aquila Space
				VehicleBuyMenuEntry( 70, nil, nil, "" ),
				-- ^ Sakura Aquila Forte (Taxi)
				VehicleBuyMenuEntry( 55, nil, nil, "" ),
				-- ^ Sakura Aquila Metro ST
				VehicleBuyMenuEntry( 13, nil, nil, "" ),
				-- ^ Stinger Dunebug 84
				VehicleBuyMenuEntry( 54, nil, nil, "" ),
				-- ^ Boyd Fireflame 544
				VehicleBuyMenuEntry( 8, nil, nil, "" ),
				-- ^ Columbi Excelsior (Limo)
				VehicleBuyMenuEntry( 8, "Hijack_Rear", nil, "" ),
				-- ^ Columbi Excelsior Rear Stuntjump (Limo)
				VehicleBuyMenuEntry( 78, "Hardtop", nil, "" ),
				-- ^ Civadier 999 Hardtop
				VehicleBuyMenuEntry( 78, "Cab", nil, "" ),
				-- ^ Civadier 999 Opentop
				VehicleBuyMenuEntry( 2, nil, nil, "" ),
				-- ^ Mancini Cavallo 1001
				VehicleBuyMenuEntry( 91, "Hardtop", nil, "" ),
				-- ^ Titus ZJ Hardtop
				VehicleBuyMenuEntry( 91, "Softtop", nil, "" ),
				-- ^ Titus ZJ Softtop
				VehicleBuyMenuEntry( 91, "Cab", nil, "" ),
				-- ^ Titus ZJ Opentop
				VehicleBuyMenuEntry( 35, nil, nil, "" ),
				-- ^ Garret Traver-Z
				VehicleBuyMenuEntry( 35, "FullyUpgraded", nil, "" ),
				-- ^ Garret Traver-Z Armed
			},
			
			["bikes"] = {
				VehicleBuyMenuEntry( 9 ),
				-- ^ Tuk-Tuk Rickshaw
				VehicleBuyMenuEntry( 22 ),
				-- ^ Tuk-Tuk Laa
				VehicleBuyMenuEntry( 47 ),
				-- ^ Schulz Virginia
				VehicleBuyMenuEntry( 83 ),
				-- ^ Mosca 125 Performance
				VehicleBuyMenuEntry( 32 ),
				-- ^ Mosca 2000
				VehicleBuyMenuEntry( 90 ),
				-- ^ Makota MZ250
				VehicleBuyMenuEntry( 61 ),
				-- ^ Makota MZ 260X
				VehicleBuyMenuEntry( 89 ),
				-- ^ Hamaya Y250S
				VehicleBuyMenuEntry( 43 ),
				-- ^ Hamaya GSY650
				VehicleBuyMenuEntry( 74 ),
				-- ^ Hamaya 1300 Elite Cruiser
				VehicleBuyMenuEntry( 21 ),
				-- ^ Hamaya Cougar 600
				VehicleBuyMenuEntry( 36, "Sport", nil, "" ),
				-- ^ Shimuzu Tracline 
				VehicleBuyMenuEntry( 36, "Gimp", nil, "" ),
				-- ^ Shimuzu Tracline RollCage
				VehicleBuyMenuEntry( 36, "Civil", nil, "" ),
				-- ^ Shimuzu Tracline Racks
				VehicleBuyMenuEntry( 11, "Police", nil, "" ),
				-- ^ Shimuzu Tracline Windshield
			},

			["jeeps"] = {
				VehicleBuyMenuEntry( 48, "Buggy", nil, "" ),
				-- ^ Maddox FVA 45
				VehicleBuyMenuEntry( 48, "BuggyMG", nil, "" ),
				-- ^ Maddox FVA 45 Mounted Gun
				VehicleBuyMenuEntry( 87, "Hardtop", nil, "" ),
				-- ^ Wilforce Trekstar Hardtop
				VehicleBuyMenuEntry( 87, "Softtop", nil, "" ),
				-- ^ Wilforce Trekstar Softtop
				VehicleBuyMenuEntry( 87, "Cab", nil, "" ),
				-- ^ Wilforce Trekstar Opentop
				VehicleBuyMenuEntry( 52, nil, nil, "" ),
				-- ^ Sass PP12 Hogg
				VehicleBuyMenuEntry( 10, "Ingame", nil, "Karl Blaine's" ),
				-- ^ Sass PP12 Hogg (Karl Blaine's)
				VehicleBuyMenuEntry( 46, nil, nil, "" ),
				-- ^ MV V880
				VehicleBuyMenuEntry( 46, "Cab", nil, "" ),
				-- ^ MV V880 Opentop
				VehicleBuyMenuEntry( 46, "Combi", nil, "" ),
				-- ^ MV V880 Loaded with Gear
				VehicleBuyMenuEntry( 46, "CombiMG", nil, "" ),
				-- ^ MV V880 Loaded with Gear, Mounted Gun
				VehicleBuyMenuEntry( 72, nil, nil, "" ),
				-- ^ Chepachet PVD
				VehicleBuyMenuEntry( 84, "HardtopMG", nil, "" ),
				-- ^ Marten Storm III Mounted Gun
				VehicleBuyMenuEntry( 84, "Cab", nil, "" ),
				-- ^ Marten Storm III Opentop Truckbed
				VehicleBuyMenuEntry( 77, "Default", nil, ""),
				-- ^ Hedge Wildchild
				VehicleBuyMenuEntry( 77, nil, nil, ""),
				-- ^ Hedge Wildchild
				VehicleBuyMenuEntry( 77, "Armed", nil, "" ),
				-- ^ Hedge Wildchild Rockets
			},

			["pickups"] = {
				VehicleBuyMenuEntry( 60, nil, nil, "" ),
				-- ^ Vaultier Patrolman
				VehicleBuyMenuEntry( 26, nil, nil, "" ),
				-- ^ Chevalier Traveller SD
				VehicleBuyMenuEntry( 73, nil, nil, "" ),
				-- ^ Chevalier Express HT
				VehicleBuyMenuEntry( 23, nil, nil, "" ),
				-- ^ Chevalier Liner SB
				VehicleBuyMenuEntry( 63, nil, nil, "" ),	
				-- ^ Chevalier Traveller SC
				VehicleBuyMenuEntry( 68, nil, nil, "" ),				
				-- ^ Chevalier Traveller SX
				VehicleBuyMenuEntry( 33, nil, nil, "" ),
				-- ^ Chevalier Piazza IX
				VehicleBuyMenuEntry( 86, nil, nil, "" ),
				-- ^ Dalton N90
				VehicleBuyMenuEntry( 7, "Default", nil, "" ),
				-- ^ Poloma Renegade
				VehicleBuyMenuEntry( 7, "Armed", nil, "" ),
				-- ^ Poloma Renegade
				VehicleBuyMenuEntry( 7, "FullyUpgraded", nil, "" ),
				-- ^ Poloma Renegade Rockets
			},

			["buses"] = {
				VehicleBuyMenuEntry( 66, "Single", nil, "" ),
				-- ^ Dinggong 134D Single-Decker
				VehicleBuyMenuEntry( 66, "Double", nil, "" ),
				-- ^ Dinggong 134D Double-Decker
				VehicleBuyMenuEntry( 12 ),
				-- ^ Vanderbildt LeisureLiner
			},

			["heavy"] = {
				VehicleBuyMenuEntry( 42, nil, nil, "" ),
				-- ^ Niseco Tusker P246
				VehicleBuyMenuEntry( 49, nil, nil, "" ),
				-- ^ Niseco Tusker D18
				VehicleBuyMenuEntry( 71, nil, nil, "" ),
				-- ^ Niseco Tusker G216
				VehicleBuyMenuEntry( 41, nil, nil, "" ),
				-- ^ Niseco Tusker D22
				VehicleBuyMenuEntry( 4, nil, nil, "" ),
				-- ^ Kenwall Heavy Rescue
				VehicleBuyMenuEntry( 79, nil, nil, "" ),
				-- ^ Pocumtruck Nomad			
				VehicleBuyMenuEntry( 40, "Regular", nil, "" ),
				-- ^ Fengding EC14FD2 Longbed
				VehicleBuyMenuEntry( 40, "Crane", nil, "" ),
				-- ^ Fengding EC14FD2 Crane
				VehicleBuyMenuEntry( 40, "Crate", nil, "" ),
				-- ^ Fengding EC14FD2 Shortbed
				VehicleBuyMenuEntry( 31, nil, nil, "" ),
				-- ^ URGA-9380 Tow Cables
				VehicleBuyMenuEntry( 31, "Cab", nil, "" ),
				-- ^ URGA-9380 Empty
				VehicleBuyMenuEntry( 31, "MG", nil, "" ),
				-- ^ URGA-9380 Mounted Gun
				VehicleBuyMenuEntry( 76, nil, nil, "" ),
				-- ^ SAAS PP30 Ox
				VehicleBuyMenuEntry( 18, nil, nil, "" ),
				-- ^ SV-1003 Raider Mounted Gun
				VehicleBuyMenuEntry( 18, "Russian", nil, "" ),
				-- ^ SV-1003 Raider Russin Minigun & Guard
				VehicleBuyMenuEntry( 18, "Cannon", nil, "" ),
				-- ^ SV-1007 Stonewall
				VehicleBuyMenuEntry( 56, "Cab", nil, "" ),
				-- ^ GV-104 Razorback UnArmed
				VehicleBuyMenuEntry( 56, "Armed", nil, "" ),
				-- ^ GV-104 Razorback Minigun
				VehicleBuyMenuEntry( 56, nil, nil, "" ),
				-- ^ GV-104 Razorback Base with Autocannon
				VehicleBuyMenuEntry( 56, "FullyUpgraded", nil, "" ),
				-- ^ GV-104 Razorback with Autocannon & Machine Guns
			},

			["tractors"] = {
				VehicleBuyMenuEntry( 1, "Modern_Cab", nil, "" ),
				-- ^ Dongtai Agriboss 35 Modern Open Cab
				VehicleBuyMenuEntry( 1, "Modern_Hardtop", nil, "" ),
				-- ^ Dongtai Agriboss 35 Modern Closed Cab
				VehicleBuyMenuEntry( 1, "Classic_Cab", nil, "" ),
				-- ^ Dongtai Agriboss 35 Old Style Open Cab
				VehicleBuyMenuEntry( 1, "Classic_Hardtop", nil, "" ),
				-- ^ Dongtai Agriboss 35 Old Style Closed Cab
			},

			["helicopters"] = {
				VehicleBuyMenuEntry( 3, nil, nil, "" ),
				-- ^ Rowlinson K22
				VehicleBuyMenuEntry( 3, "FullyUpgraded", nil, "" ),
				-- ^ Rowlinson K22 Armed
				VehicleBuyMenuEntry( 14, nil, nil, "" ),
				-- ^ Mullen Skeeter Eagle
				VehicleBuyMenuEntry( 67, nil, nil, "" ),
				-- ^ Mullen Skeeter Hawk
				VehicleBuyMenuEntry( 37 ),
				-- ^ Sivirkin 15 Havoc
				VehicleBuyMenuEntry( 57, "Mission", nil, "" ),
				-- ^ Sivirkin 15 Havoc
				VehicleBuyMenuEntry( 57, "FullyUpgraded", nil, "" ),
				-- ^ Sivirkin 15 Havoc Rockets
				VehicleBuyMenuEntry( 64, nil, nil, "" ),
				-- ^ AH-33 Topachula
				VehicleBuyMenuEntry( 65, nil, nil, "" ),
				-- ^ H-62 Quapaw
				VehicleBuyMenuEntry( 62, "UnArmed", nil, "" ),
				-- ^ UH-10 Chippewa (4 Seater)
				VehicleBuyMenuEntry( 62, "Armed", nil, "" ),
				-- ^ UH-10 Chippewa (4 Seater)
				VehicleBuyMenuEntry( 62, "Cutscene", nil, "", 1 ),
				-- ^ UH-10 Chippewa (4 Seater)
				VehicleBuyMenuEntry( 62, "Dome", nil, "" ),
				-- ^ UH-10 Chippewa (4 Seater) Rockets
			},
			
			["planes"] = {
				VehicleBuyMenuEntry( 59, nil, nil, "" ),
				-- ^ Peek Airhawk 225
				VehicleBuyMenuEntry( 81, nil, nil, "" ),
				-- ^ Pell Silverbolt 6
				VehicleBuyMenuEntry( 51, nil, nil, "" ),
				-- ^ Cassius 192
				VehicleBuyMenuEntry( 30, nil, nil, "" ),
				-- ^ Si-47 Leopard
				VehicleBuyMenuEntry( 34, nil, nil, "" ),
				-- ^ G9 Eclipse
				VehicleBuyMenuEntry( 39, nil, nil, "" ),
				-- ^ Aeroliner 474
				VehicleBuyMenuEntry( 85, nil, nil, "" ),
				-- ^ Bering I-86DP
			},
			
			["boats"] = {
				VehicleBuyMenuEntry( 38, "Djonk01", nil, "" ),
				-- ^ Kuang Sunrise
				VehicleBuyMenuEntry( 38, "Djonk02", nil, "" ),
				-- ^ Kuang Sunrise 
				VehicleBuyMenuEntry( 38, "Djonk03", nil, "" ),
				-- ^ Kuang Sunrise 
				VehicleBuyMenuEntry( 38, "Djonk04", nil, "" ),
				-- ^ Kuang Sunrise 
				VehicleBuyMenuEntry( 5, "Cab", nil, "" ),
				-- ^ Pattani Gluay Empty
				VehicleBuyMenuEntry( 5, "Softtop", nil, "" ),
				-- ^ Pattani Gluay Touring (6 Seater)
				VehicleBuyMenuEntry( 5, "Fishing", nil, "" ),
				-- ^ Pattani Gluay Fishing
				VehicleBuyMenuEntry( 6 ),
				-- ^ Orque Grandois 21TT
				VehicleBuyMenuEntry( 19 ),
				-- ^ Orque Living 42T
				VehicleBuyMenuEntry( 45 ),
				-- ^ Orque Bon Ton 71FT
				VehicleBuyMenuEntry( 16 ),
				-- ^ YP-107 Phoenix
				VehicleBuyMenuEntry( 25, "Softtop", nil, "" ),
				-- ^ Trat Tang-mo Cargo
				VehicleBuyMenuEntry( 25, "Cab", nil, "" ),
				-- ^ Trat Tang-mo Empty
				VehicleBuyMenuEntry( 28 ),
				-- ^ TextE Charteu 52CT
				VehicleBuyMenuEntry( 50 ),
				-- ^ Zhejiang 6903
				VehicleBuyMenuEntry( 80 ),
				-- ^ Frisco Catshark S-38
				VehicleBuyMenuEntry( 27 ),
				-- ^ SnakeHead T20
				VehicleBuyMenuEntry( 88, "Default" ),
				-- ^ MTA Powerrun 77
				VehicleBuyMenuEntry( 88, nil, nil, "" ),
				-- ^ MTA Powerrun 77 Armed
				VehicleBuyMenuEntry( 88, "FullyUpgraded", nil, "" ),
				-- ^ MTA Powerrun 77 Rockets
				VehicleBuyMenuEntry( 69, nil, nil, "" ),
				VehicleBuyMenuEntry( 69, "Roaches", nil, "" ),
			},
			
			["DLC"] = {
				VehicleBuyMenuEntry( 75, nil, nil, "" ),
				-- ^ Tuk Tuk Boom Boom
				VehicleBuyMenuEntry( 58, nil, nil, "" ),
				-- ^ Chevalier Classic
				VehicleBuyMenuEntry( 82, nil, nil, "" ),
				-- ^ Chevalier Ice Breaker
				VehicleBuyMenuEntry( 20, nil, nil, "" ),
				-- ^ Monster Truck
				VehicleBuyMenuEntry( 53 ),
				-- ^ Agency Hovercraft
				VehicleBuyMenuEntry( 24 ),
				-- ^ F-33 DragonFly
			}
        },

        [self.types.weapon] = {
            { "righthand", "lefthand" , "primary", "★ VIP" },
            ["righthand"] = {
				WeaponBuyMenuEntry( Weapon.BubbleGun, 1, "Пузырьковая Пушка" ),
                WeaponBuyMenuEntry( Weapon.Handgun, 1, "Пистолетик" ),
                WeaponBuyMenuEntry( Weapon.Revolver, 1, "Револьвер" ),
                WeaponBuyMenuEntry( Weapon.SMG, 1, "СМГ" ),
                WeaponBuyMenuEntry( Weapon.SawnOffShotgun, 1, "Пилотный Дробовик" ),
				WeaponBuyMenuEntry( Weapon.GrenadeLauncher, 1, "Гранатомет" ),
				WeaponBuyMenuEntry( Weapon.MachineGun, 1, "Пулемет" ),
				WeaponBuyMenuEntry( Weapon.SignatureGun, 1, "DLC - Личное оружие Рико" ),
            },

            ["lefthand"] = {
				WeaponBuyMenuEntry( Weapon.BubbleGun, 0, "Пузырьковая Пушка" ),
                WeaponBuyMenuEntry( Weapon.Handgun, 0, "Пистолетик" ),
                WeaponBuyMenuEntry( Weapon.Revolver, 0, "Револьвер" ),
                WeaponBuyMenuEntry( Weapon.SMG, 0, "СМГ" ),
                WeaponBuyMenuEntry( Weapon.SawnOffShotgun, 0, "Пилотный Дробовик" ),
				WeaponBuyMenuEntry( Weapon.GrenadeLauncher, 0, "Гранатомет" ),
				WeaponBuyMenuEntry( Weapon.MachineGun, 0, "Пулемет" ),
				WeaponBuyMenuEntry( Weapon.SignatureGun, 0, "DLC - Личное оружие Рико" ),
            },
			
            ["primary"] = {
				WeaponBuyMenuEntry( Weapon.Assault, 2, "Штурмовая Винтовка" ),
				WeaponBuyMenuEntry( Weapon.Shotgun, 2, "Дробовик" ),
				WeaponBuyMenuEntry( Weapon.MachineGun, 2, "Пулемет" ),
				WeaponBuyMenuEntry( Weapon.Sniper, 2, "Снайперская Винтовка" ),
				WeaponBuyMenuEntry( Weapon.RocketLauncher, 2, "Ракетная Установка" ),
				WeaponBuyMenuEntry( Weapon.PanayRocketLauncher, 2, "СУПЕР Ракетная Установка" ),
				WeaponBuyMenuEntry( Weapon.Airzooka, 2, "DLC - Воздушное силовое ружье" ),
				WeaponBuyMenuEntry( Weapon.ClusterBombLauncher, 2, "DLC - Кластерный бомбомет" ),
				WeaponBuyMenuEntry( Weapon.MultiTargetRocketLauncher, 2, "DLC - Залповая ракетная установка" ),
				WeaponBuyMenuEntry( Weapon.QuadRocketLauncher, 2, "DLC - Счетвернный гранатомет" ),
				WeaponBuyMenuEntry( Weapon.AlphaDLCWeapon, 2, "DLC - Штурмовая винтовка 'В яблочко'" ),
			},
			
			["★ VIP"] = {
				WeaponBuyMenuEntry( Weapon.PanayRocketLauncher, 1, "СУПЕР Ракетная Установка [Правая рука]", 1 ),
				WeaponBuyMenuEntry( Weapon.PanayRocketLauncher, 0, "СУПЕР Ракетная Установка [Левая рука]", 1 ),
				WeaponBuyMenuEntry( Weapon.RocketARVE, 2, "Ракеты", 1 ),
				WeaponBuyMenuEntry( Weapon.SAM, 2, "ПВО", 1 ),
            }
        },

        [self.types.character] = {
            { "boys", "girls", "roaches", "ulars", "reapers", "gov", "agency", "misc", "★ VIP" },
            ["boys"] = {
				ModelBuyMenuEntry( 54, "Русский телохранитель" ),
                ModelBuyMenuEntry( 96, "Японский телохранитель" ),
				ModelBuyMenuEntry( 6, "Китайский телохранитель" ),
                ModelBuyMenuEntry( 80, "Прохожий 1" ),
                ModelBuyMenuEntry( 93, "Прохожий 2" ),
				ModelBuyMenuEntry( 7, "Прохожий 3" ),
				ModelBuyMenuEntry( 10, "Прохожий 4" ),
				ModelBuyMenuEntry( 13, "Прохожий 5" ),
				ModelBuyMenuEntry( 24, "Прохожий 6" ),
				ModelBuyMenuEntry( 28, "Прохожий 7" ),
				ModelBuyMenuEntry( 29, "Прохожий 8" ),
				ModelBuyMenuEntry( 35, "Прохожий 9" ),
				ModelBuyMenuEntry( 56, "Прохожий 10" ),
				ModelBuyMenuEntry( 68, "Прохожий 11" ),
				ModelBuyMenuEntry( 73, "Прохожий 12" ),
				ModelBuyMenuEntry( 75, "Прохожий 13" ),
				ModelBuyMenuEntry( 76, "Прохожий 14" ),
				ModelBuyMenuEntry( 88, "Прохожий 15" ),
				ModelBuyMenuEntry( 91, "Прохожий 16" ),
				ModelBuyMenuEntry( 99, "Прохожий 17" ),
                ModelBuyMenuEntry( 15, "Стриптизер 1" ),
                ModelBuyMenuEntry( 17, "Стриптизер 2" ),
                ModelBuyMenuEntry( 1, "Бандит 1" ),
                ModelBuyMenuEntry( 39, "Бандит 2" ),
				ModelBuyMenuEntry( 78, "Босс бандитов" ),
				ModelBuyMenuEntry( 50, "Нефтяной работник" ),
				ModelBuyMenuEntry( 57, "Нефтяной работник 2" ),
				ModelBuyMenuEntry( 89, "Фабричный рабочий" ),
                ModelBuyMenuEntry( 40, "Фабричный босс" ),
            },

            ["girls"] = {
				ModelBuyMenuEntry( 14, "Прохожая 1" ),
				ModelBuyMenuEntry( 31, "Прохожая 2" ),
				ModelBuyMenuEntry( 41, "Прохожая 3" ),
				ModelBuyMenuEntry( 46, "Прохожая 4" ),
				ModelBuyMenuEntry( 47, "Прохожая 5" ),
				ModelBuyMenuEntry( 62, "Прохожая 6" ),
				ModelBuyMenuEntry( 72, "Прохожая 7" ),
				ModelBuyMenuEntry( 82, "Прохожая 8" ),
				ModelBuyMenuEntry( 92, "Прохожая 9" ),
				ModelBuyMenuEntry( 102, "Прохожая 10" ),
				ModelBuyMenuEntry( 60, "Девушка" ),
				ModelBuyMenuEntry( 86, "Стриптизёрша" ),
            },

            ["roaches"] = {
                ModelBuyMenuEntry( 2, "Разак Разман" ),
                ModelBuyMenuEntry( 5, "Элита" ),
                ModelBuyMenuEntry( 32, "Техник" ),
                ModelBuyMenuEntry( 85, "Солдат 1" ),
                ModelBuyMenuEntry( 59, "Солдат 2" )
            },

            ["ulars"] = {
                ModelBuyMenuEntry( 38, "Шри Ираван" ),
                ModelBuyMenuEntry( 87, "Элита" ),
                ModelBuyMenuEntry( 22, "Техник" ),
                ModelBuyMenuEntry( 27, "Солдат 1" ),
                ModelBuyMenuEntry( 103, "Солдат 2" )
            },

            ["reapers"] = {
                ModelBuyMenuEntry( 90, "Боло Сантоси" ),
                ModelBuyMenuEntry( 63, "Элита" ),
                ModelBuyMenuEntry( 8, "Техник" ),
                ModelBuyMenuEntry( 12, "Солдат 1" ),
                ModelBuyMenuEntry( 58, "Солдат 2" ),
            },

            ["gov"] = {
                ModelBuyMenuEntry( 74, "Малыш Панай" ),
                ModelBuyMenuEntry( 67, "Сгоревший малыш Панай" ),
                ModelBuyMenuEntry( 101, "Полковник" ),
                ModelBuyMenuEntry( 3, "Демо-эксперт" ),
                ModelBuyMenuEntry( 98, "Пилот" ),
                ModelBuyMenuEntry( 42, "Черная рука" ),
                ModelBuyMenuEntry( 44, "Ниндзя" ),
				ModelBuyMenuEntry( 49, "Правительственный капитан" ),
                ModelBuyMenuEntry( 23, "Ученый" ),
                ModelBuyMenuEntry( 52, "Солдат 1" ),
                ModelBuyMenuEntry( 66, "Солдат 2" ) 
            },

            ["agency"] = {
                ModelBuyMenuEntry( 9, "Карл Блейн" ),
                ModelBuyMenuEntry( 65, "Джейд Тан" ),
                ModelBuyMenuEntry( 25, "Мария Кейн" ),
                ModelBuyMenuEntry( 30, "Маршалл" ),
                ModelBuyMenuEntry( 34, "Том Шелдон" ),
                ModelBuyMenuEntry( 100, "Дилер черного рынка" ),
                ModelBuyMenuEntry( 83, "Белый Тигр" ),
                ModelBuyMenuEntry( 51, "Рико Родригес" )
            },

            ["misc"] = {
                ModelBuyMenuEntry( 70, "Генерал Масайо" ),
                ModelBuyMenuEntry( 11, "Чжан Сунь" ),
                ModelBuyMenuEntry( 84, "Александр Мириков" ),
                ModelBuyMenuEntry( 19, "Китайский Бизнесмен" ),
                ModelBuyMenuEntry( 36, "Политик" ),
                ModelBuyMenuEntry( 71, "Сауль Сукарно" ),
                ModelBuyMenuEntry( 79, "Японский Ветеран" ),
                ModelBuyMenuEntry( 16, "Полиция Панау" ),
                ModelBuyMenuEntry( 64, "Бом Бом Бохилано" ),
				ModelBuyMenuEntry( 55, "Дед" ),
                ModelBuyMenuEntry( 61, "Солдат" ),
				ModelBuyMenuEntry( 18, "Хакер" ),
                ModelBuyMenuEntry( 26, "Лодочный Капитан" ),
                ModelBuyMenuEntry( 21, "Папарацци" ),
				ModelBuyMenuEntry( 33, "Азартный игрок" ),
				ModelBuyMenuEntry( 45, "Официант" ),
				ModelBuyMenuEntry( 48, "Швейцар" ),
				ModelBuyMenuEntry( 69, "Свидетель" ),
            },

            ["★ VIP"] = {
                ModelBuyMenuEntry( 20, "Невидимка", 1 )
            }
        },

        [self.types.appearance] = {
            { "hats", "capshelmets", "shawls", "wigs", "face", "neck", "accessories", "parachutes", "★ VIP" },

            ["hats"] = {
				AppearanceBuyMenuEntry( "Clear", "Head", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "pd_arcticvillage_female2.eez/pd_arcticvillage_female_2-hat_winter.lod", "Head", "Зимняя льняная шапка" ),
				AppearanceBuyMenuEntry( "pd_arcticvillage_male2.eez/pd_arcticvillage_male_2-hat_winter.lod", "Head", "Большая зимняя льняная шапка" ),
				AppearanceBuyMenuEntry( "pd_generic_male_2.eez/pd_generic_male_2-hat_linen.lod", "Head", "Белая льняная шапка" ),
				AppearanceBuyMenuEntry( "pd_generic_male_3.eez/pd_generic_male_3-hat_linen.lod", "Head", "Пёстрая льняная шапка" ),
				AppearanceBuyMenuEntry( "pd_generic_female_1.eez/pd_generic_female_1-hat_linen.lod", "Head", "Льняная шапка в черную полоску" ),
				AppearanceBuyMenuEntry( "pd_generic_male_1.eez/pd_generic_male_1-hat_linen.lod", "Head", "Льняная шапка в тёмную полоску" ),
				AppearanceBuyMenuEntry( "pd_generic_female_2.eez/pd_generic_female_2-hat_linen.lod", "Head", "Льняная шапка в белую полоску" ),
				AppearanceBuyMenuEntry( "pd_generic_female_5.eez/pd_generic_female_5-hat_cloth.lod", "Head", "Черно-белая льняная шапка" ),
				AppearanceBuyMenuEntry( "pd_fishervillage_male1.eez/pd_fishervillage_male-hat_fisherman.lod", "Head", "Рыбацкая шапка" ),
				AppearanceBuyMenuEntry( "pd_generic_male_1.eez/pd_generic_male_1-hat_fisherman.lod", "Head", "Рыбацкая шапка 2" ),
				AppearanceBuyMenuEntry( "pd_generic_female_1.eez/pd_generic_female_1-hat_fisherman.lod", "Head", "Маленькая рыбацкая шапка" ),
				AppearanceBuyMenuEntry( "pd_tourist_male1.eez/pd_tourist_male-fisherhat.lod", "Head", "Рыбацкая шапка с наклоном" ),
				AppearanceBuyMenuEntry( "pd_fishervillage_male1.eez/pd_fishervillage_male-ricehat.lod", "Head", "Большая соломенная шляпа из рисовой соломки" ),
				AppearanceBuyMenuEntry( "pd_generic_female_5.eez/pd_generic_female_5-hat_straw2.lod", "Head", "Загорелая соломенная шляпа из рисовой соломки" ),
				AppearanceBuyMenuEntry( "pd_generic_female.eez/generic_female-ricehat.lod", "Head", "Бежевая соломенная шляпа из рисовой соломки" ),
				AppearanceBuyMenuEntry( "pd_generic_female_3.eez/pd_generic_female_3-hat_straw2.lod", "Head", "Бежевая соломенная шляпа из рисовой соломки 2" ),
				AppearanceBuyMenuEntry( "pd_generic_female_1.eez/pd_generic_female_1-hat_rice.lod", "Head", "Соломенная шляпа" ),
				AppearanceBuyMenuEntry( "pd_generic_male_1.eez/pd_generic_male_1-hat_rice.lod", "Head", "Большая соломенная шляпа" ),
				AppearanceBuyMenuEntry( "pd_generic_female_2.eez/pd_generic_female_2-hat_rice.lod", "Head", "Желтая соломенная шляпа" ), 
				AppearanceBuyMenuEntry( "pd_generic_male.eez/pd_generic_male-hat.lod", "Head", "Белая соломенная шляпа" ),
				AppearanceBuyMenuEntry( "pd_thugs1.eez/pd_thugs-h_bandana.lod", "Head", "Серая бандана-шапка" ),
				AppearanceBuyMenuEntry( "pd_ms_doorman.eez/pd_doorman-h_bandana.lod", "Head", "Изношенная серая бандана-шапка" ),
				AppearanceBuyMenuEntry( "pd_generic_male_2.eez/pd_generic_male_2-hat_fedora.lod", "Head", "Светло-серая фетровая шляпа" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_male1.eez/pd_ms_stripper_male-hat.lod", "Head", "Фетровая шляпа с наклоном" ),
				AppearanceBuyMenuEntry( "pd_ms_thugboss.eez/pd_executioner-h_felthat.lod", "Head", "Серая фетровая шляпа с наклоном" ),
				AppearanceBuyMenuEntry( "pd_roacheselite1.eez/pd_roaches_elite-h_headwear.lod", "Head", "Элитный тюрбан Тараканов" ),
				AppearanceBuyMenuEntry( "pd_generic_female_2.eez/pd_generic_female_2-hat_towel.lod", "Head", "Тканевый тюрбан" ),
            },
			
            ["capshelmets"] = {
				AppearanceBuyMenuEntry( "Clear", "Head", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "pd_tourist_male1.eez/pd_tourist_male-keps.lod", "Head", "Фуражка туриста" ),
				AppearanceBuyMenuEntry( "pd_arcticvillage_male1.eez/pd_arcticvillage_male-hat.lod", "Head", "Зимняя шапка" ),
				AppearanceBuyMenuEntry( "pd_generic_male_2.eez/pd_generic_male_2-hat_weird.lod", "Head", "Древняя корона" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_male2.eez/pd_ms_stripper_male-cowboyhat.lod", "Head", "Ковбойская шляпа" ),
				AppearanceBuyMenuEntry( "pd_oilplatform_male1.eez/pd_oilplatform-greycap.lod", "Head", "Серая шапка-ушанка" ),
				AppearanceBuyMenuEntry( "pd_oilplatform_male1.eez/pd_oilplatform-helmet.lod", "Head", "Строительная каска" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_female1.eez/pd_stripper_female-ht_militarycap.lod", "Head", "Фуражка военного командира" ),
				AppearanceBuyMenuEntry( "pd_reaperselite1.eez/pd_reapers_elite_male-cap.lod", "Head", "Элитная фуражка Жнецов" ),
				AppearanceBuyMenuEntry( "pd_ms_japaneseveterans.eez/pd_ms_japaneseveterans-hat.lod", "Head", "Японская фуражка" ),
				AppearanceBuyMenuEntry( "pd_ms_japaneseveterans.eez/pd_ms_japaneseveterans-helmet.lod", "Head", "Японский шлем" ),
				AppearanceBuyMenuEntry( "pd_gov_base01.eez/pd_gov_base-hat.lod", "Head", "Шляпа полиции Панау" ),
				AppearanceBuyMenuEntry( "pd_panaupolice.eez/panaupolice-cap.lod", "Head", "Фуражка полиции Панау" ),
				AppearanceBuyMenuEntry( "pd_panaupolice.eez/panaupolice-helmet.lod", "Head", "Шлем полиции Панау" ),
				AppearanceBuyMenuEntry( "pd_panaupolice.eez/panaupolice-turban.lod", "Head", "Тюрбан полиции Панау" ),
				AppearanceBuyMenuEntry( "pd_gov_elite.eez/pd_govnewfix_elite-helmet.lod", "Head", "Элитный шлем правительства" ),
				AppearanceBuyMenuEntry( "pd_gov_base01.eez/pd_gov_base-beret.lod", "Head", "Элитный берет правительства" ),
				AppearanceBuyMenuEntry( "pd_reaperselite1.eez/pd_reapers_elite_male-beret.lod", "Head", "Элитный берет Жнецов" ),
				AppearanceBuyMenuEntry( "pd_roacheselite1.eez/pd_roaches_elite-h_bandana.lod", "Head", "Элитный берет Тараканов" ),
            },
			
            ["shawls"] = {
				AppearanceBuyMenuEntry( "Clear", "Covering", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "pd_arcticvillage_female1.eez/pd_arcticvillage_female-headcloth.lod", "Covering", "Черный платок" ),
				AppearanceBuyMenuEntry( "pd_arcticvillage_female1.eez/pd_arcticvillage_female-headcloth2.lod", "Covering", "Бело-темный платок" ),
				AppearanceBuyMenuEntry( "pd_desertvillage_female1.eez/pd_desertvillage_female-shawl.lod", "Covering", "Белый платок" ), 
				AppearanceBuyMenuEntry( "pd_desertvillage_male1.eez/pd_desertvillage_male-turban.lod", "Covering", "Платок и тюрбан" ),
				AppearanceBuyMenuEntry( "pd_generic_female.eez/generic_female-shawl.lod", "Covering", "Бежевый платок" ), 
				AppearanceBuyMenuEntry( "pd_generic_female_3.eez/pd_generic_female_3-hat_scarf.lod", "Covering", "Белый чепец" ), 
				AppearanceBuyMenuEntry( "pd_generic_female_5.eez/pd_generic_female_5-hat_scarf.lod", "Covering", "Черный чепец" ),
            },

            ["wigs"] = {
				AppearanceBuyMenuEntry( "Clear", "Hair", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "pd_tourist_female2.eez/pd_tourist_female-h_hair.lod", "Hair", "Средний [Черный]" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_female1.eez/pd_stripper_female-h_hair1.lod", "Hair", "Средний [Серый]" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_female1.eez/pd_stripper_female-h_hair2.lod", "Hair", "Короткий [Рыжий]" ),
            },

            ["face"] = {
				AppearanceBuyMenuEntry( "Clear", "Face", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_female1.eez/pd_stripper_female-a_sunglasses.lod", "Face", "Круглые солнцезащитные очки" ),
				AppearanceBuyMenuEntry( "pd_ularboyselite1.eez/pd_ularboys_elite_male-glasses.lod", "Face", "Темные непрозрачные солнцезащитные очки" ),
				AppearanceBuyMenuEntry( "pd_blackhand.eez/pd_blackhand-glasses.lod", "Face", "Светлые непрозрачные солнцезащитные очки" ),
				AppearanceBuyMenuEntry( "pd_ms_scientist_male.eez/pd_ms_scientists-glasses.lod", "Face", "Прозрачные очки для ученых" ),
				AppearanceBuyMenuEntry( "pd_thugs1.eez/pd_thugs-o_glasses.lod", "Face", "Широкие солнцезащитные очки" ),
				AppearanceBuyMenuEntry( "pd_tourist_male1.eez/pd_tourist_male-sunglasses.lod", "Face", "Темные туристические солнцезащитные очки" ),
            },

            ["neck"] = {
				AppearanceBuyMenuEntry( "Neck", "Neck", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "pd_ms_civ_strippers_male2.eez/pd_civilian_stripper_male-cowboyscarf.lod", "Neck", "Красная бандана" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_male2.eez/pd_ms_stripper_male-cowboyscarf.lod", "Neck", "Ковбойская бандана" ),
				AppearanceBuyMenuEntry( "pd_blackmarket.eez/pd_blackmarket-scarf.lod", "Neck", "Чернокнижковая бандана" ),
            },

            ["accessories"] = {
				AppearanceBuyMenuEntry( "Clear", "Back", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "pd_ularboysbase1.eez/pd_ularboys_base_male-backpack.lod", "Back", "Рюкзак" ),
				AppearanceBuyMenuEntry( "pd_gov_base02.eez/pd_gov_base-bags.lod", "Back", "Рюкзак для спецопераций" ),
				AppearanceBuyMenuEntry( "pd_gov_elite.eez/pd_govnewfix_elite-vest1.lod", "Back", "Военный бронежилет" ),
				AppearanceBuyMenuEntry( "pd_gov_elite.eez/pd_govnewfix_elite-vest2.lod", "Back", "Легкий бронежилет" ),
				AppearanceBuyMenuEntry( "pd_ularboysbase1.eez/pd_ularboys_base_male-ammopouch.lod", "Back", "Подсумок" ),
				AppearanceBuyMenuEntry( "pd_ularboysbase1.eez/pd_ularboys_base_male-waterbottle.lod", "Back", "Фляга" ),
			},

			["parachutes"] = {
				AppearanceBuyMenuEntry( "parachute00.pickup.execute", "Parachute", "Стандартный парашют" ),
				AppearanceBuyMenuEntry( "parachute01.pickup.execute", "Parachute", "DLC - Парашют с двигателями" ),
				AppearanceBuyMenuEntry( "parachute02.pickup.execute", "Parachute", "DLC - Парашют Сорвиголовы" ),
				AppearanceBuyMenuEntry( "parachute03.pickup.execute", "Parachute", "DLC - Парашют Хаоса" ),
				AppearanceBuyMenuEntry( "parachute04.pickup.execute", "Parachute", "DLC - Камуфляжный парашют" ),
				AppearanceBuyMenuEntry( "parachute05.pickup.execute", "Parachute", "DLC - Тигровый парашют" ),
				AppearanceBuyMenuEntry( "parachute06.pickup.execute", "Parachute", "DLC - Парашют с скорпионом" ),
				AppearanceBuyMenuEntry( "parachute07.pickup.execute", "Parachute", "DLC - Огненный парашют" ),
			},
			
			["★ VIP"] = {
				AppearanceBuyMenuEntry( "Clear", "Back", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "general.blz/gae05-gae05.lod", "Back", "Парашют", 1 ),
				AppearanceBuyMenuEntry( "City_B10_roofbush-Whole.lod", "Back", "Кустик", 1 ),
				AppearanceBuyMenuEntry( "Jungle_B34_KelpS-Whole.lod", "Back", "Водоросли", 1 ),
				AppearanceBuyMenuEntry( "City_T01_SakuraL-TrunkA.lod", "Back", "Дерево (только пустыня)", 1 ),
				AppearanceBuyMenuEntry( "go225-a.lod", "Back", "Мусорное ведро", 1 ),
			}
        }
    }
end
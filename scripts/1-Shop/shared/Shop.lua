class 'Shop'
class 'BuyMenuEntry'

function BuyMenuEntry:__init(model_id, entry_type, template, decal)
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

function BuyMenuEntry:SetListboxItem(item)
    self.listbox_item = item
end

class 'VehicleBuyMenuEntry'(BuyMenuEntry)

function VehicleBuyMenuEntry:__init(model_id, template, decal, name, rank)
    BuyMenuEntry.__init(self, model_id, 1, template, decal)
    self.name = name
    self.rank = rank
end

function VehicleBuyMenuEntry:GetName()
    local modelName = Vehicle.GetNameByModelId(self.model_id)
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

class 'WeaponBuyMenuEntry'(BuyMenuEntry)

function WeaponBuyMenuEntry:__init(model_id, slot, name, rank)
    BuyMenuEntry.__init(self, model_id, 2)
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

class 'ModelBuyMenuEntry'(BuyMenuEntry)

function ModelBuyMenuEntry:__init(model_id, name, rank)
    BuyMenuEntry.__init(self, model_id, 2)
    self.name = name
    self.rank = rank
end

function ModelBuyMenuEntry:GetName()
    return self.name
end

function ModelBuyMenuEntry:GetRank()
    return self.rank
end

class 'AppearanceBuyMenuEntry'(BuyMenuEntry)

function AppearanceBuyMenuEntry:__init(model_id, itemtype, name, rank)
    BuyMenuEntry.__init(self, model_id, itemtype, 2)
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

class 'ParachutesBuyMenuEntry'(BuyMenuEntry)

function ParachutesBuyMenuEntry:__init(model_id, name, rank)
    BuyMenuEntry.__init(self, model_id, event, 2)
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

    for k, v in pairs(self.types) do
        self.id_types[v] = k
    end

    self.items = {
        [self.types.vehicles] = {
            {"cars", "bikes", "jeeps", "pickups", "buses", "heavy", "tractors", "helicopters", "planes", "boats", "DLC"},

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
            {"righthand", "lefthand" , "primary", "★ VIP"},
            ["righthand"] = {
				WeaponBuyMenuEntry( Weapon.BubbleGun, 1, "bubblegun" ),
                WeaponBuyMenuEntry( Weapon.Handgun, 1, "handgun" ),
                WeaponBuyMenuEntry( Weapon.Revolver, 1, "revolver" ),
                WeaponBuyMenuEntry( Weapon.SMG, 1, "smg" ),
                WeaponBuyMenuEntry( Weapon.SawnOffShotgun, 1, "sawnoffshotgun" ),
				WeaponBuyMenuEntry( Weapon.GrenadeLauncher, 1, "grenadelauncher" ),
				WeaponBuyMenuEntry( Weapon.MachineGun, 1, "machinegun" ),
				WeaponBuyMenuEntry( Weapon.SignatureGun, 1, "signaturegun" ),
            },

            ["lefthand"] = {
				WeaponBuyMenuEntry( Weapon.BubbleGun, 0, "bubblegun" ),
                WeaponBuyMenuEntry( Weapon.Handgun, 0, "handgun" ),
                WeaponBuyMenuEntry( Weapon.Revolver, 0, "revolver" ),
                WeaponBuyMenuEntry( Weapon.SMG, 0, "smg" ),
                WeaponBuyMenuEntry( Weapon.SawnOffShotgun, 0, "sawnoffshotgun" ),
				WeaponBuyMenuEntry( Weapon.GrenadeLauncher, 0, "grenadelauncher" ),
				WeaponBuyMenuEntry( Weapon.MachineGun, 0, "machinegun" ),
				WeaponBuyMenuEntry( Weapon.SignatureGun, 0, "signaturegun" ),
            },
			
            ["primary"] = {
				WeaponBuyMenuEntry( Weapon.Assault, 2, "assault" ),
				WeaponBuyMenuEntry( Weapon.Shotgun, 2, "shotgun" ),
				WeaponBuyMenuEntry( Weapon.MachineGun, 2, "machinegun" ),
				WeaponBuyMenuEntry( Weapon.Sniper, 2, "sniper" ),
				WeaponBuyMenuEntry( Weapon.RocketLauncher, 2, "rocketlauncher" ),
				WeaponBuyMenuEntry( Weapon.PanayRocketLauncher, 2, "panayrocketlauncher" ),
				WeaponBuyMenuEntry( Weapon.Airzooka, 2, "airzooka" ),
				WeaponBuyMenuEntry( Weapon.ClusterBombLauncher, 2, "clusterbomblauncher" ),
				WeaponBuyMenuEntry( Weapon.MultiTargetRocketLauncher, 2, "multitargetrocketlauncher" ),
				WeaponBuyMenuEntry( Weapon.QuadRocketLauncher, 2, "quadrocketlauncher" ),
				WeaponBuyMenuEntry( Weapon.AlphaDLCWeapon, 2, "alphadlcweapon" ),
			},
			
			["★ VIP"] = {
				WeaponBuyMenuEntry( Weapon.PanayRocketLauncher, 1, "panayrocketlauncherrighthand", 1 ),
				WeaponBuyMenuEntry( Weapon.PanayRocketLauncher, 0, "panayrocketlauncherlefthand", 1 ),
				WeaponBuyMenuEntry( Weapon.RocketARVE, 2, "rockets", 1 ),
				WeaponBuyMenuEntry( Weapon.SAM, 2, "sam", 1 ),
            }
        },

        [self.types.character] = {
            {"boys", "girls", "roaches", "ulars", "reapers", "gov", "agency", "misc", "★ VIP"},
            ["boys"] = {
				ModelBuyMenuEntry( 54, "russianbodyguard" ),
                ModelBuyMenuEntry( 96, "japanesebodyguard" ),
				ModelBuyMenuEntry( 6, "chinesebodyguard" ),
                ModelBuyMenuEntry( 80, "passerby1" ),
                ModelBuyMenuEntry( 93, "passerby2" ),
				ModelBuyMenuEntry( 7, "passerby3" ),
				ModelBuyMenuEntry( 10, "passerby4" ),
				ModelBuyMenuEntry( 13, "passerby5" ),
				ModelBuyMenuEntry( 24, "passerby6" ),
				ModelBuyMenuEntry( 28, "passerby7" ),
				ModelBuyMenuEntry( 29, "passerby8" ),
				ModelBuyMenuEntry( 35, "passerby9" ),
				ModelBuyMenuEntry( 56, "passerby10" ),
				ModelBuyMenuEntry( 68, "passerby11" ),
				ModelBuyMenuEntry( 73, "passerby12" ),
				ModelBuyMenuEntry( 75, "passerby13" ),
				ModelBuyMenuEntry( 76, "passerby14" ),
				ModelBuyMenuEntry( 88, "passerby15" ),
				ModelBuyMenuEntry( 91, "passerby16" ),
				ModelBuyMenuEntry( 99, "passerby17" ),
                ModelBuyMenuEntry( 15, "malestripper1" ),
                ModelBuyMenuEntry( 17, "malestripper2" ),
                ModelBuyMenuEntry( 1, "thug1" ),
                ModelBuyMenuEntry( 39, "thug2" ),
				ModelBuyMenuEntry( 78, "thugboss" ),
				ModelBuyMenuEntry( 50, "oilworker1" ),
				ModelBuyMenuEntry( 57, "oilworker2" ),
				ModelBuyMenuEntry( 89, "factoryworker" ),
                ModelBuyMenuEntry( 40, "factoryboss" ),
            },

            ["girls"] = {
				ModelBuyMenuEntry( 14, "wpasserby1" ),
				ModelBuyMenuEntry( 31, "wpasserby2" ),
				ModelBuyMenuEntry( 41, "wpasserby3" ),
				ModelBuyMenuEntry( 46, "wpasserby4" ),
				ModelBuyMenuEntry( 47, "wpasserby5" ),
				ModelBuyMenuEntry( 62, "wpasserby6" ),
				ModelBuyMenuEntry( 72, "wpasserby7" ),
				ModelBuyMenuEntry( 82, "wpasserby8" ),
				ModelBuyMenuEntry( 92, "wpasserby9" ),
				ModelBuyMenuEntry( 102, "wpasserby10" ),
				ModelBuyMenuEntry( 60, "woman" ),
				ModelBuyMenuEntry( 86, "stripper" ),
            },

            ["roaches"] = {
                ModelBuyMenuEntry( 2, "razakrazman" ),
                ModelBuyMenuEntry( 5, "elite" ),
                ModelBuyMenuEntry( 32, "technician" ),
                ModelBuyMenuEntry( 85, "soldier1" ),
                ModelBuyMenuEntry( 59, "soldier2" )
            },

            ["ulars"] = {
                ModelBuyMenuEntry( 38, "sriirawan" ),
                ModelBuyMenuEntry( 87, "elite" ),
                ModelBuyMenuEntry( 22, "technician" ),
                ModelBuyMenuEntry( 27, "soldier1" ),
                ModelBuyMenuEntry( 103, "soldier2" )
            },

            ["reapers"] = {
                ModelBuyMenuEntry( 90, "bolosantosi" ),
                ModelBuyMenuEntry( 63, "elite" ),
                ModelBuyMenuEntry( 8, "technician" ),
                ModelBuyMenuEntry( 12, "soldier1" ),
                ModelBuyMenuEntry( 58, "soldier2" ),
            },

            ["gov"] = {
                ModelBuyMenuEntry( 74, "babypanay" ),
                ModelBuyMenuEntry( 67, "burnedbabypanay" ),
                ModelBuyMenuEntry( 101, "colonel" ),
                ModelBuyMenuEntry( 3, "demoexpert" ),
                ModelBuyMenuEntry( 98, "pilot" ),
                ModelBuyMenuEntry( 42, "blackhand" ),
                ModelBuyMenuEntry( 44, "ninja" ),
				ModelBuyMenuEntry( 49, "governmentcaptain" ),
                ModelBuyMenuEntry( 23, "scientist" ),
                ModelBuyMenuEntry( 52, "soldier1" ),
                ModelBuyMenuEntry( 66, "soldier2" ) 
            },

            ["agency"] = {
                ModelBuyMenuEntry( 9, "karlblaine" ),
                ModelBuyMenuEntry( 65, "jadetan" ),
                ModelBuyMenuEntry( 25, "mariakane" ),
                ModelBuyMenuEntry( 30, "marshall" ),
                ModelBuyMenuEntry( 34, "tomsheldon" ),
                ModelBuyMenuEntry( 100, "blackmarketdealer" ),
                ModelBuyMenuEntry( 83, "whitetiger" ),
                ModelBuyMenuEntry( 51, "ricorodriguez" )
            },

            ["misc"] = {
                ModelBuyMenuEntry( 70, "generalmasayo" ),
                ModelBuyMenuEntry( 11, "zhangsun" ),
                ModelBuyMenuEntry( 84, "alexandermirikov" ),
                ModelBuyMenuEntry( 19, "chinesebusinessman" ),
                ModelBuyMenuEntry( 36, "poliitician" ),
                ModelBuyMenuEntry( 71, "saulsukarno" ),
                ModelBuyMenuEntry( 79, "japaneseveteran" ),
                ModelBuyMenuEntry( 16, "panaupolice" ),
                ModelBuyMenuEntry( 64, "bombombohilano" ),
				ModelBuyMenuEntry( 55, "grandpa" ),
                ModelBuyMenuEntry( 61, "soldier" ),
				ModelBuyMenuEntry( 18, "hacker" ),
                ModelBuyMenuEntry( 26, "boatcaptain" ),
                ModelBuyMenuEntry( 21, "paparazzi" ),
				ModelBuyMenuEntry( 33, "gambler" ),
				ModelBuyMenuEntry( 45, "waiter" ),
				ModelBuyMenuEntry( 48, "doorman" ),
				ModelBuyMenuEntry( 69, "witness" ),
            },

            ["★ VIP"] = {
                ModelBuyMenuEntry( 20, "invisible", 1 )
            }
        },

        [self.types.appearance] = {
            {"hats", "capshelmets", "shawls", "wigs", "face", "neck", "accessories", "parachutes", "★ VIP"},

            ["hats"] = {
				AppearanceBuyMenuEntry( "Clear", "Head", "clear" ),
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
				AppearanceBuyMenuEntry( "Clear", "Head", "clear" ),
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
				AppearanceBuyMenuEntry( "Clear", "Covering", "clear" ),
				AppearanceBuyMenuEntry( "pd_arcticvillage_female1.eez/pd_arcticvillage_female-headcloth.lod", "Covering", "Черный платок" ),
				AppearanceBuyMenuEntry( "pd_arcticvillage_female1.eez/pd_arcticvillage_female-headcloth2.lod", "Covering", "Бело-темный платок" ),
				AppearanceBuyMenuEntry( "pd_desertvillage_female1.eez/pd_desertvillage_female-shawl.lod", "Covering", "Белый платок" ), 
				AppearanceBuyMenuEntry( "pd_desertvillage_male1.eez/pd_desertvillage_male-turban.lod", "Covering", "Платок и тюрбан" ),
				AppearanceBuyMenuEntry( "pd_generic_female.eez/generic_female-shawl.lod", "Covering", "Бежевый платок" ), 
				AppearanceBuyMenuEntry( "pd_generic_female_3.eez/pd_generic_female_3-hat_scarf.lod", "Covering", "Белый чепец" ), 
				AppearanceBuyMenuEntry( "pd_generic_female_5.eez/pd_generic_female_5-hat_scarf.lod", "Covering", "Черный чепец" ),
            },

            ["wigs"] = {
				AppearanceBuyMenuEntry( "Clear", "Hair", "clear" ),
				AppearanceBuyMenuEntry( "pd_tourist_female2.eez/pd_tourist_female-h_hair.lod", "Hair", "mediumblack" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_female1.eez/pd_stripper_female-h_hair1.lod", "Hair", "mediumgray" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_female1.eez/pd_stripper_female-h_hair2.lod", "Hair", "Короткий [Рыжий]" ),
            },

            ["face"] = {
				AppearanceBuyMenuEntry( "Clear", "Face", "clear" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_female1.eez/pd_stripper_female-a_sunglasses.lod", "Face", "Круглые солнцезащитные очки" ),
				AppearanceBuyMenuEntry( "pd_ularboyselite1.eez/pd_ularboys_elite_male-glasses.lod", "Face", "Темные непрозрачные солнцезащитные очки" ),
				AppearanceBuyMenuEntry( "pd_blackhand.eez/pd_blackhand-glasses.lod", "Face", "Светлые непрозрачные солнцезащитные очки" ),
				AppearanceBuyMenuEntry( "pd_ms_scientist_male.eez/pd_ms_scientists-glasses.lod", "Face", "Прозрачные очки для ученых" ),
				AppearanceBuyMenuEntry( "pd_thugs1.eez/pd_thugs-o_glasses.lod", "Face", "Широкие солнцезащитные очки" ),
				AppearanceBuyMenuEntry( "pd_tourist_male1.eez/pd_tourist_male-sunglasses.lod", "Face", "Темные туристические солнцезащитные очки" ),
            },

            ["neck"] = {
				AppearanceBuyMenuEntry( "Neck", "Neck", "clear" ),
				AppearanceBuyMenuEntry( "pd_ms_civ_strippers_male2.eez/pd_civilian_stripper_male-cowboyscarf.lod", "Neck", "Красная бандана" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_male2.eez/pd_ms_stripper_male-cowboyscarf.lod", "Neck", "Ковбойская бандана" ),
				AppearanceBuyMenuEntry( "pd_blackmarket.eez/pd_blackmarket-scarf.lod", "Neck", "Чернокнижковая бандана" ),
            },

            ["accessories"] = {
				AppearanceBuyMenuEntry( "Clear", "Back", "clear" ),
				AppearanceBuyMenuEntry( "pd_ularboysbase1.eez/pd_ularboys_base_male-backpack.lod", "Back", "Рюкзак" ),
				AppearanceBuyMenuEntry( "pd_gov_base02.eez/pd_gov_base-bags.lod", "Back", "Рюкзак для спецопераций" ),
				AppearanceBuyMenuEntry( "pd_gov_elite.eez/pd_govnewfix_elite-vest1.lod", "Back", "Военный бронежилет" ),
				AppearanceBuyMenuEntry( "pd_gov_elite.eez/pd_govnewfix_elite-vest2.lod", "Back", "Легкий бронежилет" ),
				AppearanceBuyMenuEntry( "pd_ularboysbase1.eez/pd_ularboys_base_male-ammopouch.lod", "Back", "Подсумок" ),
				AppearanceBuyMenuEntry( "pd_ularboysbase1.eez/pd_ularboys_base_male-waterbottle.lod", "Back", "Фляга" ),
			},

			["parachutes"] = {
				AppearanceBuyMenuEntry( "parachute00.pickup.execute", "Parachute", "defaultparachute" ),
				AppearanceBuyMenuEntry( "parachute01.pickup.execute", "Parachute", "dualparachutethrusters" ),
				AppearanceBuyMenuEntry( "parachute02.pickup.execute", "Parachute", "daredevilparachute" ),
				AppearanceBuyMenuEntry( "parachute03.pickup.execute", "Parachute", "chaosparachute" ),
				AppearanceBuyMenuEntry( "parachute04.pickup.execute", "Parachute", "camoparachute" ),
				AppearanceBuyMenuEntry( "parachute05.pickup.execute", "Parachute", "tigerparachute" ),
				AppearanceBuyMenuEntry( "parachute06.pickup.execute", "Parachute", "scorpionparachute" ),
				AppearanceBuyMenuEntry( "parachute07.pickup.execute", "Parachute", "firestormparachute" ),
			},
			
			["★ VIP"] = {
				AppearanceBuyMenuEntry( "Clear", "Back", "clear" ),
				AppearanceBuyMenuEntry( "general.blz/gae05-gae05.lod", "Back", "parachute", 1 ),
				AppearanceBuyMenuEntry( "City_B10_roofbush-Whole.lod", "Back", "bush", 1 ),
				AppearanceBuyMenuEntry( "Jungle_B34_KelpS-Whole.lod", "Back", "seaweed", 1 ),
				AppearanceBuyMenuEntry( "City_T01_SakuraL-TrunkA.lod", "Back", "tree", 1 ),
				AppearanceBuyMenuEntry( "go225-a.lod", "Back", "bin", 1 ),
			}
        }
    }
end
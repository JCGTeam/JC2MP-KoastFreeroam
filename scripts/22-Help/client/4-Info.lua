class 'HInfo'

function HInfo:__init()
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "Lang", self, self.EngHelp )
end

function HInfo:EngHelp()
	Events:Fire( "HelpRemoveItem", { name = "Информация" } )

	Events:Fire( "HelpAddItem",
	{
		name = "Information",
		text =
			"> Main:\n" ..
			"    Group in VK              [empty_link]\n" ..
			"    Group in Steam         [empty_link]\n" ..
			"    We're in Discord           [empty_link]\n" ..
			"    Telegram Channel        [empty_link]\n \n" ..
			"> Our servers:\n" ..
			"    Just Cause 2 Multiplayer Mod:\n" ..
			"     - Koast Freeroam – [empty_link] (You are here)\n" ..
			"     - Panau Crisis – [empty_link]\n" ..
			"         - Group in VK - [empty_link]\n \n" ..
			"> Developer:\n" ..
			"     Hallkezz\n \n" ..
			"> Help in development:\n" ..
			"     Neon\n \n" ..
			"> Also thanks for scripts:\n" ..
			"     Proxwian\n" ..
			"     JasonMRC\n" ..
			"     benank\n" ..
			"     Dev_34\n" ..
			"     DaAlpha\n" ..
			"     SinisterRectus\n" ..
			"     SK83RJOSH\n" ..
			"     dreadmullet\n" ..
			"     Trix\n" ..
			"     Castillos15\n" ..
			"     Jasonmrc\n" ..
			"     Philpax\n" ..
			"     BluShine\n" ..
			"     Rene-Sackers\n \n" ..
			"> API/Used libraries:\n" ..
			"     luasocket (by Diego Nehab)\n" ..
			"     json.lua (by rxi/David Kolf)\n" ..
			"     Discordia (by SinisterRectus)\n" ..
			"     Luvit (luvit.io)\n" ..
			"     IP-API (ip-api.com)\n \n" ..
			"> Also thanks:\n" ..
			"     Cavick (Artist)\n" ..
			"     Dragonshifter (RUSSIAN FREEROAM MAYHEM server source code)\n \n" ..
			"> Open source:\n" ..
			"     GitHub - github.com/JCGTeam/KoastFreeroam"
	} )
end

function HInfo:RusHelp()
	Events:Fire( "HelpRemoveItem", { name = "Information" } )

	Events:Fire( "HelpAddItem",
	{
		name = "Информация",
		text =
			"> Главное:\n" ..
			"    Группа в VK               [empty_link]\n" ..
			"    Группа в Steam         [empty_link]\n" ..
			"    Сервер в Discord      [empty_link]\n" ..
			"    Телеграм канал         [empty_link]\n \n" ..
			"> Наши сервера:\n" ..
			"    Just Cause 2 Multiplayer Mod:\n" ..
			"     - Koast Freeroam – [empty_link] (Вы тут)\n" ..
			"     - Panau Crisis – [empty_link]\n" ..
			"         - Группа в VK - [empty_link]\n \n" ..
			"> Разработчик:\n" ..
			"     Hallkezz\n \n" ..
			"> Помощь в разработке:\n" ..
			"     Neon\n \n" ..
			"> Заимствованный код:\n" ..
			"     Proxwian\n" ..
			"     JasonMRC\n" ..
			"     benank\n" ..
			"     Dev_34\n" ..
			"     DaAlpha\n" ..
			"     SinisterRectus\n" ..
			"     SK83RJOSH\n" ..
			"     dreadmullet\n" ..
			"     Trix\n" ..
			"     Castillos15\n" ..
			"     Jasonmrc\n" ..
			"     Philpax\n" ..
			"     BluShine\n" ..
			"     Rene-Sackers\n \n" ..
			"> API/Используемые библеотеки:\n" ..
			"     luasocket (by Diego Nehab)\n" ..
			"     json.lua (by rxi/David Kolf)\n" ..
			"     Discordia (by SinisterRectus)\n" ..
			"     Luvit (luvit.io)\n" ..
			"     IP-API (ip-api.com)\n \n" ..
			"> Также спасибо:\n" ..
			"     Cavick (Художник-аферист)\n" ..
			"     Dragonshifter (Исходный код сервера RUSSIAN FREEROAM MAYHEM)\n \n" ..
			"> Открытый исходный код:\n" ..
			"     GitHub - github.com/JCGTeam/KoastFreeroam\n \n" ..
			"> Спонсорство:\n" ..
			"     В список спонсоров попадают люди, которые поддержали сервер суммой более 500 рублей.\n" ..
			"     Для попадания в список - уведомите администрацию.\n \n" ..
			"Никнеймы спонсоров: Oleg, Arko, Cavick"
	} )
end

function HInfo:ModuleLoad()
	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:EngHelp()
	else
		self:RusHelp()
	end
end

hinfo = HInfo()

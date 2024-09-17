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
			"> Links:\n" ..
			"    Telegram      t.me/koastfreeroam\n" ..
			"    Discord        discord.me/koastfreeroam\n" ..
			"    Steam           steamcommunity.com/groups/koastfreeroam\n" ..
			"    YouTube      www.youtube.com/@jcgteam\n \n" ..
			"> Official JCGTeam servers:\n" ..
			"    Just Cause 2: Multiplayer Mod:\n" ..
			"     - Koast Freeroam | IP: 62.122.214.141:7777\n \n" ..
			"> Developer:\n" ..
			"     Hallkezz\n \n" ..
			"> Development help (Contributors):\n" ..
			"     Neon\n" ..
			"     haker2377\n \n" ..
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
			"     GitHub - github.com/JCGTeam/JC2MP-KoastFreeroam\n \n" ..
			"© JCGTeam, Hallkezz 2017-2024"
	} )
end

function HInfo:RusHelp()
	Events:Fire( "HelpRemoveItem", { name = "Information" } )

	Events:Fire( "HelpAddItem",
	{
		name = "Информация",
		text =
			"> Ссылки:\n" ..
			"    Telegram      t.me/koastfreeroam\n" ..
			"    Discord        clck.ru/37FZrU\n" ..
			"    Steam           steamcommunity.com/groups/koastfreeroam\n" ..
			"    YouTube      www.youtube.com/@jcgteam\n" ..
			"    VK                 vk.com/koastfreeroam\n \n" ..
			"> Официальные сервера JCGTeam:\n" ..
			"    Just Cause 2: Multiplayer Mod:\n" ..
			"     - Koast Freeroam | IP: 62.122.214.141:7777\n \n" ..
			"> Разработчик:\n" ..
			"     Hallkezz\n \n" ..
			"> Помощь в разработке:\n" ..
			"     Neon\n" ..
			"     haker2377\n \n" ..
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
			"     GitHub - github.com/JCGTeam/JC2MP-KoastFreeroam\n \n" ..
			"© JCGTeam, Hallkezz 2017-2024"
	} )
end

function HInfo:ModuleLoad()
	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:EngHelp()
	else
		self:RusHelp()
	end
end

hinfo = HInfo()
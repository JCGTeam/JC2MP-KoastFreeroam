class 'HDonate'

function HDonate:__init()
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "Lang", self, self.EngHelp )
end

function HDonate:EngHelp()
	Events:Fire( "HelpRemoveItem", { name = "Донат" } )

	Events:Fire( "HelpAddItem",
	{
		name = "Donate",
		text =
			"> Links:\n" ..
			"    Buy - [empty_link]\n \n" ..
			"> VIP:\n" ..
			"    - Prefix VIP.\n" ..
			"    - Access to *VIP* tabs in the black market.\n" ..
			"    - Pigeon mod (allows you to fly a wingsuit like superman).\n" ..
			"    - Opportunity to have 2 homes.\n" ..
			"    - Take off into the sky and drop down (Located in the Actions menu).\n" ..
			'    - Super-speed for pigeon mode (command "superspeed" in the console at F4).\n' ..
			'    - Vehicle tricks (Found in the server settings, tab "Abilities" ).\n' ..
			'    - Jetpack (Found in the server settings, tab "Abilities").\n' ..
			'    - Local weather change (Located in the server settings, tab "Abilities" ).\n \n' ..
			"> Moderator:\n" ..
			"    - All VIP features.\n" ..
			"    - Access to the admin panel (P key).\n" ..
			"    - Kick.\n" ..
			"    - Warn.\n" ..
			"    - Kill.\n" ..
			"    - Teleport to player.\n" ..
			"    - Spectate.\n" ..
			"    - Set model.\n" ..
			"    - Set health.\n" ..
			"    - Give weapon.\n" ..
			"    - Teleport player.\n" ..
			"    - Freeze.\n" ..
			"    - Give vehicle.\n" ..
			"    - Repair vehicle.\n" ..
			"    - Destroy vehicle.\n" ..
			"    - Set vehicle colors.\n" ..
			"    - Message to player screen.\n" ..
			"    - Admin-chat.\n \n" ..
			"   Conditions:\n" ..
			'    - When you buy an admin, all the rules of the administrator are imposed on you, except for all the items in the category "Admins NOT-TO-DO list".\n' ..
			"    - We have the right to take away your privilege without refund for rule violations.\n \n" ..
			"> Administrator:\n" ..
			"    - All VIP features.\n" ..
			"    - All moderator features.\n" ..
			"    - Ban.\n" ..
			"    - Mute.\n" ..
			"    - Set server weather.\n \n" ..
			"   Conditions:\n" ..
			'    - When you buy an admin, all the rules of the administrator are imposed on you, except for all the items in the category "Admins NOT-TO-DO list".\n' ..
			"    - We have the right to take away your privilege without refund for rule violations.\n \n" ..
			"> Other:\n" ..
			"    Game currency\n" ..
			"    Unban\n" ..
			"    Advertising in game chat\n \n" ..
			"Prices and other details - [empty_link]"
	} )
end

function HDonate:RusHelp()
	Events:Fire( "HelpRemoveItem", { name = "Donate" } )

	Events:Fire( "HelpAddItem",
	{
		name = "Донат",
		text =
			"> Ссылки:\n" ..
			"    Купить - [empty_link]\n" ..
			"    Купить (VK) - [empty_link]\n \n" ..
			"> VIP:\n" ..
			"    - Префикс VIP.\n" ..
			"    - Доступ ко вкладкам *VIP* в чёрном рынке.\n" ..
			"    - Режим голубя (позволяет летать на вингсьюте, как супермен).\n" ..
			"    - Возможность иметь 2 дома.\n" ..
			"    - Взлет в небо и опускание вниз (Находятся в меню действий).\n" ..
			'    - Супер-скорость для режима голубя (команда "superspeed" в консоли на F4).\n' ..
			'    - Транспортные трюки (Находится в настройках сервера, вкладка "Способности" ).\n' ..
			'    - Реактивный ранец (Находится в настройках сервера, вкладка "Способности" ).\n' ..
			'    - Локальная смена погоды (Находится в настройках сервера, вкладка "Способности" ).\n \n' ..
			"> Модератор:\n" ..
			"    - Весь функционал VIP.\n" ..
			"    - Доступ к админ-панели (Кнопка P).\n" ..
			"    - Кик.\n" ..
			"    - Варн.\n" ..
			"    - Убить.\n" ..
			"    - Телепорт к игроку.\n" ..
			"    - Наблюдение.\n" ..
			"    - Установить модель.\n" ..
			"    - Установить здоровье.\n" ..
			"    - Выдать оружие.\n" ..
			"    - Телепортировать игрока.\n" ..
			"    - Заморозить.\n" ..
			"    - Выдать транспорт.\n" ..
			"    - Починить транспорт.\n" ..
			"    - Уничтожить транспорт.\n" ..
			"    - Установить цвета транспорта.\n" ..
			"    - Сообщение на экран игрока.\n" ..
			"    - Админ-чат.\n \n" ..
			"   Условия:\n" ..
			'    - Приобретая модерку на вас навязываются все правила администратора, кроме всех пунктов в категории "Администратор должен".\n' ..
			"    - Мы имеем право забрать у вас привилегию без возрата средств за нарушения правил.\n \n" ..
			"> Администратор:\n" ..
			"    - Весь функционал VIP.\n" ..
			"    - Весь функционал модератора.\n" ..
			"    - Бан.\n" ..
			"    - Мут.\n" ..
			"    - Установить погоду на сервере.\n \n" ..
			"   Условия:\n" ..
			'    - Приобретая админку на вас навязываются все правила администратора, кроме всех пунктов в категории "Администратор должен".\n' ..
			"    - Мы имеем право забрать у вас привилегию без возрата средств за нарушения правил.\n \n" ..
			"> Прочее:\n" ..
			"    Игровая валюта\n" ..
			"    Разблокировка\n" ..
			"    Реклама в игровом чате\n \n" ..
			"Цены и остальные подробности - [empty_link]"
	} )
end

function HDonate:ModuleLoad()
	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:EngHelp()
	else
		self:RusHelp()
	end
end

hdonate = HDonate()

class 'HADMCommands'

function HADMCommands:__init()
	Events:Subscribe( "LoadAdminsTab", self, self.LoadAdminsTab )
	Events:Subscribe( "UnloadAdminsTab", self, self.UnloadAdminsTab )
end

function HADMCommands:LoadAdminsTab()
	if LocalPlayer:GetValue( "Tag" ) == "Creator" or LocalPlayer:GetValue( "Tag" ) == "GlAdmin" or LocalPlayer:GetValue( "Tag" ) == "Admin" or LocalPlayer:GetValue( "Tag" ) == "Organizer" then
		Events:Fire( "HelpAddItem",
		{
			name = "Админское :3",
			text =
				"> Админам:\n" ..
				"    /petyx                 Дать петуча.\n" ..
				"    /unpetyx            Убрать петуча.\n" ..
				"    /hi                       Поприветствовать игрока в общий чат (анонимно).\n" ..
				"    /bb                      Попрощаться с игроком в общий чат (анонимно).\n" ..
				"    /clearchat           Очистить чат (не очищает историю).\n" ..
				"    /warn                  Дать проста варн.\n" ..
				"    /getmoney         Узнать сколько бабла.\n" ..
				"    /kick                   Кикнуть игрока.\n" ..
				"    /skick                 Беспалевно кикнуть игрока.\n" ..
				"    /boton                Включить бота-чистильщика.\n" ..
				"    /botoff                Выключить бота-чистильщика.\n" ..
				"    /sky                    Отправить игрока в небо.\n" ..
				"    /down                 Отправить игрока вниз.\n" ..
				"    /notice                Сообщение на экраны игроков.\n" ..
				"    /joinnotice         Установить сообщение при подключении игроков на сервер.\n" ..
				"    /clearjoinnotice Удалить сообщение при подключении игроков на сервер.\n" ..
				"    /hidetag             Скрыть/показать тэг над головой.\n" ..
				"    /rnb                    Вкл/выкл переливание цветов для транспорта.\n" ..
				"    /ptphere             Телепортировать к себе. (all* - всех)\n" ..
				"    /addcustomtp   Добавить точку для телепортации.\n" ..
				"    /clearallcustomtp   Очистить все созданные точки для телепортации.\n \n" ..
				"> Гл. Админам:\n" ..
				"    /ban                    Добавить игрока в ЧС (разбан только владельцем).\n" ..
				"    /remveh              Удалить весь ТС с сервера до его рестарта (В САМЫХ КРАЙНИХ СЛУЧАЯХ).\n" ..
				"    /addmoney        Дать бабла игроку.\n" ..
				"    /setgm                Изменить режим игроку (только визуально).\n" ..
				"    /setlang              Изменить язык игроку (только визуально).\n" ..
				"    /setlevel              Изменить уровень игроку (до переподключения).\n" ..
				"    /forcetron           Запустить трон принудительно для всех (ЗАПОЛНЯЕТ ИГРОКАМИ ЛОББИ).\n" ..
				"    /forcekhill           Запустить царь горы принудительно для всех (ЗАПОЛНЯЕТ ИГРОКАМИ ЛОББИ).\n" ..
				"    /derbydbgstart   Запустить дерби принудительно для всех (ЗАПОЛНЯЕТ ИГРОКАМИ ЛОББИ).\n" ..
				"    /derbyjoinall       Добавить всех игроков в очередь на дерби.\n" ..
				"    /cleardrift            Сбросить хорошечный дрифтер.\n" ..
				"    /cleartetris          Сбросить хорошечный тетрис.\n" ..
				"    /clearpigeon       Сбросить хорошечный голубь.\n \n" ..
				"> Организаторам:\n" ..
				"    /warn                  Дать проста варн.\n" ..
				"    /kick                   Кикнуть игрока.\n" ..
				"    /boton                Включить бота-чистильщика.\n" ..
				"    /botoff                Выключить бота-чистильщика.\n" ..
				"    /notice                Сообщение на экраны игроков.\n" ..
				"    /joinnotice         Установить сообщение при подключении игроков на сервер.\n" ..
				"    /clearjoinnotice Удалить сообщение при подключении игроков на сервер.\n" ..
				"    /addcustomtp   Добавить точку для телепортации.\n" ..
				"    /clearallcustomtp   Очистить все созданные точки для телепортации."
		} )
	elseif LocalPlayer:GetValue( "Tag" ) == "AdminD" or LocalPlayer:GetValue( "Tag" ) == "ModerD" then
		Events:Fire( "HelpAddItem",
		{
			name = "Админское :3",
			text =
				"> Модераторам:\n" ..
				"    /petyx                 Дать петуча.\n" ..
				"    /unpetyx            Убрать петуча.\n" ..
				"    /hi                       Поприветствовать игрока в общий чат (анонимно).\n" ..
				"    /bb                      Попрощаться с игроком в общий чат (анонимно).\n" ..
				"    /warn                  Дать проста варн.\n" ..
				"    /warn(1-3)          Дать варны (число берется от веденной цифры).\n" ..
				"    /getwarns          Узнать сколько варнов у игрока.\n" ..
				"    /getmoney         Узнать сколько бабла.\n" ..
				"    /kick                   Кикнуть игрока.\n" ..
				"    /hidetag             Скрыть/показать тэг над головой.\n \n" ..
				"> Админам:\n" ..
				"    /rnb                    Включить переливание цветов для транспорта."
		} )
	end
end

function HADMCommands:UnloadAdminsTab()
	if LocalPlayer:GetValue( "Tag" ) == "Creator" or LocalPlayer:GetValue( "Tag" ) == "GlAdmin" or LocalPlayer:GetValue( "Tag" ) == "Admin" then
		Events:Fire( "HelpRemoveItem", { name = "Админское :3" } )
	end
end

hadmCommands = HADMCommands()
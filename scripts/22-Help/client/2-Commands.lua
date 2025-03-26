class 'HCommands'

function HCommands:__init()
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "Lang", self, self.EngHelp )
end

function HCommands:EngHelp()
	Events:Fire( "HelpRemoveItem", { name = "Команды" } )

	Events:Fire( "HelpAddItem",
	{
		name = "Commands",
		text =
			"* All commands must be entered in the game chat (T).\n \n" ..
			"> Basic:\n" ..
			"    /passive               Toggle passive mode.\n" ..
			"    /heal                     Restore health.\n" ..
			"    /kill                       Suicide.\n" ..
			"    /hideme                Hide your marker on map/mini-map.\n" ..
			"    /jesus                   Toggle jesus mode (Water Walk).\n" ..
			"    /repair                   Repair vehicle.\n" ..
			"    /lock                     Lock/unlock driver's door.\n" ..
			"    /boom                  Blow up vehicle.\n" ..
			"    /pos                      Get your coordinates.\n" ..
			"    /angle                   Get character angle.\n" ..
			"    /tp                         Teleport to location.\n" ..
			"    /bind                     Key binding.\n" ..
			"    /myhomes            Get coordinates of your homes.\n" ..
			"    /mass <value>      Change vehicle mass.\n \n" ..
			"> Chat:\n" ..
			"    /me <text>        Action.\n" ..
			"    /try <text>         Solving disputes.\n" ..
			"    /cd <time>        Countdown.\n" ..
			"    /pm <player> <message>      Send a private message.\n \n" ..
			"> Mini-games:\n" ..
			"    /tron              Join/leave on Tron.\n" ..
			"    /khill              Join/leave on King Of The Hill.\n" ..
			"    /derby            Join/leave on Derby.\n" ..
			"    /race              Open Racing Menu.\n" ..
			"    /casino          Open Casino Menu.\n" ..
			"    /tetris             Play Tetris.\n" ..
			"    /pong <difficulty> Play Pong.\n" ..
			"       *difficulties: Noob, Easy, Medium, Hard, Extreme"
	} )
end

function HCommands:RusHelp()
	Events:Fire( "HelpRemoveItem", { name = "Commands" } )

	Events:Fire( "HelpAddItem",
	{
		name = "Команды",
		text =
			"* Все команды нужно вводить в игровой чат (T).\n \n" ..
			"> Часто используемые:\n" ..
			"    /passive               Включить/отключить мирный режим.\n" ..
			"    /heal                     Восстановить здоровье.\n" ..
			"    /kill                       Самоубийство.\n" ..
			"    /hideme                Скрыть маркер на карте/мини-карте.\n" ..
			"    /jesus                   Включить/отключить режим Иисуса (ходьба по воде).\n" ..
			"    /repair                   Починить транспортное средство.\n" ..
			"    /lock                     Заблокировать/разблокировать водителькую дверь.\n" ..
			"    /boom                  Взорвать транспортное средство.\n" ..
			"    /pos                      Узнать ваши координаты.\n" ..
			"    /angle                   Узнать угол персонажа.\n" ..
			"    /tp                         Телепортироваться в доступное место.\n" ..
			"    /bind                    Привязка клавиш.\n" ..
			"    /myhomes           Получить координаты домов.\n" ..
			"    /mass <число>   Изменить массу транспорта.\n \n" ..
			"> Чат:\n" ..
			"    /me <текст>        Действие.\n" ..
			"    /try <текст>         Решение спорных ситуаций.\n" ..
			"    /cd <время>        Обратный отсчёт.\n" ..
			"    /pm <игрок> <сообщение>      Отправить личное сообщение.\n \n" ..
			"> Развлечения:\n" ..
			"    /tron              Войти/выйти в лобби на трон.\n" ..
			"    /khill              Войти/выйти в лобби на царь горы.\n" ..
			"    /derby            Войти/выйти в лобби на дерби.\n" ..
			"    /race              Открыть меню гонок.\n" ..
			"    /casino          Открыть меню казино.\n" ..
			"    /tetris             Открыть тетрис.\n" ..
			"    /pong <сложность> Играть в понг.\n" ..
			"       *сложности: Noob, Easy, Medium, Hard, Extreme"
	} )
end

function HCommands:ModuleLoad()
	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:EngHelp()
	else
		self:RusHelp()
	end
end

hcommands = HCommands()
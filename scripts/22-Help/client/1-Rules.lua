class 'HCommands'

function HCommands:__init()
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "Lang", self, self.EngHelp )
end

function HCommands:EngHelp()
	Events:Fire( "HelpRemoveItem", { name = "ПРАВИЛА" } )

	Events:Fire( "HelpAddItem",
	{
		name = "RULES",
		text =
				"> Forbidden for players:\n" ..
				"    1. Insults in the general chat.\n" ..
				"    2. Abuse of CAPS / aLtErNaTiNg CaSe.\n" ..
				"    3. Spam or unauthorized advertising in chat.\n" ..
				"    4. Threats, discussions of physical violence or terrorist plans outside of the in-game context.\n" ..
				"    5. Intentional attempts to break the server or game.\n" ..
				"    6. Intentional killing while in peaceful mode or killing peaceful players.\n" ..
				"       P.S. Violation reports should contain screen recording.\n" ..
				"    7. Pretending to be an admin, but with your own nickname.\n" ..
				"    8. Intentional use of admin nicknames. \n \n \n" ..
				"> Forbidden for clans:\n" ..
				"    1. Have a name that offends the player/server administration.\n \n" ..
				">  Forbidden for administration:\n" ..
				"    1. Insulting players on the server.\n" ..
				"    2- Use admin privileges for any negative interaction with players.\n" ..
				"      - Allowed, if the administrator was asked to do something to the player by the player himself.\n" ..
				"      - Allowed, if interaction is with another administrator.\n" ..
				"    3. Giving money to other players (using the admin panel).\n" ..
				"      - Allowed only for head administrators or creators during server events.\n \n" ..
				"> Administrator should:\n" ..
				"    1. Give answer questions regarding the server.\n" ..
				"      - Not necessary until the administrator has enabled their prefix.\n" ..
				"      - Not necessary to server owners.\n" ..
				"    2. Ensure that players do not break the rules.\n" ..
				"    3. Know >80% of the server functionality and/or be able to navigate the help menu.\n" ..
				"      - Not necessary for players who bought the privilege with money.\n" ..
				"         (such players have a $ sign at the end of the prefix)\n \n" ..
				"> Additionally:\n" ..
				"    1. Maximum ban period is one month. In case of multiple violations, the ban is issued permanently.\n" .. 
				"    2. The measure of punishment depends on the severity of violation, public opinion, context and mood of the administration :)\n" .. 
				"    3. Blocked player can buy an unlock regardless of the number of violations.\n" ..
				"    4. Ignorance of server rules do not exempt you from responsibility!\n" ..
				"    5. If you think that the administrator exceeds his authority - report it to us."
	} )
end

function HCommands:RusHelp()
	Events:Fire( "HelpRemoveItem", { name = "RULES" } )

	Events:Fire( "HelpAddItem",
	{
		name = "ПРАВИЛА",
		text =
				"> Игрокам запрещается:\n" ..
				"    1. Оскорбления в общем чате.\n" ..
				"    2. Злоупотребление КАПСОМ / ЧеРедОВаНиЕм РеГиСтТрА.\n" ..
				"    3. Спам или несогласованная реклама в чате.\n" ..
				"    4. Угрозы, обсуждения физического насилия или террористических планов вне игрового контекста.\n" ..
				"    5. Намеренные попытки сломать сервер или игру людям.\n" ..
				"    6. Намеренные убийства находясь в мирном режиме или убийства мирных игроков.\n" ..
				"           P.S. Необходимо предъявить видео с нарушением.\n" ..
				"    7. Притворяться админом, но со своим ником.\n" ..
				"    8. Намеренное использование админских ников.\n \n" ..
				"> Кланам запрещается:\n" ..
				"    1. Иметь название, оскорбляющее игрока/администрацию сервера.\n \n" ..
				"> Администраторам запрещается:\n" ..
				"    1. Оскорблять игроков на сервере.\n" ..
				"    2. Использовать админские привилегии для любого негативного взаимодействия с игроками.\n" ..
				"      - Не считается, если администратора попросили сделать то или иное действие над игроком.\n" ..
				"      - Не считается, если негативное взаимодействие происходит над другим администратором.\n" ..
				"    3. Выдавать деньги другим игрокам (с помощью админ-панели).\n" ..
				"      - Не считается, при проведении гл. админом или владельцем сервера внутриигровых событий.\n \n" ..
				"> Администратор должен:\n" ..
				"    1. Давать ответы на вопросы, касающиеся сервера.\n" ..
				"      - Эти обязанности не актуальны до момента пока администратор не включил свой префикс.\n" ..
				"      - Эти обязанности не актуальны для владельцев сервера.\n" ..
				"    2. Следить за порядком сервера.\n" ..
				"    3. Знать >80% функционала сервера и/или уметь ориентироваться в меню помощи.\n" ..
				"      - Эти обязанности не актуальны для игроков, которые купили привилегию за деньги.\n" ..
				"         (у таких игроков значок $ на конце префикса)\n \n" ..
				"> Дополнительно:\n" ..
				"    1. Максимальный срок блокировки - месяц. При многочисленных нарушениях бан выдается перманентно (навсегда).\n" ..
				"    2. Мера наказания зависит от степени нарушения, общественного порицания, контекста и настроения администрации :)\n" ..
				"    3. Заблокированный игрок может купить разблокировку вне зависимости от количества нарушений.\n" ..
				"    4. Незнание правил сервера не освобождает вас от ответственности!\n" ..
				"    5. Если считаете то, что администратор превышает свои полномочия - сообщите нам об этом."
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
class 'HFAQ'

function HFAQ:__init()
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "Lang", self, self.EngHelp )
end

function HFAQ:EngHelp()
	Events:Fire( "HelpRemoveItem", { name = "Часто задаваемые вопросы (FAQ)" } )

	Events:Fire( "HelpAddItem",
	{
		name = "FAQ",
		text =
			"> What language is the server?\n" ..
			"    This is a Russian server.\n" ..
			"     Now jokes about vodka and Putin will go.\n \n" ..
			"> What languages can I use to chat?\n" ..
			"    You can chat in absolutely any language!\n \n" ..
			"> Is there any missions on server?\n" ..
			"    There is no mission on our server, but they may be on other servers.\n" ..
			"    We recommend JC2RP for them. \n \n" ..
			"> How to gain money?\n" ..
			"    Play minigames and gain rewards!\n \n" ..
			"> Where is bots (NPC)?\n" ..
			"    The only bots on the server are BOATS.\n" ..
			"    No any police here.\n \n" ..
			"> What to do here?\n" ..
			"    Get a rid of fun of here!\n" ..
			"    You always can find what to do on server. That's for sure!\n" ..
			"    In every moment the answer for this question will be found automatically.\n \n" ..
			"> The market and map doesn't work?\n" ..
			"    You don't have needed files in 'images' folder.\n" ..
			"    You need to verify your game files, using the 'Properties->Verify Game Files' buttons in Steam.\n \n" ..
			"> The model of player is broken. What i should do?\n" ..
			"    Bug can be obtained on entering the server.\n" ..
			"    To fix this, you need to re-enter the game. Or have fun with it :3\n \n" ..
			"> How to become an administrator?\n" ..
			"    We will decide it on our own :)\n \n" ..
			"> Other problems with JC2MP:\n    jc2mpwiki.miraheze.org/wiki/Troubleshooting\n \n" ..
			"Enjoy the game on the Russian server! :D"
	} )
end

function HFAQ:RusHelp()
	Events:Fire( "HelpRemoveItem", { name = "FAQ" } )

	Events:Fire( "HelpAddItem",
	{
		name = "Часто задаваемые вопросы (FAQ)",
		text =
			"> Тут есть миссии?\n" ..
			"    На данном сервере нет, но возможно есть на других.\n" ..
			"     Рекомендуем для этого сервер - JC2RP\n \n" ..
			"> Как зарабатывать?\n" ..
			"    - Выигрывай в мини-играх.\n" ..
			"    - Находи ящики с деньгами по карте.\n" ..
			"    - Удерживайте и устанавливайте хорошечные рекорды.\n" ..
			"    - Выполняйте ежедневные задания.\n" ..
			"    - Выполняйте задания в чате.\n" ..
			"    - Убивайте игроков, которые имеют более 1-го убийства (посмотреть можно в списке игроков).\n" ..
			"    - Устройте стартап и выпрашивайте деньги у других игроков.\n" ..
			'    Игровую валюту можно также приобрести за донат, подробности во вкладке "Информация".\n \n' ..
			"> Где боты (NPC)?\n" ..
			"    На данном сервере отсутствуют какие-либо боты.\n \n" ..
			"> Что тут делать?\n" ..
			"    Веселись, бухай, стреляй, угарай!\n" ..
			"     На сервере всегда найдется, чем заняться. Уж это точно.\n" ..
			"     В любой момент этот вопрос найдет сам на себя ответ.\n \n" ..
			"> Не работает магазин/карта?\n" ..
			"    У вас отсутствуют нужные файлы в папке images.\n" ..
			"     Чтобы восстановить файлы, достаточно переустановить клиент\n     или через свойства стима выполнить проверку цельности файлов игры.\n \n" ..
			"> Сломались кости персонажа?\n" ..
			"    Баг появляется после любого перезахода на сервер.\n" ..
			"     Чтобы исправить, просто перезайдите в игру или наслаждайтесь :3\n \n" ..
			"> Что такое СКМ?\n" ..
			"    СКМ - Средняя кнопка мыши.\n" ..
			"     Средняя кнопка мыши - это колесико мыши. Просто нажмите по нему.\n \n" ..
			"> Мешают РП процессу?\n" ..
			"    Это не РП сервер и каждый игрок может делать то, что он захочет, соблюдая правила.\n" ..
			"    Любой игрок может вас убить до тех пор, пока вы не будете находиться в мирном режиме.\n \n" ..
			"> Как стать админом?\n" ..
			"    Мы сами решим :)\n \n" ..
			"> Решение других проблем связанных с JC2MP:\n    jc2mpwiki.miraheze.org/wiki/Troubleshooting\n \n" ..
			"Надеюсь, после прочтения этой вкладки у вас будет меньше вопросов.\n" ..
			"(Кто-то это читает? O_o)"
	} )
end

function HFAQ:ModuleLoad()
	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:EngHelp()
	else
		self:RusHelp()
	end
end

hfaq = HFAQ()
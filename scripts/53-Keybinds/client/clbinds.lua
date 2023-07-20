class 'Bind'

local toBind = nil
local binds = {}
local unbind = false
local color = Color( 240, 195, 55 )

function Bind:__init()
	self.cooldown = 1
	timer = Timer()
	self.cooltime = 0

	Events:Subscribe( "LocalPlayerChat", self, self.LocalPlayerChat )
	Events:Subscribe( "KeyDown", self, self.KeyDown )
end

function Bind:LocalPlayerChat( args )
	if string.sub(args.text,1,6) == "/bind " then
		toBind = string.sub(args.text, 7)
		if string.sub(toBind,1,1) == "/" then
			Chat:Print( "[Привязка] ", Color.White, "Нажмите клавишу, которую вы хотите связать с командой " .. toBind, Color.Red )
		end
	elseif string.sub(args.text,1,5) == "/bind" then
		Chat:Print( "[Привязка] ", Color.White, "Пример использования:", color, " /bind /jesus", Color.White )
		Chat:Print( "[Привязка] ", Color.White, "Вам будет предложено нажать клавишу для привязки команды.", color )
		Chat:Print( "[Привязка] ", Color.White, "Другие команды:", color, " /unbind, /unbindall, /list", Color.White )
	elseif args.text == "/unbindall" then
		binds = {}
		Chat:Print( "[Привязка] ", Color.White, "Все клавиши отвязаны.", color )
		UpdateKeys()
	elseif string.sub(args.text,1,7) == "/unbindall" then
		Chat:Print( "[Привязка] ", Color.White, "Введите /unbindall, чтобы отвязать все клавиши.", color )
	elseif args.text == "/unbind" then
		unbind = true
		Chat:Print ("[Привязка] ", Color.White, "Нажмите клавишу, которую вы хотели бы отвязать.", color )
	elseif string.sub(args.text,1,7) == "/unbind" then
		Chat:Print( "[Привязка] ", Color.White, "Введите /unbind, чтобы отвязать клавишу", color )
	elseif args.text == "/list" then
		for k,v in pairs(binds) do
			Chat:Print( "[Привязка] ", Color.White, k .. " (" .. string.char(k) .. ") делает " .. v, color )
		end
	end
end


function Bind:KeyDown( args )
	local time = Client:GetElapsedSeconds()
	if unbind then
		if binds[args.key] then
			Chat:Print( "[Привязка] ", Color.White, "Команда " .. binds[args.key] .. " отвязана от " .. args.key .. " ("..string.char(args.key) .. ")", color )
			binds[args.key] = nil
			unbind = false
			UpdateKeys()
		else
			Chat:Print( "[Привязка] ", Color.White, "Никакая команда не была связана с кнопкой " .. args.key .. " (" .. string.char(args.key) .. ")", color )
			unbind = false
		end
	elseif toBind then
		if string.sub(toBind,1,1) == "/" then
			local message = ""
			if string.sub(toBind,1,1) == "/" then
				message = message .. "Команда "
			end
			message = message .. toBind .. " привязана к клавише " .. args.key .. " ("..string.char(args.key)..")"
			if binds[args.key] then message = message .. ", изменено на " .. binds[args.key] end
			binds[args.key] = toBind
			Chat:Print( "[Привязка] ", Color.White, message, color )
			toBind = nil
			UpdateKeys()
		end
	elseif binds[args.key] then
		if time < self.cooltime then return end
		Events:Fire("LocalPlayerChat", {text=binds[args.key]})
		Network:Send("SimulateCommand", binds[args.key])
		self.cooltime = time + self.cooldown
	end
end

function UpdateKeys()
	Network:Send( "SQLSave", binds )
end

Network:Subscribe( "SQLLoad", function( args )
	binds = args
	if next(binds) == nil then
	else
		print( "Привязка клавиш загружена!" )
	end
end )

bind = Bind()
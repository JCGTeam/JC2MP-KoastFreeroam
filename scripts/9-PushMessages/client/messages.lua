class 'Messages'

function Messages:__init()
	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
		self.updatefiles = "Обновление файлов! "
		self.loadfiles = "Идёт загрузка файлов..."
		self.err = "Произошла ошибка! "
		self.errTw = "Критическая ошибка! "
		self.higping = "Высокий пинг! "
		self.mblags = "Возможны задержки"
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
	Events:Subscribe( "ModuleError", self, self.ModuleError )
	Network:Subscribe( "text", self, self.Text )
	Network:Subscribe( "textTw", self, self.TextTw )
end

function Messages:Lang()
	self.updatefiles = "Updating files! "
	self.loadfiles = "Downloading files..."
	self.err = "Module error! "
	self.errTw = "Critical error! "
	self.higping = "High ping! "
	self.mblags = "Possible delays"
end

function Messages:ModulesLoad()
	Events:Fire( "SendNotification", {txt = self.updatefiles, image = "Upgrade", subtxt = self.loadfiles} )
	Events:Fire( "LoadUI" )
end

function Messages:ModuleError( e )
	Events:Fire( "SendNotification", {txt = self.err, image = "Warning", subtxt = "Module: " .. e.module} )
	Network:Send( "ClientError", { moduletxt = e.module, errortxt = e.error } )
end

function Messages:Text()
	Events:Fire( "SendNotification", {txt = self.higping, image = "Warning", subtxt = self.mblags} )
end

function Messages:TextTw( args )
    Events:Fire( "SendNotification", {txt = self.errTw, image = "Warning", subtxt = "Module: " .. args.error} )
end

messages = Messages()
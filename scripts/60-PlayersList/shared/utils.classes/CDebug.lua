class 'CDebug'

function CDebug:__init()
	-- Settings
	self.types_enum = { "error", "warning", "default" };

	self.tMessageTypes =
	{
		error 	= { prefix = "[Error]", color = Color(255, 0, 0, 255) },
		warning = { prefix = "[Warning]", color = Color(255, 255, 0, 255) },
		default = { prefix = "[Debug]", color = Color(0, 255, 0, 255) },
	};
end

function CDebug:GetTypeData(debugType)
	if (type(debugType) == 'string' and self.tMessageTypes[debugType]) then
		return self.tMessageTypes[debugType];
	end
	return self.tMessageTypes[self.types_enum[tonumber(debugType)]];
end

function CDebug:Print(text, type)
	type = type or 3;
	local typeData = self:GetTypeData(type);
	local msg = typeData.prefix .. " "..tostring(text);
	Chat:Print(msg, typeData.color);
end

CDebug = CDebug();
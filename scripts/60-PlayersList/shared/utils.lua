function table.merge(table1, table2)
	for k, v in pairs(table2) do
		table1[k] = v;
	end
	return table1;
end

function table.isValue(table1, value)
	for i, v in ipairs(table1) do
		if (v == value) then
			return true;
		end
	end
	return false;
end

function isClientSide()
	return type(Render) == "userdata"; end

function isServerSide()
	return type(Render) ~= "userdata"; end


function formatNumber(amount)
	local formatted = tostring(amount);
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2');
		if (k==0) then
			break
		end
	end
	return formatted;
end
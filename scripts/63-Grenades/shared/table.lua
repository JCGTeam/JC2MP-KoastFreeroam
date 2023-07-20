function table.compare(tbl1, tbl2)
	for k, v in pairs(tbl1) do
		if tbl2[k] ~= v then
			return false
		end
	end

	for k, v in pairs(tbl2) do
		if tbl1[k] ~= v then
			return false
		end
	end

	return true
end
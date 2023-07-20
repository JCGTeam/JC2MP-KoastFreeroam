function Client:getServerPlayers()
	local players = {LocalPlayer};
	for p in Client:GetPlayers() do
		table.insert(players, p);
	end
	return players;
end
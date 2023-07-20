class 'SeaTrafficMap'

function SeaTrafficMap:__init( data, cell_size )
	local h = data.h
	local graph = {}

	local function GetCellXY(x, z)
		return math.floor((x + 16384) / cell_size), math.floor((z + 16384) / cell_size)
	end

	local function GetCell(x, z)
		local cell_x, cell_y = GetCellXY(x, z)
		return graph[cell_x] and graph[cell_x][cell_y] or nil
	end

	local function AddNode(x, z)
		local cell_x, cell_y = GetCellXY(x, z)
		graph[cell_x] = graph[cell_x] or {}
		graph[cell_x][cell_y] = graph[cell_x][cell_y] or {}
		graph[cell_x][cell_y][x] = graph[cell_x][cell_y][x] or {}
		graph[cell_x][cell_y][x][z] = {Vector3(x, 200, z), {}}
	end

	local function DeleteNode(node)
		for _, neighbor in ipairs(node[2]) do
			table.remove(neighbor[2], table.find(neighbor[2], node))
		end

		local x = math.floor(node[1].x + 0.5)
		local z = math.floor(node[1].z + 0.5)
		local cell_x, cell_y = GetCellXY(x, z)

		graph[cell_x][cell_y][x][z] = nil

		if not next(graph[cell_x][cell_y][x]) then
			graph[cell_x][cell_y][x] = nil
			if not next(graph[cell_x][cell_y]) then
				graph[cell_x][cell_y] = nil
				if not next(graph[cell_x]) then
					graph[cell_x] = nil
				end
			end
		end
	end
	
	-- load nodes from position data
	for x, v in pairs(data.positions) do
		for _, z in ipairs(v) do
			AddNode(x, z)
		end
	end
	
	-- add connections for neighboring nodes
	for cell_x, v in pairs(graph) do
		for cell_y, v in pairs(v) do
			for x, v in pairs(v) do
				for z, node in pairs(v) do
					local f_cell = GetCell(x, z - h)
					local b_cell = GetCell(x, z + h)
					local l_cell = GetCell(x - h, z)
					local r_cell = GetCell(x + h, z)
					
					local fl_cell = GetCell(x - h, z - h)
					local fr_cell = GetCell(x + h, z - h)
					local bl_cell = GetCell(x - h, z + h)
					local br_cell = GetCell(x + h, z + h)
					
					local f_neighbor = f_cell and f_cell[x] and f_cell[x][z - h]
					if f_neighbor then table.insert(node[2], f_neighbor) end
					
					local b_neighbor = b_cell and b_cell[x] and b_cell[x][z + h]
					if b_neighbor then table.insert(node[2], b_neighbor) end
					
					local l_neighbor = l_cell and l_cell[x - h] and l_cell[x - h][z]
					if l_neighbor then table.insert(node[2], l_neighbor) end
					
					local r_neighbor = r_cell and r_cell[x + h] and r_cell[x + h][z]
					if r_neighbor then table.insert(node[2], r_neighbor) end

					local fl_neighbor = fl_cell and fl_cell[x - h] and fl_cell[x - h][z - h]
					if fl_neighbor then table.insert(node[2], fl_neighbor) end
					
					local fr_neighbor = fr_cell and fr_cell[x + h] and fr_cell[x + h][z - h]
					if fr_neighbor then table.insert(node[2], fr_neighbor) end
					
					local bl_neighbor = bl_cell and bl_cell[x - h] and bl_cell[x - h][z + h]
					if bl_neighbor then table.insert(node[2], bl_neighbor) end
					
					local br_neighbor = br_cell and br_cell[x + h] and br_cell[x + h][z + h]
					if br_neighbor then table.insert(node[2], br_neighbor) end
				end
			end
		end
	end

	-- mark nodes connected to the origin node
	local start = graph[0][0][-16384][-16384]
	local connected = {[start] = true}
	local s = {start}

	while #s > 0 do
		for _, neighbor in ipairs(table.remove(s)[2]) do
			if not connected[neighbor] then
				table.insert(s, neighbor)
				connected[neighbor] = true
			end
		end	
	end

	-- delete all nodes not connected to the origin node
	local deletions = {}
	for cell_x, v in pairs(graph) do
		for cell_y, v in pairs(v) do
			for x, v in pairs(v) do
				for z, node in pairs(v) do
					if not connected[node] then
						table.insert(deletions, node)
					end
				end
			end
		end
	end

	for _, node in ipairs(deletions) do
		DeleteNode(node)
	end

	-- remove dead ends
	repeat
		local deletions = {}
		for cell_x, v in pairs(graph) do
			for cell_y, v in pairs(v) do
				for x, v in pairs(v) do
					for z, node in pairs(v) do
						if #node[2] < 2 then
							table.insert(deletions, node)
						end
					end
				end
			end
		end

		for _, node in ipairs(deletions) do
			DeleteNode(node)
		end
	
	until #deletions == 0

	-- add all node references to one array
	local nodes = {}
	for cell_x, v in pairs(graph) do
		for cell_y, v in pairs(v) do
			for x, v in pairs(v) do
				for z, node in pairs(v) do
					table.insert(nodes, node)
				end
			end
		end
	end

	self.graph = graph
	self.nodes = nodes
	self.cell_size = cell_size
	self.h = h
end

function SeaTrafficMap:GetRandomPath( node, direction )
	local path = {node}

	path[2] = self:GetNextNode(path[1], direction)
	path[3] = self:GetNextNode(path[2], path[2][1] - path[1][1])
	path[4] = self:GetNextNode(path[3], path[3][1] - path[2][1])
	path[5] = self:GetNextNode(path[4], path[4][1] - path[3][1])
	path[6] = self:GetNextNode(path[5], path[5][1] - path[4][1])

	return path
end

function SeaTrafficMap:GetNearestNode( position )
	local nearest_distance, nearest_node = math.huge
	local cell = self:GetCell(position.x, position.z) or self:GetNearestCell(position)

	for x, v in pairs(cell) do
		for z, node in pairs(v) do
			local distance = position:DistanceSqr(node[1])
			if distance < nearest_distance then
				nearest_distance = distance
				nearest_node = node
			end
		end
	end

	return nearest_node
end

function SeaTrafficMap:GetNextNode( node, direction )
	local position = node[1]
	local priority = {{}, {}, {}}

	for _, neighbor in ipairs(node[2]) do
		local dot = (neighbor[1] - position):Normalized():Dot(direction:Normalized())
		dot = math.floor(dot * 10 + 0.5) / 10
		
		if dot == 1 then
			table.insert(priority[1], neighbor)
		elseif dot > 0 then
			table.insert(priority[2], neighbor)
		else
			table.insert(priority[3], neighbor)
		end
	end

	local n = math.random()

	if n > 0.5 and #priority[1] > 0 then
		return table.randomvalue(priority[1])
	elseif #priority[2] > 0 then
		return table.randomvalue(priority[2])
	else
		return table.randomvalue(priority[3])
	end
end

function SeaTrafficMap:GetNearestCell( position )
	local nearest_distance, nearest_cell = math.huge

	for cell_x, v in pairs(self.graph) do
		for cell_y in pairs(v) do
			local x = self.cell_size * (cell_x + 0.5) - 16384
			local z = self.cell_size * (cell_y + 0.5) - 16384

			local distance = position:DistanceSqr(Vector3(x, position.y, z))
			if distance < nearest_distance then
				nearest_distance = distance
				nearest_cell = self.graph[cell_x][cell_y]
			end
		end
	end			

	return nearest_cell
end

function SeaTrafficMap:GetCellXY( x, z )
	return math.floor((x + 16384) / self.cell_size), math.floor((z + 16384) / self.cell_size)
end
	
function SeaTrafficMap:GetCell( x, z )
	local cell_x, cell_y = self:GetCellXY(x, z)
	return self.graph[cell_x] and self.graph[cell_x][cell_y] or nil
end
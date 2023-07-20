class "Course"
function Course:__init(manager)
	self.derbyManager = manager
	self.manifestPath = "server/Courses/Manifest.txt"
	self.courseNames = {}
	self.numCourses = 0

	self.smallCourses = {}
	self.largeCourses = {}

	self:LoadManifest(self.manifestPath)
	self:DetermineClass()
end
---------------------------------------------------------------------------------------------------------------------
------------------------------------------------MANIFEST LOADING-----------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
function Course:LoadManifest(path)
	local tempFile , tempFileError = io.open(path , "r")
	if tempFileError then
			print()
			print("*ERROR*")
			print(tempFileError)
			print()
			fatalError = true
			return
	else
			io.close(tempFile)
	end
	-- Loop through each line in the manifest.
	for line in io.lines(path) do
		-- Make sure this line has stuff in it.
		if string.find(line , "%S") then
				-- Add the entire line, sans comments, to self.courseNames
				table.insert(self.courseNames , line:trim())
				self.numCourses = self.numCourses + 1
		end
	end
end
---------------------------------------------------------------------------------------------------------------------
------------------------------------------------DETERMINE CLASSES----------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
function Course:DetermineClass()
	for index, course in pairs(self.courseNames) do
		local path = "server/Courses/" .. course:trim() .. ".course"
		--check if path is invalid
		if path == nil then
			print("*ERROR* - Course path is nil!")
			return nil
		end	
		local file = io.open(path , "r") 
		--check if file exists
		if not file then
			print("Determine Class")
			print("*ERROR* - Cannot open course file: "..path)
			return nil
		end
		for line in file:lines() do
			if line:sub(1,1) == "T" then
				line = line:gsub("Type%(", "")
				line = line:gsub("%)", "")
				line = line:trim()

				if (line == "small") then
					table.insert(self.smallCourses, course:trim())
				elseif (line == "large") then
					table.insert(self.largeCourses, course:trim())
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------
-----------------------------------------------COURSE FILE PARSING---------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
function Course:LoadCourse(name)
	if name == nil then
		name = self:PickCourse()
	end
	local path = "server/Courses/" .. name .. ".course"
	--check if path is invalid
	if path == nil then
		print("*ERROR* - Course path is nil!")
		return nil
	end	
	local file = io.open(path , "r") 
	--check if file exists
	if not file then
		print("*ERROR* - Cannot open course file: "..path)
		return nil
	end

	local course = {}
	course.Location = nil
	course.courseType = nil
	course.Time = nil
	course.Weather = nil
	course.minPlayers = nil
	course.maxPlayers = nil
	course.Boundary = {}
	course.MinimumY = nil
	course.MaximumY = nil
	course.Event = {}
	course.Vehicles = {}
	course.SpawnPoint = {}


	--loop through file line by line
	for line in file:lines() do
		if line:sub(1,1) == "L" then
			course.Location =  self:Location(line)
		elseif line:sub(1,1) == "T" and line:sub(2,2) == "y" then
			course.courseType =  self:Type(line)
		elseif line:sub(1,1) == "T" and line:sub(2,2) == "i" then
			course.Time =  self:Time(line)
		elseif line:sub(1,1) == "W" then
			course.Weather = self:Weather(line)
		elseif line:sub(1,1) == "P" then
			local playerCount = self:Players(line)
			course.minPlayers = playerCount.minPlayers
			course.maxPlayers = playerCount.maxPlayers
		elseif line:sub(1,1) == "B" then
			local boundary = self:Boundary(line)
			course.Boundary.position = boundary.position
			course.Boundary.radius = boundary.radius
		elseif line:sub(1,1) == "M" and line:sub(2,2) == "i" then
			course.MinimumY = self:MinimumY(line)
		elseif line:sub(1,1) == "M" and line:sub(2,2) == "a" then
			course.MaximumY = self:MaximumY(line)
		elseif line:sub(1,1) == "E" then
			table.insert(course.Event, self:Event(line))
		elseif line:sub(1,1) == "V" then
			course.Vehicles = self:Vehicle(line)
		elseif line:sub(1,1) == "S" then
			table.insert(course.SpawnPoint, self:Spawn(line))
		end
	end
	return course
end
function Course:Location(line)
	line = line:gsub("Location%(", "")
	line = line:gsub("%)", "")

	return line
end
function Course:Type(line)
	line = line:gsub("Type%(", "")
	line = line:gsub("%)", "")

	return line
end
function Course:Time(line)
	line = line:gsub("Time%(", "")
	line = line:gsub("%)", "")
	line = line:gsub(" ", "")

	local tokens = line:split(",")   
	if tokens[1]:trim() == "random" then
		math.randomseed(os.time())
		tokens[1] = math.random() * 24
	end
	if tokens[2]:trim() == "random" then
		math.randomseed(os.time())
		tokens[2] = math.random() * 60
	end
	return tokens
end
function Course:Weather(line)
	line = line:gsub("Weather%(", "")
	line = line:gsub("%)", "")
	line = line:gsub(" ", "")

	if line:trim() == "random" then
		math.randomseed(os.time())
		line = math.random() * 2
	end
	return line
end
function Course:Players(line)
	line = line:gsub("Players%(", "")
	line = line:gsub("%)", "")
	line = line:gsub(" ", "")

	local tokens = line:split(",")   
	local args = {}

	args.minPlayers = tonumber(tokens[1])
	args.maxPlayers = tonumber(tokens[2])

	return args
end
function Course:Boundary(line)
	line = line:gsub("Boundary%(", "")
	line = line:gsub("%)", "")
	line = line:gsub(" ", "")

	local tokens = line:split(",")   
	local args = {}
	-- Create tables containing appropriate strings
	args.position	= Vector3(tonumber(tokens[1]), tonumber(tokens[2]), tonumber(tokens[3]))
	args.radius		= tonumber(tokens[4])

	return args
end
function Course:MinimumY(line)
	line = line:gsub("MinimumY%(", "")
	line = line:gsub("%)", "")

	return tonumber(line)
end
function Course:MaximumY(line)
	line = line:gsub("MaximumY%(", "")
	line = line:gsub("%)", "")

	return tonumber(line)
end
function Course:Event(line)
	line = line:gsub("Event%(", "")
	line = line:gsub("%)", "")
	line = line:gsub(" ", "")

	local tokens = line:split(",")  
	local args = {}

	args.min = tokens[1]
	args.max = tokens[2]
	args.events = {}

	for i=3, #tokens, 1 do
		table.insert(args.events, tokens[i])
	end

	return args
end
function Course:Vehicle(line)
	line = line:gsub("Vehicles%(", "")
	line = line:gsub("%)", "")
	line = line:gsub(" ", "")

	local tokens = line:split(",")  

	local args = {}
	if tokens[1] == "true"  then
		for i=2, #tokens, 1 do
			table.insert(args, tokens[i])
		end
	else
		math.randomseed(os.time())
		local var = math.floor(math.random(2, #tokens))
		table.insert(args, tokens[var])
	end
	return args
end
function Course:Spawn(line)
	line = line:gsub("Spawn%(", "")
	line = line:gsub("%)", "")
	line = line:gsub(" ", "")

	local tokens = line:split(",")   
	local args = {}
	-- Create tables containing appropriate strings
	args.position	= Vector3(tonumber(tokens[1]), tonumber(tokens[2]), tonumber(tokens[3]))
	args.angle		= Angle(tonumber(tokens[4]), tonumber(tokens[5]), tonumber(tokens[6]))

	return args
end
function Course:PickCourse()
	if #self.smallCourses == 0 then
		return table.randomvalue(self.largeCourses)
	elseif #self.largeCourses == 0 then
		return table.randomvalue(self.smallCourses)
	else
		if self.derbyManager.largeActive == true then
			return table.randomvalue(self.smallCourses)
		else
			if #self.largeCourses ~= 0 then
				self.derbyManager.largeActive = true
				return table.randomvalue(self.largeCourses)
			else
				return table.randomvalue(self.smallCourses)
			end
		end
	end
end
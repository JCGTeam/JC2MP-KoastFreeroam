class "Event"

function Event:__init(derby, eventTable)
	self.derby = derby
	self.events = {}
	self.timer = nil
	self:Parse(eventTable)
end

function Event:Parse(eventTable)
	for index in pairs(eventTable) do
		local time = math.random(eventTable[index].min, eventTable[index].max)
		local args = {}
		args.min = eventTable[index].min
		args.max = eventTable[index].max
		args.time = time
		args.events = {}
		for index, item in pairs(eventTable[index].events) do
			table.insert(args.events, item)
		end
		table.insert(self.events, args)
	end
end

function Event:ResetTimer()
	self.timer = nil
	self.timer = Timer()
end

function Event:ResetEvent(index)
	self.events[index].time = math.random(self.events[index].min + self.timer:GetSeconds(), self.events[index].max + self.timer:GetSeconds())
end

function Event:Update()
	for index, item in ipairs(self.events) do
		if self.timer:GetSeconds() >= item.time then
			for index, item in ipairs(item.events) do
				self:TriggerEvent(item)
			end
			self:ResetEvent(index)
		end
	end
end

function Event:TriggerEvent(event)
	for k,p in pairs(self.derby.players) do
		Network:Send(p, "TriggerEvent", event)
	end
end
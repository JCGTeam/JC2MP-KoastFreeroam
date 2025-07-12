class "Set"

function Set:__init()
    self.items = {}
end

function Set:GetSize()
    return #self.items
end

function Set:GetItems()
    return self.items
end

function Set:Contains(item)
    return table.find(self.items, item) ~= nil
end

function Set:Add(item)
    if not self:Contains(item) then
        table.insert(self.items, item)
    end
end

function Set:Remove(item)
    if self:Contains(item) then
        table.remove(self.items, table.find(self.items, item))
    end
end

function Set:Clear()
    self.items = {}
end
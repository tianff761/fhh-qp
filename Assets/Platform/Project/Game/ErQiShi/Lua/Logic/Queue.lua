Queue = Class("Queue")

Queue.items = nil

function Queue:Enqueue(item)
    if self.items == nil then
        self.items = {}
    end
    table.insert(self.items,1, item)
end

function Queue:Count()
    return GetTableSize(self.items)
end

function Queue:Items()
    return self.items
end

function Queue:Dequeue()
    if self.items == nil then
        return nil
    end

    local count = GetTableSize(self.items)
    local idx = 0
    for key, item in pairs(self.items) do
        idx = idx + 1
        if count == idx  then
            table.remove(self.items, key)
            return item
        end
    end
    return nil
end

function Queue:Clear()
    self.items = {}
end

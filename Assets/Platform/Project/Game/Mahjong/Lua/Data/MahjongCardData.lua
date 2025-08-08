--麻将牌数据
MahjongCardData = {
    --麻将牌的ID，如101、102等
    id = 0,
    --麻将牌的Key，如1、11、21等
    key = 0,
    --麻将类型，区分筒条万
    type = 0,
    --排序字段，如果是定缺牌的话，就用ID加上一个固定值，否则就是ID
    sort = 0,
    --是否是听用牌，临时使用
    isTingYong = false,
    --是否是定缺牌，临时使用
    isDingQue = false,
}

local meta = { __index = MahjongCardData }

function MahjongCardData.New()
    local obj = {}
    setmetatable(obj, meta)
    return obj
end

--设置ID
--101-104表示1万、201-204表示2万
--1101-1104表示1条、1201-1204表示2条
--2101-2104表示1同、2201-2204表示2筒
function MahjongCardData:SetId(id)
    --LogError("SetId", id)
    self.id = id
    local tempId = id > 0 and id or -id
    self.key = math.floor(tempId / 100)
    self.type = math.floor(tempId / 1000) + 1
end

--更新排序值
function MahjongCardData:UpdateSort()
    if self.isTingYong then
        self.sort = self.id - 10000
    else
        self.sort = self.id
    end
end
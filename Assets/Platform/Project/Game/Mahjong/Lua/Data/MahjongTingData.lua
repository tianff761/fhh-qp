--听牌处理对象
MahjongTingData = {
    --类型，0表示3个非听用牌组合，1表示2张牌挨着+听用；2表示需要卡一张牌+听用
    type = 0,
    card1 = nil,
    card2 = nil,
    card3 = nil,
    card4 = nil,
}

local meta = { __index = MahjongTingData }

function MahjongTingData.New()
    local obj = {}
    setmetatable(obj, meta)
    return obj
end
--牌数：共32张牌 			
-- 20,21,22,23,        --2
-- .....
-- 130,131,132,133    -- A
-- 花色 id%10
-- 点数 id/ 10
--
TpCardData = {
    --ID
    id = 0,
    --牌的Key，具体数值(点数)，比如红2为2，黑2为2
    key = 0,
    --类型，区分方梅红黑
    type = 0,
    --排序字段
    sort = 0,
    --资源
    resKey = -1
}

local meta = { __index = TpCardData }

function TpCardData.New()
    local obj = {}
    setmetatable(obj, meta)
    return obj
end

--设置ID
function TpCardData:SetId(id)
    self.id = id
    self.key =  (id - 1) % 13 + 1  --math.floor(id / 10)
    self.type = math.floor((id - 1) / 13) --id % 10
    --处理资源名称Key
    local temp = self.key
    if self.key == 14 then
        temp = 1
    end
    self.resKey = temp * 100 + (self.type + 1)--服务器是0-3，客户端是1-4
end



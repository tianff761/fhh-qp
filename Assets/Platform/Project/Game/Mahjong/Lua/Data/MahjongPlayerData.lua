--麻将玩家数据
MahjongPlayerData = {
    --玩家id
    id = nil,
    --玩家远端座位号
    seat = 0,
    --玩家名称
    name = "",
    --玩家头像
    headUrl = "0",
    --玩家头像框ID
    headFrame = 0,
    --玩家性别
    gender = Global.GenderType.Female,
    --玩家本地的座位索引
    seatIndex = 0,
    --
    --玩家分数
    score = 0,
    --玩家分数
    gold = 0,
    --玩家IP
    ip = nil,
    --玩家GPS信息
    gps = nil,
    --玩家GPS地址
    address = nil,
    --玩家准备状态1表示准备了，0表示没有准备
    ready = nil,
    --玩家进入房间标识，0未进入，1进入
    join = nil,
    --在线标识
    online = 0,
    --定缺，服务器可能发送数据0，0表示没有定缺
    dingQue = 0,
    --胡的类型
    huType = nil,
    --胡的索引，即是第几胡
    huIndex = nil,
    --胡的番数
    huFan = 0,
    --玩家状态
    state = 0,
    --玩家桌子状态
    tState = 0,
    --托管状态
    trust = 0,
    --===============================
    --换出的牌，用于回放
    changeCardsOut = nil,
    --换回的牌，用于回放
    changeCardsBack = nil,
    --===============================
    --扣除的分数，属于临时变量
    deductGold = 0,
}

local meta = { __index = MahjongPlayerData }

function MahjongPlayerData.New()
    local o = {}
    setmetatable(o, meta)
    o.address = ""
    return o
end

--
--用于小局开始的重置
function MahjongPlayerData:Reset()
    self.ready = nil
    self.huType = nil
    self.huIndex = nil
    self.huFan = 0
    self.state = 0
    self.tState = 0
    self.trust = 0
    self.address = ""
    --===============================
    self:ClearChangeCards()
end

--清除换牌数据，用于回放
function MahjongPlayerData:ClearChangeCards()
    self.changeCardsOut = nil
    self.changeCardsBack = nil
end

--设置Gps数据
function MahjongPlayerData:SetGps(gps)
    if self.gps == nil then
        self.gps = {}
    end
    if gps == nil then
        return
    end
    self.address = gps.address
    self.gps.lng = gps.lng
    self.gps.lat = gps.lat
end
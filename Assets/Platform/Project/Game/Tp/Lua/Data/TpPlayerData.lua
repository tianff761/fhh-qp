--玩家数据
TpPlayerData = {
    --玩家id
    id = nil,
    --玩家远端座位号
    seatIndex = 0,
    --玩家名称
    name = "",
    --玩家头像
    headUrl = "0",
    --玩家头像框ID
    headFrame = 0,
    --玩家性别
    gender = Global.GenderType.Female,
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
    ready = false,
    --玩家加入标识，0未加入，1加入
    join = false,
    --是否坐下
    isSitDown = false,
    --在线标识，0不在线，1在线
    online = false,
    --玩家状态
    status = 0,
    --是否留桌
    isStay = false,
    --留桌时间
    stayTime = 0,
    --是否申请过回桌
    isApplyBackTable = false,
    --===============================
    --操作类型
    operateType = TpOperateType.None,
    --下的芒
    betMang = 0,
    --下注
    betScore = 0,
    --是否看牌
    isKanPai = false,
    --是否亮牌
    isLiangPai = false,
    --是否弃牌
    isDiscard = false,
    --手牌
    handCards = nil,
    --之后扯得牌，分牌过后才有的数据
    pullCards = nil,
    --是否可以加注
    isCanAddBit = false,
    --===============================
    --扣除的分数，属于临时变量
    deductGold = 0,
}

local meta = { __index = TpPlayerData }

function TpPlayerData.New()
    local o = {}
    setmetatable(o, meta)
    o.address = ""
    return o
end

--
--用于小局开始的重置
function TpPlayerData:Reset()
    self.ready = false
    self.operateType = TpOperateType.None
    self.betMang = 0
    self.betScore = 0
    self.isKanPai = false
    self.isLiangPai = false
    self.isDiscard = false
    LogError("有设置为空")
    self.handCards = nil
    self.pullCards = nil
    self.isCanAddBit = false
end

--设置Gps数据
function TpPlayerData:SetGps(gps)
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
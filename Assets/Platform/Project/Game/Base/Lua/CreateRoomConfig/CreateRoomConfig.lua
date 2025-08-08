CreateRoomConfig = {}
local this = CreateRoomConfig

--普通颜色
CreateRoomConfig.COLOR_NORMAL = Color(153 / 255, 96 / 255, 71 / 255, 1)
--选中颜色
CreateRoomConfig.COLOR_SELECTED = Color(230 / 255, 82 / 255, 17 / 255, 1)
--禁用颜色
CreateRoomConfig.COLOR_FORBIDDEN = Color(140 / 255, 85 / 255, 48 / 255, 1)

function CreateRoomConfig.Init()

end

--创建房间玩法配置
CreateRoomConfig.PlayWayConfigs = {
    [GameType.Mahjong] = {
        { index = 1, name = "幺鸡四人" },
        { index = 2, name = "幺鸡三人" },
        { index = 3, name = "幺鸡二人" },
        { index = 4, name = "血战到底" },
        { index = 5, name = "三人两房" },
        { index = 6, name = "四人两房" },
        { index = 7, name = "三人三房" },
        { index = 8, name = "两人麻将" },
        { index = 9, name = "两人一房" },
    },
    [GameType.ErQiShi] = {
        { index = 1, name = "乐山贰柒拾" },
        { index = 2, name = "犍为贰柒拾" },
        { index = 3, name = "眉山贰柒拾" },
        { index = 4, name = "十四张两人" },
        { index = 5, name = "十四张三人" },
        { index = 6, name = "十四张四人" },
        { index = 7, name = "两人贰柒拾" },
    },
    [GameType.PaoDeKuai] = {
        { index = 1, name = "乐山三人" },
        { index = 2, name = "乐山四人" },
        { index = 3, name = "两人无四炸" },
        { index = 4, name = "三人无四炸" },
        { index = 5, name = "四人跑得快" },
        { index = 6, name = "15张跑得快" },
        { index = 7, name = "16张跑得快" },
    },
    [GameType.Pin5] = {
        { index = 1, name = "明牌抢庄" },
    },
    [GameType.Pin3] = {
        { index = 1, name = "经典模式" },
    },
    [GameType.LYC] = {
        { index = 1, name = "捞腌菜" },
    },
    [GameType.TP] = {
        { index = 1, name = "德州" },
    }
}

--创建房间的节点配置
CreateRoomConfig.NodeConfigs = {
    [GameType.Mahjong] = { name = "Mahjong", prefab = "CreateRoomNodeMahjong", panel = "CreateMahjongRoomPanel" },
    [GameType.ErQiShi] = { name = "ErQiShi", prefab = "CreateRoomNodeEqs", panel = "CreateEqsRoomPanel" },
    [GameType.PaoDeKuai] = { name = "PaoDeKuai", prefab = "CreateRoomNodeLSPdk", panel = "CreateLSPdkRoomPanel" },
    [GameType.Pin5] = { name = "Pin5", prefab = "CreateRoomNodePin5", panel = "CreatePin5RoomPanel" },
    [GameType.Pin3] = { name = "Pin3", prefab = "CreateRoomNodePin3", panel = "CreatePin3RoomPanel" },
    [GameType.SDB] = { name = "SDB", prefab = "CreateRoomNodeSDB", panel = "CreateSDBRoomPanel" },
    [GameType.LYC] = { name = "LYC", prefab = "CreateRoomNodeLYC", panel = "CreateLYCRoomPanel" },
    [GameType.TP] = { name = "Tp", prefab = "CreateRoomNodeCommon", panel = "CreateRoomCommonPanel" },
}


--通过玩法获取高级配置
function CreateRoomConfig.GetAdvancedData(gameType, playWayType)
    local result = nil
    if gameType ~= nil then
        local key = string.format("RoomAdvancedConfig-%s-%s", gameType, playWayType)
        local str = GetLocal(key, nil)
        if str ~= nil then
            TryCatchCall(function()
                result = JsonToObj(str)
            end)
        end
    end
    return result
end

--保存高级配置
function CreateRoomConfig.SaveAdvancedData(gameType, playWayType, data)
    if gameType ~= nil then
        local key = string.format("RoomAdvancedConfig-%s-%s", gameType, playWayType)
        local str = ObjToJson(data)
        SetLocal(key, str)
    end
end

--底分配置
CreateRoomConfig.DiFenConfig = {
    [GameType.TP] = {
        [TpPlayWayType.PlayWay1] = { 1 },
    },
}

--底分名称文本配置
CreateRoomConfig.DiFenNameConfig = {
    [GameType.TP] = {
        [TpPlayWayType.PlayWay1] = { "1分" },
    },
}

--玩法配置
CreateRoomConfig.PlayWayConfig = {
    [GameType.TP] = TpConfig.PlayWayConfig
}

--通用规则类型配置
CreateRoomConfig.RuleTypeConfig = {
    [GameType.TP] = {
        RoomType = TpRuleType.RoomType,
        PlayWayType = TpRuleType.PlayWayType,
        PlayerTotal = TpRuleType.PlayerTotal,
        GameTotal = TpRuleType.GameTotal,
        Gps = TpRuleType.Gps,
        Pay = TpRuleType.Pay,
        DiFen = TpRuleType.DiFen,
        ZhunRu = TpRuleType.ZhunRu,
        JieSanFenShu = TpRuleType.JieSanFenShu,
    }
}

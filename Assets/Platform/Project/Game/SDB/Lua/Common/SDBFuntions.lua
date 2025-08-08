SDBFuntions = {}
-- 获取玩法字符串
function SDBFuntions.PlayWay(arg)
    local config = arg
	LogError("config")
    local tab = {}
    local isGoldGame = SDBRoomData.IsGoldGame()

    --局数
    if config.jushu ~= nil and config.jushu ~= "" then
        LogError("config.jushu", config.jushu)
        SDBRoomData.gameTotal = config.jushu--tonumber(SDBGameCount_CONFIG[config.jushu].name)
    end

    --推注
    if not isGoldGame and config.tuizhu ~= nil and config.tuizhu ~= "" then
        SDBRoomData.tuiZhu = SDBGameTuizhu_CONFIG[config.tuizhu].name
    end

    --抢庄(倍率)
    if config.qiangzhuang ~= nil and config.qiangzhuang ~= "" then
        SDBRoomData.multiple = SDBGameMultiple_CONFIG[config.qiangzhuang].name
        SDBRoomData.multipleValue = SDBGameMultiple_CONFIG[config.qiangzhuang].value
    end

    --开始类型
    if config.kaishi ~= nil and config.kaishi ~= "" then
        SDBRoomData.showStartType = SDBGameStart_CONFIG[SDBRoomData.gameType][config.kaishi].name
        SDBRoomData.startType = config.kaishi
    end

    --人数
    if config.renshu ~= nil and config.renshu ~= "" then
        SDBRoomData.manCount = config.renshu
    end

    --模式
    if config.moshi ~= nil and config.moshi ~= "" then
        SDBRoomData.model = SDBGameModel_CONFIG[config.moshi].name
    end

    --支付
    if config.zhifu ~= nil and config.zhifu ~= "" then
        SDBRoomData.payType = SDBGamePayType[config.zhifu].name
    end

    --底分
    if config.df ~= nil and config.df ~= "" then
        SDBRoomData.diFen = config.df
        SDBRoomData.Bet = SDBGameDiFen_CONFIG[config.Bet].name
    end

    --高级
    if config.gaoji ~= nil and config.gaoji ~= "" then
        local gaoji = config.gaoji
        local str = " "
        if gaoji.ZhuangWin == 1 then
            str = str .. SDBGameHighLevel_CONFIG[4].name .. "  "
        end

        if not isGoldGame and gaoji.canJoin == 1 then
            str = str .. SDBGameHighLevel_CONFIG[1].name .. "  "
        end

        if gaoji.XiaZhu == 1 then
            str = str .. SDBGameHighLevel_CONFIG[5].name .. "  "
        end

        if gaoji.ZhuangFanBei == 1 then
            str = str .. SDBGameHighLevel_CONFIG[3].name .. "  "
            SDBRoomData.isBankerDoubleWin = true
        else
            SDBRoomData.isBankerDoubleWin = false
        end
        SDBRoomData.gaoJiConfig = str
    end
end

--通过服务器座位号计算本地座位号
function SDBFuntions.CalcLocalSeatByServerSeat(relative, seatNumber)
    -- (最大人数 - 自己服务器座位号 + 玩家服务器座位号) % 最大人数 + 1
    return (SDBRoomData.manCount - relative + seatNumber) % SDBRoomData.manCount + 1
end

--是否为空或者零
function SDBFuntions.IsNilOrZero(num)
    return IsNil(num) or num == 0
end

function SDBFuntions.GetActive(item)
    return item.gameObject.activeSelf
end

--是否需要抢庄
function SDBFuntions.isRobBanker()
    return SDBRoomData.gameType ~= SDBGameType.TAKE_TURNS_BANKER and SDBRoomData.gameType ~= SDBGameType.OWNERS_BANKER
end

return SDBFuntions 
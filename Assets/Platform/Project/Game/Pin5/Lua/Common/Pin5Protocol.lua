--加入房间信息
Pin5Action.Pin5_STC_JoinRoom_Info = {
    state = 1, --状态(number)
    roomId = 0, --房间id(number)
    zhuangId = 0, --庄家id(number)
    maxJuShu = 0, --最大局数(number)
    juShu = 0, --当前局数(number)
    isFrist = true, --是否首局(bool)
    adminId = 0, --房主id(number)
    isJs = true, --房间是否处于解散状态(bool)
    playerList = { --玩家列表(table)
        userId = 0, --玩家id(number)
        userName = "", --玩家名称(string)
        sex = 0, --玩家性别(number) 1:男 2:女
        iCon = 0, --玩家头像id(number) 
        gift = 0, --礼券数量(number)
        gold = 0, --元宝数量(number)
        frameId = 0, --头像框id(number)
        state = 0, --玩家状态(number)
        seatNum = 0, --座位id(number)
        online = true, --是否在线(bool)
        score = 0, --分数(number)
        midCard = {}, --手牌(table){1001,1002,1003,1004,-1} -1为没有翻开的牌
    },
    rule = {}
}

--通知游戏是否可以开始
Pin5Action.Pin5_STC_Start_State = {}

--通知房间变化
Pin5Action.Pin5_STC_RoomState = {
    state = 0, --房间状态(number)
    countDown = 0, --当前状态倒计时(number)
    playerList = { --玩家列表(table)
        userId = 0, --玩家id(number)
        state = 0, --玩家状态(number)
    }
}

--更新玩家信息
Pin5Action.Pin5_STC_Update_Player_Info = {
    userId = 0, --玩家id(number)
    userName = "", --玩家姓名(string)
    sex = 0, --玩家性别(number)
    iCon = 0, --玩家头像(number)
    gift = 0, --礼券数量(number)
    gold = 0, --元宝数量(number)
    frameId = 0, --头像框id(number)
    state = 0, --状态(number)
    seatNum = 0, --座位号(number)
    online = true, --是否在线(bool)
    score = 0, --分数(number)
    midCard = {}, --手牌(table){101,201,301,504,1001}
    updatePlayer = 0, --加入或者退出的玩家(number)
    type = 0, --加入或者退出(number) 1--加入 2--退出
}

--发牌
Pin5Action.Pin5_STC_Send_Cards = {
    playerList = { --玩家牌数据数组(table)
        playerId = 0, --玩家id(number)
        midCard = {}, --玩家手牌(table)
        nowCard = {}, --当前发的牌(table)
    }
}

--操作
Pin5Action.Pin5_CTS_Operate = {
    operType = 0, --操作类型(number) 1--抢庄 2--下注 3--翻牌 4--获取提示
    betNum = 0, --下注分(number) 下注时不能为0
    robNum = 0, --抢庄倍数(number) 	0不抢
}

--操作回复
Pin5Action.Pin5_STC_Operate = {}

--广播玩家操作
Pin5Action.Pin5_STC_B_Operate = {
    operType = 0, --操作类型(number) 1--抢庄 2--下注
    betNum = 0, --下注分(number) 下注时不能为0 不操作默认为最低下注分数
    robNum = 0, --抢庄倍数(number) 抢庄倍数 0:不抢
    playerId = 0, --操作玩家(number)
}

--广播某个玩家亮牌
Pin5Action.Pin5_STC_B_FlipCard = {
    playerId = 0, --玩家id(number)
    midCard = {}, --手牌(table){101,201,301,504,1001}
    spellCard = {}, --组成炮的两张牌(table){101,102}
    point = 0, --炮的类型(number)
    lastCard = 0, --最后一张牌(number)
}

--请求提示
Pin5Action.Pin5_CTS_GetTipCard = {

}

--请求提示回复
Pin5Action.Pin5_STC_GetTipCard = {
    midCard = {}, --手牌(table)
    spellCard = {}, --组成炮的两张牌(table)
    point = 0, --炮的类型(number)
}

--广播小结算
Pin5Action.Pin5_STC_B_XiaoJie = {
    playerList = {--玩家结算数据数组(table)
        midCard = {}, --手牌(table)
        spellCard = {}, --组成炮的两张牌(table)
        point = 0, --炮的类型(number)
        playerId = 0, --玩家id(number)
        score = 0, --玩家总分(number)
        currScore = 0, --玩家当局分数(number)
    }
}


CreateRule = {
    renshu = 6, --人数(6人,8人...)
    difen = 1, --底分(1=1/2/4  2=3/6/12  3=5/10/20  4=10/20/40)

}
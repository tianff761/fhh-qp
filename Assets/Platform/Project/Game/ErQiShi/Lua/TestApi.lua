TestApi = {}
local this = TestApi

function Init()
    AddMsg(CMD.Tcp.C2S_GetRoomData,TestApi.TestDealGetRoomData)
    AddMsg(CMD.Tcp.C2S_Operation772,TestApi.TestDealOperation)
end

function TestApi.TestDealGetRoomData(data)
    Log("服务器接收数据：", data)
    SendMsg(CMD.Tcp.S2C_GetRoomData, TestApi.GetRoomData())

    --发牌
    Scheduler.scheduleOnceGlobal(function()
        SendMsg(CMD.Tcp.S2C_UserCards, this.GetFaPaiData())
    end,2)
end


function TestApi.TestDealOperation(data)
    local root = {}
    root.code = 0
    root.data = data
    Scheduler.scheduleOnceGlobal(function() 
        --回复执行成功
        SendMsg(CMD.Tcp.S2C_Operation772, root)

        --回复三家执行结果
        local root = {}
        root.code = 0
        root.data = {}
        root.data.operUid = 100004
        root.data.oper = data
        root.data.users = {
            {
                uid = 100004,
                rightCard = 1021,
                handCards = {111,112,311,222,213,   420,621,721,722,713,   821,911,1021,1022,521,   522,523,1011,1012,1013,   1023},
                handCount = 18,
                leftCards = {
                    {
                        oper        = EqsOperation.Chi, --操作类型
                        targetId    = 521,              --目标牌
                        from        = 2,                --目标牌来源
                        id1         = 511,              --和目标牌一起组合的操作牌
                        id2         = 522,              --和目标牌一起组合的操作牌
                        id3         = 0                 --和目标牌一起组合的操作牌
                    },
                    {
                        oper        = EqsOperation.Kai, --操作类型
                        targetId    = 621,              --目标牌
                        from        = 2,                --目标牌来源
                        id1         = 622,              --和目标牌一起组合的操作牌
                        id2         = 623,              --和目标牌一起组合的操作牌
                        id3         = 624                 --和目标牌一起组合的操作牌
                    },
                    {
                        oper        = EqsOperation.Dui, --操作类型
                        targetId    = 721,              --目标牌
                        from        = 2,                --目标牌来源
                        id1         = 722,              --和目标牌一起组合的操作牌
                        id2         = 723,              --和目标牌一起组合的操作牌
                        id3         = 0                 --和目标牌一起组合的操作牌
                    },
                },
            },
        }

        SendMsg(CMD.Tcp.S2C_UserOperation773, root)
    end,1)
end

function TestApi.GetRoomData()
     --test 模拟服务器发给客户端数据
     local data = {}
     data.roomId = 100001
     data.clubId = 0
     data.teaId = 0
     data.circle = 2  --当前圈数
     data.juShu = 5   --当前局数
     local rules = {}
     rules[EqsRuleType.RType] = PlayType.LeShan
     rules[EqsRuleType.ShangTai] = 1
     rules[EqsRuleType.QuanShu] = 3
     rules[EqsRuleType.TianDiHu] = 1
     rules[EqsRuleType.RoomNum]  = 3
     data.rules = rules
     data.users = {}
     --userId,userName,icon,sex,seatId,score,isOwner,ip,status,online
     data.users[1] = {
         userId = 100004,
         userName = "猪小乖1",
         icon = "ttttt",
         sex = 1,
         seatId = 1,
         score = 100,
         isOwner = true,
         ip = "192.168.0.1",
         status = EqsUserStatus.Prepared,
         online = true
     }
     
     data.users[2] = {
        userId = 100005,
        userName = "猪小乖2",
        icon = "ttttt",
        sex = 1,
        seatId = 2,
        score = 1001,
        isOwner = false,
        ip = "192.168.0.1",
        status = EqsUserStatus.Prepared,
        online = true
    }

    data.users[3] = {
        userId = 100006,
        userName = "猪小乖3",
        icon = "ttttt",
        sex = 1,
        seatId = 3,
        score = 102,
        isOwner = false,
        ip = "192.168.0.1",
        status = EqsUserStatus.Prepared,
        online = false
    }
     local root = {}
     root.data = data
     root.code = 0
     return root
end

function TestApi.GetFaPaiData()
    local data = {}
    data.leftCount = 21
    data.userCard = {}
    data.userCard[1] = {
        uid = 100004,
        status = EqsUserStatus.Operating,
        --操作项组
        opers ={
            {
                oper        = EqsOperation.Chi, --操作类型
                targetId    = 521,              --目标牌
                from        = 2,                --目标牌来源
                id1         = 511,              --和目标牌一起组合的操作牌
                id2         = 522,              --和目标牌一起组合的操作牌
                id3         = 0                 --和目标牌一起组合的操作牌
            },
            {
                oper        = EqsOperation.Dui, --操作类型
                targetId    = 521,              --目标牌
                from        = 2,                --目标牌来源
                id1         = 523,              --和目标牌一起组合的操作牌
                id2         = 522,              --和目标牌一起组合的操作牌
                id3         = 0                 --和目标牌一起组合的操作牌
            },
        },
        --手牌
        handCards = {111,112,311,222,213,   420,621,721,722,713,   821,911,1021,1022,521,   522,523,1011,1012,1013,   1023},
        --对、吃、开、雨牌   模拟 吃，开，对  
        leftCards = {
            {
                oper        = EqsOperation.Chi, --操作类型
                targetId    = 521,              --目标牌
                from        = 2,                --目标牌来源
                id1         = 511,              --和目标牌一起组合的操作牌
                id2         = 522,              --和目标牌一起组合的操作牌
                id3         = 0                 --和目标牌一起组合的操作牌
            },
            {
                oper        = EqsOperation.Kai, --操作类型
                targetId    = 621,              --目标牌
                from        = 2,                --目标牌来源
                id1         = 622,              --和目标牌一起组合的操作牌
                id2         = 623,              --和目标牌一起组合的操作牌
                id3         = 624                 --和目标牌一起组合的操作牌
            },
            -- {
            --     oper        = EqsOperation.Dui, --操作类型
            --     targetId    = 721,              --目标牌
            --     from        = 2,                --目标牌来源
            --     id1         = 722,              --和目标牌一起组合的操作牌
            --     id2         = 723,              --和目标牌一起组合的操作牌
            --     id3         = 0                 --和目标牌一起组合的操作牌
            -- },
        },
        chuPai = {721,722,711,822}            --出过得牌
    }

    data.userCard[2] = {
        uid = 100005,
        status = EqsUserStatus.Operating,
        --操作项组
        opers ={
            {
                oper        = EqsOperation.Chi, --操作类型
                targetId    = 521,              --目标牌
                from        = 2,                --目标牌来源
                id1         = 511,              --和目标牌一起组合的操作牌
                id2         = 522,              --和目标牌一起组合的操作牌
                id3         = 0                 --和目标牌一起组合的操作牌
            },
            {
                oper        = EqsOperation.Chi, --操作类型
                targetId    = 521,              --目标牌
                from        = 2,                --目标牌来源
                id1         = 511,              --和目标牌一起组合的操作牌
                id2         = 522,              --和目标牌一起组合的操作牌
                id3         = 0                 --和目标牌一起组合的操作牌
            },
            
        },
        --手牌
        handCards = {},
        handCount = 5,
        --对、吃、开、雨牌   模拟 吃，开，对  
        leftCards = {
            {
                oper        = EqsOperation.Chi, --操作类型
                targetId    = 521,              --目标牌
                from        = 2,                --目标牌来源
                id1         = 511,              --和目标牌一起组合的操作牌
                id2         = 522,              --和目标牌一起组合的操作牌
                id3         = 0                 --和目标牌一起组合的操作牌
            },
            {
                oper        = EqsOperation.Kai, --操作类型
                targetId    = 621,              --目标牌
                from        = 2,                --目标牌来源
                id1         = 622,              --和目标牌一起组合的操作牌
                id2         = 623,              --和目标牌一起组合的操作牌
                id3         = 624                 --和目标牌一起组合的操作牌
            },
            {
                oper        = EqsOperation.Dui, --操作类型
                targetId    = 721,              --目标牌
                from        = 2,                --目标牌来源
                id1         = 722,              --和目标牌一起组合的操作牌
                id2         = 723,              --和目标牌一起组合的操作牌
                id3         = 0                 --和目标牌一起组合的操作牌
            },
        },
        chuPai = {721,722,711,822}            --出过得牌
    }

    data.userCard[3] = {
        uid = 100006,
        status = EqsUserStatus.Operating,
        --操作项组
        opers ={
            {
                oper        = EqsOperation.BaYu, --操作类型
                targetId    = 521,              --目标牌
                from        = 2,                --目标牌来源
                id1         = 523,              --和目标牌一起组合的操作牌
                id2         = 522,              --和目标牌一起组合的操作牌
                id3         = 524,                 --和目标牌一起组合的操作牌
            },
            {
                oper        = EqsOperation.BaYu, --操作类型
                targetId    = 521,              --目标牌
                from        = 2,                --目标牌来源
                id1         = 523,              --和目标牌一起组合的操作牌
                id2         = 522,              --和目标牌一起组合的操作牌
                id3         = 524,                 --和目标牌一起组合的操作牌
            },
        },
        --手牌
        handCards = {111,112,311,222,213,   420,621,721,722,713,   821,911,1021,1022,521,   522,523,1011,1012,1013,   1021},
        --对、吃、开、雨牌   模拟 吃，开，对  
        leftCards = {
            {
                oper        = EqsOperation.Chi, --操作类型
                targetId    = 521,              --目标牌
                from        = 2,                --目标牌来源
                id1         = 511,              --和目标牌一起组合的操作牌
                id2         = 522,              --和目标牌一起组合的操作牌
                id3         = 0                 --和目标牌一起组合的操作牌
            },
            {
                oper        = EqsOperation.BaYu, --操作类型
                targetId    = 621,              --目标牌
                from        = 2,                --目标牌来源
                id1         = 622,              --和目标牌一起组合的操作牌
                id2         = 623,              --和目标牌一起组合的操作牌
                id3         = 624                 --和目标牌一起组合的操作牌
            },
            {
                oper        = EqsOperation.Dui, --操作类型
                targetId    = 721,              --目标牌
                from        = 2,                --目标牌来源
                id1         = 722,              --和目标牌一起组合的操作牌
                id2         = 723,              --和目标牌一起组合的操作牌
                id3         = 0                 --和目标牌一起组合的操作牌
            },
        },
        chuPai = {721,722,711,822}            --出过得牌
    }

    local root = {}
    root.code = 0
    root.data = data
    return root
end
--Init()
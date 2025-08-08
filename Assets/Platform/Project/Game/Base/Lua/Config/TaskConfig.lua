
TaskConfig = {
    {taskId = 1001,gameType = GameType.None,taskType =2,contTxt = "邀请5名好友加入俱乐部并在茶馆里完成任意1局游戏"},
    {taskId = 1002,gameType = GameType.None,taskType =1,contTxt = "分享一次游戏到微信朋友圈"},
    {taskId = 1003,gameType = GameType.None,taskType =1,contTxt = "完成超过5个每日任务"},
    {taskId = 1004,gameType = GameType.None,taskType =1,contTxt = "每日登录"},
}

TaskType = {
    Active = 0,  --活跃度
    EveryDay = 1,
    LimitTime = 2,
    Activity = 3,
}

DrawGiftList = {
    {{["2"] = 10},{["3"] = 10}},
    {{["2"] = 30},{["3"] = 20}},
    {{["2"] = 50},{["3"] = 30}},
    {{["2"] = 100},{["3"] = 50}},
    {{["2"] = 200},{["3"] = 100}},
}


--协议号6301 在原来协议号基础上改动
local C2S_TaskList  = {
    taskType =  1, --1日常 2限时 3活动
}
--6302服务器返回
local S2C_TaskList = {
    code = 0,
    data = {
        --任务列表
        list = {
            {
                tId = 1001,  --任务ID
                tPs = 100,  --当前任务的总进度
                cPs = 0,   --当前任务完成的进度
                acs = 10,  --单个活跃度的值
                reward = "1,20", --第一个为类型（1钻石2元宝3礼券） 第二个为奖励数量  
                status = 0  -- 0未完成 1 已完成未领取 2 已领取
            },
        },

    }
}

--协议号6309 选择任务
local C2S_SlectTasks  = {
    taskType =  1, --1随机任务 2捕鱼类 3麻将类 4长牌类 5扑克类 
}
--6310
local S2C_SlectTasks = {
    code = 0,
    data = {
        status = 0  --成功
    }
}
--协议号6311 活跃度列表
local C2S_ActiveList  = {}
--6312
local S2C_ActiveList  = {
    code = 0,
    data = {
        curAct = 0,  --当前活跃度
        totAct = 100 , --总活跃度
        --活跃值列表
        acList ={
            {
                actValue = 20,  --单个活跃值
                isGet = 0  -- 0未完成 1已完成未领取  2已完成已领取
            },
        }
    }
}


--7051 发送CDK 
local C2S_CDKCode  ={
    cdkCode = "XSWWSE"
}
--7052 CDK兑换结果
local  S2C_CDKCode = {
    code = 0,
    data = {
        status = 0  --成功  可以不传（客户端不用）
    }
}


--
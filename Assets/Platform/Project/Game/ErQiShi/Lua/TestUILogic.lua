function Init()
      -- 测试牌
    --Scheduler.scheduleOnceGlobal(testFp,3)
    --Scheduler.scheduleOnceGlobal(testChangePai,6)
    --Scheduler.scheduleOnceGlobal(TestBai,3)
    --Scheduler.scheduleOnceGlobal(TestChi,3)
   
   
    --test771
    -- Scheduler.scheduleOnceGlobal(function ()
    --     UserData.SetIsReconnectTag(true)
    --     local json = '{"code":0,"err":"成功","data":{"userCard":[{"uid":100120,"opers":[],"chuPai":[],"handCards":20,"leftCards":[],"status":4},{"uid":100040,"opers":[],"chuPai":[],"selectCard":[313,323,224],"handCards":[122,211,214,521,924,913,512,422,212,412,914,323,912,523,614,923,123,313,423,224,513],"leftCards":[],"status":5},{"uid":100121,"opers":[],"chuPai":[],"handCards":20,"leftCards":[],"status":4}],"leftCount":19},"cmd":70771}'
    --     this.FaPai(JsonToObj(json).data)
    -- end,3)

    -- Scheduler.scheduleOnceGlobal(function()
    --     local data = JsonToObj('{"code":0,"cmd":70810,"data":{"users":[{"yuType":{},"huType":0,"yuScore":-3,"uid":100011,"huRules":{},"huShu":0,"huScore":0,"totalScore":-3},{"yuType":[400],"huType":3,"yuScore":6,"uid":100012,"huRules":{},"huShu":0,"huScore":-24,"totalScore":-18},{"yuType":{},"huType":1,"yuScore":-3,"uid":100013,"huRules":[1003,1002],"huShu":13,"huScore":24,"totalScore":21}]},"err":"成功"}')
    --     PanelManager.Open(EqsPanels.DanJuJieSuan, data.data)
    -- end,5)

   -- Scheduler.scheduleOnceGlobal(TestEffect,3)
   

    --测试音效
   -- Scheduler.scheduleOnceGlobal(TestAudio,3)


    --测试广播
    -- Scheduler.scheduleGlobal(function()
    --      SendTcpMsg(CMD.Tcp.C2S_Broadcast, {id = 454534543})
    -- end,5)

    -- Scheduler.scheduleOnceGlobal(function()
    --   TestJieShanRoom()
    -- end,3)

    --单局结算测试
    -- Scheduler.scheduleOnceGlobal(function()
    --     TestDanJuJieSuan()
    -- end,5)

    --总结算测试
    -- Scheduler.scheduleOnceGlobal(function()
    --     TestZongJieSuan()
    -- end,5)

    --测试
    --  Scheduler.scheduleOnceGlobal(function()
    --     TestBaYu()
    --  end,5)

    -- Scheduler.scheduleOnceGlobal(function()
    --     TestBuDa()
    --  end,5)

    -- local str = {423,311,1022,1014,111,513,522,514,512,722,123,712,413,322,1013,524,222,212,1011,1012,414}
    -- Scheduler.scheduleOnceGlobal(function() 
    --     Log("test：", DanJuJieSuanPanel.CalcuLines(str))
    -- end,5)

    -- Scheduler.scheduleOnceGlobal(function()
    --     PanelManager.Open(EqsPanels.EqsSuiJiQuan,1, EqsBattlePanel.GetSuiJiQuanCard())
    -- end,3)
end

function TestBuDa()
    local str = '{"code":0,"err":"成功","data":{"users":[{"uid":100002,"huShu":0,"huRules":[],"yuType":[],"huType":0,"huScore":-1,"handCards":[722,213,422,923,711,522,723,1013,1011,622],"totalScore":-8,"yuScore":-1},{"uid":100021,"huShu":0,"huRules":[],"yuType":[300],"huType":0,"huScore":-1,"handCards":[1021,613,1023,714,623,713,921,1022,1024,1012,223,624,712,814],"totalScore":6,"yuScore":3},{"uid":100001,"huShu":12,"huRules":[],"yuType":[200,100],"huType":10,"huScore":2,"handCards":[721,922,724,224,524,621,824],"rightCard":1013,"totalScore":2,"yuScore":-2}]},"cmd":70810}'
    BattleModule.OnCmdOperation(JsonToObj(str))
end

function TestBaYu()
    local str = '{"code":0,"err":"成功","data":{"operUid":100090,"oper":{"targetId":514,"oper":50,"from":-1},"userCard":[{"uid":100089,"opers":[],"chuPai":[123,323,312,711],"handCards":5,"leftCards":[{"targetId":522,"id2":521,"id1":523,"from":3,"id3":524,"oper":44},{"targetId":811,"id2":812,"id1":813,"from":3,"oper":45},{"targetId":222,"id2":224,"id1":212,"from":3,"oper":46},{"targetId":1011,"id2":1014,"id1":1013,"from":3,"oper":45},{"targetId":1024,"id2":1021,"id1":1023,"from":3,"oper":45}],"status":6},{"uid":100090,"opers":[],"chuPai":[724,314],"handCards":11,"leftCards":[{"targetId":712,"id2":713,"id1":714,"from":1,"oper":45},{"targetId":511,"id2":512,"id1":513,"from":2,"oper":45},{"targetId":913,"id2":912,"id1":914,"from":1,"oper":45}],"status":6},{"uid":100088,"opers":[],"chuPai":[313,113,324],"selectCard":[],"handCards":[124,524,211,421,911,321,624,223,422,721,111,1012,821],"leftCards":[{"targetId":414,"id2":413,"id1":411,"id3":412,"from":1,"oper":43},{"targetId":611,"id2":612,"id1":613,"id3":614,"from":2,"oper":43}],"status":6}],"leftCount":9},"cmd":70773}'
    BattleModule.OnCmdOperation(JsonToObj(str))
end

function TestDanJuJieSuan()
    local str = '{"code":0,"err":"成功","data":{"users":[{"uid":100002,"huShu":0,"huRules":[],"yuType":[],"huType":0,"huScore":-1,"handCards":[722,213,422,923,711,522,723,1013,1011,622],"totalScore":-8,"yuScore":-1},{"uid":100021,"huShu":0,"huRules":[],"yuType":[300],"huType":0,"huScore":-1,"handCards":[1021,613,1023,714,623,713,921,1022,1024,1012,223,624,712,814],"totalScore":6,"yuScore":3},{"uid":100001,"huShu":12,"huRules":[],"yuType":[200,100],"huType":10,"huScore":2,"handCards":[721,922,724,224,524,621,824],"rightCard":1013,"totalScore":2,"yuScore":-2}]},"cmd":70810}'
    BattleModule.OnTcpDanJuJieSuan(JsonToObj(str))
end

function TestZongJieSuan()
    local djjs = '{"code":0,"err":"成功","data":{"users":[{"uid":100107,"huShu":0,"huRules":[],"yuType":[],"huType":0,"huScore":0,"handCards":[713,312,112,114,711,1021,421,911,121,123,912,211,322,1011,624,1024,712,824,823,513],"totalScore":-12,"yuScore":0},{"uid":100064,"huShu":0,"huRules":[],"yuType":[],"huType":0,"huScore":0,"handCards":[423,523,922,511,1014,314,813,213,323,413,612,621,921,923,311,223,721,113,723,812,224],"totalScore":9,"yuScore":0},{"uid":100106,"huShu":0,"huRules":[],"yuType":[],"huType":0,"huScore":0,"handCards":[821,522,412,811,313,623,924,1023,611,221,324,122,622,613,524,521,512,222,414,614],"totalScore":3,"yuScore":0}]},"cmd":70810}'
    local zjs = '{"code":0,"err":"成功","data":{"users":[{"uid":100107,"score":-12,"hp":0,"mh":0,"dp":1,"lz":1},{"uid":100064,"score":9,"hp":1,"mh":16,"dp":0,"lz":1},{"uid":100106,"score":3,"hp":0,"mh":0,"dp":0,"lz":0}]},"cmd":70811}'

    BattleModule.OnTcpDanJuJieSuan(JsonToObj(djjs))
    BattleModule.OnTcpZongJieSuan(JsonToObj(zjs))
end

--投票解散房间
function TestJieShanRoom()
   local str = '{"code":0,"err":"成功","data":{"leftTime":30,"users":[{"uid":100095,"status":-1},{"uid":100096,"status":-1},{"uid":100094,"status":1}],"apyUid":100094},"cmd":70793}'
    BattleModule.OnCmdTouPiaoJieShanRoom(JsonToObj(str))
end

local testCardId = { 423,311,1022,1014,111,513,522,514,512,722,123,712,413,322,1013,524,222,212,1011,1012,414 }
--todo: 牌型测试
function testFp()
    --this.hszCardsQueue = Queue.New()
    --UserData.SetHsz(true)
    local cards = {}
    for k, id in pairs(testCardId) do
        table.insert(cards, EqsCardsManager.GetCardByUid(id))
    end
    SelfHandEqsCardsCtrl.AddCards(cards, true)
end
--测试同步牌
local testCardId1 = { 311, 222, 213, 420, 621, 721, 722, 713, 821, 911, 1021, 1022, 521, 522, 523, 1011, 1012, 1013, 1014 }
function testChangePai()
    SelfHandEqsCardsCtrl.CheckAndSyncCards(testCardId1)
end

--测试吃牌
function TestChi()
    local opers = {}
    table.insert(opers, { targetId = 512, from = 2, id3 = 0, id1 = 612, id2 = 712, oper = EqsOperation.Chi })
    table.insert(opers, { targetId = 512, from = 2, id1 = 412, id2 = 612, id3 = 0, oper = EqsOperation.Chi })
    PanelManager.Open(EqsPanels.ChiPanel, opers)
end

--测试摆牌
function TestBai()
    local opers = {}
    table.insert(opers, { targetId = 512, from = 2, id1 = 512, id2 = 612, id3 = 712, oper = EqsOperation.BaiPai })
    table.insert(opers, { targetId = 512, from = 2, id1 = 412, id2 = 512, id3 = 612, oper = EqsOperation.BaiPai })
    PanelManager.Open(EqsPanels.BaiPanel, opers)
end

--测试特效
function TestEffect()
     Scheduler.scheduleOnceGlobal(function()
        EffectMgr.PlayEffect(EffectType.EqsBai, EqsBattlePanel.GetChuPaiRect())
    end,3)

    Scheduler.scheduleOnceGlobal(function()
        EffectMgr.PlayEffect(EffectType.EqsDui, EqsBattlePanel.GetChuPaiRect())
    end,5)

    Scheduler.scheduleOnceGlobal(function()
        EffectMgr.PlayEffect(EffectType.EqsEat, EqsBattlePanel.GetChuPaiRect())
    end,7)

    Scheduler.scheduleOnceGlobal(function()
        EffectMgr.PlayEffect(EffectType.EqsHu, EqsBattlePanel.GetChuPaiRect())
    end,9)

    Scheduler.scheduleOnceGlobal(function()
        EffectMgr.PlayEffect(EffectType.EqsKai, EqsBattlePanel.GetChuPaiRect())
    end,11)

    Scheduler.scheduleOnceGlobal(function()
        EffectMgr.PlayEffect(EffectType.EqsYu, EqsBattlePanel.GetChuPaiRect())
    end,13)
end

--测试音效
function TestAudio()
     --女出牌
     local count = 0
     for b = 1, 10 do
         for s = 1, 2 do
             for g = 1, 4 do
                 count = count + 1
                 Scheduler.scheduleOnceGlobal(function()
                     EqsSoundManager.PlayChuPaiAudio(b * 100 + s * 10 + g, Global.GenderType.Female)
                 end,count)
             end
         end
     end

     --男出牌
     for b = 1, 10 do
         for s = 1, 2 do
             for g = 1, 4 do
                 count = count + 1
                 Scheduler.scheduleOnceGlobal(function()
                     EqsSoundManager.PlayChuPaiAudio(b * 100 + s * 10 + g, Global.GenderType.Male)
                 end,count)
             end
         end
     end
     --八块不打
     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayBaKuai(8,Global.GenderType.Male)
     end,count)

     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayBaKuai(12,Global.GenderType.Male)
     end,count)

     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayBaKuai(16,Global.GenderType.Male)
     end,count)

     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayBaKuai(20,Global.GenderType.Male)
     end,count)

     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayBaKuai(8,Global.GenderType.Female)
     end,count)

     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayBaKuai(12,Global.GenderType.Female)
     end,count)

     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayBaKuai(16,Global.GenderType.Female)
     end,count)

     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayBaKuai(20,Global.GenderType.Female)
     end,count)

     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayBaKuai(20,Global.GenderType.Female)
     end,count)

     --男操作
     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayOperationAudio(EqsOperation.Hu,Global.GenderType.Male)
     end,count)

     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayOperationAudio(EqsOperation.Kai,Global.GenderType.Male)
     end,count)

     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayOperationAudio(EqsOperation.Dui,Global.GenderType.Male)
     end,count)

     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayOperationAudio(EqsOperation.Chi,Global.GenderType.Male)
     end,count)

     --女操作
     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayOperationAudio(EqsOperation.Hu,Global.GenderType.Female)
     end,count)

     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayOperationAudio(EqsOperation.Kai,Global.GenderType.Female)
     end,count)

     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayOperationAudio(EqsOperation.Dui,Global.GenderType.Female)
     end,count)

     count = count + 1
     Scheduler.scheduleOnceGlobal(function()
         EqsSoundManager.PlayOperationAudio(EqsOperation.Chi,Global.GenderType.Female)
     end,count)
end
Init()




Pin3NetworkManager = {}
local this = Pin3NetworkManager
function Pin3NetworkManager.Init()
    AddMsg(CMD.Tcp.Pin3.S2C_GetRoomData, this.OnTcpRoomInfo)
    AddMsg(CMD.Tcp.Pin3.S2C_UpdateUserInfo, this.OnTcpUpdateUserInfo)
    AddMsg(CMD.Tcp.Pin3.S2C_UpdateTableOperStatus, this.OnTcpUpdateTableOperStatus)
    AddMsg(CMD.Tcp.Pin3.S2C_UserPrepared, this.OnTcpUserPrepare)
    AddMsg(CMD.Tcp.Pin3.S2C_UserPerformOper, this.OnTcpPerformOper)
    AddMsg(CMD.Tcp.Pin3.S2C_DanJuJieSuan, this.OnTcpJieSuan)
    AddMsg(CMD.Tcp.Pin3.S2C_QuitRoom, this.OnTcpQuitRoom)
    AddMsg(CMD.Tcp.Pin3.S2C_AutoYaZhu, this.OnTcpAutoYaZhu)
    AddMsg(CMD.Game.Reauthentication, Pin3Manager.OnReauthentication)
    AddMsg(CMD.Tcp.Pin3.S2C_UpdateGold, this.OnTcpUpdateUserGold)
    AddMsg(CMD.Tcp.Pin3.S2C_FangZhuStartGame, this.OnTcpStartGame)
    AddMsg(CMD.Tcp.Pin3.RESPOND_SIT_DOWN, this.ReceiveSitdownMessage)
    AddMsg(CMD.Tcp.Pin3.S2C_JoinFkGame, this.OnTcpJoinFkGame)
    AddMsg(CMD.Tcp.Pin3.S2C_DissolveFkRoomRequest, this.OnTcpDissolveFkRoomStatus)
    AddMsg(CMD.Tcp.Pin3.S2C_DealDissolveFkRoomRequest, this.OnTcpDissolveFkRoomStatus)
    AddMsg(CMD.Tcp.Pin3.S2C_ZongJieSuan, this.OnTcpZongJieSuan)
    AddMsg(CMD.Tcp.Pin3.PUSH_GAME_START, this.ReceiveStartGameCountdown)
    AddEventListener(CMD.Game.Ping, this.OnPing)
end

function Pin3NetworkManager.Uninit()
    RemoveMsg(CMD.Tcp.Pin3.S2C_GetRoomData, this.OnTcpRoomInfo)
    RemoveMsg(CMD.Tcp.Pin3.S2C_UpdateUserInfo, this.OnTcpUpdateUserInfo)
    RemoveMsg(CMD.Tcp.Pin3.S2C_UpdateTableOperStatus, this.OnTcpUpdateTableOperStatus)
    RemoveMsg(CMD.Tcp.Pin3.S2C_UserPrepared, this.OnTcpUserPrepare)
    RemoveMsg(CMD.Tcp.Pin3.S2C_UserPerformOper, this.OnTcpPerformOper)
    RemoveMsg(CMD.Tcp.Pin3.S2C_DanJuJieSuan, this.OnTcpJieSuan)
    RemoveMsg(CMD.Tcp.Pin3.S2C_QuitRoom, this.OnTcpQuitRoom)
    RemoveMsg(CMD.Tcp.Pin3.S2C_AutoYaZhu, this.OnTcpAutoYaZhu)
    RemoveMsg(CMD.Game.Reauthentication, Pin3Manager.OnReauthentication)
    RemoveMsg(CMD.Tcp.Pin3.S2C_UpdateGold, this.OnTcpUpdateUserGold)
    RemoveMsg(CMD.Tcp.Pin3.S2C_FangZhuStartGame, this.OnTcpStartGame)
    RemoveMsg(CMD.Tcp.Pin3.RESPOND_SIT_DOWN, this.ReceiveSitdownMessage)
    RemoveMsg(CMD.Tcp.Pin3.S2C_JoinFkGame, this.OnTcpJoinFkGame)
    RemoveMsg(CMD.Tcp.Pin3.S2C_DissolveFkRoomRequest, this.OnTcpDissolveFkRoomStatus)
    RemoveMsg(CMD.Tcp.Pin3.S2C_DealDissolveFkRoomRequest, this.OnTcpDissolveFkRoomStatus)
    RemoveMsg(CMD.Tcp.Pin3.S2C_ZongJieSuan, this.OnTcpZongJieSuan)
    RemoveMsg(CMD.Tcp.Pin3.PUSH_GAME_START, this.ReceiveStartGameCountdown)
    RemoveEventListener(CMD.Game.Ping, this.OnPing)
end

--------------------------------加入房间-----------------------------------------
--加入房间   加入房间成功后获取房间数据   101700
function Pin3NetworkManager.SendJoinedRoom()
    local obj = {
        userId = Pin3Data.uid,
        roomId = Pin3Data.roomId,
        img = Pin3Data.headIcon,
        username = Pin3Data.userName,
        sex = Pin3Data.sex,
        frameId = Pin3Data.frameId,
        gold = Pin3Data.goldNum,
        line = Pin3Data.port
    }
    SendTcpMsg(CMD.Tcp.Pin3.C2S_JoinedRoom, obj)
end

--101700
function Pin3NetworkManager.OnTcpRoomInfo(data)
    --Log(".....................", data)
    if data.code == 0 then
        this.HandleOnTcpRoomInfo(data.data)
    else
        Pin3Utils.ShowError(data.code)
    end
end

--处理协议
function Pin3NetworkManager.HandleOnTcpRoomInfo(data)
    Pin3Data.ParseRoomData(data)
    Pin3Manager.InitRoomInfo()
end

------------------------------------------------------------------------------
-------------------------------更新玩家信息101701------------------------------
function Pin3NetworkManager.OnTcpUpdateUserInfo(data)
    --LogError("<color=aqua>OnTcpUpdateUserInfo</color>", data)
    ---sNum表示座位号，大于0为有座位号，否则则无
    if data.code == 0 and data.data.sNum > 0 then
        Pin3Data.ParseUserData(data.data, true)
        Pin3Manager.UpdateUserInfo(data.data.pId)
        --主要用于更新开始游戏按钮显示
        if not Pin3Data.GetStandUp() then
            Pin3Data.SetStandUp(false)
            Pin3BattlePanel.UpdateTableInfo()
        end
    else
        Pin3Utils.ShowError(data.code)
    end
end

------------------------------------------------------------------------------
-------------------------------更新桌面玩家操作状态101702-----------------------
function Pin3NetworkManager.OnTcpUpdateTableOperStatus(data)
    if data.code == 0 then
        this.HandleOnTcpUpdateTableOperStatus(data.data)
    else
        Pin3Utils.ShowError(data.code)
    end
end

--处理数据
function Pin3NetworkManager.HandleOnTcpUpdateTableOperStatus(data)
    Pin3Data.ParseTableOperStatus(data)
    Pin3Manager.UpdateTableOperStatus()
end

------------------------------------------------------------------------------
------------------------------玩家准备101703-----------------------------------
function Pin3NetworkManager.SendPrepare()
    local obj = {
        userId = Pin3Data.uid,
    }
    SendTcpMsg(CMD.Tcp.Pin3.C2S_UserPrepare, obj)
end

--101704
function Pin3NetworkManager.OnTcpUserPrepare(data)
    --100003错误码表示前端已经准备
    if data.code == 0 or data.code == 100003 then
        local uid = data.data.pId
        Pin3Data.SetIsPrepare(uid, true)
        Pin3Manager.UpdateUserInfo(uid)
        --为了显示房卡场房主开始游戏按钮
        Pin3BattlePanel.UpdateTableInfo()
    else
        Pin3Utils.ShowError(data.code)
    end
end
------------------------------------------------------------------------------
------------------------------玩家操作101705-----------------------------------
---operType:Pin3UserOperType定义
---fightId:比牌玩家id
---yzGold:押注金额
function Pin3NetworkManager.SendOper(operType, fightUId, yzGold)
    LockScreen(0.5)
    local obj = {
        opType = operType
    }
    if fightUId ~= nil then
        obj.fightId = fightUId
    end
    if yzGold ~= nil then
        obj.ig = yzGold
    end
    SendTcpMsg(CMD.Tcp.Pin3.C2S_UserPerformOper, obj)
end

--101706
function Pin3NetworkManager.OnTcpPerformOper(data)
    if data.code == 0 then
        this.HandleOnTcpPerformOper(data.data)
    else
        Pin3Utils.ShowError(data.code)
    end
end

--处理信息
function Pin3NetworkManager.HandleOnTcpPerformOper(data)
    Pin3Data.ParseUserOper(data)
    Pin3Manager.PerformOper()
end

------------------------------------------------------------------------------
------------------------------结算101707---------------------------------------
function Pin3NetworkManager.OnTcpJieSuan(data)
    if data.code == 0 then
        Pin3Data.ParseJieSuanInfo(data.data)
        Pin3Manager.OnDanJuJieSuan()
    end
end

--处理回放的结算数据
function Pin3NetworkManager.HandleJieSuanByPlayback(data)
    Pin3Data.ParseJieSuanInfoByPlayback(data)
    Pin3Manager.OnDanJuJieSuan()
end

-------------------------------------------------------------------------------
---------------------------------退出101708------------------------------------
function Pin3NetworkManager.SendQuitRoom()
    SendTcpMsg(CMD.Tcp.Pin3.C2S_QuitRoom, { roomId = Pin3Data.roomId })
end
function Pin3NetworkManager.OnTcpQuitRoom(data)
    if data.code == 0 then
        Pin3Manager.QuitRoom(data.data.type)
    else
        Pin3Utils.ShowError(data.code)
    end
end
-------------------------------------------------------------------------------
---
------------------------------------自动跟注101709------------------------------
---autoYz:1自动跟注   0取消自动跟注
function Pin3NetworkManager.SendAutoYaZhu(autoYz)
    SendTcpMsg(CMD.Tcp.Pin3.C2S_AutoYaZhu, { opType = autoYz })
end
function Pin3NetworkManager.OnTcpAutoYaZhu(data)
    if data.code == 0 then
        Pin3Data.SetIsAutoYaZhu(Pin3Data.uid, data.data.opType == 1)
        Pin3BattlePanel.UpdateTableInfo()
    else
        Pin3Utils.ShowError(data.code)
    end
end
----------------------------------更新玩家金币----------------------------------
--19995
function Pin3NetworkManager.OnTcpUpdateUserGold(data)
    if data.code == 0 then
        local userDatas = data.data.players
        if GetTableSize(userDatas) > 0 then
            for _, item in pairs(userDatas) do
                if IsNumber(item.id) and IsNumber(item.gold) then
                    Pin3Data.SetGoldNum(item.id, item.gold)
                    Pin3Manager.UpdateUserInfo(item.id)
                end
            end
        end
    end
end
----------------------------------开始游戏--------------------------------------
--101720
function Pin3NetworkManager.SendStartGame()
    if Pin3Data.ownerId == Pin3Data.uid then
        SendTcpMsg(CMD.Tcp.Pin3.C2S_FangZhuStartGame, {})
    end
end

function Pin3NetworkManager.OnTcpStartGame(data)
    if data.code ~= 0 then
        Pin3Utils.ShowError(data.code)
    end
end

---坐下
function Pin3NetworkManager.SendSitdownMessage()
    SendTcpMsg(CMD.Tcp.Pin3.REQUEST_SIT_DOWN, {})
end

function Pin3NetworkManager.ReceiveSitdownMessage(data)
    --LogError("<color=aqua>data</color>", data)
    if data.data.code == 0 then
        Pin3Data.SetIsObserver(false)
    else
        Pin3Utils.ShowError(data.data.code)
        Pin3BattlePanel.SetSitdownBtnActive(false)
    end
end

-------------------------------------------------------------------------------
---
---------------------------------加入房卡游戏-----------------------------------
--101722 
function Pin3NetworkManager.SendJoinFkGame()
    SendTcpMsg(CMD.Tcp.Pin3.C2S_JoinFkGame, {})
end

--101723
function Pin3NetworkManager.OnTcpJoinFkGame(data)
    if data.code == 0 then
        Pin3Data.SetIsJoinGame(Pin3Data.uid, 1)
        Pin3BattlePanel.UpdateTableInfo()
        Toast.Show("加入游戏成功，下一局自动参与游戏")
    end
end
----------------------------------解散房卡房间----------------------------------
--101750
function Pin3NetworkManager.SendDissovleFkRoom()
    SendTcpMsg(CMD.Tcp.Pin3.C2S_DissolveFkRoomRequest, {})
end

--101752  opType:1 同意解散   0拒绝解散
function Pin3NetworkManager.SendDealDessovleFkRoomRequset(opType)
    SendTcpMsg(CMD.Tcp.Pin3.C2S_DealDissolveFkRoomRequest, { isAgree = opType })
end

--101751 解散房间状态
function Pin3NetworkManager.OnTcpDissolveFkRoomStatus(data)
    if data.code == 0 then
        if GetTableSize(data.data.msgs) > 0 then
            for _, item in pairs(data.data.msgs) do
                Pin3Data.SetIsAgreeDissolveRoom(item.playerId, item.isAgree == 1)
            end
        end
        Pin3Data.requestDissolveUid = data.data.dId
        Pin3Data.dissolveStatus = data.data.result
        Pin3Data.dissolveLeftTime = data.data.countDown

        if PanelManager.IsOpened(Pin3Panels.Pin3DismissRoom) then
            Pin3DismissPanel.UpdatePanel()
        else
            PanelManager.Open(Pin3Panels.Pin3DismissRoom)
        end
    end
end
---------------------------------------------------------------------------------
-------------------------------------总结算---------------------------------------
---101721
function Pin3NetworkManager.OnTcpZongJieSuan(data)
    if data.code == 0 then
        Scheduler.scheduleOnceGlobal(function()
            PanelManager.Open(Pin3Panels.Pin3ZongJieSuan, data.data)
        end, 3)
    end
end
---------------------------------------------------------------------------------
---开始游戏倒计时更新
function Pin3NetworkManager.ReceiveStartGameCountdown(data)
    --LogError("ReceiveStartGameCountdown", data)
    Pin3BattlePanel.UpdateClock("即将开始", data.data.second)
end

function Pin3NetworkManager.OnPing()
    if lastPing == arg then
        return
    end
    lastPing = arg
    if arg ~= "" and not IsNil(Pin3BattlePanel) then
        Pin3BattlePanel.SetPing(arg)
    end
end
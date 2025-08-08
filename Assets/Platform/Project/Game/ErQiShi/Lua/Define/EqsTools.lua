EqsTools = {}
--前端牌唯一ID
function EqsTools.GetEqsCardPoint(clientCardUId)
    --  Log("GetEqsCardPoint:", clientCardUId)
    return math.floor(tonumber(clientCardUId) / 100)
end

function EqsTools.GetEqsCardType(clientCardUId)
    return math.floor(tonumber(clientCardUId) % 100 / 10)
end

function EqsTools.GetEqsCardId(clientCardUId)
    return math.floor(tonumber(clientCardUId) / 10) * 10
end

function EqsTools.GetTime(timeNum)
    if UserData.IsReconnect() then
        return 0
    end
    if timeNum < 0.001 then
        return 0
    end
    return timeNum
end

function EqsTools.SetCellCardYuTag(cell)
    if cell ~= nil and cell.childCount > 0 then
        local card = cell:GetChild(0)
        if BattleModule.IsYuCardUid(tonumber(card.gameObject.name)) then
            EqsCardsManager.SetSmallCardEffect(card, EqsCardDefine.SmallCardEffectType.BoundEffect)
        end
    end
end

function EqsTools.SetCellCardEffect(cell, smallCardEffectType, cardid)
    if cell ~= nil and cell.childCount > 0 then
        local card = cell:GetChild(0)
        if EqsTools.GetEqsCardId(card.gameObject.name)  == EqsTools.GetEqsCardId(cardid) then
            EqsCardsManager.SetSmallCardEffect(card, smallCardEffectType)
        end
    end
end

function EqsTools.AddSmallCardToCell(cardId, cell)
    if cell == nil or not IsNumber(cardId) then
        Log("AddSmallCardToCell", cardId, cell)
        return nil
    end
    local smallTran = EqsCardsManager.GetSmallCardByUid(cardId)
    if smallTran ~= nil then
        smallTran:SetParent(cell)
        smallTran.anchoredPosition = Vector3.zero
        smallTran.localScale = Vector3.one
        smallTran.gameObject.name = tostring(cardId)
        EqsCardsManager.SetSmallCardEffect(smallTran, EqsCardDefine.SmallCardEffectType.Null)
    else
        Log("不存在的Card：", cardId, cell)
    end
    return smallTran
end

function EqsTools.GetCellCardUid(cell)
    if cell ~= nil then
        local count = cell.childCount
        if count == 1 then
            return tonumber(cell:GetChild(0).gameObject.name)
        elseif count > 1 then
            LogWarn("cell牌错误，回收所有牌", cell.name, count)
            EqsTools.RecycleSmallCardCell(cell)
            return 0
        end
    end
    return 0
end

function EqsTools.RecycleSmallCardCell(cell)
    if cell ~= nil then
        local count = cell.childCount
        if count > 0 then
            for i = 0, count - 1 do
                EqsCardsManager.RecycleSmallCard(cell:GetChild(i))
            end
        end
    end
end

--直接拼接所有规则
function EqsTools.GetRulesText1(rules)
    if BattleModule.parsedRules ~= nil then
        return BattleModule.parsedRules.playWayName..":"..BattleModule.parsedRules.rule
    else
        return ""
    end
end

--数字转中文
function EqsTools.NumberToChinese(num)
    if num == 0 then
        return '零'
    elseif num == 1 then
        return '壹'
    elseif num == 2 then
        return '贰'
    elseif num == 3 then
        return '叁'
    elseif num == 4 then
        return '肆'
    elseif num == 5 then
        return '伍'
    elseif num == 6 then
        return '陆'
    elseif num == 7 then
        return '柒'
    elseif num == 8 then
        return '捌'
    elseif num == 9 then
        return '玖'
    elseif num == 10 then
        return '拾'
    elseif num == 11 then
        return '拾壹'
    elseif num == 12 then
        return '拾贰'
    elseif num == 13 then
        return '拾叁'
    elseif num == 14 then
        return '拾肆'
    elseif num == 15 then
        return '拾伍'
    end
    return tostring(num)
end

--{targetId = 0, from = 0, oper = EqsOperation.Guo, id1 = 0, id2 = 0, id3 = 0}
function EqsTools.GetOperation(operType, targetId, from, id1, id2, id3)
    local oper = {}
    oper.targetId = targetId
    oper.from = from
    oper.oper = operType
    oper.id1 = id1
    oper.id2 = id2
    oper.id3 = id3
    return oper
end

function EqsTools.CheckOperation(operation)
    -- if  not IsTable(operation)          or not IsNumber(operation.oper) or not IsNumber(operation.targetId) or 
    --     not IsNumber(operation.from)    or not IsNumber(operation.id1)  or 
    --     not IsNumber(operation.id2)     or not IsNumber(operation.id3)  then
    --         LogError("operation参数规则错误", operation)
    --         return false
    -- end
    return true
end

function EqsTools.GetTargetId(operation)
    if operation ~= nil and IsNumber(operation.targetId) then
        return operation.targetId
    end
    return -1
end

function EqsTools.GetOperationType(operation)
    if operation ~= nil and IsNumber(operation.oper) then
        return operation.oper
    end
    return -1
end

function EqsTools.GetFrom(operation)
    if operation ~= nil and IsNumber(operation.from) then
        return operation.from
    end
    return -1
end

function EqsTools.GetCardUid1(operation)
    if operation ~= nil and IsNumber(operation.id1) then
        return operation.id1
    end
    return -1
end

function EqsTools.GetCardUid2(operation)
    if operation ~= nil and IsNumber(operation.id2) then
        return operation.id2
    end
    return -1
end

function EqsTools.GetCardUid3(operation)
    if operation ~= nil and IsNumber(operation.id3) then
        return operation.id3
    end
    return -1
end

function EqsTools.SetHeadIcon(transform, url)
    Functions.SetHeadImage(transform:GetComponent("Image"), url)
end

local dis = {0,100,500}
function EqsTools.GetGps(gps1, gps2)
    return 0
end

function EqsTools.ReturnToLobby()
    TryCatchCall(function() 
        EqsCardsManager.reset() 
        EqsBattleCtrl.ClearHsz() 
        SelfHandEqsCardsCtrl.Reset()
    end)
    local args = {gameType = GameType.ErQiShi}
    if not BattleModule.isPlayback then
        if BattleModule.IsClubRoom() then
            args.openType = DefaultOpenType.Tea
            args.groupId = BattleModule.clubId
        elseif BattleModule.IsTeaRoom() then
            args.openType = DefaultOpenType.Tea
            args.groupId = BattleModule.teaId
        end
    else
        args.openType = DefaultOpenType.Record
        args.recordType = BattleModule.recordType
        if BattleModule.recordType == 2 then
            args.groupId = BattleModule.clubId
        end
    end
    BattleModule.Uninit()
    GameSceneManager.SwitchGameScene(GameSceneType.Lobby,GameType.ErQiShi,args)
end

function EqsTools.ScreenPosInRect(rect)
    local isIn = false
    if not IsNull(rect) then
        isIn = UIUtil.ScreenPosInRect(rect, Input.mousePosition, UIConst.uiCamera)
    end
    return isIn
end

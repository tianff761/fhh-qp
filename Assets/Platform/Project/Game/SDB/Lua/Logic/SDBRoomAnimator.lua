SDBRoomAnimator = {
    jieSuanTimer = nil,
    sendCarding = nil,
}
local this = SDBRoomAnimator

--抢庄动画跳动次数
local robZhuangCount = 10
--抢庄动画每次等待间隔
local robZhuangTime = 0.1
--所有参与抢庄的人的UI
local robBankerPlayersUI = {}
--抢庄动画回调
local robBankerOnComplete = nil

---! 播放准备动画
function SDBRoomAnimator.PlayReadyAnim(item)
    local font = item.transform:Find('ImgFont').gameObject
    SDBRoomAnimator.PlayScaleEaseAnim(font)
end

--播放从大到小的动画
function SDBRoomAnimator.PlayScaleEaseAnim(obj)
    local Ease = DG.Tweening.Ease
    local rtransform = obj:GetComponent('RectTransform')
    rtransform.localScale = Vector3.New(4, 4, 4)
    local tweener = rtransform:DOScale(Vector3.New(1, 1, 1), 0.2)
    tweener:SetEase(Ease.InQuart)
    tweener:SetDelay(0.1)
end

--播放抢庄动画
function SDBRoomAnimator.PlayRobZhuangAni(playerInfos, funs)
    robBankerOnComplete = funs
    robBankerPlayersUI = {}
    --将所有参与抢庄的玩家的UI保存下来
    for i = 1, #playerInfos do
        local robDatas = string.split(playerInfos[i], ",")
        local item = SDBRoomData.GetPlayerUIById(tonumber(robDatas[1]))
        table.insert(robBankerPlayersUI, item)
    end
    coroutine.start(this.RobBanker)
end

--抢庄
function SDBRoomAnimator.RobBanker()
    --一个人抢庄的情况
    if #robBankerPlayersUI == 1 then
        UIUtil.SetActive(robBankerPlayersUI[1].bankeBox.gameObject, false)
        --播放抢庄音效
        SDBResourcesMgr.PlayGameSound(SDBGameEffSoundType.EFFRANDOMBANKER)
    else
        local robBankerId = {}
        local lastplayerId = nil
        --多人抢庄的情况
        for i = 1, robZhuangCount do
            if robBankerId == nil or #robBankerId == 0 then
                robBankerId = CopyTable(robBankerPlayersUI, true)
            end
            --当前阶段不是抢庄阶段，不播放抢庄动画...
            if SDBRoomData.gameState ~= SDBGameState.BetState and SDBRoomData.gameState ~= SDBGameState.RobBanker then
                break
            end
            local num = 0
            for i = 1, 100 do
                num = math.ceil(Util.Random(0, #robBankerId))
                local mPlayerId = robBankerId[num].playerId
                if mPlayerId ~= lastplayerId then
                    break
                end
            end

            lastplayerId = robBankerId[num].playerId

            UIUtil.SetActive(robBankerId[num].bankeBox.gameObject, true)
            --播放抢庄音效
            SDBResourcesMgr.PlayGameSound(SDBGameEffSoundType.EFFRANDOMBANKER)

            coroutine.wait(robZhuangTime)
            if robBankerId[num] ~= nil then
                UIUtil.SetActive(robBankerId[num].bankeBox.gameObject, false)
            end
            table.remove(robBankerId, num)
        end
        lastplayerId = nil
        --关闭所有抢庄的框
        for i = 1, #robBankerPlayersUI do
            UIUtil.SetActive(robBankerPlayersUI[i].bankeBox.gameObject, false)
        end
    end

    if robBankerOnComplete ~= nil then
        robBankerOnComplete()
        robBankerOnComplete = nil
    end
end

--飞金币动画 
function SDBRoomAnimator.SettlementAnim(bankerItem, winners, losers, OnComplete)
    --输了的闲家先飞到庄家头上
    if losers ~= nil and #losers > 0 then
        for s = 1, #losers do
            local playerItem = SDBRoomData.GetPlayerUIById(losers[s])
            if playerItem ~= nil then
                for i = 1, 15 do
                    local prefab = playerItem.goldItem.gameObject
                    this.FlyGold(i, playerItem.faceGO.transform, bankerItem, prefab)
                end
            end
        end
        SDBResourcesMgr.PlayGameSound(SDBGameEffSoundType.EFFFLYCOINS)
    end

    local time = 0
    local isPlay = false
    this.jieSuanTimer = Scheduler.scheduleGlobal(function()
        time = time + 1
        if not isPlay then
            isPlay = true
            --从庄家头上飞到赢了的闲家头上
            if winners ~= nil and #winners > 0 then
                for s = 1, #winners do
                    local playerItem = SDBRoomData.GetPlayerUIById(winners[s])
                    if not IsNil(playerItem) then
                        playerItem:PlayWinAni()
                        local prefab = playerItem.goldItem.gameObject
                        for i = 1, 15 do
                            this.FlyGold(i, bankerItem, playerItem.faceGO.transform, prefab)
                        end
                    end
                end
                SDBResourcesMgr.PlayGameSound(SDBGameEffSoundType.EFFFLYCOINS)
            end
        end
        if time == 3 and OnComplete ~= nil then
            OnComplete()
            Scheduler.unscheduleGlobal(this.jieSuanTimer)
        end
    end, 1)
end

--飞金币
function SDBRoomAnimator.FlyGold(index, startTrasn, endTrasn, perfab)
    local item = SDBResourcesMgr.GetFlyGoldItem(perfab, startTrasn)
    item.transform.localScale = Vector3.one
    local tempX = GetRandom(-5, 5)
    local tempY = GetRandom(-6, 6)
    item.transform.localPosition = Vector3(tempX, tempY, 0)
    local rectTransform = item:GetComponent('RectTransform')

    item.transform:SetParent(endTrasn)
    ---! 移动
    if index % 2 > 0 then
        tempX = GetRandom(-5, 6)
        tempY = GetRandom(-6, 5)
    end

    local tweener = rectTransform:DOLocalMove(Vector3(0, 0, 0), 0.4, true)
    local Ease = DG.Tweening.Ease
    tweener:SetEase(Ease.OutSine)
    tweener:SetDelay(0.06 * index + math.random(1, 10) / 1000)
    --飞金币回调
    tweener:OnComplete(function()
        SDBResourcesMgr.RecycleFlyGoldItem(item)
    end)
end

--是否可以点击
function SDBRoomAnimator.IsOnClick()
    if this.sendCarding or SDBRoomData.isGetCard == false then
        Toast.Show("请不要频繁操作...")
        return false
    end
    return true
end

--播放要牌中动画
function SDBRoomAnimator.PlayYaoPaiZhongAni(playerId)
    local playerItem = SDBRoomData.GetPlayerUIById(playerId)
    if playerItem ~= nil then
        playerItem:PlayYaoPaiZhongAni()
    end
end

--关闭要牌中动画
function SDBRoomAnimator.StopYaoPaiZhongAni(playerId)
    local playerItem = SDBRoomData.GetPlayerUIById(playerId)
    if playerItem ~= nil then
        playerItem:StopYaoPaiZhongAni()
    end
end

return SDBRoomAnimator
LYCRoomAnimator = {
    jieSuanTimer = nil,
    sendCarding = nil,
}
local this = LYCRoomAnimator

--抢庄动画跳动次数
local robZhuangCount = 10
--抢庄动画每次等待间隔
local robZhuangTime = 0.05
--所有参与抢庄的人的UI
local robBankerPlayersUI = {}
--抢庄动画回调
local robBankerOnComplete = nil

---! 播放准备动画
function LYCRoomAnimator.PlayReadyAnim(item)
    local font = item.transform:Find('ImgFont').gameObject
    LYCRoomAnimator.PlayScaleEaseAnim(font)
end

--播放从大到小的动画
function LYCRoomAnimator.PlayScaleEaseAnim(obj)
    local Ease = DG.Tweening.Ease
    local rtransform = obj:GetComponent('RectTransform')
    rtransform.localScale = Vector3.New(2, 2, 2)
    local tweener = rtransform:DOScale(Vector3.New(1, 1, 1), 0.2)
    tweener:SetEase(Ease.InQuart)
    tweener:SetDelay(0.1)
end

--播放抢庄动画
function LYCRoomAnimator.PlayRobZhuangAni(playerInfos, funs)
    robBankerOnComplete = funs
    robBankerPlayersUI = {}
    --将所有参与抢庄的玩家的UI保存下来
    for i = 1, #playerInfos do
        local item = LYCRoomData.GetPlayerUIById(playerInfos[i])
        if not IsNil(item) then
            --先隐藏所有玩家庄图标
            item:SetZhuangImageActive(false)
            table.insert(robBankerPlayersUI, item)
        end
    end
    coroutine.start(this.RobBanker)
end

--抢庄
function LYCRoomAnimator.RobBanker()
    --一个人抢庄的情况
    if #robBankerPlayersUI == 1 then
        UIUtil.SetActive(robBankerPlayersUI[1].bankeBox.gameObject, false)
        --播放抢庄音效
        LYCResourcesMgr.PlayGameSound(LYCGameEffSoundType.EFFRANDOMBANKER)
    else
        local robBankerId = {}
        local lastplayerId = nil
        --多人抢庄的情况
        for i = 1, robZhuangCount do
            if robBankerId == nil or #robBankerId == 0 then
                robBankerId = CopyTable(robBankerPlayersUI, true)
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
            LYCResourcesMgr.PlayGameSound(LYCGameEffSoundType.EFFRANDOMBANKER)

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
function LYCRoomAnimator.SettlementAnim(bankerItem, winners, losers, OnComplete)
    --输了的闲家先飞到庄家头上
    if losers ~= nil and #losers > 0 then
        for s = 1, #losers do
            local playerItem = LYCRoomData.GetPlayerUIById(losers[s])
            if playerItem ~= nil then
                for i = 1, 5 do
                    local prefab = playerItem.goldItem.gameObject
                    this.FlyGold(i, playerItem.faceGO.transform, bankerItem, prefab)
                end
            end
        end
        LYCResourcesMgr.PlayGameSound(LYCGameEffSoundType.EFFFLYCOINS)
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
                    local playerItem = LYCRoomData.GetPlayerUIById(winners[s])
                    if not IsNil(playerItem) then
                        playerItem:PlayWinAni()
                        local prefab = playerItem.goldItem.gameObject
                        for i = 1, 15 do
                            this.FlyGold(i, bankerItem, playerItem.faceGO.transform, prefab)
                        end
                    end
                end
                LYCResourcesMgr.PlayGameSound(LYCGameEffSoundType.EFFFLYCOINS)
            end
        end
        if time == 3 and OnComplete ~= nil then
            OnComplete()
            Scheduler.unscheduleGlobal(this.jieSuanTimer)
        end
    end, 1)
end

--飞金币
function LYCRoomAnimator.FlyGold(index, startTrasn, endTrasn, perfab)
    local item = LYCResourcesMgr.GetFlyGoldItem(perfab, startTrasn)
    --item.transform.localScale = Vector3(2, 2, 2)
    local tempX = math.random(-100, 100)
    local tempY = math.random(-100, 100)
    item.transform.localPosition = Vector3(tempX, tempY, 0)
    local rectTransform = item.transform:GetComponent('RectTransform')

    item.transform:SetParent(endTrasn)
    ---! 移动
    if index % 2 > 0 then
        tempX = GetRandom(-5, 6)
        tempY = GetRandom(-6, 5)
    end

    local tweener = rectTransform:DOLocalMove(Vector3(0, 0, 0), 0.6, true)
    local Ease = DG.Tweening.Ease
    tweener:SetEase(Ease.OutSine)
    --tweener:SetDelay(0.06 * index + math.random(1, 10) / 1000)
    --飞金币回调
    tweener:OnComplete(function()
        LYCResourcesMgr.RecycleFlyGoldItem(item)
    end)
end

--关闭要牌中动画
function LYCRoomAnimator.StopYaoPaiZhongAni(playerId)
    local playerItem = LYCRoomData.GetPlayerUIById(playerId)
    if playerItem ~= nil then
        playerItem:StopYaoPaiZhongAni()
    end
end

return LYCRoomAnimator
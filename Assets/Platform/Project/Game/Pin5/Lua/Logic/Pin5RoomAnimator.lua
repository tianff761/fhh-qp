Pin5RoomAnimator = {
    sendCarding = nil,
}
local this = Pin5RoomAnimator

--抢庄动画跳动次数
local robBankerAnimTotal = 10
--抢庄动画每次等待间隔
local robBankerAnimInterval = 0.05
--所有参与抢庄的人的UI
local robBankerPlayerItems = {}
--抢庄动画回调
local robBankerCallback = nil

---! 播放准备动画
function Pin5RoomAnimator.PlayReadyAnim(item)
    local font = item.transform:Find('ImgFont').gameObject
    Pin5RoomAnimator.PlayScaleEaseAnim(font)
end

--播放从大到小的动画
function Pin5RoomAnimator.PlayScaleEaseAnim(obj)
    local Ease = DG.Tweening.Ease
    local rtransform = obj:GetComponent('RectTransform')
    rtransform.localScale = Vector3.New(4, 4, 4)
    local tweener = rtransform:DOScale(Vector3.New(1, 1, 1), 0.2)
    tweener:SetEase(Ease.InQuart)
    tweener:SetDelay(0.1)
end

--================================================================
--播放抢庄动画
function Pin5RoomAnimator.PlayRobBankerAnim(playerIds, callback)

    LogError(">> Pin5RoomAnimator.PlayRobBankerAnim")

    robBankerCallback = callback
    robBankerPlayerItems = {}
    --将所有参与抢庄的玩家的UI保存下来
    for i = 1, #playerIds do
        local item = Pin5RoomData.GetPlayerItemById(playerIds[i])
        if not IsNil(item) then
            --先隐藏所有玩家庄图标
            item:HideBankerDisplay()
            table.insert(robBankerPlayerItems, item)
        end
    end
    coroutine.start(this.HandlePlayRobBankerAnim)
end

--处理播放抢庄动画
function Pin5RoomAnimator.HandlePlayRobBankerAnim()
    --一个人抢庄的情况
    if #robBankerPlayerItems == 1 then
        --
        robBankerPlayerItems[1]:SetImgBankerBoxDisplay(false)
        --播放抢庄音效
        Pin5ResourcesMgr.PlayGameSound(Pin5GameEffSoundType.EFFRANDOMBANKER)
    else
        local playerItems = {}
        local lastPlayerId = nil
        local playerItem = nil
        --多人抢庄的情况
        for i = 1, robBankerAnimTotal do
            if playerItems == nil or #playerItems == 0 then
                for i = 1, #robBankerPlayerItems do
                    table.insert(playerItems, robBankerPlayerItems[i])
                end
            end
            local index = 0
            for i = 1, 50 do
                index = math.ceil(Util.Random(0, #playerItems))
                if playerItems[index].playerId ~= lastPlayerId then
                    break
                end
            end

            playerItem = playerItems[index]
            lastPlayerId = playerItem.playerId
            --显示庄BOX
            playerItem:SetImgBankerBoxDisplay(true)
            --播放抢庄音效
            Pin5ResourcesMgr.PlayGameSound(Pin5GameEffSoundType.EFFRANDOMBANKER)

            coroutine.wait(robBankerAnimInterval)

            if playerItem ~= nil then
                playerItem:SetImgBankerBoxDisplay(false)
            end
            table.remove(playerItems, index)
        end
        lastPlayerId = nil
        --关闭所有抢庄的框
        for i = 1, #robBankerPlayerItems do
            robBankerPlayerItems[i]:SetImgBankerBoxDisplay(false)
        end
    end
    this.PlayBankerActiveAnim()
end

--设置庄动画激活状态
function Pin5RoomAnimator.PlayBankerActiveAnim()
    local playerItem = Pin5RoomData.GetPlayerItemById(Pin5RoomData.BankerPlayerId)
    local tempCallback = robBankerCallback
    robBankerCallback = nil
    if not IsNil(playerItem) then
        playerItem:PlayBankerAnim(tempCallback)
    else
        if tempCallback ~= nil then
            tempCallback()
        end
    end
end

--================================================================

return Pin5RoomAnimator
ChatModule = {
    --是否可以发送数据
    isCanSend = false,
}
local this = ChatModule
--当前游戏类型
local curGameType = nil
------------------------------------------------
--聊天文本显示时间  秒
local ChatTextShowTime = 2
------------------------------------------------
--麦克风是否能够开启
local microphoneIsFailure = false
--录音显示录音面板延迟事件
local recordShowSpeedTime = 0.3
--录音按钮上次点击时间
local recordOnClickTime = 0;
--录音timer
local recordTimer
------------------------------------------------
--道具 资源名
local chatAssetName = "ChatAnim"
--表情播放时间  秒
local emotionShowTime = 3
local isInit = false
--是否屏蔽道具显示
local isShieldPropShow = false
------------------------------------------------
--快捷语配置
local chatConfig = nil
--玩家信息
local playerInfos = nil

--提示使用的格式
function ChatModule.Tip()
    -- local chatConfig = {
    --      audioBundle = "",
    --      textChatConfig = 文本配置表,
    --      languageType = nil, --语言类型(putonghua ?)
    -- }
    --文本配置表
    -- {
    -- 	[LanguageType.sichuan] = {
    -- 		[Global.GenderType.Male] = {
    -- 			{text = "搞快点儿出嘛，公园儿嘞老头都比你打的快。", audio = "chat_boy_1"} ,
    -- 		},
    -- 		[Global.GenderType.Female] = {
    -- 			{text = "打快点嘛，公园头的都比你打的快", audio = "chat_girl_1"} ,
    -- 		}
    -- 	}
    -- }
    -- local playerInfos = {}
    -- playerInfos[uid] = {
    --     animNode = nil,             --动画播放节点  --不需要动画可以不传
    --     emotionNode = nil,          --表情播放节点  --不需要表情可以不传
    --     name = "",
    --     gender = Global.GenderType.Female
    -- }
end

--聊天弹窗
local popCallback = nil   --方法
--语音弹窗
local voicePopCallback = nil
-----------------------------模块使用前必须注册的方法------------------------
--设置聊天方法显示回调(发聊天的玩家id，显示时间长度，文本)
function ChatModule.SetChatCallback(callback)
    popCallback = callback
end
--设置聊天气泡方法显示回调(发聊天的玩家id，显示时间长度)
function ChatModule.SetVoiceCallback(callback)
    voicePopCallback = callback
end

--设置聊天文本配置
function ChatModule.SetChatConfig(config)
    chatConfig = config
end

--设置玩家信息
function ChatModule.SetPlayerInfos(mplayerInfos)
    playerInfos = mplayerInfos
end

--注册聊天按钮事件  --传入聊天点击的按钮GameObject
function ChatModule.RegisterChatTextEvent(go)
    if IsNil(go) then
        LogError(">>>>>> ChatModule > RegisterChatTextEvent > go is nil")
        return
    end
    local btn = go:GetComponent(typeof(Button))
    if btn == nil then
        btn = go:AddComponent(typeof(Button))
    end
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(this.OnClickChatBtn)
end

function ChatModule.SetIsCanSend(bool)
    this.isCanSend = bool
end

--注册语音事件  --传入语音按钮的GameObject
function ChatModule.RegisterVoiceEvent(go)
    if IsNil(go) then
        LogError(">>>>>> ChatModule > RegisterVoiceEvent > go is nil")
        return
    end
    local btnSpeech = go:GetComponent(typeof(ButtonSpeech))
    if btnSpeech == nil then
        btnSpeech = go:AddComponent(typeof(ButtonSpeech))
    end
    btnSpeech:Init(this.OnSpeechDown, this.OnSpeechUp, this.OnSpeechMove)
end
-----------------------------模块使用前必须注册的方法end------------------------
function ChatModule.GetIsInit()
    return isInit
end

--初始化Api
function ChatModule.Init()
    --清除数据
    this.ClearData()
    isInit = true
    this.AddMsg()
    isShieldPropShow = toboolean(GetLocal(CMD.Game.ShieldProp, false))
end

--监听聊天事件
function ChatModule.AddMsg()
    --TCP协议
    --LogError("<color=aqua>AddMsg</color>")
    AddMsg(CMD.Tcp.S2C_PushChatData, this.OnReceiveChatData)
    AddMsg(CMD.Tcp.S2C_ChatData, this.OnChatData)
    --游戏自定义协议
    AddMsg(CMD.Game.VoiceDown, this.OnVoiceDown)
    AddMsg(CMD.Game.VoicePlay, this.OnVoicePlay)
    AddMsg(CMD.Game.VoiceUpload, this.OnVoiceUpload)
    AddMsg(CMD.Game.MicrophoneFailure, this.SetMicrophoneIsFailure)
    AddMsg(CMD.Game.ShieldProp, this.OnShieldProp)
end

--移除聊天事件
function ChatModule.RemoveMsg()
    --TCP协议
    --LogError("<color=aqua>RemoveMsg</color>")
    RemoveMsg(CMD.Tcp.S2C_PushChatData, this.OnReceiveChatData)
    RemoveMsg(CMD.Tcp.S2C_ChatData, this.OnChatData)
    --游戏自定义协议
    RemoveMsg(CMD.Game.VoiceDown, this.OnVoiceDown)
    RemoveMsg(CMD.Game.VoicePlay, this.OnVoicePlay)
    RemoveMsg(CMD.Game.VoiceUpload, this.OnVoiceUpload)
    RemoveMsg(CMD.Game.MicrophoneFailure, this.SetMicrophoneIsFailure)
    RemoveMsg(CMD.Game.ShieldProp, this.OnShieldProp)
end

--卸载聊天Api
function ChatModule.UnInit()
    playerInfos = nil
    popCallback = nil   --方法
    voicePopCallback = nil
    chatConfig = nil
    isInit = false
    ChatModule.SetIsCanSend(false)
    --移除事件
    this.RemoveMsg()
    --清除数据
    this.ClearData()
    --删除UI面板
    this.CloseUI()
    --清除道具动画
    PropsAnimationMgr.UnInit()
end

--清除聊天数据(包括历史记录以及本地缓存的语音)
function ChatModule.ClearData()
    --清空历史记录
    ChatDataManager.ClearHistoryData()
    --关闭语音
    ChatVoice.Close()
end

--关闭聊天模块相关UI
function ChatModule.CloseUI()
    PanelManager.Close(PanelConfig.RoomChat, true)
    PanelManager.Close(PanelConfig.RoomSpeech, true)
    PanelManager.Close(PanelConfig.RoomUserInfo, true)
end

--获取玩家数量
function ChatModule.GetPlayerInfoCount()
    if playerInfos == nil then
        return 0
    end
    return GetTableSize(playerInfos)
end

--是否屏蔽道具
function ChatModule.OnShieldProp(isBool)
    isShieldPropShow = isBool
end

--打开RoomUserPanel
function ChatModule.OpenRoomUserInfoPanel(arg)
    PanelManager.Open(PanelConfig.RoomUserInfo, arg)
end

--======================================================
--点击聊天按钮
function ChatModule.OnClickChatBtn()
    Audio.PlayClickAudio()
    PanelManager.Open(PanelConfig.RoomChat, { isShield = true })
end
--================================================语音相关
--设置麦克风是否开启失败
function ChatModule.SetMicrophoneIsFailure(bool)
    microphoneIsFailure = bool
end

--按下
function ChatModule.OnSpeechDown(y)
    if ChatVoice.canStartClick ~= true then
        Toast.Show("请不要频繁点击")
        return
    end
    local time = Time.realtimeSinceStartup
    if time - recordOnClickTime < 5 then
        Toast.Show("请不要频繁点击")
        return
    end

    this.speechTouchY = y

    microphoneIsFailure = false
    --开始录音
    ChatVoice.RecordStart()

    if recordTimer ~= nil then
        recordTimer:Stop()
        recordTimer = nil
    end
    --延迟显示录音中动画（目的：先尝试录音，如果麦克风权限未开启，会在0.3秒内返回停止录音）
    recordTimer = Scheduler.scheduleOnceGlobal(this.ScheduleClickVoice, recordShowSpeedTime)
end

--开启录音面板
function ChatModule.ScheduleClickVoice()
    if not microphoneIsFailure then
        PanelManager.Open(PanelConfig.RoomSpeech, ChatVoice.recordInteval)
        recordOnClickTime = Time.realtimeSinceStartup
    end
end

--弹起
function ChatModule.OnSpeechUp(y)
    local delta = y - this.speechTouchY
    this.CloseSpeechUI()
    if delta < 60 then
        ChatVoice.RecordEnd()
    else
        ChatVoice.RecordCancel()
    end
    -- ChatModule.OnVoiceUpload({speekTime = 10000,fileName = "100202-131961573098596600.amr"})
    microphoneIsFailure = true
end

function ChatModule.CloseSpeechUI()
    PanelManager.Close(PanelConfig.RoomSpeech)
end

--移动
function ChatModule.OnSpeechMove(y)
    local delta = y - this.speechTouchY
    local speech = PanelManager.GetPanel(PanelConfig.RoomSpeech)
    if IsNil(speech) then
        return
    end
    if delta < 60 then
        speech:Notice()
    else
        speech:Confirm()
    end
end

--上传语音成功
function ChatModule.OnVoiceUpload(arg)
    local data = {
        speekTime = arg.speekTime
    }
    this.SendChatData(ChatDataType.voiceChat, data, arg.fileName, 0)
end
--===================================================快捷聊天相关
--获取快捷聊天文本
function ChatModule.GetPhraseConfig()
    --return this.GetTextConfigByGender(UserData.GetGender())
    return this.GetCommonQuickMessage(UserData.GetGender())
end

--发送快捷文本
function ChatModule.SendTextChatData(index)
    this.SendChatData(ChatDataType.phraseChat, { gender = UserData.GetGender() }, index, 0)
end
--===================================================输入文字相关
--发送聊天文本
function ChatModule.SendInputTextChatData(text)
    local str = ReplaceSensitiveWords(text)
    this.SendChatData(ChatDataType.inuptChat, nil, str, 0)
end
--===================================================表情相关
--发送表情
function ChatModule.SendEmotionChatData(index)
    this.SendChatData(ChatDataType.emotionChat, nil, index, 0)
end
--===================================================道具相关
--发送道具
function ChatModule.SendFreePropChatData(index, toId)
    local tId = toId
    if tId == UserData.GetUserId() then
        tId = 0
    end
    this.SendChatData(ChatDataType.propChat, { toId = toId }, index, tId)
end
--===============================================
--发送聊天信息
function ChatModule.SendChatData(type, arg, cId, toId)
    local data = {
        type = type,
        tId = toId or 0,
        cId = cId or "",
        arg = arg or ""
    }

    if this.isCanSend then
        SendTcpMsg(CMD.Tcp.C2S_ChatData, data)
    end
end

function ChatModule.OnChatData(arg)
    local data = arg.data
    if data.code == ChatModuleCode.Gift_Not_Enough then
        Alert.Show("发送失败，礼券不足")
    elseif data.code == ChatModuleCode.Gold_Not_Enough then
        Alert.Prompt("发送失败，元宝不足")
    end
end

--=====================================================================================================================
--====================================================接收聊天信息======================================================
--=====================================================================================================================
--收到聊天信息
function ChatModule.OnReceiveChatData(arg)
    LogError("<color=aqua>OnReceiveChatData</color>")
    if arg.code ~= 0 then
        return
    end

    local data = arg.data
    local content = data.cId
    local sendPlayerInfo = playerInfos[data.fId]

    if sendPlayerInfo == nil then
        LogError(">>>>>>>>>> ChatModule > OnReceiveChatData 发送玩家信息为空 ")
        return
    end

    local chatData = SingChatData:New()
    --特殊处理短语，他发过来的不是完整文字，是下标
    if data.type == ChatDataType.phraseChat then
        --local config = this.GetTextConfigByGender(data.arg.gender)
        local config = this.GetCommonQuickMessage(data.arg.gender)
        if config ~= nil then
            content = config[data.cId].text
        end
    elseif data.type == ChatDataType.propChat then
        chatData.toId = data.arg.toId
    end

    chatData:SetData(data.time, sendPlayerInfo.name, data.type, data.fId, content, data.arg.speekTime, data.arg.gender)

    if data.type == ChatDataType.voiceChat then
        this.OnVoiceChat(chatData)
    elseif data.type == ChatDataType.phraseChat then
        this.OnPhraseChat(chatData, data.cId)
    elseif data.type == ChatDataType.inuptChat then
        this.OnInuptChat(chatData)
    elseif data.type == ChatDataType.propChat then
        if not isShieldPropShow or data.fId == UserData.GetUserId() then
            this.OnPropChat(chatData)
        end
    elseif data.type == ChatDataType.emotionChat then
        this.OnEmotionChat(chatData)
    end

    --如果是表情或者道具，不记录聊天记录
    if data.type == ChatDataType.emotionChat or data.type == ChatDataType.propChat then
        ChatDataManager.DeleteHistoryData(ChatDataManager.GetHistoryCount())
    else
        --通知显示记录
        SendEvent(CMD.Game.UpdateHistoryData, { chatData = chatData, type = 1 })
    end
end

--处理语音聊天
function ChatModule.OnVoiceChat(chatData)
    ChatVoice.PlayVoice(chatData.content, chatData.formId, chatData.duration, chatData.uid)
end

--处理道具
function ChatModule.OnPropChat(chatData)
    --LogError("<color=aqua>OnPropChat</color>")
    local assert = ResourcesManager.LoadPrefabBySynch(BundleName.Chat, chatAssetName)
    if assert == nil then
        LogError(">>>>>>>>>> ChatModule > OnEmotionChat 表情资源加载失败 ")
        return
    end

    if chatData.toId == chatData.formId then
        --LogError("111111")
        --高级道具
        if PropsAnimationType[chatData.content] then
            this.SendHightPropAll(chatData)
        else
            --发送目标为自己时，全部发送  --普通道具
            for k, v in pairs(playerInfos) do
                if k ~= chatData.formId then
                    this.SendFreeProp(k, chatData.formId, assert, chatData.content)
                end
            end
        end
    else
        --LogError("222222")
        if PropsAnimationType[chatData.content] then
            --LogError("2 1111")
            this.SendHightPropOne(chatData)
        else
            --LogError("2 2222")
            this.SendFreeProp(chatData.toId, chatData.formId, assert, chatData.content)
        end
    end
end

--单发高级道具
function ChatModule.SendHightPropOne(chatData)
    local type = chatData.content
    local target = {}
    local aniTra = playerInfos[chatData.toId].animNode.transform
    table.insert(target, aniTra)

    local arg = {
        from = playerInfos[chatData.formId].animNode.transform,
        to = target
    }
    PropsAnimationMgr.PlayAni(PropsAnimationType[type], arg)
end

--发送高级道具给除了自己以外的所有人
function ChatModule.SendHightPropAll(chatData)
    local type = chatData.content
    local target = {}
    --是否为全局动画 就为单发
    if PropsAnimationType[type].isFull then
        this.SendHightPropOne(chatData)
    else
        --不是全局，发送人与接收人相同，发送所有人
        for k, v in pairs(playerInfos) do
            if k ~= chatData.formId then
                table.insert(target, v.animNode.transform)
            end
        end
        --没有发送玩家
        if #target == 0 then
            return
        end

        local arg = {
            from = playerInfos[chatData.formId].animNode.transform,
            to = target
        }
        PropsAnimationMgr.PlayAni(PropsAnimationType[type], arg)
    end
end

--发送免费道具
function ChatModule.SendFreeProp(toId, formId, assert, type)
    LogError("<color=aqua>SendFreeProp</color>")
    local itemAni = assert.transform:Find(PropConfig[type].Move)
    if itemAni == nil then
        LogError(">>>>>>>>>> ChatModule > OnEmotionChat itemAni is nil ")
        return
    end
    local ToAnimNode = playerInfos[toId].animNode.transform
    local formAnimNode = playerInfos[formId].animNode.transform
    if ToAnimNode ~= nil and formAnimNode ~= nil then
        local twoLayer = uiMgr:GetUILayer(3)
        local propImage = CreateGO(itemAni.gameObject, formAnimNode, "tem1")
        propImage.transform.localPosition = Vector3.zero
        propImage.transform:SetParent(twoLayer)
        propImage.transform.localScale = Vector3.one--Vector3.New(0.7, 0.7, 0.7)
        local v3 = ToAnimNode.position

        propImage.transform:DOMove(v3, 0.9):OnComplete(function()
            destroy(propImage, 0.05)
            this.SendFreePropCallback(type, ToAnimNode)
        end)

        --播放音效
        AudioManager.PlaySound(BundleName.Chat, PropConfig[type].Move)
    end
end

function ChatModule.SendFreePropCallback(type, ToAnimNode)
    ResourcesManager.LoadPrefab(
            BundleName.Chat,
            PropConfig[type].Anim,
            function(obj)
                local propAniItem = CreateGO(obj.gameObject, ToAnimNode, "temp")
                propAniItem.transform.localPosition = Vector3.zero

                local spineAnim = propAniItem:GetComponentInChildren(TypeSkeletonGraphic)
                spineAnim.AnimationState.Complete = spineAnim.AnimationState.Complete + function() destroy(propAniItem, 0.1) end

                -- local unityArmature = propAniItem:GetComponentInChildren(TypeArmature)
                -- DragonBonesUtil.AddEventListener(unityArmature, DragonBonesEventObject.COMPLETE, function() destroy(propAniItem, 0.1) end)
                -- DragonBonesUtil.Play(unityArmature, "newAnimation", 1)

                -- local ani = propAniItem.transform:Find("Item"):GetComponent("UISpriteAnimation")
                -- ani:Play()
                -- ani.onCompleted = function()
                --     destroy(propAniItem, 0.1)
                -- end
            end
    )
end

--处理短语聊天
function ChatModule.OnPhraseChat(chatData, index)
    --local strs = ChatModule.GetTextConfigByGender(chatData.gender)
    local strs = ChatModule.GetCommonQuickMessage(chatData.gender)
    local str = strs[index].text
    if IsFunction(popCallback) and IsString(str) then
        popCallback(chatData.formId, ChatTextShowTime, str)
    end
    --播放音效
    --AudioManager.PlaySound(chatConfig.audioBundle, strs[index].audio)
    AudioManager.PlaySound(CommonQuickMessageAudioBundle.Quick, strs[index].audio)
end

--处理文本输入聊天
function ChatModule.OnInuptChat(chatData)
    --显示语音气泡 arg.playerId : 玩家id 
    if IsFunction(popCallback) then
        popCallback(chatData.formId, ChatTextShowTime, chatData.content)
    end
end

--处理表情
function ChatModule.OnEmotionChat(chatData)
    ResourcesManager.LoadPrefab(BundleName.Chat, "Emotion" .. chatData.content, HandlerByStaticArg1(chatData, this.LoadEmotinChatResCallback))
end

--加载表情资源回调
function ChatModule.LoadEmotinChatResCallback(chatData, obj)
    if obj == nil then
        return
    end
    local emotionTra = obj.transform
    local emotionNode = playerInfos[chatData.formId].emotionNode

    if emotionTra ~= nil and emotionNode ~= nil then
        local item = CreateGO(emotionTra, emotionNode, "temEmotion")
        UIUtil.SetActive(item, true)
        UIUtil.SetActive(emotionNode, true)
        item.transform.localPosition = Vector3.zero
        --local itmeAni = item.transform:Find("Item"):GetComponent("UISpriteAnimation")
        --itmeAni:Play()

        destroy(item, emotionShowTime)

        Scheduler.scheduleOnceGlobal(
                function()
                    UIUtil.SetActive(emotionNode, false)
                end,
                emotionShowTime
        )
    end
end


--当语音下载成功,写入本条本地链接
function ChatModule.OnVoiceDown(chatDataUid, url)
    local chatData = ChatDataManager.GetHistoryDataByUid(chatDataUid)
    if chatData ~= nil then
        chatData.localurl = url
    end
end

--语音开始播放
function ChatModule.OnVoicePlay(arg)
    local chatData = ChatDataManager.GetHistoryDataByUid(arg.chatDataUid)
    if chatData == nil then
        LogError(">>>>>>>>>> ChatModule > OnVoicePlay 该语音不存在 uid=", arg.uId)
        return
    end
    --显示语音气泡 arg.playerId : 玩家id    chatData.duration : 毫秒
    if IsFunction(voicePopCallback) then
        voicePopCallback(chatData.formId, chatData.duration / 1000)
    else
        --如果没有气泡，显示文本
        if IsFunction(popCallback) then
            popCallback(chatData.formId, chatData.duration / 1000, "正在讲话...")
        end
    end
end

--根据性别获取文本
function ChatModule.GetTextConfigByGender(gender)
    return chatConfig.textChatConfig[chatConfig.languageType][gender]
end

function ChatModule.GetCommonQuickMessage(gender)
    return CommonQuickMessage[LanguageType.putonghua][Global.GenderType.Male]
end

--==============================================龙骨动画使用示例Start=========================================
local unityArmature = nil
--测试龙骨动画
function ChatModule.TestPlayDragonBonesAnimation()
    local assert = ResourcesManager.LoadPrefabBySynch(BundleName.Chargingprops, "WealthGod")
    local go = CreateGO(assert, uiMgr:GetUILayer(5), "1")
    UIUtil.SetLocalPosition(go, 0, 0, 0)

    unityArmature = go.transform:Find("Armature"):GetComponent("UnityArmatureComponent")

    --注册回调 complete 注册类型 固定返回两个参
    -- unityArmature:AddDBEventListener(TestDragonBonesEventObject.COMPLETE, HandlerByStaticArg2({item = go}, this.OnCompleteAnimator))
    --参数：
    --1: <param name="animationName">- 动画数据名称。 （如果未设置，则播放默认动画，或将暂停状态切换为播放状态，或重新播放之前播放的动画）</param>
    --2: <param name="playTimes">- 循环播放次数。 [-1: 使用动画数据默认值, 0: 无限循环播放, [1~N]: 循环播放 N 次] （默认: -1）</param>
    -- unityArmature.animation:Play("newAnimation", 1)
    DragonBonesUtil.AddEventListener(unityArmature, TestDragonBonesEventObject.COMPLETE, HandlerByStaticArg2({ item = go }, this.OnCompleteAnimator))
    DragonBonesUtil.Play(unityArmature, "newAnimation", 1)
end

function ChatModule.TestJixuDragonBonesAnimation()
    --如果暂停时，不传参，为继续播放
    -- unityArmature.animation:Play()
    DragonBonesUtil.UnPause(unityArmature)
end

function ChatModule.TestStopDragonBonesAnimation()
    --暂停动画
    -- unityArmature.animation:Stop()
    DragonBonesUtil.Stop(unityArmature)
end

function ChatModule.OnCompleteAnimator(arg, str, eventObject)
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>  播放完成", str, arg)
    destroy(arg.item)
end
--==============================================龙骨动画使用示例End=========================================
return ChatModule
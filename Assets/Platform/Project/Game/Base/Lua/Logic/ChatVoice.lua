-- 管理器--
ChatVoice = {
    canStartClick = true,
    --录制超时时间
    recordInteval = 16,
}
local this = ChatVoice

local voice

-- 语言列表，存储语言对象，包括玩家信息等
local voiceList = {}
-- 正在播放的ID
local playingId = nil
-- 准备播放的列表
local playingList = {}
-- 播放超时监听
local playTimer = nil
-- 播放超时时长，单位秒，因限制的最长录音时长为60，所以此处取61
local playInteval = 16
--录制计时器，用于处理录制超时
local recordTimer = nil
-- 正在播放的玩家id
local playerSeatid = nil
--上传列表
local updateVoiceList = {}
--缓存本地地址
local localPath = Application.persistentDataPath .. "/Voice/";
--是否初始化成功
local isInitSucceed = false
--appKey
local appKey = 1003727

--上传方法
local UploadFileRequest = nil
--下载方法
local DownLoadFileRequest = nil

--初始化，id为玩家ID
function ChatVoice.Init()
    Log("初始化ChatVoice")

    --初始化存储桶
    if AppConfig.VoiceUpType == Global.VoidUploadType.Tencent then
        TencentApiMgr.Init(localPath)
        UploadFileRequest = TencentApiMgr.UploadFileRequest
        DownLoadFileRequest = TencentApiMgr.DownLoadFileRequest
    else
        QiNiuApiMgr.Init(localPath)
        UploadFileRequest = QiNiuApiMgr.UploadFileRequest
        DownLoadFileRequest = QiNiuApiMgr.DownLoadFileRequest
    end

    voice = YunWaSDK.Instance
    voice:YunWaInit(appKey, function(isSucceed)
        if isSucceed == 0 then
            Log(">>>>>>>>>>>>>>>>>>>>  初始化成功，开始登录》》》》》")
            this.Login()
            isInitSucceed = true
        else
            isInitSucceed = false
        end
    end)
end

--登录
function ChatVoice.Login()
    Log("登录ChatVoice")
    local name = UserData.GetName()
    local uId = UserData.GetUserId()
    voice:YunWaLogin(name, uId, this.LoginCallBack)
end

--登录回调
function ChatVoice.LoginCallBack(str)
    Log("{>>>>>>>>>>>>>>>>>>>>>>> LoginCallBack  登录回调")
    local data = ObjToJson(str)
    if data.result == 0 then
        -- Log("{>>>>>>>>>>>>>>>>>>>>>>> 登录成功")
    else
        -- Log("{>>>>>>>>>>>>>>>>>>>>>>> 登录失败")
    end
end

--================================================================
--播放超时
function ChatVoice.CheckPlayTimer(time)
    if time ~= nil and tonumber(time) > 0 then
        playInteval = tonumber(time) / 1000
    else
        playInteval = 15
    end

    if playTimer then
        playTimer:Stop()
    end
    playTimer = Timer.New(this.PlayTimeOut, playInteval, 1)
    playTimer:Start()
end

--播放超时处理
function ChatVoice.PlayTimeOut()
    LogWarn("ChatVoice", "超时等待，不管当前有么有东西在播放超时就得结束")
    this.OnVoicePlayCallback("")
end

function ChatVoice.StopPlayTimer()
    if playTimer then
        playTimer:Stop()
    end
    playTimer = nil
end

--================================================================
--录音超时
function ChatVoice.CheckRecordTimer()
    if recordTimer then
        recordTimer:Stop()
    end
    recordTimer = Timer.New(this.RecordTimeout, this.recordInteval, 1)
    recordTimer:Start()
end

--录制超时则取消
function ChatVoice.RecordTimeout()
    Toast.Show("录制超时，已发送")
    this.RecordEnd()
    ChatModule.CloseSpeechUI()
end

function ChatVoice.StopRecordTimer()
    if recordTimer then
        recordTimer:Stop()
    end
    recordTimer = nil
end

--================================================================
--开始录音
function ChatVoice.RecordStart()
    if not isInitSucceed then
        return
    end

    voice:RecordStopRequest(2)
    --开始录制之前取消有可能在录制的情况
    this.canStartClick = false

    Log("ChatVoice", ">> ========== > ChatVoice.RecordStart")
    voice:RecordStartRequest(this.OnVoiceStopCallback)
    this.CheckRecordTimer()
    AudioManager.PauseBackgroud()
end

--结束录音
function ChatVoice.RecordEnd()
    --继续播放bgm
    AudioManager.UnPauseBackgroud()

    if not isInitSucceed then
        return
    end

    if this.canStartClick then
        return
    end
    this.canStartClick = true

    this.StopRecordTimer()

    Log("ChatVoice", ">> ========== > ChatVoice.RecordEnd")

    voice:RecordStopRequest(1)

end

function ChatVoice.RecordCancel()
    --继续播放bgm
    AudioManager.UnPauseBackgroud()

    if not isInitSucceed then
        return
    end

    if this.canStartClick then
        return
    end
    this.canStartClick = true

    this.StopRecordTimer()

    Log("ChatVoice", ">> ========== > ChatVoice.RecordCancel")

    voice:RecordStopRequest(2)
end

--================================================================
--播放语音，并保存数据，fileName语音文件名 ,playerId为发送玩家 speakTime:说话时间 arg:在执行委托时发送的参数
function ChatVoice.PlayVoice(fileName, playerId, speakTime, arg)
    if not isInitSucceed then
        return
    end

    if voiceList[fileName] ~= nil then
        -- 相同的fid被服务器推了多次，不再处理
        Log("ChatVoice", ">> ========== > the same fileName.")
        return
    end
    local speakTime = tonumber(speakTime)

    if speakTime == nil or speakTime == "" then
        speakTime = 0
    end

    voiceList[fileName] = {}
    voiceList[fileName].player = playerId
    voiceList[fileName].speakTime = speakTime

    DownLoadFileRequest(fileName, HandlerByStaticArg2({ arg = arg }, this.OnVoiceDownFileCallback))
end

--当前播放语音 localUrl:下载的语音在本地的路径地址 fileName:玩家id-文件id  arg:传参 isShowPop:是否显示气泡
function ChatVoice.Play(localFilePath, fileName, arg, isShowPop)
    AudioManager.UnPauseBackgroud()
    if not isInitSucceed then
        return
    end

    local playerId = string.split(fileName, "-")[1]
    -- if playingId == nil then
    local playerId = tonumber(playerId)
    if playerId == nil then
        LogError(">>>>>>>> ChatVoice >  Play PlayerId is err")
        return
    end
    Log("ChatVoice", ">> ========== > 开始播放语音 > ", localFilePath)
    if isShowPop == nil or isShowPop then
        Event.Brocast(CMD.Game.VoicePlay, { playerId = playerId, chatDataUid = arg })
    end
    AudioManager.PauseBackgroud()
    voice:RecordStartPlayRequest(localFilePath, "", this.OnVoicePlayCallback)
end

-- 停止播放语言，需要考虑是否把播放中列表的也停止
function ChatVoice.Stop()
    if voice ~= nil then
        voice:RecordStopPlayRequest()
    end
    this.StopRecordTimer()
end

function ChatVoice.Close()
    --停止语音播放
    this.Stop()
    --清空数据
    this.CleanVoice()
end

-- 清空语音
function ChatVoice.CleanVoice()
    --清除本地语音文件
    this.ClearLocalVoiceFile()
    voiceList = {}
    playingList = {}
    playingId = nil
    playerSeatid = nil
    this.canStartClick = true
    updateVoiceList = {}
    --继续播放bgm
    AudioManager.UnPauseBackgroud()
end


-- ======================================
-- 回调函数
-- ======================================
--停止录音回调
function ChatVoice.OnVoiceStopCallback(str, isUpdateFile)
    local data = JsonToObj(str)
    Log(">>>>>>>>>>>>>>>>      停止录音回调 ： ", str, isUpdateFile)

    if data.result ~= 0 then
        SendEvent(CMD.Game.MicrophoneFailure, true)
        Log(">>>>>>>>>>>>>>>  停止录音失败 msg:", data.msg)
        if data.result == 1911 then
            --麦克风权限开启失败
            Toast.Show("麦克风开启失败，请稍后再试")
        end
        return
    end

    --判断录音时间
    if data.time <= 1000 then
        Toast.Show("说话时间太短")
        return
    end

    --上传
    if tonumber(isUpdateFile) == 1 then
        Log(">>>>>>>>>>>>>>>>>>     录音成功，上传  文件地址:", data.strfilepath)
        local paths = string.split(data.strfilepath, "/")
        local filename = UserData.GetUserId() .. "-" .. paths[#paths]

        updateVoiceList[filename] = {
            time = data.time
        }

        UploadFileRequest(data.strfilepath, filename, this.OnVoiceUploadFileCallback)
    else
        Log(">>>>>>>>>>>>>>>>>>     录音成功，不上传 文件地址:", data.strfilepath)
    end
end

--上传录音回调
function ChatVoice.OnVoiceUploadFileCallback(code, key)
    Log(">>>>>>>>>>>>>>> code ：", code, " key :", key)
    this.canStartClick = true

    if tonumber(code) == 0 then
        local time = 0
        if updateVoiceList[key] ~= nil then
            time = updateVoiceList[key].time
        end
        --上传成功
        Event.Brocast(CMD.Game.VoiceUpload, { fileName = key, speekTime = time })
    else
        --上传失败
    end
    updateVoiceList[key] = nil
end

--下载录音回调  arg传参，code 是否成功，localFilePath 下载文件在本地的文件路径
function ChatVoice.OnVoiceDownFileCallback(arg, code, localFilePath)
    local fileName = ""

    if AppConfig.VoiceUpType == Global.VoidUploadType.Tencent then
        fileName = localFilePath
        localFilePath = TencentApiMgr.GetVoiceDataPath() .. localFilePath
        Log(">>>>>>>>>>>>>>>>      腾讯下载录音回调 ： code=", code, " ", localFilePath)
    else
        local paths = string.split(localFilePath, "/")
        fileName = paths[#paths]
        Log(">>>>>>>>>>>>>>>>      七牛下载录音回调 ： code=", code, " ", localFilePath)
    end

    if tonumber(code) == 0 then
        SendMsg(CMD.Game.VoiceDown, arg.arg, localFilePath)
        this.Play(localFilePath, fileName, arg.arg, true)
        voiceList[fileName].localFilePath = localFilePath
    else
        voiceList[fileName] = nil
    end
end

--播放回调
function ChatVoice.OnVoicePlayCallback(arg)
    AudioManager.UnPauseBackgroud()

    Event.Brocast(CMD.Game.VoicePlayEnd, { playerId = playingId })
    this.StopRecordTimer()
end

--清除本地语音文件
function ChatVoice.ClearLocalVoiceFile()
    Util.DeleteFilesOnFolder(localPath)
end

return ChatVoice
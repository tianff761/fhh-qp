ChatDataManager = {}
local this = ChatDataManager

--当前聊天id
local curChatId = 0
--=================================历史记录Start================================================
--单条聊天格式
SingChatData = {  
    uid = nil,         --历史记录唯一ID(清空历史记录时，归0)
    type = nil,       --chatDataType
    formId = nil,     --来自玩家Id(哪个玩家发的)
    toId = nil,       --发送给哪个玩家
    content = nil,    --收到聊天的内容
    time = nil,       --收到聊天的时间
    duration = nil,   --本次聊天多长时间(暂用于语音时间)
    localurl = nil,   --本地保存位置
    url = nil,        --远端保存位置
}

SingChatData = Class(SingChatData)
function  SingChatData:ctor()
    curChatId = curChatId + 1
    self.uid = curChatId
    this.AddHistoryData(self)
end

function SingChatData:SetData(time,name, type,  fId, content, speekTime, gender)
    self.type = type
    self.formId = fId
    self.content = content
    self.time = os.date("%Y-%m-%d %H:%M:%S",time)
    self.duration = speekTime
    self.gender = gender
    self.name = name
end

--聊天记录
local chatHistoryData = {}

--历史记录保存条数  --0 表示无限
local historyCount = 0

--增加历史记录
function ChatDataManager.AddHistoryData(data)
    table.insert(chatHistoryData, data)

    if historyCount > 0 then
        --移除超过条数后最前面的历史记录
        if #chatHistoryData > historyCount then
            local count = #chatHistoryData - historyCount
            for i = 1, count do
                SendEvent(CMD.Game.UpdateHistoryData, {chatData = chatHistoryData[1], type = 2})
                this.DeleteHistoryData(1)
            end
        end
    end
end


--删除历史记录 传入删除第几条
function ChatDataManager.DeleteHistoryData(index)
    if index <= #chatHistoryData then
        table.remove(chatHistoryData, index)
    end
end

--获取历史记录数量
function ChatDataManager.GetHistoryCount()
    return #chatHistoryData
end

--获取历史记录 传入获取第几条历史记录
function ChatDataManager.GetHistoryData(index)
    return chatHistoryData[index]
end

--通过唯一id获取记录
function ChatDataManager.GetHistoryDataByUid(uid)
    for i = 1, #chatHistoryData do
        if chatHistoryData[i].uid == uid then
            return chatHistoryData[i]
        end
    end
end

--清空历史记录
function ChatDataManager.ClearHistoryData()
    chatHistoryData = {}
    curChatId = 0
end
--=================================历史记录End================================================
--=================================语音相关Start==============================================
--播放语音，通过历史记录下标
function ChatDataManager.PlayVoiceByIndex(index)
    local chatData = this.GetHistoryDataByUid(index)
    if chatData == nil then
        LogError(">>>>>>>>>> ChatDataManager > PlayVoiceByIndex > 传入下标错误，获取不到该记录"..index)
        return
    end
    if chatData.type ~= ChatDataType.voiceChat then
        LogError(">>>>>>>>>> ChatDataManager > PlayVoiceByIndex > 传入下标错误，该记录不是语音"..index)
        return
    end
    
    ChatVoice.Play(chatData.localurl, chatData.content, chatData.uid, false)
end



return ChatDataManager
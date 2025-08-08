RedPointMgr = {}
--k:RedPointType类型   value:数组，如果是大联盟和俱乐部，数组你们存储相关组织ID
RedPointMgr.redPointDatas = nil

local this = RedPointMgr

--获取类型获取小红点
function RedPointMgr.GetRedPointByType(redPointType)
    if this.redPointDatas ~= nil then
        return this.redPointDatas[redPointType]
    end
    return nil
end

--通过值获取小红点
function RedPointMgr.GetRedPointByValue(redPointType, value)
    local ids = this.redPointDatas[redPointType]
    Log("GetRedPointByValue",GetTableString(this.redPointDatas), ids, value, type(value))
    if IsTable(ids) then
        for _, v in pairs(ids) do
            if v == value then
                return true
            end
        end
    end
    return nil
end

--通过类型删除小红点
function RedPointMgr.RemoveRedPointByType(redPointType)
    this.redPointDatas[redPointType] = nil
end

--通过值删除小红点
function RedPointMgr.RemoveRedPointByValue(redPointType, value)
    local vals = this.redPointDatas[redPointType]
    if IsTable(vals) then
        for k, v in pairs(vals) do
            if v == value then
                vals[k] = nil
                if GetTableSize(vals) <= 0 then
                    this.redPointDatas[redPointType] = nil
                end
                break
            end
        end
    end
end

--清除所有红点
function RedPointMgr.ClearAllRedPointDatas()
    this.redPointDatas = {}
end

--解析所有红点
function RedPointMgr.ParseRedPointsByData(data)
    this.ClearAllRedPointDatas()
    for k, v in pairs(data) do
        this.redPointDatas[k] = v
    end
    SendEvent(CMD.Game.UpdateRedPointTips)
end

--添加单条红点数据
function RedPointMgr.AddRedPointData(data)
    local addOne = function (k, v)
        local val = this.redPointDatas[k]
        if val == nil then
            val = {}
            this.redPointDatas[k] = val
        end
        if v ~= nil then
            for k1, v1 in pairs(v) do
                val[k1] = v1
            end
        end
    end
    if data ~= nil then
        for k, v in pairs(data) do
            addOne(k, v)
        end
    end
    SendEvent(CMD.Game.UpdateRedPointTips)
end

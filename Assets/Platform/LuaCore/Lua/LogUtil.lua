LogUtil = {}
LogUtil.IsPrintLog = true
function isKey(str)
    if str ~= "class" and string.find(str, "__") == nil then
        return true
    end
    return false
end



function dealTable(table,level)
    if table ~= nil then
        local t = {}
        for k, v in pairs(table) do
            if isKey(k) then
                if IsNumber(v) or IsString(v) or IsBool(v) then
                    t[tostring(k)] = v
                elseif IsTable(v) then
                    if (level>5) then
                        t[k] = tostring(v);
                    else 
                        t[k] = dealTable(v,level+1);
                    end 
                elseif IsUserdata(v) then
                    t[k] = tostring(v)
                end
            end
        end
        return t
    end
    return nil
end

function dealLogTable(table)
    local t = {}
    for k0, v0 in pairs(table) do
        if isKey(k0) then
            if IsNumber(v0) or IsString(v0) or IsBool(v0) then
                t[tostring(k0)] = v0
            elseif IsTable(v0) then
                t[k0] = dealTable(v0,1)
            elseif IsUserdata(v0) then
                t[k0] = tostring(v0)
            end
        end
    end
    return ObjToJson(t)
end

function getLogString(...)
    -- local time = os.date("%Y:%m:%d %H:%M:%S  ", os.time())
    local trace = '\n\n' .. debug.traceback()
    local args = { ... }
    local log = ''
    TryCatchCall(function()
        for k, arg in pairs(args) do
            if IsTable(arg) then
                log = log .. dealLogTable(arg) .. '->'
            elseif arg == nil then
                log = log .. 'nil->'
            elseif IsNumber(arg) or IsString(arg) or IsBool(arg) then
                log = log .. tostring(arg) .. '->'
            elseif IsUserdata(arg) then
                log = log .. tostring(arg) .. '->'
            else
                log = log .. tostring(arg) .. '->'
            end
        end
    end)

    return log .. trace
end

--输出日志--
function Log(...)
    if LogUtil.IsPrintLog then
        Util.Log(getLogString(...))
    end
end

--错误日志--
function LogError(...)
    if LogUtil.IsPrintLog then
        local logStr = getLogString(...)
        Util.LogError(logStr)
    end
    -- if AppConfig ~= nil and IsString(AppConfig.LogUploadUrl) then
    --     local www = WWW(AppConfig.LogUploadUrl..'?cmd=1&log='..UserData.GetUserId()..":"..logStr)
    --     if www ~= nil then
    --         Scheduler.scheduleOnceGlobal(function()
    --             www:Dispose()
    --         end,3)  
    --     end
    -- end
end

function LogUpload(text)
    -- TryCatchCall(function ()
    --     if AppConfig ~= nil and IsString(AppConfig.LogUploadUrl) then
    --         local ms = os.timems()
    --         local hm = ms % 1000
    --         local time = os.date("%H:%M:%S", ms / 1000)
    --         Log("上传:", text)
    --         coroutine.start(function ()
    --             local www = WWW(AppConfig.LogUploadUrl..'?cmd=1&log='..time.."."..hm..":"..text.."&id="..UserData.GetUserId())
    --             coroutine.www(www);
    --             Log("上传结束:", text, www.error)
    --         end)
    --     end
    -- end)
end

--警告日志--
function LogWarn(...)
    if LogUtil.IsPrintLog then
        Util.LogWarning(getLogString(...))
    end
end

function InternalGetIndentSpace(indent)
    local str = ""
    for i = 1, indent do
        str = str .. "  "
    end
    return str
end


function InternalNewLine(indent)
    local str = "\n"
    str = str .. InternalGetIndentSpace(indent)
    return str
end

function InternalCreateKeyVal(key, value, bline, deep, indent)
    local str = "";
    if (bline[deep]) then
        str = str .. InternalNewLine(indent)
    end
    if type(key) == "number" then
        str = str .. key .. "  =  "
    elseif type(key) == "string" then
        str = str .. '"'..key .. '"  =  '
    end
    if type(value) == "table" then
        str = str .. InternalGetTableStr(value, bline, deep + 1, indent)
    elseif type(value) == "string" then
        str = str .. '"' .. tostring(value) .. '"'
    else
        str = str .. tostring(value)
    end
    str = str .. ","
    return str
end

function InternalGetTableStr(t, bline, deep, indent)
    local str
    if bline[deep] then
        str = "{" .. InternalNewLine(indent)
        indent = indent + 4
    else
        str = "{"
    end

    for key, val in pairs(t) do
        str = str .. InternalCreateKeyVal(key, val, bline, deep, indent)
    end
    if bline[deep] then
        indent = indent - 4
        str = str .. InternalNewLine(indent) .. "}"
    else
        str = str .. "}"
    end
    return str
end


function GetTableString(t)
    if IsTable(t) then
        return InternalGetTableStr(t, {true, true, true }, 1, 0)
    end
    return "nil table "
end

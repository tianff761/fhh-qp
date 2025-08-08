--lua基本类型判断
function IsNil(luaObj)
    if type(luaObj) == "nil" then
        return true
    else
        return false
    end
end

--lua基本类型判断
function IsString(luaObj)
    if type(luaObj) == "string" then
        return true
    else
        return false
    end
end

--lua基本类型判断
function IsTable(luaObj)
    if type(luaObj) == "table" then
        return true
    else
        return false
    end
end

--判断C#组件是否是空
function IsNull(obj)
    if obj == nil then
        return true
    end
    if tostring(obj) == "null" or tostring(obj) == "Null" or tostring(obj) == "" then
        return true
    end
    return false
end

--lua基本类型判断
function IsFunction(luaObj)
    if type(luaObj) == "function" then
        return true
    else
        return false
    end
end

--lua基本类型判断
function IsNumber(luaObj)
    if type(luaObj) == "number" then
        return true
    else
        return false
    end
end

function IsUserdata(luaObj)
    if type(luaObj) == "userdata" then
        return true
    else
        return false
    end
end

function IsBool(luaObj)
    if type(luaObj) == "boolean" then
        return true
    else
        return false
    end
end

local clone = function(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--Create an class.
function Class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k, v in pairs(super) do
                cls[k] = v
            end
            cls.__create = super.__create
            cls.super = super
        else
            cls.__create = super
        end

        cls.ctor = function()
        end
        cls.__cname = classname
        cls.__ctype = 1

        function cls.New(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k, v in pairs(cls) do
                instance[k] = v
            end
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    else
        -- inherited from Lua Object
        if super then
            cls = clone(super)
            cls.super = super
        else
            cls = { ctor = function()
            end }
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.New(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

--创建panel类
function ClassPanel(className)
    return Class(className, BasePanel)
end

--创建LuaComponent类
function ClassLuaComponent(className)
    return Class(className, BaseLuaComponent)
end

function error(msg)
    Util.LogError("---------------------------------------------------")
    LogError("Error:", msg)
    Util.LogError("---------------------------------------------------")
end

function TryCatchCall(func, a1, a2, a3, a4, a5, a6, a7, a8)
    local dfunc = function()
        return func(a1, a2, a3, a4, a5, a6, a7, a8)
    end
    return xpcall(dfunc, error)
end

--lua带参类方法包装为静态无参方法
function HandlerByStatic(target, method, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    if IsTable(target) and IsFunction(method) then
        return function()
            return method(target, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
        end
    else
        LogError("function HandlerByStatic(target, method,...): 参数错误")
    end
end

--lua带参类方法包装为静态带参方法
function HandlerByStaticArg1(target, method, a1, a2, a3, a4, a5, a6)
    if IsTable(target) and IsFunction(method) then
        return function(arg1)
            return method(target, arg1, a1, a2, a3, a4, a5, a6)
        end
    else
        LogError("function HandlerByStaticArg1(target, method,...): 参数错误")
    end
end

--lua带参类方法包装为静态带两个参方法
function HandlerByStaticArg2(target, method, a1, a2, a3, a4, a5, a6)
    if IsTable(target) and IsFunction(method) then
        return function(arg1, arg2)
            return method(target, arg1, arg2, a1, a2, a3, a4, a5, a6)
        end
    else
        LogError("function HandlerByStaticArg2(target, method,...): 参数错误")
    end
end


--lua带参方法包装为无参方法
function HandlerArgs(method, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    if IsFunction(method) then
        return function()
            return method(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
        end
    else
        LogError("function HandlerArgs(method,...): 参数错误")
    end
end

--清除所有子节点
function ClearChildren(tran)
    if IsNull(tran) then
        LogError("参数错误")
        return
    end
    local count = tran.childCount
    if count > 0 then
        for i = 0, count - 1 do
            destroy(tran:GetChild(i).gameObject)
        end
    end
end

function ClearChildrenImmediately(tran)
    if not IsNull(tran) then
        local count = tran.childCount
        if count > 0 then
            local children = {}
            for i = 0, count - 1 do
                table.insert(children, tran:GetChild(i))
            end

            for _, child in pairs(children) do
                UIUtil.SetActive(child, false)
                child:SetParent(nil)
                destroy(child.gameObject)
            end
        end
    end
end

--隐藏所有子节点
function HideChildren(tran)
    if IsNull(tran) then
        LogError("参数错误")
        return
    end
    local count = tran.childCount
    if count > 0 then
        for i = 0, count - 1 do
            tran:GetChild(i).gameObject:SetActive(false)
        end
    end
end

--获取表长度
function GetTableSize(tab)
    if not IsTable(tab) then
        return 0
    end
    local len = 0
    for k, v in pairs(tab) do
        len = len + 1
    end
    return len
end

function AddLuaComponent(gameObject, lua)
    if IsNull(gameObject) or not IsString(lua) or #lua <= 0 then
        LogError("参数错误")
        return
    end
    return Util.AddLuaComponent(gameObject, lua)
end

function GetLuaComponent(gameObject, lua)
    if IsNull(gameObject) or not IsString(lua) or #lua <= 0 then
        LogError("参数错误")
        return
    end
    return Util.GetLuaComponent(gameObject, lua)
end

--Json
function JsonToObj(Jsontext)
    if Jsontext ~= nil then
        return json.decode(Jsontext)
    else
        return {}
    end
end

function ObjToJson(Table)
    return json.encode(Table)
end

function DestroyObj(obj)
    GameObject.Destroy(obj)
end

function NewObject(prefab, parent, instantiateInWorldSpace)
    instantiateInWorldSpace = instantiateInWorldSpace or false
    if parent then
        return GameObject.Instantiate(prefab, parent, instantiateInWorldSpace)
    else
        return GameObject.Instantiate(prefab)
    end
end

function Find(path)
    return GameObject.Find(path)
end

--添加消息事件监听  msgId:自动转为字符串
function AddMsg(msgId, hander)
    --Log("添加事件消息：", msgId, "    ", hander)
    Event.AddListener(tostring(msgId), hander)
end

function AddEventListener(msgId, hander)
    Event.AddListener(tostring(msgId), hander)
end

function RemoveEventListener(msgId, hander)
    --Log("RemoveMsg事件消息：", msgId, "    ", hander)
    Event.RemoveListener(tostring(msgId), hander)
end

function SendEvent(msgId, ...)
    --Log("发送事件消息：", msgId, "    ", ...)
    Event.Brocast(tostring(msgId), ...)
end

--移除消息事件监听  msgId:自动转为字符串
function RemoveMsg(msgId, hander)
    --Log("RemoveMsg事件消息：", msgId, "    ", hander)
    Event.RemoveListener(tostring(msgId), hander)
end
--发送消息事件  msgId:自动转为字符串
function SendMsg(msgId, ...)
    -- Log("发送事件消息：", msgId, "    ", ...)
    Event.Brocast(tostring(msgId), ...)
end

--发送Http消息
function SendHttpMsg(msgId, obj, dontShowLoading)
    HttpApi.Request(msgId, obj, dontShowLoading)
end

--发送Tcp消息
function SendTcpMsg(msgId, obj)
    Network.SendJsonObj(msgId, obj)
end

--设置本地保存
function SetLocal(key, value)
    PlayerPrefs.SetString(tostring(key), tostring(value))
end

--获取本地保存
function GetLocal(key, default)
    if PlayerPrefs.HasKey(key) then
        return PlayerPrefs.GetString(key)
    else
        return default
    end
end

-- split，返回一个table
function string.split(s, p)
    if s == nil then
        return nil
    end
    if p == nil then
        return s
    end
    local rt = {}
    s = tostring(s)
    string.gsub(
            s,
            "[^" .. p .. "]+",
            function(w)
                table.insert(rt, w)
            end
    )
    return rt
end

--是否为空
function string.IsNullOrEmpty(str)
    return str == nil or str == ""
end

--去除空格
function string.Trim(str)
    if str == nil then
        return nil
    else
        return (string.gsub(str, " ", ""))
    end
end

--将beInsertedTable表元素插入到targetTable中的最后位置，抛弃beInsertedTable中的key值，只插入value为基本类型的元素
function table.InsertTableToEnd(targetTable, beInsertedTable)
    if IsTable(targetTable) and IsTable(beInsertedTable) then
        for k, v in pairs(beInsertedTable) do
            if not IsFunction(v) then
                table.insert(targetTable, v)
            end
        end
    end
end

function table.ContainValue(tab, val)
    if IsTable(tab) and val ~= nil then
        for k, v in pairs(tab) do
            if val == v then
                return true
            end
        end
    end
    return false
end

--获取格式化字符串
local format = string.format
function GetS(key, ...)
    if not key then return end

    --使用pcall进行调用，方便错误打印
    local flag, msg = pcall(format, key, ...)
    if not flag then
        local err = format([[语言ID: 语言所需参数与实际参数不符\n [key:%s]\n param sum:%d]], key, select('#', ...))
        LogError(err)
        return key
    end
    return msg
end

------------------------------------------------------------------
------------------------------数值方法-----------------------------
------------------------------------------------------------------
--
function math.NewToNumber(str)
    --local n = 2
    --local startIndex, endIndex = string.find(str, ".", 1, true)
    --if startIndex and startIndex > 0 then
    --    if startIndex + n < string.len(str) then
    --        return tonumber(string.sub(str, 1, startIndex + n)) -- 两位精度是3
    --    else
    --        return tonumber(string.sub(str, 1, string.len(str)))
    --    end
    --else
    return tonumber(str)
    --end
end

---优化随机数
function math.BetterRandom(m, n)
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    return math.random(m, n)
end

---插值函数
function math.Lerp(from, to, time)
    return from + (to - from) / time
end

--保留小数位数，有四舍五入
function math.Round(num, n)
    if type(num) ~= "number" then
        return num
    end

    n = n or 0
    n = math.floor(n)
    local fmt = "%." .. n .. "f"
    local result = tonumber(string.format(fmt, num))

    return result
end

--保留小数位数，返回字符串型，有四舍五入
function math.RoundToString(num, n)
    if type(num) ~= "number" then
        return num
    end

    n = n or 0
    n = math.floor(n)
    if n < 0 then
        n = 0
    end
    local fmt = "%." .. n .. "f"

    return string.format(fmt, num)
end

--保留小数位数，返回字符串；正数向下取，负数的数字向上去
function math.PreciseDecimal(num, n)
    if type(num) ~= "number" then
        return num
    end
    n = n or 0
    n = math.floor(n)
    if n < 0 then
        n = 0
    end
    local decimal = 10 ^ n
    local temp = 0
    local floorValue = 0
    if num < 0 then
        temp = num * decimal * -1
        floorValue = math.ceil(temp)
        temp = -floorValue
    else
        --加上一个小数，用于处理浮点数比整数小的问题
        temp = num * decimal + (1 / (decimal * 100))
        floorValue = math.floor(temp)
        temp = floorValue
    end

    local fmt = "%." .. n .. "f"
    return string.format(fmt, temp / decimal)
end

--保留小数后转换成数字
function math.ToRound(num, n)
    return tonumber(math.PreciseDecimal(num, n))
end

------------------------------------------------------------------
--删除GameObject
function destroy(obj, time)
    if obj == nil then
        return
    end
    if time ~= nil then
        GameObject.Destroy(obj, time)
    else
        GameObject.Destroy(obj)
    end
end

--转为Boolean类型
function toboolean(v)
    if v == nil then
        return false
    end

    local str = tostring(v)
    if str == "False" or str == "false" or str == "" then
        return false
    end
    return true
end

-- 创建并初始化游戏对象
function CreateGO(prefab, parentTrans, name)
    local obj = GameObject.Instantiate(prefab)
    InitGO(obj, parentTrans, name)
    return obj.gameObject
end

-- 初始化游戏对象
function InitGO(go, parentTrans, name)
    if parentTrans ~= nil then
        go.transform:SetParent(parentTrans)
    end
    go.transform.localScale = Vector3.one

    if name ~= nil then
        go.gameObject.name = name
    end

    go.gameObject:SetActive(true)
end

--销毁并清空对象列表
function ClearObjList(list)
    if list == nil then
    else
        for k, v in pairs(list) do
            if v.gameObject ~= nil then
                GameObject.Destroy(v.gameObject)
            end
        end
    end
    return {}
end

-- 复制一个table, 保证原table不被修改
local tbRecord = {}
function CopyTable(st, isDeep)
    local tab = {}
    st = st or {}
    if not isDeep then
        tbRecord = {}
    end
    tbRecord[st] = tab
    for k, v in pairs(st or {}) do
        if tostring(k) ~= "__index" and type(v) == "table" then
            if tbRecord[v] ~= nil then
                tab[k] = tbRecord[v]
            else
                tab[k] = CopyTable(v, true)
            end
        elseif tostring(k) ~= "__index" and type(v) ~= "function" then
            tab[k] = v
        end
    end
    return tab
end

function os.timems()
    return math.floor(Util.GetTime())
end

function ClearMemory()
    Log("*******************当前Lua内存:", collectgarbage("count"))
    collectgarbage("collect")
    Util.ClearMemory()
    Log("*******************释放后Lua内存:", collectgarbage("count"))
end

--设置按钮点击事件执行时的一个调用。用途：为所有点击统一添加点击声音
function SetBtnClickCallback(callback)
    if IsFunction(callback) then
        btnClickCallback = callback
    end
end

--获取随机数
function GetRandom(min, max)
    math.randomseed(os.timems())
    return math.random(min, max)
end

---------------------------------------------------------YWQ---新增-------------------------------
--计算 UTF8 字符串的长度，每一个中文算一个字符
--local input = "你好World"
--print(GetUTF8Length(input))
-- 输出 7
function GetUTF8Length(input)
    if input == nil then
        return 0
    end
    local len = string.len(input)
    local left = len
    local cnt = 0
    local arr = { 0, 192, 224, 240, 248, 252 }
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

--重写中英文混合字符串截取（string.sub()截取中英文会造成乱码)
function SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = SubStringGetTotalIndex(str) + startIndex + 1
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = SubStringGetTotalIndex(str) + endIndex + 1
    end

    if endIndex == nil then
        return string.sub(str, SubStringGetTrueIndex(str, startIndex))
    else
        return string.sub(str, SubStringGetTrueIndex(str, startIndex), SubStringGetTrueIndex(str, endIndex + 1) - 1)
    end
end

--获取中英混合UTF8字符串的真实字符数量
function SubStringGetTotalIndex(str)
    local curIndex = 0
    local i = 1
    local lastCount = 1
    repeat
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount
        curIndex = curIndex + 1
    until (lastCount == 0)
    return curIndex - 1
end

function SubStringGetTrueIndex(str, index)
    local curIndex = 0
    local i = 1
    local lastCount = 1
    repeat
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount
        curIndex = curIndex + 1
    until (curIndex >= index)
    return i - lastCount
end

--返回当前字符实际占用的字符数
function SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte >= 192 and curByte <= 223 then
        byteCount = 2
    elseif curByte >= 224 and curByte <= 239 then
        byteCount = 3
    elseif curByte >= 240 and curByte <= 247 then
        byteCount = 4
    end
    return byteCount
end
--截取名称 若超过某文本框限制长度显示..
-- endIndex代表要显示的字符长度  不填截取长度默认截取5个字符串
function SubStringName(str, endIndex)
    local newStr = str
    local subLength = endIndex
    if subLength == nil then
        subLength = 7
    end
    if GetUTF8Length(str) > subLength then
        newStr = SubStringUTF8(str, 1, subLength) .. ".."
        -- newStr = SubStrName(str, subLength)
    end
    return newStr
end

--根据ascll码127为界，小于未一个字符，大于算两个截取
-- endIndex代表要显示的字符长度
function SubStrName(str, endIndex)
    local maxLen = endIndex * 2
    local len = 0
    local subLen = 0

    local systemStr = System.String.New(str)
    local strs = systemStr:ToCharArray()
    for i = 0, strs.Length - 1 do
        if len < maxLen then
            if strs[i] < 127 then
                len = len + 1
            else
                len = len + 2
            end
            subLen = i + 1
        else
            break
        end
    end

    local retrunStr = systemStr:Substring(0, subLen)
    if len >= maxLen then
        retrunStr = retrunStr .. ".."
    end
    return retrunStr
end

--设置富文本显示
function SetRichText(str, hexColor, size)
    local newStr = "<color=#" .. hexColor .. ">" .. str .. "</color>"
    if size ~= nil and type(size) == "number" then
        newStr = "<size=" .. size .. ">" .. "<color=#" .. hexColor .. ">" .. str .. "</color></size>"
    end
    return newStr
end


--检测货币单位，返回带单位的字符串
--保留两位小数，小数位置常显示，0也需要显示出来    
--两位小数以后的直接不显示
--四位数进阶    万 亿
--不满足万的全显示
--例如35226显示为3.52万
function CheckCurrencyUnit(currencyNum, n)
    local currency = math.ceil(currencyNum)
    n = n or 2
    if currency < 10000 then
        return currencyNum
    elseif currency < 100000000 then
        local temp = currency / 10000
        local words = "万"
        local result = ""
        if currency % 1000 == 0 then
            n = 1
        end
        if currency % 10000 ~= 0 then
            result = math.PreciseDecimal(temp, n) .. words
        else
            result = temp .. words
        end
        return result
    elseif currency < 1000000000000 then
        local words = "亿"
        local temp = currency / 100000000
        local result = ""
        if currency % 10000000 == 0 then
            n = 1
        end
        if currency % 100000000 ~= 0 then
            result = math.PreciseDecimal(temp, n) .. words
        else
            result = temp .. words
        end
        return result
    else
        local words = "千亿"
        local temp = currency / 100000000000
        local result = ""
        if currency % 100000000000 == 0 then
            n = 1
        end
        if currency % 100000000000 ~= 0 then
            result = math.PreciseDecimal(temp, n) .. words
        else
            result = temp .. words
        end
        return result
    end
end

--截取数字以万为单位 (如果是艺术字，则传true)
function CutNumber(num, isArtText)
    if type(num) ~= "number" then
        num = tonumber(num)
    end
    if num == nil then
        return ""
    end

    local lastTxt = ""
    if isArtText == nil or not isArtText then
        lastTxt = "万"
    else
        lastTxt = "W"
    end

    local score = ""
    local tempNum = num / 10000
    if math.abs(num) >= 10000000 then
        --大于1000w使用整数
        if num > 0 then
            score = math.floor(tempNum) .. lastTxt
        else
            score = "-" .. tostring(math.floor(math.abs(tempNum))) .. lastTxt
        end
    elseif math.abs(num) < 10000000 and math.abs(num) >= 100000 then
        --大于10万小于1000万保留一位小数
        score = math.PreciseDecimal(tempNum, 1) .. lastTxt
    elseif math.abs(num) < 100000 and math.abs(num) >= 10000 then
        --大于1万小于10万保留两位小数
        score = math.PreciseDecimal(tempNum, 2) .. lastTxt
    else
        score = tostring(num)
    end
    return score
end

--设置UI的X偏移
function SetGameObjectOffsetX(gameObject, offSetX)
    local rectTransform = gameObject:GetComponent("RectTransform")
    rectTransform.anchoredPosition = Vector2.New(rectTransform.anchoredPosition.x + offSetX, rectTransform.anchoredPosition.y)
end

local eventSystem = nil
local lockScreenTimer = nil
--锁屏
function LockScreen(lockTime)
    LogError("<color=aqua>LockScreen</color>")
    if lockTime == nil or lockTime < 0.05 then
        LogError("LockScreen >>>>> lockTime is Nil or 0")
        return
    end

    --if lockScreenTimer ~= nil then
    --    lockScreenTimer:Stop()
    --    lockScreenTimer = nil
    --end

    if eventSystem == nil then
        eventSystem = GameObject.Find("UIRoot/EventSystem")
    end

    UIUtil.SetActive(eventSystem, false)

    --lockScreenTimer = Timer.New(
    --        function()
    --            UIUtil.SetActive(eventSystem, true)
    --            lockScreenTimer = nil
    --        end,
    --        lockTime,
    --        1
    --)
    --lockScreenTimer:Start()
    Scheduler.scheduleOnceGlobal(function()
        UIUtil.SetActive(eventSystem, true)
    end, lockTime)
end

--传入年月日 算出是周几
function CaculateWeekDay(y, m, d)
    if m == 1 then
        m = 13
        y = y - 1
    end
    if m == 2 then
        m = 14
        y = y - 1
    end
    local week = (d + 2 * m + 3 * (m + 1) / 5 + y + y / 4 - y / 100 + y / 400) % 7 + 1
    return week
end

--根据年月获取当前月天数
function function_name(y, m)
    return DateTime.DaysInMonth(y, m)
end

--将  年-月-日T时:分:秒.毫秒 转为 年-月-日 时:分:秒
function GetNormalTime(time)
    local index = string.find(time, "T")
    if index ~= nil then
        time = string.gsub(time, "T", " ")
        time = string.sub(time, 1, string.len(time) - 4)
    end
    return time
end

--将  年-月-日T时:分:秒.毫秒 转为 年-月-日
function GetYMDTime(time)
    local index = string.find(time, "T")
    if index ~= nil then
        time = string.split(time, "T")[1]
    end
    return time
end


--替换登录敏感词
function CheckSensitiveWords(nickName)
    local newNickName = Util.FilterSentiveWords(nickName, SensitiveWord, Global.specialRegexStr, "*")
    return newNickName
end

--替换输入敏感词
function ReplaceSensitiveWords(inputStr)
    return SensitiveWordsMgr:ReplaceWordAtPhrases(inputStr, "*")
end

-------------------------------------End----------------------------
--Url的decode
function UrlDecode(s)
    s = string.gsub(s, '%%(%x%x)', function(h)
        return string.char(tonumber(h, 16))
    end)
    return s
end

--Url的encode
function UrlEncode(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    return string.gsub(s, " ", "+")
end

-----------------------------------------------------------------
--
--是否为编辑器平台
function IsEditorPlatform()
    return Application.platform == RuntimePlatform.WindowsEditor or Application.platform == RuntimePlatform.OSXEditor
end

--是否为编辑器平台或者PC平台
function IsEditorOrPcPlatform()
    return Application.platform == RuntimePlatform.WindowsEditor or Application.platform == RuntimePlatform.OSXPlayer or Application.platform == RuntimePlatform.WindowsPlayer
end

--是否为Android平台
function IsAndroidPlatform()
    return Application.platform == RuntimePlatform.Android and Application.platform ~= RuntimePlatform.WindowsEditor
end

--是否为Windows PC平台
function IsOnlyPcPlatform()
    return Application.platform == RuntimePlatform.WindowsPlayer and Application.platform ~= RuntimePlatform.WindowsEditor
end

--是否为IOS平台
function IsIPhonePlatform()
    return Application.platform == RuntimePlatform.IPhonePlayer and Application.platform ~= RuntimePlatform.WindowsEditor
end

--table数组合并
function TableCombine(t1, t2)
    local length = #t2
    for i = 1, length do
        table.insert(t1, t2[i])
    end
end
----------------------------------------------------------
--是否开启为超级盾
function IsOpenChaoJiDun()
    return AppConfig.ShieldType == Global.ShieldType.ChaoJiDun
end
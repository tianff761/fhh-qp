--登录时使用的设备类型
Global = {}

Global.DeviceType = {
    --安卓
    Android = 1,
    --苹果
    iOS = 2,
    --H5
    Html5 = 3,
}

--获取设备的平台类型
function Global.GetDeviceType()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        return Global.DeviceType.iOS
    else
        return Global.DeviceType.Android
    end
end

--性别类型
Global.GenderType = {
    --男性
    Male = 1,
    --女性
    Female = 2,
}

--设备偏移
Global.OffsetX = 64
--实际偏移量
Global.tempOffsetX = nil

--获取偏移量值
function Global.GetOffsetX()
    if Global.tempOffsetX == nil then
        local scale = UnityEngine.Screen.width / UnityEngine.Screen.height
        if scale > 2 then
            --iphoneX，16:9，超宽屏再做比例处理
            if UnityEngine.Screen.width > 2436 then
                Global.tempOffsetX = ((UnityEngine.Screen.width - 2436) / 2436 + 1 + 0.02) * Global.OffsetX
            else
                Global.tempOffsetX = Global.OffsetX
            end
        else
            Global.tempOffsetX = 0
        end
    end

    return Global.tempOffsetX
end

--iPhoneX的偏移,44 + 10
Global.iPhoneXOffsetX = 54
--iPhoneX设备
Global.iPhoneXDevices = {
    ["iPhone10,3"] = "iPhone X",
    ["iPhone10,6"] = "iPhone X",
    ["iPhone11,2"] = "iPhone XS",
    ["iPhone11,4"] = "iPhone XS Max",
    ["iPhone11,6"] = "iPhone XS Max",
    ["iPhone11,8"] = "iPhone XR",
}
--设备类型
Global.DeviceModelType = {
    Unknown = 0,
    iPhoneX = 1
}

--设备类型，使用Get方法获取
Global.mDeviceModelType = nil
--获取设备类型，用于iPhoneX的刘海处理
function Global.GetDeviceModelType()
    if Global.mDeviceModelType == nil then
        local deviceModel = SystemInfo.deviceModel
        --iPhone X，需要做偏移
        if Global.iPhoneXDevices[deviceModel] ~= nil then
            Global.mDeviceModelType = Global.DeviceModelType.iPhoneX
        else
            Global.mDeviceModelType = Global.DeviceModelType.Unknown
        end
    end
    return Global.mDeviceModelType
end

Global.inviteRoomCode = ""
--非中文字母数字
Global.specialRegexStr = "[^\\u4e00-\\u9fa5^a-z^A-Z^0-9]"

--防护盾类型
Global.ShieldType = {
    None = 0,      --无，不开
    TaiJiDun = 1,  --太极盾
    ChaoJiDun = 2, --超级盾
    --云盾
    YunDun = 3,
    --云盾2s
    CloudShield = 4,
}

--交互的数据类型
Global.DataType = {
    --盾初始化
    ShieldInit = 1,
    --盾获取
    ShieldGet = 2,
}


--语音上传类型
Global.VoidUploadType = {
    QiNiu = 1,
    Tencent = 2,
}

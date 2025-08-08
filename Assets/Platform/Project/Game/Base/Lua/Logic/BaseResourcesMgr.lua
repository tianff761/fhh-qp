--基础资源管理
BaseResourcesMgr = {
    --初始化标识
    inited = false,
    --全屏面板背景
    background = nil,
    --默认头像，未获取到头像时使用的头像Sprite
    headNoneSprite = nil,
    --聊天默认加载图片
    imageNoneSprite = nil,
    --下载分享图片中
    downLoadShareImageing = false,
}
--分享图片下载列表
local shareImageDownList = {}
--保存路径
local shareImageSavePath = Assets.RuntimeAssetsPath .. "shareImage/"
--分享图片下载回调
local shareImageCallback = nil

--保存二维码路径
local shareCodeImageSavePath = Assets.RuntimeAssetsPath .. "shareCodeImage/"

local this = BaseResourcesMgr
--资源初始化，加载必要的资源
function BaseResourcesMgr.Initialize()
    this.headNoneSprite = ResourcesManager.LoadSpriteBySynch(BundleName.Common, "HeadNoneIcon")
    this.imageNoneSprite = ResourcesManager.LoadSpriteBySynch(BundleName.Common, "ImageNoneIcon")
    this.inited = true


    -- this.CheckLocalImage()
    -- this.InitDownLoadShareImage()
end


--获取全屏面板背景图片Sprite
function BaseResourcesMgr.GetFullScreenBackground()
    if this.background == nil then
        local scale = 1280 / 720
        local temp = ScenemMgr.width / ScenemMgr.height
        local diff = math.abs(temp - scale)
        local abName = nil
        local assetName = nil
        if diff < 0.001 then
            abName = "base/bground"
            assetName = "PanelBgRound"
        else
            abName = "base/bgnormal"
            assetName = "PanelBgNormal"
        end
        this.background = ResourcesManager.LoadSpriteBySynch(abName, assetName)
    end

    return this.background
end

--预下载分享图片  --更新图片，替换图片必须要将图片名字改变，不能同名
function BaseResourcesMgr.InitDownLoadShareImage(callback)
    shareImageCallback = callback
    this.downLoadShareImageing = true

    FileUtils.CheckCrateDir(shareImageSavePath)

    for _, v in ipairs(ShareImageNames) do
        local path = AppConfig.ShareImageDwonUrl .. v
        local filePath = shareImageSavePath .. Util.md5(path) .. ".jpg"

        if not FileUtils.ExistsFile(filePath) then
            table.insert(shareImageDownList, path)
        end
    end

    this.CheckDownNextUrl()
end

function BaseResourcesMgr.DownLoadShareImageCallback(data)
    if data.code == 0 then
        local path = shareImageSavePath .. Util.md5(data.url) .. ".jpg"
        Util.SaveToFile(path, data.bytes)
        if shareImageCallback ~= nil then
            Waiting.ForceHide()
            shareImageCallback(path)
            shareImageCallback = nil
        end
    end

    table.remove(shareImageDownList, 1)
    this.CheckDownNextUrl()
end

--下载下一个链接
function BaseResourcesMgr.CheckDownNextUrl()
    if #shareImageDownList > 0 then
        coroutine.start(this.DownLoadShareImage, shareImageDownList[1])
    else
        this.downLoadShareImageing = false
        local paths = Util.GetFilesByFolderPath(shareImageSavePath):ToTable()
        if paths == nil or #paths == 0 then
            Toast.Show("分享图片加载失败")
            Waiting.ForceHide()
        end
    end
end

--下载图片
function BaseResourcesMgr.DownLoadShareImage(url)
    local httpDown = HttpRequest.New(url)
    httpDown:SetTimeout(10)
    httpDown:AddListener(this.DownLoadShareImageCallback)
    httpDown:Connect()
end

--随机获取分享图片
function BaseResourcesMgr.GetShareImage(callback)
    FileUtils.CheckCrateDir(shareImageSavePath)
    local paths = Util.GetFilesByFolderPath(shareImageSavePath):ToTable()
    local index = 1
    if #paths > 0 then
        index = math.floor(Util.Random(1, #paths + 1))
        callback(paths[index])
    else
        Waiting.Show("准备分享...")
        this.InitDownLoadShareImage(callback)
    end
end


--随机获取分享图片
function BaseResourcesMgr.CheckLocalImage()
    FileUtils.CheckCrateDir(shareImageSavePath)
    local paths = Util.GetFilesByFolderPath(shareImageSavePath):ToTable()
    for _, n in ipairs(paths) do
        local isExists = false
        for _, v in ipairs(ShareImageNames) do
            local path = AppConfig.ShareImageDwonUrl .. v
            local filePath = shareImageSavePath .. Util.md5(path) .. ".jpg"
            if filePath == n then
                isExists = true
                break
            end
        end

        if not isExists then
            Util.DeleteFile(n)
        end
    end
end

--通过名称获取分享图片
function BaseResourcesMgr.GetShareImageByFileName(fileName, callback)
    FileUtils.CheckCrateDir(shareCodeImageSavePath)
    this.DownGuildCodeByGuildId(fileName, callback)
end

--请求俱乐部二维码
function BaseResourcesMgr.DownGuildCodeByGuildId(guildId, callBack)
    local url = AppConfig.ReqGuildCode .. "?guildId=" .. guildId
    local path = shareCodeImageSavePath .. guildId .. ".jpg"
    coroutine.start(function()
        local www = WWW(url)
        coroutine.www(www)
        Waiting.Hide()
        if www.error == nil and www.bytes.Length > 1000 then
            FileUtils.WriteFile(path, www.bytes)
            if callBack ~= nil then
                callBack(0, www.bytes)
            end
        else
            if callBack ~= nil then
                callBack(2)
            end
        end
    end)
end
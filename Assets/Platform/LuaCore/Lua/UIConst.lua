--UI使用的全局变量
UIConst = {
    --UI根路径，GameObject
    uiRoot = nil,
    --UI摄像机，Camera
    uiCamera = nil,
    --UI的Canvas，Canvas
    uiCanvas = nil,
    --UI的RectTransform，Canvas的RectTransform
    uiCanvasTrans = nil,
    --
    uiCanvasWidth = 1280,
}

local this = UIConst

--初始化
function UIConst.Initialize()
    this.uiRoot = GameObject.Find("UIRoot")
    if this.uiRoot ~= nil then
        local uiRootTrans = this.uiRoot.transform
        --UI摄像机
        local uiCameraTrans = uiRootTrans:Find("UICamera")
        if uiCameraTrans ~= nil then
            this.uiCamera = uiCameraTrans:GetComponent("Camera")
            this.uiCamera.useOcclusionCulling = false
            this.uiCamera.allowHDR = false
            this.uiCamera.allowMSAA = false
        end
        --UI的Canvas
        local uiCanvasTrans = uiRootTrans:Find("Canvas")
        if uiCanvasTrans ~= nil then
            this.uiCanvas = uiCanvasTrans:GetComponent("Canvas")
            this.uiCanvasTrans = uiCanvasTrans:GetComponent("RectTransform")
            this.uiCanvasWidth = this.uiCanvasTrans.sizeDelta.x
        end
    end

    Log(">> UIConst.Initialize > ", this.uiCamera)
    Log(">> UIConst.Initialize > ", this.uiCanvas)
    Log(">> UIConst.Initialize > ", this.uiCanvasTrans)
end

--全局的事件管理
BaseGlobalEventMgr = {}
--引用
local this = BaseGlobalEventMgr

--初始化
function BaseGlobalEventMgr.Initialize()
	AddEventListener(CMD.Game.LogoutAndOpenLogin, this.OnLogoutAndOpenLogin)
	AddEventListener(CMD.Game.LogoutAndQuitApp, this.OnLogoutAndQuitApp)
end

--注销并返回登录界面
function BaseGlobalEventMgr.OnLogoutAndOpenLogin()
	Network.Disconnect(true)
	GPSModule.Stop()
	UserData.Clear()
	SetLocal(LocalDatas.UserInfoData, "")
	if not GameSceneManager.CheckGameScene(GameSceneType.Login) then
		PanelManager.CloseAll()
		GameSceneManager.SwitchGameScene(GameSceneType.Login)
	end
end

--注销并退出App
function BaseGlobalEventMgr.OnLogoutAndQuitApp()
	Network.Disconnect(true)
	GPSModule.Stop()
	UserData.Clear()
	SetLocal(LocalDatas.UserInfoData, "")
	AppPlatformHelper.QuitGame()
end 
--命令
CMD = {}
CMD.Http = {}

--================================================================
--
--Tcp 协议类型，值为数字类型
CMD.Tcp = {}
--tcp心跳请求
CMD.Tcp.C2S_Heartbeat = 777
--tcp心跳
CMD.Tcp.S2C_Heartbeat = 778
--系统提示推送
CMD.Tcp.Push_SystemTips = 901
--登录请求
CMD.Tcp.C2S_Login = 1001
--登录返回
CMD.Tcp.S2C_Login = 1002
--推送顶号
CMD.Tcp.Push_OtherLogin = 1003
--系统错误推送
CMD.Tcp.Push_SystemError = 9101

--================================================================
--
--游戏内部命令，值为字符串
CMD.Game = {}

--登录
CMD.Game.Login = "Login"
--重新认证
CMD.Game.Reauthentication = "Reauthentication"

CMD.Game.Ping = 19
CMD.Game.OnConnected = 11 --连接服务器
CMD.Game.OnDisconnected = 12 --异常掉线
CMD.Game.OnConnectFailed = 13 --正常断线
CMD.Game.OnConnectTimeout = 14 --网络连接超过最大次数
CMD.Game.OnBeginReconnect = 20 --断线重连
CMD.Game.DownloadFailed = 16 --资源文件下载失败   
CMD.Game.DownloadProgress = 17 --资源文件下载进度
--应用切出去
CMD.Game.ApplicationPause = "ApplicationPause"
--授权登录回调
CMD.Game.AuthLogin = "AuthLogin"
--注销并返回登录界面
CMD.Game.LogoutAndOpenLogin = "LogoutAndOpenLogin"
--注销并退出App
CMD.Game.LogoutAndQuitApp = "LogoutAndQuitApp"
--更新玩家货币
CMD.Game.UpdateMoney = "UpdateMoney"
--更新玩家信息
CMD.Game.UpdateUserInfo = "UpdateUserInfo"
--================================================================
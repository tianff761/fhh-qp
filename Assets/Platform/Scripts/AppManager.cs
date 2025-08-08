
/// <summary>
/// App的管理类
/// 主要功能是启动其他功能的执行
/// </summary>
public class AppManager : TSingleton<AppManager>
{
    private AppManager() { }

    /// <summary>
    /// 启动
    /// </summary>
    public void StartUp()
    {
        //初始平台管理
        PlatformManager.Instance.Init();
        //启动PureMVC
        AppFacade.Instance.StartUp();

    }

}

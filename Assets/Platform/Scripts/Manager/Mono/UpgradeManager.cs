using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System;
using LitJson;
using LuaFramework;
using System.Text;

public class UpgradeManager : TMonoBehaviour<UpgradeManager>
{
    /// <summary>
    /// 远端资源的Url，推荐配置根路径，然后使用空间前缀字段来处理资源路径的前缀
    /// </summary>
    public static string RemoteResUrl = "";
    /// <summary>
    /// 远端空间前缀，主要是用于使用盾的时候，资源路径前缀，盾直接获取的是根路径
    /// </summary>
    public static string RemoteZonePrefix = "";

    /// <summary>
    /// files文件名称
    /// </summary>
    private static string FilesFileName = "files.json";

    /// <summary>
    /// 版本文件名称
    /// </summary>
    private static string VersionFileName = "version.txt";

    /// <summary>
    /// 重试最大总数
    /// </summary>
    private const int RETRY_MAX_TOTAL = 2;
    /// <summary>
    /// 获取远端超时时间
    /// </summary>
    private const float REMOTE_MAX_TIMEOUT = 60f;

    /// <summary>
    /// 游戏的files文件名称
    /// </summary>
    private string mGameFilesFileName = "";

    /// <summary>
    /// 游戏的版本文件名称
    /// </summary>
    private string mGameVersionFileName = "";

    /// <summary>
    /// 用于比较的最低版本
    /// </summary>
    private Version mMinVersion = new Version(1, 0, 0);

    /// <summary>
    /// 是否读取到远端配置信息
    /// </summary>
    private bool mIsLoadRemoteConfig = false;

    /// <summary>
    /// 远端APP版本号
    /// </summary>
    private Version mRemoteAppVersion = new Version(1, 0, 0);
    /// <summary>
    /// 远端的应用连接
    /// </summary>
    private string mRemoteAppUrl = null;


    /// <summary>
    /// 资源的根目录路径，可读写文件夹下的资源目录路径，直接用IO操作的路径
    /// </summary>
    private string mSaveResAssetsPath = "";
    /// <summary>
    /// 当前存储资源的目录路径，可读写文件夹下的资源目录路径，直接用IO操作的路径
    /// </summary>
    private string mSaveGameAssetsPath = "";
    /// <summary>
    /// StreamingAssets中Res路径
    /// </summary>
    private string mStreamingAssetsResPath = "";
    /// <summary>
    /// StreamingAssets中游戏资源路径
    /// </summary>
    private string mStreamingAssetsGamePath = "";

    /// <summary>
    /// StreamAssets资源的版本号
    /// </summary>
    private Version mStreamingAssetsVersion = null;

    /// <summary>
    /// 进度回调
    /// </summary>
    private Action<int, float> mOnProgressCallback = null;
    /// <summary>
    /// 检测完成回调
    /// </summary>
    private Action mOnCheckFinshCallback = null;

    /// <summary>
    /// 更新进度，用于处理各种更新当前占用的百分比
    /// </summary>
    private float mUpgradeProgress = 0;

    /// <summary>
    /// 更新文件数据字典
    /// </summary>
    private Dictionary<string, Md5FileSingleData> updateFilesDic = new Dictionary<string, Md5FileSingleData>();

    /// <summary>
    /// 需要更新文件总数
    /// </summary>
    private int mNeedUpgradeFileTotal = 0;
    /// <summary>
    /// 成功更新的文件总数
    /// </summary>
    private int mUpgradeSuccessFileCount = 0;
    /// <summary>
    /// 当前正在更新的Md5FileSingleData
    /// </summary>
    private Md5FileSingleData mMd5FileSingleData = null;
    /// <summary>
    /// 更新的文件总数
    /// </summary>
    private int mUpgradeFileTotal = 1;
    /// <summary>
    /// 更新的文件计数
    /// </summary>
    private int mUpgradeFileCount = 0;

    //-----------------------------------

    /// <summary>
    /// 是否暂停下载，用于Alert提示时，暂停下载循环
    /// </summary>
    private bool mIsPauseDownload = false;

    /// <summary>
    /// files文件内容
    /// </summary>
    private string mFilesContent = "";

    /// <summary>
    /// 远端info文件的路径，url添加了随机数，每次下载失败时，需要重置，故全局缓存
    /// </summary>
    private string mRemoteConfigUrl = "";
    /// <summary>
    /// 当前的资源游戏名称
    /// </summary>
    private string mGameName = string.Empty;

    /// <summary>
    /// 更新状态
    /// </summary>
    private int mUpgradeStatus = UpgradeStatus.NONE;

    /// <summary>
    /// 是否协同等待
    /// </summary>
    private bool mIsCoroutineWaiting = false;

    //-----------------------------------
    /// <summary>
    /// 资源服务器Url路径
    /// </summary>
    private string mResServerUrlPath = "";
    /// <summary>
    /// 是否在检查资源服务器Url路径
    /// </summary>
    private bool mIsCheckingResServerUrlPath;


    //================================================================

    /// <summary>
    // 还原设置
    /// </summary>
    private void Reset()
    {
        this.mStreamingAssetsVersion = null;
        this.mUpgradeProgress = 0;
        this.updateFilesDic.Clear();
        this.mUpgradeStatus = UpgradeStatus.NONE;
        UpgradeStatus.Reset();
    }

    /// <summary>
    /// 检测更新，带更新远端版本检测；没有进度回调，会使用默认提示
    /// </summary>
    public void Check(string gameName, Action onCheckFinshCallback)
    {
        Check(gameName, onCheckFinshCallback, null);
    }

    /// <summary>
    /// 检测更新，带更新远端版本检测
    /// </summary>
    public void Check(string gameName, Action onCheckFinshCallback, Action<int, float> onProgressCallback)
    {
        Debug.LogWarning(">> Upgrade > Check > GameName > " + gameName);

        this.Reset();
        this.mGameName = this.CheckGameName(gameName);
        this.CheckAssetsPath();
        this.mOnProgressCallback = onProgressCallback;
        this.mOnCheckFinshCallback = onCheckFinshCallback;

        if (AppConst.IsCheckUpgrade())
        {
            StartCoroutine(CoroutineCheck());
        }
        else
        {
            FinishedCallback();
        }
    }

    /// <summary>
    /// 检测游戏更新，不进行远端版本检测；没有进度回调，会使用默认提示
    /// </summary>
    public void CheckWithoutVersion(string gameName, Action onCheckFinshCallback)
    {
        CheckWithoutVersion(gameName, onCheckFinshCallback, null);
    }

    /// <summary>
    /// 检测游戏更新，不进行远端版本检测
    /// </summary>
    public void CheckWithoutVersion(string gameName, Action onCheckFinshCallback, Action<int, float> onProgressCallback)
    {
        Debug.LogWarning(">> Upgrade > CheckWithoutVersion > GameName > " + gameName);
        this.Reset();
        this.mGameName = this.CheckGameName(gameName);
        this.CheckAssetsPath();
        this.mOnProgressCallback = onProgressCallback;
        this.mOnCheckFinshCallback = onCheckFinshCallback;

        if (AppConst.IsCheckUpgrade())
        {
            StartCoroutine(CoroutineCheckGame());
        }
        else
        {
            FinishedCallback();
        }
    }

    /// <summary>
    /// 检测游戏名称
    /// </summary>
    private string CheckGameName(string gameName)
    {
        if (gameName == null)
        {
            return "";
        }
        else
        {
            return gameName;
        }
    }

    /// <summary>
    /// 进度回调
    /// </summary>
    private void ProgressCallback(int status, float progress)
    {
        if (this.mOnProgressCallback != null)
        {
            this.mOnProgressCallback.Invoke(status, progress);
            return;
        }

        //Debug.Log(">> UpgradeManager > ProgressCallback > progress = " + progress);

        //内部默认处理
        if (status != this.mUpgradeStatus)
        {
            this.mUpgradeStatus = status;
            if (this.mUpgradeStatus == UpgradeStatus.BEGIN)
            {
                Loading.Begin(UpgradeStatus.BeginTipsTxt, null);
            }
            else if (this.mUpgradeStatus == UpgradeStatus.CHECK)
            {
                Loading.SetTips(UpgradeStatus.CheckTipsTxt);
                Loading.SetSpeed(Loading.SPEED_SLOWEST);
            }
            else if (this.mUpgradeStatus == UpgradeStatus.COPY)
            {
                Loading.SetTips(UpgradeStatus.CopyTipsTxt);
                Loading.SetSpeed(Loading.SPEED_UPGRADE);
            }
            else if (this.mUpgradeStatus == UpgradeStatus.DOWNLOAD)
            {
                Loading.SetTips(UpgradeStatus.DownloadTipsTxt);
                Loading.SetSpeed(Loading.SPEED_UPGRADE);
            }
            else if (this.mUpgradeStatus == UpgradeStatus.FINISHED)
            {
            }
            else if (this.mUpgradeStatus == UpgradeStatus.STOP)
            {
            }
        }

        Loading.SetProgress(progress);
    }

    /// <summary>
    /// 完成回调
    /// </summary>
    private void FinishedCallback()
    {
        if (this.mOnCheckFinshCallback != null)
        {
            this.mOnCheckFinshCallback.Invoke();
        }
    }

    //----------------------------------------------------------------

    /// <summary>
    /// 检测保存路径
    /// </summary>
    private void CheckAssetsPath()
    {
        string lowerGameName = this.mGameName.ToLower();

        this.mSaveResAssetsPath = Util.AssetsPath + AppConst.ResPathName + "/";
        this.mSaveGameAssetsPath = this.mSaveResAssetsPath + lowerGameName;
        if (!this.mSaveGameAssetsPath.EndsWith("/"))
        {
            this.mSaveGameAssetsPath += "/";
        }
        if (!Directory.Exists(this.mSaveResAssetsPath))
        {
            Directory.CreateDirectory(this.mSaveResAssetsPath);
        }
        if (!Directory.Exists(this.mSaveGameAssetsPath))
        {
            Directory.CreateDirectory(this.mSaveGameAssetsPath);
        }

        this.mStreamingAssetsResPath = Assets.StreamingAssetsUrlPath + AppConst.ResPathName + "/";
        this.mStreamingAssetsGamePath = this.mStreamingAssetsResPath + lowerGameName;
        if (!this.mStreamingAssetsGamePath.EndsWith("/"))
        {
            this.mStreamingAssetsGamePath += "/";
        }

        this.mGameFilesFileName = lowerGameName + "/" + FilesFileName;
        this.mGameVersionFileName = lowerGameName + "/" + VersionFileName;
    }


    /// <summary>
    /// 检测远端配置，外部使用
    /// </summary>
    public void CheckRemoteConfig(Action onCheckFinshCallback)
    {
        StartCoroutine(this.CoroutineCheckRemoteConfig(true, onCheckFinshCallback));
    }


    /// <summary>
    /// 重新开始检查，针对远端配置下载失败
    /// </summary>
    private void OnReCheckAlertCallback()
    {
        StartCoroutine(this.CoroutineCheck());
    }


    /// <summary>
    /// 重新开始检测资源，针对远端版本号下载失败
    /// </summary>
    private void OnReCheckAssetsAlertCallback()
    {
        StartCoroutine(this.CoroutineCheck());
    }


    //================================================================

    /// <summary>
    /// 协同等待
    /// </summary>
    IEnumerator CoroutineWaiting()
    {
        this.mIsCoroutineWaiting = true;
        while (this.mIsCoroutineWaiting)
        {
            yield return null;
        }
    }

    //================================================================

    /// <summary>
    /// 内部协同检测入口方法1，协同检测基础资源，需要检测远端配置文件
    /// </summary>
    IEnumerator CoroutineCheck()
    {
        Debug.LogWarning(">> Upgrade > CoroutineCheck > Enter.");
        this.CheckLoadLocalVersion();
        yield return null;

        //检查远端版本号，使用5%左右的进度
        this.mUpgradeProgress = UnityEngine.Random.Range(0.045f, 0.055f);
        this.ProgressCallback(UpgradeStatus.CHECK, this.mUpgradeProgress);

        //如果资源服务器使用盾的话，就需要获取资源服务器的Url路径
        yield return this.CoroutineCheckGetResServerUrlPath();
        //检测远端配置
        yield return this.CoroutineCheckRemoteConfig(false);

        //如果需要检测远端配置
        if (AppConst.IsCheckRemoteUpgrade)
        {
            if (!this.mIsLoadRemoteConfig || string.IsNullOrEmpty(this.mRemoteAppUrl))
            {
                Alert.Show("服务器获取错误，请联系客服！", AlertType.Prompt, "重试", OnReCheckAlertCallback, "退出", OnQuitAlertCallback);
                yield break;
            }
        }

        //检查资源
        yield return this.CoroutineCheckAssets();
    }

    /// <summary>
    /// 内部协同检测入口方法2，协同检测游戏资源
    /// </summary>
    IEnumerator CoroutineCheckGame()
    {
        this.CheckLoadLocalVersion();
        //如果资源服务器使用盾的话，就需要获取资源服务器的Url路径
        yield return this.CoroutineCheckGetResServerUrlPath();
        //检查资源
        yield return this.CoroutineCheckAssets();
    }

    //================================================================

    /// <summary>
    /// 协同检测远端配置
    /// </summary>
    IEnumerator CoroutineCheckRemoteConfig(bool isBackgroundLoadRemoteConfig, Action onCheckFinshCallback = null)
    {
        //原生平台没有初始化就等待，便于版本号等数据已经初始化完成
        // #if !UNITY_EDITOR && (UNITY_ANDROID || UNITY_IPHONE)
        //         while(!AppConst.IsPlatformInited)
        //         {
        //             yield return null;
        //         }
        // #endif
        //更新版本号显示
        DelegateManager.Instance.Dispatch(DelegateCommand.AppVersionUpdate, this.mGameName);
        //检测解析远端配置
        if (AppConst.IsCheckRemoteUpgrade)
        {
            //获取远端配置文件信息
            if (isBackgroundLoadRemoteConfig)
            {
                yield return this.CheckLoadRemoteConfigByBackground();
            }
            else
            {
                //非后台获取，失败则添加提示，添加提示防止意外，便于调试
                yield return this.CheckLoadRemoteConfig();
            }
        }
        else
        {
            yield return null;
        }
        //回调
        if (onCheckFinshCallback != null)
        {
            onCheckFinshCallback.Invoke();
        }
    }

    /// <summary>
    /// 检测资源更新
    /// </summary>
    IEnumerator CoroutineCheckAssets()
    {
        //等待一帧
        yield return null;
        //检测App版本号
        Debug.LogWarning(">> Upgrade > CoroutineCheckAssets > AppConst.AppVersion = " + AppConst.AppVersion);
        if (AppConst.AppVersion < this.mRemoteAppVersion)
        {
            Alert.Show("当前版本过低，请下载最新版本！", this.OnDownAppUrlAlertCallback);
            //删除本地版本号文件，便于重新安装APP后，便于再次拷贝StreamingAssets下的资源                                      
            this.DeleteLocalVersionFile();
            yield break;
        }

        Version remoteAssetsVersion = VersionManager.Instance.GetGameRemoteVersion(this.mGameName);
        Debug.LogWarning(">> Upgrade > CoroutineCheckAssets > remoteAssetsVersion = " + remoteAssetsVersion);
        if (AppConst.IsCheckRemoteUpgrade)
        {
            //判断远端版本号，如果版本号不对，则提示
            if (remoteAssetsVersion == null || remoteAssetsVersion <= this.mMinVersion)
            {
                Alert.Show("服务器获取错误，请联系客服。", AlertType.Prompt, "重试", OnReCheckAssetsAlertCallback, "退出", OnQuitAlertCallback);
                yield break;
            }
        }

        //获取本地版本号
        Version localAssetsVersion = VersionManager.Instance.GetGameLocalVersion(this.mGameName);
        Debug.LogWarning(">> Upgrade > CoroutineCheckAssets > localAssetsVersion = " + localAssetsVersion);
        //还没有版本号，开始APP初始化，即文件拷贝等流程
        if (localAssetsVersion == null)
        {
            //加载StreamAssets中的游戏版本号
            yield return this.CheckLoadStreamingAssetsVersion();
            //即读取到StreamingAssets中的版本文件才进行拷贝
            if (this.mStreamingAssetsVersion != null)
            {
                //初始解压进度要到30%左右
                float tempProgress = UnityEngine.Random.Range(0.255f, 0.355f);
                yield return UpgradeAssets(this.mStreamingAssetsResPath, tempProgress, UpgradeStatus.COPY, true, this.mStreamingAssetsVersion);
                //再次读取本地版本
                localAssetsVersion = VersionManager.Instance.GetGameLocalVersion(this.mGameName);
            }
        }

        //再次更新版本号显示
        DelegateManager.Instance.Dispatch(DelegateCommand.AppVersionUpdate, this.mGameName);

        //是否更新了远端资源
        bool isUpgradeRemoteAssets = false;
        if (AppConst.IsCheckRemoteUpgrade)
        {
            if (localAssetsVersion == null || (this.mMinVersion < remoteAssetsVersion && localAssetsVersion < remoteAssetsVersion))
            {
                //远端更新进度要到60%左右
                float tempProgress = UnityEngine.Random.Range(0.555f, 0.655f);

                //urlPath + appVersion + path

                string remoteAssetsPath = string.Format("{0}v{1}/{2}", this.mResServerUrlPath, AppConst.AppVerStr, VersionManager.Instance.GetGameAssetsPath(this.mGameName));

                //Debug.LogError(">> remoteAssetsPath > " + remoteAssetsPath);

                yield return UpgradeAssets(remoteAssetsPath, tempProgress, UpgradeStatus.DOWNLOAD, false, remoteAssetsVersion);
                //再次读取本地版本
                localAssetsVersion = VersionManager.Instance.GetGameLocalVersion(this.mGameName);
                //标记更新了远端资源
                isUpgradeRemoteAssets = true;
            }
        }

        //没有更新远端资源，再次进行StreamingAssets资源检测
        if (!isUpgradeRemoteAssets)
        {
            if (localAssetsVersion != null)
            {
                if (this.mStreamingAssetsVersion == null)
                {
                    //加载StreamAssets中的游戏版本号
                    yield return this.CheckLoadStreamingAssetsVersion();
                }
                Debug.LogWarning(">> Upgrade > CoroutineCheckAssets > mStreamingAssetsVersion = " + this.mStreamingAssetsVersion);

                if (this.mStreamingAssetsVersion != null)
                {
                    if (localAssetsVersion < this.mStreamingAssetsVersion)
                    {
                        //StreamingAssets版本更新进度也要到60%左右
                        float tempProgress = UnityEngine.Random.Range(0.555f, 0.655f);
                        yield return UpgradeAssets(this.mStreamingAssetsResPath, tempProgress, UpgradeStatus.COPY, true, this.mStreamingAssetsVersion);
                        //再次读取本地版本
                        localAssetsVersion = VersionManager.Instance.GetGameLocalVersion(this.mGameName);
                    }
                }
                else
                {
                    //如果远端没有开启更新，且没有加载到StreamAssets中的游戏版本号，无法继续游戏
                    if (!AppConst.IsCheckRemoteUpgrade)
                    {
                        Alert.Show("资源检测错误，请联系客服人员。", "退出", this.OnQuitAlertCallback);
                        yield break;
                    }
                }
            }
            else
            {
                //没有本地版本号，就无法进行
                Alert.Show("资源检测错误，请联系客服。", "退出", this.OnQuitAlertCallback);
                yield break;
            }
        }

        //每一个游戏资源更新，更新进度只处理到70%，剩余的外部功能之间处理
        this.ProgressCallback(UpgradeStatus.FINISHED, 0.7f);

        this.FinishedCallback();
    }

    //================================================================

    /// <summary>
    /// 打开下载APP的URL
    /// </summary>
    private void OnDownAppUrlAlertCallback()
    {
        if (!string.IsNullOrEmpty(this.mRemoteAppUrl))
        {
            Application.OpenURL(this.mRemoteAppUrl);
        }
    }

    /// <summary>
    /// 获取远端的配置URL完整路径
    /// </summary>
    private string GetRemoteConfigUrl(string path)
    {
        string url = path.Trim() + string.Format("v{0}/", AppConst.AppVerStr);//如v1.1.3/
#if UNITY_ANDROID
        url += "android/config.json";
#endif
#if UNITY_IPHONE
        url += "iOS/config.json";
#endif
#if UNITY_STANDALONE_WIN
        url += "standalone/config.json";
#endif
        return url;
    }


    //================================================================

    /// <summary>
    /// 获取远端配置文件信息
    /// </summary>
    IEnumerator CheckLoadRemoteConfig()
    {
        Util.LogWarning(">> Upgrade > CheckLoadRemoteConfig > Enter.");
        WWW www = null;
        int loadCount = 0;
        while (true)
        {
            if (www == null)
            {
                this.mRemoteConfigUrl = this.GetRemoteConfigUrl(this.mResServerUrlPath) + GetRandomNumber();
                Debug.LogError(">> Upgrade > CheckLoadRemoteConfig > RemoteConfigUrl = " + this.mRemoteConfigUrl);
                www = new WWW(this.mRemoteConfigUrl);
            }
            yield return null;
            if (www.isDone)
            {
                if (string.IsNullOrEmpty(www.error))
                {
                    //下载成功
                    this.HandleRemoteConfig(www.text);
                    www.Dispose();
                    yield break;
                }
                else
                {
                    Debug.LogError(">> Upgrade > CheckLoadRemoteConfig > Load Error.");
                    Debug.LogError(www.error);
                    loadCount += 1;
                    www = null;
                }
            }
            if (loadCount >= 2)
            {
                this.HandleLoadRemoteConfigFailCallback();
                loadCount = 0;
                this.mIsPauseDownload = true;
                while (this.mIsPauseDownload)
                {
                    yield return null;
                }
                float interval = UnityEngine.Random.Range(0.3f, 0.8f);
                yield return new WaitForSeconds(interval);
            }
        }
    }

    /// <summary>
    /// 处理获取远端配置文件信息失败回调
    /// </summary>
    private void HandleLoadRemoteConfigFailCallback()
    {
        if (Application.internetReachability == NetworkReachability.NotReachable)
        {
            Alert.Show("连接服务器失败，请检查网络！", AlertType.Prompt, "重试", OnReloadRemoteConfigAlertCallback, "退出", OnQuitAlertCallback);
        }
        else
        {
            Alert.Show("连接服务器失败，请稍后重试！", AlertType.Prompt, "重试", OnReloadRemoteConfigAlertCallback, "退出", OnQuitAlertCallback);
        }
    }

    /// <summary>
    /// 处理获取远端配置文件信息失败回调
    /// </summary>
    private void OnReloadRemoteConfigAlertCallback()
    {
        this.mIsPauseDownload = false;
    }

    /// <summary>
    /// 后台获取远端配置文件信息
    /// </summary>
    IEnumerator CheckLoadRemoteConfigByBackground()
    {
        Debug.LogWarning(">> Upgrade > CheckLoadRemoteConfigByBackground > Enter.");

        this.mRemoteConfigUrl = this.GetRemoteConfigUrl(this.mResServerUrlPath) + GetRandomNumber();
        //Debug.Log(">> Upgrade > CheckLoadRemoteConfigByBackground > ================ RemoteConfigUrl > ");
        //Debug.Log(this.mRemoteConfigUrl);
        WWW www = new WWW(this.mRemoteConfigUrl);
        yield return www;
        if (www.isDone && string.IsNullOrEmpty(www.error))
        {
            this.HandleRemoteConfig(www.text);
        }
        www.Dispose();
    }

    /// <summary>
    /// 处理远端的版本号
    /// </summary>
    private void HandleRemoteConfig(string txt)
    {
        Util.LogWarning(">> Upgrade > HandleRemoteConfig > Enter.");
        try
        {
            this.mIsLoadRemoteConfig = true;
            if (string.IsNullOrEmpty(txt))
            {
                Debug.LogWarning(">> Upgrade > HandleRemoteConfig > IsNullOrEmpty");
                return;
            }
            //Debug.Log(txt);
            VersionManager.Instance.SetRemoteVersionData(txt);

            this.mRemoteAppVersion = new Version(VersionManager.Instance.appRemoteVersionStr);
            this.mRemoteAppUrl = VersionManager.Instance.appRemoteVersionUrl;
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    //================================================================


    /// <summary>
    /// 删除本地版本号文件，用于更新包处理
    /// </summary>
    private void DeleteLocalVersionFile()
    {
        try
        {
            string localVersionFilePath = this.mSaveResAssetsPath + VersionFileName;
            //Debug.Log(">> UpgradeManager > DeleteLocalVersionFile > localVersionFilePath");
            //Debug.Log(localVersionFilePath);

            if (File.Exists(localVersionFilePath))
            {
                File.Delete(localVersionFilePath);
            }
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    /// <summary>
    /// 检查本地版本号
    /// </summary>
    private void CheckLoadLocalVersion()
    {
        //判断本地版本号是否加载
        if (!VersionManager.Instance.IsLoadLocalVersion())
        {
            //检查本地是否用于Version文件
            string localVersionFilePath = this.mSaveResAssetsPath + VersionFileName;

            Debug.LogWarning(">> UpgradeManager > CheckLoadLocalVersion > localVersionFilePath");
            //Debug.Log(localVersionFilePath);

            string localVersionFileTxt = null;
            try
            {
                if (File.Exists(localVersionFilePath))
                {
                    localVersionFileTxt = File.ReadAllText(localVersionFilePath);
                    //Debug.Log(localVersionFileTxt);
                    VersionManager.Instance.SetLocalVersionData(localVersionFileTxt);
                }
                else
                {
                    Debug.LogWarning(">> Upgrade > localVersionFilePath not exist.");
                }
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }
    }

    /// <summary>
    /// 检测StreamAssets资源版本号
    /// </summary>
    IEnumerator CheckLoadStreamingAssetsVersion()
    {
        string streamAssetsVersionPath = this.mStreamingAssetsResPath + mGameVersionFileName;

        Debug.LogWarning(">> UpgradeManager > streamAssetsVersionPath = " + streamAssetsVersionPath);

        WWW www = new WWW(streamAssetsVersionPath);
        yield return www;
        if (string.IsNullOrEmpty(www.error))
        {
            try
            {
                this.mStreamingAssetsVersion = new Version(www.text);
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }
        else
        {
            Debug.LogWarning(">> Upgrade > " + www.error);
            Debug.LogWarning(">> Upgrade > not found > " + streamAssetsVersionPath);
        }
    }

    //================================================================

    /// <summary>
    /// 下载文件通用方法，成功回调指向后WWW将被销毁；该方法只能一个一个的文件下载
    /// </summary>
    IEnumerator DownloadFile(string url, Action<WWW> loadSuccssCallback, Action loadFailCallback)
    {
        //Debug.Log(">> UpgradeManager > DownloadFile > url = " + url);

        WWW www = null;
        //用于事件统计
        float time = 0;
        //加载次数
        int loadCount = 0;
        //是否加载错误
        bool isLoadError = false;
        //加载重试最大次数
        int retryMaxTotal = RETRY_MAX_TOTAL;

        //循环处理
        while (true)
        {
            if (www == null)
            {
                isLoadError = false;
                time = 0;
                www = new WWW(url);
            }
            yield return null;

            if (www.isDone && !isLoadError)
            {
                if (string.IsNullOrEmpty(www.error))
                {
                    Debug.LogWarning(">> Upgrade > DownloadFile > Success. ");
                    if (loadSuccssCallback != null)
                    {
                        loadSuccssCallback.Invoke(www);
                    }
                    //Debug.LogWarning(www.url);
                    //Debug.LogWarning(time);
                    www.Dispose();
                    yield break;
                }
                else
                {
                    isLoadError = true;
                    Debug.LogWarning(">> Upgrade > DownloadFile > Error. ");
                    Debug.LogWarning(www.url);
                    Debug.LogWarning(www.error);
                    //Debug.LogWarning(time);

                    //如果处理超时时间大于1秒，就设置等待指定秒后进行超时处理，即至多等待指定秒就重试
                    if (REMOTE_MAX_TIMEOUT - time > 0.5f)
                    {
                        time = REMOTE_MAX_TIMEOUT - 0.5f;
                    }
                }
            }
            time += Time.deltaTime;
            if (time > REMOTE_MAX_TIMEOUT)
            {
                loadCount++;
                if (www != null)
                {
                    www.Dispose();
                    www = null;
                }
                Debug.LogWarning(">> Upgrade > DownloadFile > Error or Timeout.");
                if (loadCount >= retryMaxTotal)
                {
                    loadCount = 0;
                    this.mIsPauseDownload = true;
                    if (loadFailCallback != null)
                    {
                        loadFailCallback.Invoke();
                    }
                    while (this.mIsPauseDownload)
                    {
                        yield return null;
                    }
                }
            }
        }
    }

    /// <summary>
    /// 重新下载提示回调
    /// </summary>
    private void OnReloadAlertCallback()
    {
        this.mIsPauseDownload = false;
    }

    /// <summary>
    /// 退出提示回调
    /// </summary>
    private void OnQuitAlertCallback()
    {
        PlatformHelper.QuitGame();
    }

    //================================================================

    /// <summary>
    /// 更新资源
    /// </summary>
    /// <param name="loadUrlPath">读取路径，StreamingAssets路径, Http路径</param>
    /// <param name="updateProgress">该次更新最高进度，控制进度条的百分比</param>
    /// <param name="loadingTips">加载条的提示文本</param>
    /// <param name="isLocalExtract">是否是本地提取，可以用于iOS快速提取文件</param>
    IEnumerator UpgradeAssets(string loadUrlPath, float updateProgress, int upgradeStatus, bool isLocalExtract, Version version)
    {
        Debug.LogWarning(">> Upgrade > UpdateAssets > Enter.");
        //Debug.Log(loadUrlPath);

        double downTime = Util.GetTime();

        this.ProgressCallback(upgradeStatus, this.mUpgradeProgress);

        yield return null;

        string filesUrlPath = loadUrlPath + this.mGameFilesFileName;

        //第一步，获取更新的files列表
        yield return DownloadFile(filesUrlPath, OnFilesLoadSuccessCallback, OnFilesLoadFailCallback);

        if (string.IsNullOrEmpty(this.mFilesContent))//添加提示，便于调试
        {
            Alert.Show("服务器获取错误，请退出后重试！", OnQuitAlertCallback);
            yield return this.CoroutineWaiting();
        }

        this.ParseFilesList(this.mFilesContent);
        this.mFilesContent = null;//用完就清除
        yield return null;

        //第二步，对比出需要删除文件和设置需要更新的文件
        //删除列表
        List<string> deleteList = this.CheckUpdateFiles();
        Debug.LogWarning(">> Upgrade > UpgradeAssets > delete files > count = " + deleteList.Count);
        yield return null;

        //第三步删除文件
        this.DeleteFiles(deleteList);
        yield return null;

        //第四步提取或者下载更新文件
        yield return this.UpdateFiles(loadUrlPath, updateProgress, upgradeStatus, isLocalExtract);

        Debug.LogWarning(">> Upgrade > mNeedUpdateFileTotal = " + this.mNeedUpgradeFileTotal);

        Debug.LogWarning("下载完毕，共计花费时间（毫秒）：" + (Util.GetTime() - downTime));

        //下载完成存储版本
        VersionManager.Instance.SetLocalGameVersion(this.mGameName, version.ToString());

        //第五步写入version文件
        string outVersionPath = this.mSaveResAssetsPath + VersionFileName;
        //存储本地版本数据文件
        File.WriteAllText(outVersionPath, VersionManager.Instance.GetLocalVersionJson());

        this.mUpgradeProgress = updateProgress;
        this.ProgressCallback(upgradeStatus, this.mUpgradeProgress);
        yield return null;
    }

    /// <summary>
    /// files文件下载成功处理
    /// </summary>
    private void OnFilesLoadSuccessCallback(WWW www)
    {
        this.mFilesContent = www.text;
    }

    /// <summary>
    /// files文件下载失败处理
    /// </summary>
    private void OnFilesLoadFailCallback()
    {
        if (Application.internetReachability == NetworkReachability.NotReachable)
        {
            Alert.Show("更新资源失败，请检查网络！", AlertType.Prompt, "重试", OnReloadAlertCallback, "退出", OnQuitAlertCallback);
        }
        else
        {
            Alert.Show("更新资源失败，请稍后重试！", AlertType.Prompt, "重试", OnReloadAlertCallback, "退出", OnQuitAlertCallback);
        }
    }

    /// <summary>
    /// 解析更新文件列表
    /// </summary>
    private void ParseFilesList(string txt)
    {
        updateFilesDic.Clear();

        try
        {
            Md5FilesData md5FilesData = JsonMapper.ToObject<Md5FilesData>(txt);
            if (md5FilesData != null && md5FilesData.datas != null)
            {
                Md5FileSingleData md5FileSingleData = null;
                for (int i = 0; i < md5FilesData.datas.Count; i++)
                {
                    md5FileSingleData = md5FilesData.datas[i];
                    if (md5FileSingleData != null && !string.IsNullOrEmpty(md5FileSingleData.name))
                    {
                        updateFilesDic.Add(md5FileSingleData.name, md5FileSingleData);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    /// <summary>
    /// 本地对比，获取到需要更新和删除的文件
    /// </summary>
    private List<string> CheckUpdateFiles()
    {
        List<string> deleteList = new List<string>();
        DirectoryInfo dirInfo = new DirectoryInfo(this.mSaveGameAssetsPath);
        string dirFullName = dirInfo.FullName;
        //Debug.Log(">> UpdateManager > CheckUpdateFiles > dirFullName = " + dirFullName);
        FileInfo[] fileInfos = dirInfo.GetFiles("*.*", SearchOption.AllDirectories);

        string gameDir = this.mGameName.ToLower() + "/";

        string tempFilePath;
        string tempFileFullPath;
        string tempMd5;
        Md5FileSingleData md5FileSingleData;
        foreach (FileInfo fileInfo in fileInfos)
        {
            tempFileFullPath = fileInfo.FullName;
            tempFilePath = gameDir + tempFileFullPath.Replace(dirFullName, "").Replace("\\", "/");
            if (updateFilesDic.ContainsKey(tempFilePath))
            {
                tempMd5 = Util.md5file(tempFileFullPath);
                md5FileSingleData = updateFilesDic[tempFilePath];
                if (tempMd5.Equals(md5FileSingleData.md5))
                {
                    md5FileSingleData.SetNeedUpdate(false);
                }
            }
            else
            {
                deleteList.Add(tempFileFullPath);
            }
        }
        return deleteList;
    }

    /// <summary>
    /// 删除文件
    /// </summary>
    private void DeleteFiles(List<string> list)
    {
        try
        {
            foreach (string path in list)
            {
                File.Delete(path);
            }
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    /// <summary>
    /// 更新资源文件
    /// </summary>
    IEnumerator UpdateFiles(string loadUrlPath, float updateProgress, int upgradeStatus, bool isLocalExtract)
    {
        float currTotalProgress = updateProgress - this.mUpgradeProgress;

        this.mUpgradeFileTotal = updateFilesDic.Count;
        this.mUpgradeFileCount = 0;
        this.mNeedUpgradeFileTotal = 0;
        this.mUpgradeSuccessFileCount = 0;

        string inFilePath = null;
        string inFileSpareUrl = null;

        foreach (KeyValuePair<string, Md5FileSingleData> kv in updateFilesDic)
        {
            this.mUpgradeFileCount++;
            this.mMd5FileSingleData = kv.Value;
            if (!this.mMd5FileSingleData.GetNeedUpdate()) { continue; }
            this.mNeedUpgradeFileTotal++;

            inFilePath = loadUrlPath + this.mMd5FileSingleData.name;

            yield return this.DownloadFile(inFilePath, this.OnUpdateFileLoadSuccessCallback, this.OnUpdateFileLoadFailCallback);

            float progress = (float)this.mUpgradeFileCount / (float)this.mUpgradeFileTotal;
            float upgradeProgress = this.mUpgradeProgress + progress * currTotalProgress;

            this.ProgressCallback(upgradeStatus, upgradeProgress);
        }
        yield return null;
        this.mMd5FileSingleData = null;
        if (this.mUpgradeSuccessFileCount != this.mNeedUpgradeFileTotal)//文件没有完全更新完成（可能写文件出错了），则提示，也是便于调试，一般情况是不会出现该情况的
        {
            Debug.LogWarning(">> Upgrade > UpdateFiles > file num error > " + this.mUpgradeSuccessFileCount + "/" + this.mNeedUpgradeFileTotal);
            Alert.Show("更新资源失败，请联系客服！", "退出", OnQuitAlertCallback);
            yield return this.CoroutineWaiting();
        }
    }

    private void OnUpdateFileLoadSuccessCallback(WWW www)
    {
        try
        {
            string outFilePath = this.mSaveResAssetsPath + this.mMd5FileSingleData.name;
            Debug.LogWarning(">> Upgrade > OnUpdateFileLoadSuccessCallback > OutFilePath > ");
            Debug.LogWarning(outFilePath);

            FileInfo outFileInfo = new FileInfo(outFilePath);
            if (!outFileInfo.Directory.Exists)
            {
                outFileInfo.Directory.Create();
            }

            File.WriteAllBytes(outFilePath, www.bytes);
            this.mUpgradeSuccessFileCount++;
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    /// <summary>
    /// 资源文件下载失败处理
    /// </summary>
    private void OnUpdateFileLoadFailCallback()
    {
        if (Application.internetReachability == NetworkReachability.NotReachable)
        {
            Alert.Show("更新资源失败，请检查网络。", AlertType.Prompt, "重试", OnReloadAlertCallback, "退出", OnQuitAlertCallback);
        }
        else
        {
            Alert.Show("更新资源失败，请稍后重试。", AlertType.Prompt, "重试", OnReloadAlertCallback, "退出", OnQuitAlertCallback);
        }
    }

    //================================================================

    /// <summary>
    /// 协同检测获取资源服务器Url路径
    /// </summary>
    IEnumerator CoroutineCheckGetResServerUrlPath()
    {
        Debug.LogWarning(">> Upgrade > CoroutineCheckGetResServerUrlPath > Enter > " + AppConst.IsCheckRemoteUpgrade);
        yield return null;
        if (AppConst.IsCheckRemoteUpgrade)
        {
            if (AppConst.IsUseDun)
            {
                this.mIsCheckingResServerUrlPath = true;
                this.CheckAndGetSecurityServerAddress();
                while (this.mIsCheckingResServerUrlPath)
                {
                    yield return null;
                }
            }
            else
            {
                this.mResServerUrlPath = RemoteResUrl + UpgradeManager.RemoteZonePrefix;
                Debug.LogError(">> Upgrade > CoroutineCheckGetResServerUrlPath > ResServerUrlPath > " + this.mResServerUrlPath);
            }
        }
    }


    /// <summary>
    /// 处理盾
    /// </summary>
    private void CheckAndGetSecurityServerAddress()
    {
        Debug.LogWarning(">> Upgrade > CheckAndGetSecurityServerAddress > Enter.");
        PlatformManager.Instance.SetDunCallback(this.OnDunInitCallback, this.OnDunGetCallback);
        if (AppConst.IsInitDun)
        {
            //盾已经初始化了，就直接获取端口
            this.OnDunInitCallback();
        }
        else
        {
            try
            {
                //构造发送数据
                JsonData jsonData = new JsonData();
                jsonData["dataType"] = 1;
                jsonData["shieldType"] = 3;
                jsonData["accessKey"] = AppConst.DunAccessKey;
                jsonData["uuid"] = AppConst.DunUuid;
                string jsonString = jsonData.ToJson();
                //Debug.LogWarning(">> Upgrade > CheckAndGetSecurityServerAddress > jsonString > " + jsonString);
                PlatformHelper.HandleData(jsonString);
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }
    }

    /// <summary>
    /// 处理盾回调
    /// </summary>
    private void OnDunInitCallback()
    {
        Debug.LogWarning(">> Upgrade > OnDunInitCallback > Enter.");
        try
        {
            string key = "" + AppConst.DunPort;
            //构造发送数据
            JsonData jsonData = new JsonData();
            jsonData["dataType"] = 2;
            jsonData["shieldType"] = 3;
            jsonData["key"] = key;
            jsonData["host"] = "";
            jsonData["port"] = AppConst.DunPort;
            string jsonString = jsonData.ToJson();
            //Debug.LogWarning(">> Upgrade > OnDunInitCallback > jsonString > " + jsonString);
            PlatformManager.Instance.AddDunGetDataKey(key);
            PlatformHelper.HandleData(jsonString);
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    /// <summary>
    /// 处理盾回调
    /// </summary>
    private void OnDunGetCallback(int code, int port)
    {
        Debug.LogError(">> Upgrade > OnDunGetCallback > Enter.");
        if (code == 0)
        {
            this.mResServerUrlPath = string.Format("http://{0}:{1}/{2}", "127.0.0.1", port, UpgradeManager.RemoteZonePrefix);
            Debug.LogError(">> Upgrade > OnDunGetCallback > ResServerUrlPath > " + this.mResServerUrlPath);
            //移除回调
            PlatformManager.Instance.SetDunCallback(null, null);
            //可以继续执行下一步了
            this.mIsCheckingResServerUrlPath = false;
        }
        else
        {
            Alert.Show("初始化网络错误！", AlertType.Prompt, "重试", OnRetryCheckDunCallback, "退出", OnQuitAlertCallback);
        }
    }

    /// <summary>
    /// 重新尝试获取盾
    /// </summary>
    private void OnRetryCheckDunCallback()
    {
        this.CheckAndGetSecurityServerAddress();
    }


    //================================================================

    /// <summary>
    /// 获取一个随机的guid作为无效参数确保www能更新
    /// </summary>
    public static string GetRandomNumber()
    {
        return "?v=" + DateTime.Now.ToString("yyyymmddhhmmss");
    }

}

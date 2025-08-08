using UnityEngine;
using System;
using System.Collections;
using LitJson;
using System.Text;

namespace LuaFramework
{
    public class GameManager : Manager
    {
        /// <summary>
        /// 初始化完成标识
        /// </summary>
        protected static bool Initialized = false;

        /// <summary>
        /// 初始化游戏管理器
        /// </summary>
        void Awake()
        {
            PlatformHelper.InitPlatform();
            Init();
        }

        void Start()
        {
        }

        /// <summary>
        /// 初始化
        /// </summary>
        private void Init()
        {
            DontDestroyOnLoad(gameObject);  //防止销毁自己

            Screen.sleepTimeout = SleepTimeout.NeverSleep;
            //Application.targetFrameRate = AppConst.GameFrameRate;
            Debug.unityLogger.logEnabled = AppConst.DebugMode;

#if UNITY_EDITOR
            Application.runInBackground = true;
#endif
            Debug.Log(">> GameManager > Init.");
            Debug.Log(">> GameManager > IsCheckUpgrade = " + AppConst.IsCheckUpgrade());
            Debug.Log(">> GameManager > IsCheckRemoteUpgrade = " + AppConst.IsCheckRemoteUpgrade);

            StartCoroutine(this.LoadConfig());
        }

        /// <summary>
        /// 协同检测远端配置
        /// </summary>
        IEnumerator LoadConfig()
        {
            string configPath = Assets.StreamingAssetsUrlPath + "Config.txt";
            WWW www = new WWW(configPath);
            yield return www;
            if (!string.IsNullOrEmpty(www.error) || www.bytes == null)
            {
                //用于内部提示，回调容错
                Alert.Show("初始化失败，请退出重试！", this.OnExitAppAlertCallback);
            }
            else
            {
                try
                {
                    byte[] bytes = ExceptionUtil.Decode(www.bytes);
                    string configTxt = Encoding.UTF8.GetString(bytes);

                    JsonData jsonData = JsonMapper.ToObject(configTxt);

                    AppConst.IsCheckRemoteUpgrade = JsonUtil.GetBool(jsonData, "IsCheckRemote");
                    AppConst.IsUseDun = JsonUtil.GetBool(jsonData, "IsUseDun");
                    //
                    UpgradeManager.RemoteResUrl = JsonUtil.GetString(jsonData, "RemoteResUrl");
                    UpgradeManager.RemoteZonePrefix = JsonUtil.GetString(jsonData, "RemoteZonePrefix");
                    //
                    AppConst.DunAccessKey = JsonUtil.GetString(jsonData, "DunAccessKey");
                    AppConst.DunUuid = JsonUtil.GetString(jsonData, "DunUuid");
                    AppConst.DunHost = JsonUtil.GetString(jsonData, "DunHost");
                    AppConst.DunPort = JsonUtil.GetInt(jsonData, "DunPort");

                    //检测更新
                    this.CheckUpgrade();
                }
                catch (Exception ex)
                {
                    Debug.LogException(ex);
                    Alert.Show("初始化失败，配置错误！", this.OnExitAppAlertCallback);
                }
            }
        }

        /// <summary>
        /// 检查更新
        /// </summary>
        private void CheckUpgrade()
        {
            Loading.Begin(UpgradeStatus.BeginTipsTxt, null);
            if (AppConst.IsCheckUpgrade())
            {
                GameUpgradeManager.Instance.Check(this.OnCheckUpgradeCompleted);
            }
            else
            {
                this.OnCheckUpgradeCompleted();
            }
        }

        /// <summary>
        /// 检测更新完成
        /// </summary>
        private void OnCheckUpgradeCompleted()
        {
            Debug.Log(">> GameManager > OnCheckUpdateCompleted.");
            this.StartResourceInitialize();
        }

        /// <summary>
        /// 启动资源初始化
        /// </summary>
        private void StartResourceInitialize()
        {
            //资源管理器初始化
            ResManager.Initialize();
#if UNITY_EDITOR
            if(EditorConst.editorAssetsType == EditorAssetsType.Editor)
            {
                //todo
            }
            else
#endif
            {
                //添加基础依赖
                ResManager.AddDependencies(AppConst.BaseName.ToLower());
            }
            this.OnResourceInitialize();
        }

        /// <summary>
        /// 资源初始化完成，然后初始化Lua相关
        /// </summary>
        private void OnResourceInitialize()
        {
            LuaManager.InitStart();
            //进入Lua层游戏入口
            LuaManager.DoFile("AppGame");

            Initialized = true;
        }

        /// <summary>
        /// 析构函数
        /// </summary>
        void OnDestroy()
        {
            if (LuaManager != null)
            {
                LuaManager.Close();
            }
            Debug.Log("~GameManager was destroyed");
        }

        /// <summary>
        /// App焦点切换
        /// </summary>
        void OnApplicationFocus(bool hasFocus)
        {
            if (Initialized)
            {
                PlatformManager.Instance.ApplicationFocus(hasFocus);
            }
        }

        /// <summary>
        /// App的pauseStatus切换
        /// </summary>
        void OnApplicationPause(bool pauseStatus)
        {
            if (Initialized)
            {
                PlatformManager.Instance.ApplicationPause(pauseStatus);
            }
        }

#if UNITY_ANDROID
        /// <summary>
        /// 处理返回键
        /// </summary>
        void Update()
        {
            if(Input.GetKeyDown(KeyCode.Escape))
            {
                //有提示显示，就不显示返回键的提示
                if(!Alert.IsActive())
                {
                    if(AppConst.IsLuaStarted)
                    {
                        PlatformManager.Instance.EscapeKeyDown();
                    }
                    else
                    {
                        Alert.Show("是否退出游戏吗？", OnExitAppAlertCallback, null);
                    }
                }
            }
        }
#endif

        /// <summary>
        /// 退出应用提示处理
        /// </summary>
        void OnExitAppAlertCallback()
        {
            PlatformHelper.QuitGame();
        }

    }

}
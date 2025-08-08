using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

public class AppConst
{
    /// <summary>
    /// 调试模式-用于内部测试，发布版本的时候需要注意设置初始值
    /// </summary>
    public static bool DebugMode = true;

    /// <summary>
    /// 是否是使用Bundle包进行压缩Lua文件，默认为true
    /// </summary>
    public const bool LuaBundleMode = true;

    /// <summary>
    /// Timer使用
    /// </summary>
    public const int TimerInterval = 1;
    /// <summary>
    /// 游戏帧频
    /// </summary>
    public const int GameFrameRate = 60;

    /// <summary>
    /// 应用程序名称
    /// </summary>
    public const string AppName = "";
    /// <summary>
    /// Lua临时目录，拷贝Lua时使用
    /// </summary>
    public const string LuaTempDir = "Lua/";
    /// <summary>
    /// 资源AB包扩展名
    /// </summary>
    public const string AssetExtName = ".unity3d";
    /// <summary>
    /// StreamingAssets资源目录 
    /// </summary>
    public const string StreamingAssetsDir = "StreamingAssets";

    /// <summary>
    /// Http服务器地址
    /// </summary>
    public static string HttpServerUrl = string.Empty;
    /// <summary>
    /// Socket服务器端口
    /// </summary>
    public static int SocketPort = 0;
    /// <summary>
    /// Socket服务器地址
    /// </summary>
    public static string SocketAddress = string.Empty;

    /// <summary>
    /// LuaFrameworkd的路径
    /// </summary>
    public static string LuaFrameworkRoot
    {
        get
        {
            return Application.dataPath + "/LuaFramework";
        }
    }

    //================================================================

    /// <summary>
    /// UI，Canvas的ReferenceResolution设置
    /// </summary>
    public static Vector2 ReferenceResolution = new Vector2(1280, 720);


    //================================================================

    /// <summary>
    /// 资源路径名称
    /// </summary>
    public static string ResPathName = "res";
    /// <summary>
    /// Base名称
    /// </summary>
    public static string BaseName = "Base";

    /// <summary>
    /// APP包名
    /// </summary>
    public static string AppPackgeName = string.Empty;

    /// <summary>
    /// 是否安装了微信
    /// </summary>
    public static bool IsWXAppInstalled = false;
    /// <summary>
    /// 是否安装了闲聊
    /// </summary>
    public static bool IsXLAppInstalled = false;

    /// <summary>
    /// 平台是否初始化完成，在平台设置版本号后就一起设置
    /// </summary>
    public static bool IsPlatformInited = false;

    /// <summary>
    /// 是否是在模拟器上运行
    /// </summary>
    public static bool IsEmulator = false;

    /// <summary>
    /// 是否Lua启动
    /// </summary>
    public static bool IsLuaStarted = false;


    //================================================================
    /// <summary>
    /// APP版本号，用于对比APP是否更新
    /// </summary>
    public static Version AppVersion = new Version(1, 0, 1);//使用原生设置
    /// <summary>
    /// APP的字符串版本号
    /// </summary>
    private static string mAppVerStr = null;
    /// <summary>
    /// APP的字符串版本号
    /// </summary>
    public static string AppVerStr
    {
        get
        {
            if (string.IsNullOrEmpty(mAppVerStr))
            {
                mAppVerStr = AppVersion.ToString();
            }
            return mAppVerStr;
        }
    }

    /// <summary>
    /// 设置APP的版本号，一把情况下是给原生调用
    /// </summary>
    /// <param name="versionStr"></param>
    public static void SetAppVersion(string versionStr)
    {
        AppVersion = new Version(versionStr);
        mAppVerStr = AppVersion.ToString();
    }

    /// <summary>
    /// APP的数值版本号
    /// </summary>
    public static int AppVerNum
    {
        get
        {
            int result = 0;
            result = AppVersion.Major * 10000;
            result += AppVersion.Minor * 100;
            result += AppVersion.Build;
            return result;
        }
    }

    //================================================================

    /// <summary>
    /// 是否检测远端更新，如果不检测的话，就只对StreamingAssets下进行对比拷贝
    /// </summary>
    public static bool IsCheckRemoteUpgrade = true;
    /// <summary>
    /// 是否使用盾，使用盾的话，优先用盾获取资源URL路径
    /// </summary>
    public static bool IsUseDun = false;
    /// <summary>
    /// 盾的AK
    /// </summary>
    public static string DunAccessKey = null;
    /// <summary>
    /// 盾的ID
    /// </summary>
    public static string DunUuid = null;
    /// <summary>
    /// 盾的Host
    /// </summary>
    public static string DunHost = null;
    /// <summary>
    /// 盾的Port
    /// </summary>
    public static int DunPort = 0;
    /// <summary>
    /// 是否初始化了盾，如果C#层使用了盾，初始化后就需要设置该值
    /// </summary>
    public static bool IsInitDun = false;

    /// <summary>
    /// 是否检测更新
    /// </summary>
    /// <returns></returns>
    public static bool IsCheckUpgrade()
    {
        bool isCheckUpgrade = true;

#if UNITY_EDITOR
        //编辑器下，模拟发布就要进行更新，完全模拟发布后的更新方式，也会进行网络更新
        isCheckUpgrade = EditorConst.editorAssetsType == EditorAssetsType.Release;
#endif
#if !UNITY_EDITOR && UNITY_STANDALONE
            //电脑版本就不进行更新
            isCheckUpgrade = false;
#endif
        return isCheckUpgrade;
    }

    /// <summary>
    /// 获取更新的平台名称
    /// </summary>
    public static string GetUpgradePlatformName()
    {
#if UNITY_IPHONE
            return "iOS";
#elif UNITY_ANDROID
            return "android";
#else
        return "standalone";
#endif
    }

}
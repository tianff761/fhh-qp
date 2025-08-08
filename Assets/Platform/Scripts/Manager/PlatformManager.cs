using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using LitJson;
using LuaFramework;
using System.IO;

/// <summary>
/// 处理与原生平台相关交互
/// </summary>
public class PlatformManager : MonoBehaviour
{
    private static PlatformManager mInstance;

    /// <summary>
    /// Lua的脚本文件名称
    /// </summary>
    public static string LuaScriptName = "AppPlatformHelper";

    public static PlatformManager Instance
    {
        get
        {
            if (mInstance == null)
            {
                mInstance = TMonoBehaviourHelper.GetManagerInstance<PlatformManager>("UnityPlatform");
            }
            return mInstance;
        }
    }


    public void Init()
    {

    }

    /// <summary>
    /// App焦点切换
    /// </summary>
    public void ApplicationFocus(bool hasFocus)
    {
        Util.CallMethod(LuaScriptName, "OnApplicationFocus", hasFocus);
    }

    /// <summary>
    /// App的pauseStatus切换
    /// </summary>
    public void ApplicationPause(bool pauseStatus)
    {
        Util.CallMethod(LuaScriptName, "OnApplicationPause", pauseStatus);
    }

    /// <summary>
    /// 返回键按下，用于Android提示退出游戏
    /// </summary>
    public void EscapeKeyDown()
    {
        Util.CallMethod(LuaScriptName, "OnEscapeKeyDown");
    }


    //================================================================
    /// <summary>
    /// 设置是否是模拟器
    /// </summary>
    /// <param name="isEmulator"></param>
    public void SetIsEmulator(string isEmulator)
    {
        Boolean.TryParse(isEmulator, out AppConst.IsEmulator);
    }

    /// <summary>
    /// 打开某个App回调
    /// </summary>
    public void OpenAppCallback(string isinstall)
    {
        LuaUtil.CallMethod(LuaScriptName, "OpenAppCallback", isinstall);
    }

    /// <summary>
    /// 设置包名
    /// </summary>
    public void SetAppPackgeName(string name)
    {
        AppConst.AppPackgeName = name;
    }

    /// <summary>
    /// 设置应用版本号
    /// </summary>
    /// <param name="version"></param>
    public void SetAppVersion(string version)
    {
        AppConst.SetAppVersion(version);
    }

    /// <summary>
    /// 设置原生平台初始化完成
    /// </summary>
    public void SetPlatformInited(string value)
    {
        AppConst.IsPlatformInited = true;
    }

    /// <summary>
    /// 调用Lua中的Toast
    /// </summary>
    /// <param name="text"></param>
    public void ShowLuaToast(string text)
    {
        LuaUtil.CallMethod(LuaScriptName, "ShowToast", text);
    }


    /// <summary>
    /// 设置是否安装了微信标识
    /// </summary>
    public void SetIsWXAppInstalled(string isInstalled)
    {
        Boolean.TryParse(isInstalled, out AppConst.IsWXAppInstalled);
    }

    /// <summary>
    /// 平台授权回调
    /// </summary>
    /// <param name="data"></param>
    public void AuthCallback(string data)
    {
        AuthLoginHelper.AuthLogin(data);
    }

    /// <summary>
    /// 登录回调
    /// </summary>
    /// <param name="data"></param>
    public void LoginCallback(string data)
    {
        Util.LogWarning(data);
    }

    /// <summary>
    /// 分享回调
    /// </summary>
    /// <param name="data"></param>
    public void ShareCallback(string data)
    {
        PlatformHelper.ClearShareImagePngBytes();
        LuaUtil.CallMethod(LuaScriptName, "ShareCallback", data);
    }

    /// <summary>
    /// 复制回调
    /// </summary>
    /// <param name="result"></param>
    public void CopyTextCallback(string result)
    {
        LuaUtil.CallMethod(LuaScriptName, "CopyTextCallback", result);
    }

    /// <summary>
    /// 获取粘贴板内容回调
    /// </summary>
    /// <param name="result"></param>
    public void GetCopyTextCallback(string result)
    {
        LuaUtil.CallMethod(LuaScriptName, "GetCopyTextCallback", result);
    }

    /// <summary>
    /// 获取房间号回调
    /// </summary>
    public void GetRoomCodeCallback(string value)
    {
        LuaUtil.CallMethod(LuaScriptName, "GetRoomCodeCallback", value);
    }

    /// <summary>
    /// 获取电量回调回调
    /// </summary>
    public void GetBatteryStateCallback(string value)
    {
        LuaUtil.CallMethod(LuaScriptName, "GetBatteryStateCallback", value);
    }

    /// <summary>
    /// 数据交互回调，如果以后要修改，盾的接口需要单独出来，与其他数据分开
    /// </summary>
    public void OnHandleDataCallback(string content)
    {
        Debug.LogError(">> OnHandleDataCallback.");
        this.HandleData(content);
    }

    /// <summary>
    /// 当调用android原始退出方法try出现异常时，调用该方法
    /// </summary>
    public void QuitGameCallback(string content)
    {
        Application.Quit();
    }

    /// <summary>
    /// 获取手机是否开启GPS回调
    /// </summary>
    /// <param name="content">"0":是,"1":否</param>
    public void GetIsOpenAppGPSCallback(string content)
    {
        LuaUtil.CallMethod(LuaScriptName, "GetIsOpenAppGPSCallback", content);
    }

    public void GetOriginGpsCallback(string value)
    {
        Debug.LogError("GetOriginGpsCallback" + value);
        string[] gpsValue = value.Split(' ');
        double Latitude;
        double.TryParse(gpsValue[0],out Latitude);
        double Longitude;
        double.TryParse(gpsValue[1], out Longitude);
        float latitude = (float)Latitude;
        float longitude = (float)Longitude;
        LuaUtil.CallMethod(LuaScriptName, "GetOriginGpsCallback", latitude, longitude);
    }

    /// <summary>
    /// 获取应用是否开启GPS回调
    /// </summary>
    /// <param name="content">"0":是,"1":否</param>
    public void GetIsAppGPSEnableCallback(string content)
    {
        Debug.LogError("C#取得GPS开启回调 GetIsAppGPSEnableCallback!");
        LuaUtil.CallMethod(LuaScriptName, "GetIsAppGPSEnableCallback", content);
    }

    /// <summary>
    /// 获取应用是否开启某个权限回调
    /// </summary>
    /// <param name="content">"0":是,"1":否</param>
    public void GetIsAppAnyEnableCallback(string content)
    {
        LuaUtil.CallMethod(LuaScriptName, "GetIsAppAnyEnableCallback", content);
    }

    /// <summary>
    /// 截图监听事件
    /// </summary>
    public void ScreenShotListen(string imagePath)
    {
        LuaUtil.CallMethod(LuaScriptName, "OnScreenShotListen", imagePath);
    }

    /// <summary>
    /// 获取位置信息回调
    /// </summary>
    public void GpsLocationCallback(string content)
    {
        LuaUtil.CallMethod(LuaScriptName, "OnGpsLocation", content);
    }

    /// <summary>
    /// 初始化设置Lua 判断是否为miniGame
    /// </summary>
    public void SetIsMiniGame()
    {
        LuaUtil.CallMethod(LuaScriptName, "SetIsMiniGame", 0);
    }


    /// <summary>
    /// 判断是否保存图片成功
    /// </summary>
    /// <param name="content">"0":是,"1":否</param>
    public void SaveImageResult(string content)
    {
        LuaUtil.CallMethod(LuaScriptName, "SaveImageResult", content);
    }

    /// <summary>
    /// 从相册获取图片路径回调
    /// </summary>
    public void GetImagePathByPhotoCallback(string imagePath)
    {
        LuaUtil.CallMethod(LuaScriptName, "GetImagePathByPhotoCallback", imagePath);
    }

    /// <summary>
	/// 打开相册相机后的从ios回调到unity的方法
	/// </summary>
	/// <param name="base64">Base64.</param>
	void OnSaveImgiOSToUnity(string base64)
    {

#if !UNITY_EDITOR && UNITY_IPHONE
        try
        {
            string strDir = Assets.RuntimeAssetsPath + "temp";
            if (!Directory.Exists(strDir))
            {
                Directory.CreateDirectory(strDir);
            }

            string strSaveFile = strDir + "/head.png";
            if (File.Exists(strSaveFile))
            {
                File.Delete(strSaveFile);
            }
            byte[] dataBytes = System.Convert.FromBase64String(base64);
            FileStream fs = File.Open(strSaveFile, FileMode.OpenOrCreate);
            fs.Write(dataBytes, 0, dataBytes.Length);
            fs.Flush();
            fs.Close();
            Debug.Log("保存图片成功");
            this.GetImagePathByPhotoCallback(strSaveFile);
        }
        catch (System.Exception ex)
        {
            Debug.LogError("保存图片失败" + ex.Message);
            this.GetImagePathByPhotoCallback("");
        }
#endif
    }

    //================================================================
    //========盾相关========

    private Dictionary<string, string> dunGetDataKeyDict = new Dictionary<string, string>();
    private Action dunInitCallback = null;
    private Action<int, int> dunGetPortCallback = null;

    /// <summary>
    /// 设置盾获取数据的key，目的是区分数据分派
    /// </summary>
    public void AddDunGetDataKey(string key) 
    {
        if (!dunGetDataKeyDict.ContainsKey(key)) 
        {
            dunGetDataKeyDict.Add(key, key);
        }
    }

    /// <summary>
    /// 移除
    /// </summary>
    public void RemoveDunGetDataKey(string key)
    {
        if (dunGetDataKeyDict.ContainsKey(key))
        {
            dunGetDataKeyDict.Remove(key);
        }
    }

    /// <summary>
    /// 设置盾的回调
    /// </summary>
    public void SetDunCallback(Action initCallback, Action<int, int> getPortCallback) 
    {
        this.dunInitCallback = initCallback;
        this.dunGetPortCallback = getPortCallback;
    }

    /// <summary>
    /// 处理数据
    /// </summary>
    private void HandleData(string content)
    {
        Debug.LogError(">> PlatformManager > HandleData > 1.");
        try
        {
            JsonData jsonData = JsonMapper.ToObject(content);
            int dataType = JsonUtil.GetInt(jsonData, "dataType");
            int code = JsonUtil.GetInt(jsonData, "code", -1);
            if (dataType == 1)//盾初始化
            {
                if (code == 0)
                {
                    AppConst.IsInitDun = true;
                    if (this.dunInitCallback != null)
                    {
                        this.dunInitCallback();
                    }
                    if (AppConst.IsLuaStarted)
                    {
                        LuaUtil.CallMethod(LuaScriptName, "OnHandleDataCallback", content);
                    }
                }
                else
                {
                    Alert.Show("网络初始化错误", this.OnExitAppAlertCallback);
                    Debug.LogError(">> PlatformManager > HandleData > Error > " + content);
                }
            }
            else if (dataType == 2)//盾获取数据
            {
                string key = JsonUtil.GetString(jsonData, "key");
                if (this.dunGetDataKeyDict.ContainsKey(key))
                {
                    this.RemoveDunGetDataKey(key);
                    if (this.dunGetPortCallback != null)
                    {
                        this.dunGetPortCallback(code, JsonUtil.GetInt(jsonData, "port"));
                    }
                }
                else
                {
                    if (AppConst.IsLuaStarted)
                    {
                        LuaUtil.CallMethod(LuaScriptName, "OnHandleDataCallback", content);
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
    /// 退出应用提示处理
    /// </summary>
    private void OnExitAppAlertCallback()
    {
        PlatformHelper.QuitGame();
    }
}

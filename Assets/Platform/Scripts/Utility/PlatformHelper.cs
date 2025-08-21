using UnityEngine;
using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using LuaInterface;
using System.Runtime.InteropServices;
using LuaFramework;


public class PlatformHelper
{

    private static string RoomCode = "";
    /// <summary>
    /// 用于分享图片的png数据
    /// </summary>
    private static byte[] ShareImagePngBytes = null;

#if !UNITY_EDITOR && UNITY_ANDROID

    private static AndroidJavaObject androidJavaObject = null;

    private static AndroidJavaObject GetAndroidActivity()
    {
        if (androidJavaObject == null)
        {
            try
            {
                AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
                androidJavaObject = jc.GetStatic<AndroidJavaObject>("currentActivity");
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }
        return androidJavaObject;
    }

    public static void CallAndroidApi(string func, params object[] args)
    {
        AndroidJavaObject jo = GetAndroidActivity();
        if (jo != null)
        {
            try
            {
                jo.Call(func, args);
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }
    }

    public static T CallAndroidApi<T>(string func, params object[] args)
    {
        AndroidJavaObject jo = GetAndroidActivity();
        if (jo != null)
        {
            try
            {
                return jo.Call<T>(func, args);
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }
        return default(T);
    }
#endif

#if !UNITY_EDITOR && UNITY_IPHONE

    // [DllImport("__Internal")]
    // private static extern void initPlatform();

    // [DllImport("__Internal")]
    // private static extern void setLuaStarted();

    [DllImport("__Internal")]
    private static extern void authLogin(int platformType);

    // [DllImport("__Internal")]
    // private static extern void setShareImagePngBytes(byte[] bytes, int length);

    // [DllImport("__Internal")]
    // private static extern void share(int platformType, int scene, byte[] title, byte[] content, byte[] imagePath, byte[] url, byte[] roomCode);

    // [DllImport("__Internal")]
    // private static extern void copyText(byte[] text);

    // [DllImport("__Internal")]
    // private static extern void getCopyText(byte[] tag);

    // [DllImport("__Internal")]
    // private static extern void clearAppData();

    // [DllImport("__Internal")]
    // private static extern void getRoomCode();

    // [DllImport("__Internal")]
    // private static extern void clearRoomCode();

    // [DllImport("__Internal")]
    // private static extern void getBatteryState(int state);

    // [DllImport("__Internal")]
    // private static extern void openDeviceSetting();

    // [DllImport("__Internal")]
    // private static extern void openOtherApp(int platformType);

    // [DllImport("__Internal")]
    // private static extern void startScreenShotListen();

    // [DllImport("__Internal")]
    // private static extern void stopScreenShotListen();

    // [DllImport("__Internal")]
    // private static extern void startRequestLocation();

    // [DllImport("__Internal")]
    // private static extern void stopRequestLocation();

    // [DllImport("__Internal")]
    // private static extern void handleData(string content);
#endif


    //================================================================
    //原生对接

    /// <summary>
    /// 初始化原生平台，有数据设置回调
    /// </summary>
    public static void InitPlatform()
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("initPlatform");
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        // initPlatform();
#endif

#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
        PlatformManager.Instance.SetIsEmulator("false");
        PlatformManager.Instance.SetAppVersion(Application.version);
        PlatformManager.Instance.SetPlatformInited("true");
#endif
    }

    /// <summary>
    /// 设置LUA准备好了
    /// </summary>
    public static void SetLuaStarted()
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("setLuaStarted");
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        // setLuaStarted();
#endif
    }


    /// 拷贝文本，有回调
    /// </summary>
    /// <param name="text"></param>
    public static void CopyText(string text)
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("copyText", text);
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        // byte[] bytes = System.Text.Encoding.UTF8.GetBytes(text);
        // copyText(bytes);
#endif
#if UNITY_EDITOR || UNITY_STANDALONE
        PlatformManager.Instance.CopyTextCallback("0");
#endif
    }

    /// <summary>
    /// 获取剪切板上的文本，有回调
    /// </summary>
    /// <param name="tag"></param>
    public static void GetCopyText(string tag)
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("getCopyText", tag);
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        // byte[] bytes = System.Text.Encoding.UTF8.GetBytes(tag);
        // getCopyText(bytes);
#endif

#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
        LuaUtil.CallMethod(PlatformManager.LuaScriptName, "GetCopyTextCallback", "{tag=\"1\",text = \"" + GUIUtility.systemCopyBuffer + "\"}");
#endif

#if UNITY_EDITOR
        LuaUtil.CallMethod(PlatformManager.LuaScriptName, "GetCopyTextCallback", "{tag=\"\";}");
#endif
    }

    /// <summary>
    /// 清除APP上的数据
    /// </summary>
    public static void ClearAppData()
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("clearAppData");
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        // clearAppData();
#endif
    }

    /// <summary>
    /// 获取快捷启动或者邀请的房间号
    /// </summary>
    public static void GetRoomCode()
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("getRoomCode");
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        // getRoomCode();
#endif
    }

    /// <summary>
    /// 清除快捷启动或者邀请的房间号
    /// </summary>
    public static void ClearRoomCode()
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("clearRoomCode");
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        // clearRoomCode();
#endif
    }

    /// <summary>
    /// 获取电池状态，包括电量等，数据直接返回
    /// </summary>
    public static void GetBatteryState(int state)
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("getBatteryState");
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        // getBatteryState(state);
#endif
    }


    //================================================================
    /// <summary>
    /// 分享，有回调
    /// 1.纯文本分享，标题为空，描述不为空，则为纯文本分享
    /// 2.纯图片分享，标题、描述为空，图片路径（此时为本地图片路径，如果是网络图片，先用WWW下载，然后再获取到路径）不为空，则为纯图片分享;
    /// 3.截图分享，标题、描述为空，图片路径为空，则为截图分享;
    /// 4.默认图片网页类型分享（带标题、描述、图标、链接），标题、描述都不为空，图片路径为空，则为默认图片网页类型分享
    /// 5.指定图片网页类型分享（带标题、描述、图标、链接），标题、描述都不为空，图片路径不为空，则为指定图片网页类型分享
    /// </summary>
    public static void Share(int platformType, int scene, string title, string content, string imagePath, string url)
    {
        Share(platformType, scene, title, content, imagePath, url, "");
    }

    /// <summary>
    /// 分享
    /// </summary>
    public static void Share(int platformType, int scene, string title, string content, string imagePath, string url, string roomCode)
    {
        if (string.IsNullOrEmpty(roomCode))
        {
            roomCode = "empty_room_code";
        }
        //先处理是否截图
        if (string.IsNullOrEmpty(title) && string.IsNullOrEmpty(content) && string.IsNullOrEmpty(imagePath) && string.IsNullOrEmpty(url))
        {
            if (ShareImagePngBytes != null)
            {
                SetShareImagePngBytes(ShareImagePngBytes);
            }
        }

        //--------------------------------

#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("share", platformType, scene, title, content, imagePath, url, roomCode);
#endif

#if !UNITY_EDITOR && UNITY_IPHONE
        // byte[] titleBytes = System.Text.Encoding.UTF8.GetBytes(title);
        // byte[] contentBytes = System.Text.Encoding.UTF8.GetBytes(content);
        // byte[] imagePathBytes = System.Text.Encoding.UTF8.GetBytes(imagePath);
        // byte[] urlBytes = System.Text.Encoding.UTF8.GetBytes(url);
        // byte[] roomCodeBytes = System.Text.Encoding.UTF8.GetBytes(roomCode);

        // byte[] bTitle = new byte[titleBytes.Length + 1];
        // titleBytes.CopyTo(bTitle, 0);
        // bTitle[titleBytes.Length] = 0;

        // byte[] bContent = new byte[contentBytes.Length + 1];
        // contentBytes.CopyTo(bContent, 0);
        // bContent[contentBytes.Length] = 0;

        // byte[] bImagePath = new byte[imagePathBytes.Length + 1];
        // imagePathBytes.CopyTo(bImagePath, 0);
        // bImagePath[imagePathBytes.Length] = 0;

        // byte[] bUrl = new byte[urlBytes.Length + 1];
        // urlBytes.CopyTo(bUrl, 0);
        // bUrl[urlBytes.Length] = 0;

        // byte[] bRoomCode = new byte[roomCodeBytes.Length + 1];
        // roomCodeBytes.CopyTo(bRoomCode, 0);
        // bRoomCode[roomCodeBytes.Length] = 0;

        // share(platformType, scene, bTitle, bContent, bImagePath, bUrl, bRoomCode);
#endif
    }

    /// <summary>
    /// 设置分享图片数据
    /// </summary>
    private static void SetShareImagePngBytes(byte[] bytes)
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("setShareImagePngBytes", bytes);
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        // setShareImagePngBytes(bytes, bytes.Length);
#endif
    }

    ///// <summary>
    ///// 分享截图
    ///// </summary>
    //public static void ShareScreenshotImage(int platformType, int scene, string roomCode, int x = 0, int y = 0, int width = -1, int height = -1)
    //{
    //    CoroutineManager.Instance.StartCoroutine(HandleScreenshotImagePngBytes(
    //        delegate ()
    //        {
    //            Share(platformType, scene, "", "", "", "", roomCode);
    //        }
    //        , x, y, width, height
    //    ));
    //}

    /// <summary>
    /// 通过摄像机获取图片
    /// </summary>
    public static void ShareScreenshotImageByCamera(int platformType, int scene, string roomCode, string ScreenshotCameraName, int x = 0, int y = 0, int width = -1, int height = -1)
    {
        try
        {
            Camera camera = GameObject.Find(ScreenshotCameraName).GetComponent<Camera>();

            ShareImagePngBytes = GetScreenshotPngBytesByCamera(camera, x, y, width, height);

            Share(platformType, scene, "", "", "", "", roomCode);
        }
        catch (Exception)
        {
            Debug.LogError(">>>>>>>>>>>>>>>>>> ShareScreenshotImageByCamera LogError");
            throw;
        }

    }

    //================================================================
    //内部处理


    ///// <summary>
    ///// 处理分享截屏数据
    ///// </summary>
    //public static void HandleShareScreenshotImage(string roomCode, LuaFunction func, LuaTable arg, int x = 0, int y = 0, int width = -1, int height = -1)
    //{
    //    if (RoomCode != roomCode || ShareImagePngBytes == null)
    //    {
    //        RoomCode = roomCode;
    //        CoroutineManager.Instance.StartCoroutine(HandleScreenshotImagePngBytes(
    //            delegate ()
    //            {
    //                if (func != null)
    //                {
    //                    if (arg != null)
    //                    {
    //                        func.Call(arg);
    //                    }
    //                    else
    //                    {
    //                        func.Call();
    //                    }
    //                }
    //            }
    //            , x, y, width, height
    //        ));
    //    }
    //    else
    //    {
    //        if (func != null)
    //        {
    //            if (arg != null)
    //            {
    //                func.Call(arg);
    //            }
    //            else
    //            {
    //                func.Call();
    //            }
    //        }
    //    }
    //}


    //----------------------------------------------------------------


    ///// <summary>
    ///// 处理截屏数据，截屏需要在帧结尾
    ///// </summary>
    ///// <returns></returns>
    //private static IEnumerator HandleScreenshotImagePngBytes(Action callback, int x = 0, int y = 0, int width = -1, int height = -1)
    //{
    //    yield return new WaitForEndOfFrame();
    //    ShareImagePngBytes = GetScreenshotPngBytes(callback, x, y, width, height);
    //    if (callback != null)
    //    {
    //        callback.Invoke();
    //    }
    //}

    /// <summary>
    /// 处理截图数据，通过摄像机影像截图
    /// </summary>
    public static byte[] GetScreenshotPngBytesByCamera(Camera camera, int x = 0, int y = 0, int width = -1, int height = -1)
    {
        if (width < 1)
        {
            width = Screen.width;
        }

        if (height < 1)
        {
            height = Screen.height;
        }

        Rect rect = new Rect(x, y, width, height);
        // 创建一个RenderTexture对象  
        RenderTexture rt = new RenderTexture((int)rect.width, (int)rect.height, -1);
        // 临时设置相关相机的targetTexture为rt, 并手动渲染相关相机  
        camera.targetTexture = rt;
        camera.Render();

        //ps: -------------------------------------------------------------------  
        // 激活这个rt, 并从中中读取像素。  
        RenderTexture.active = rt;
        Texture2D screenShot = new Texture2D((int)rect.width, (int)rect.height, TextureFormat.RGB24, false);
        screenShot.ReadPixels(rect, 0, 0);// 注：这个时候，它是从RenderTexture.active中读取像素  
        screenShot.Apply();

        // 重置相关参数，以使用camera继续在屏幕上显示  
        camera.targetTexture = null;

        RenderTexture.active = null; // JC: added to avoid errors  
        GameObject.Destroy(rt);
        // 最后将这些纹理数据，成一个png图片文件  
        byte[] bytes = screenShot.EncodeToPNG();

        //System.IO.File.WriteAllBytes("C:/Users/mayn/Desktop/test/png.png", bytes);
        return bytes;
    }


    /// <summary>
    /// 获取截屏数据
    /// </summary>
    public static void GetScreenshotPngBytes(Action<byte[]> callback = null, int x = 0, int y = 0, int width = -1, int height = -1)
    {
        CoroutineManager.Instance.StartCoroutine(HandleScreenshot(callback, x, y, width, height));
    }

    public static IEnumerator HandleScreenshot(Action<byte[]> callback = null, int x = 0, int y = 0, int width = -1, int height = -1)
    {
        yield return new WaitForEndOfFrame();

        if (width < 1)
        {
            width = Screen.width;
        }

        if (height < 1)
        {
            height = Screen.height;
        }
        Rect rect = new Rect(x, y, width, height);

        Texture2D screenshotTxture = new Texture2D(width, height, TextureFormat.RGB24, false);

        screenshotTxture.ReadPixels(rect, 0, 0);
        screenshotTxture.Apply();

        byte[] bytes = screenshotTxture.EncodeToJPG();

        if (bytes.Length > 0)
        {
            Debug.Log("截图成功，拥有截图数据" + bytes.Length);
        }

        //File.WriteAllBytes("C:/Users/mayn/Desktop/test/png.png", bytes);

        if (callback != null)
        {
            callback.Invoke(bytes);
        }
    }

    //----------------------------------------------------------------

    /// <summary>
    /// 清除分享图片数据
    /// </summary>
    public static void ClearShareImagePngBytes()
    {
        RoomCode = "";
        ShareImagePngBytes = null;
    }

    /// <summary>
    /// 处理资源包的图片数据
    /// </summary>
    public static void HandleShareAssetImage(string abName, string assetName, LuaFunction func, LuaTable arg)
    {
        if (ShareImagePngBytes != null)
        {
            if (func != null)
            {
                if (arg != null)
                {
                    func.Call(arg);
                }
                else
                {
                    func.Call();
                }
            }
            return;
        }
        string imageKey = abName + "." + assetName;

        AppFacade.Instance.GetManager<ResourceManager>(ManagerName.Resource).LoadSprite(abName, assetName, (objs) =>
        {
            if (objs == null || objs.Length < 1) { return; }

            Sprite sprite = objs[0] as Sprite;
            if (sprite == null) { return; }

            Texture2D screenShot = sprite.texture;
            if (screenShot == null) { return; }

            byte[] bytes = screenShot.EncodeToJPG();
            ShareImagePngBytes = bytes;

            if (func != null)
            {
                if (arg != null)
                {
                    func.Call(arg);
                }
                else
                {
                    func.Call();
                }
            }
        });
    }



    /// <summary>
    /// 打开其他应用
    /// </summary>
    public static void OpenOtherApp(int platformType)
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("openOtherApp", platformType);
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        // openOtherApp(platformType);
#endif
    }

    /// <summary>
    /// 退出游戏
    /// </summary>
    public static void QuitGame()
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("QuitGame");
#else
        Application.Quit();
#endif
    }

    //-------------------------------------GPS相关------------------------------
    /// <summary>
    /// 设备是否开启GPS功能（仅限安卓）
    /// </summary>
    public static void GetIsOpenAppGPS()
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("isLocServiceEnable");
#endif
    }

    /// <summary>
    /// 应用是否拥有GPS功能（仅限安卓）
    /// </summary>
    public static void GetIsAppGPSEnable()
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        Debug.LogError("PlatformHelper GetIsAppGPSEnable!");
        CallAndroidApi("isAppGPSEnable");
#endif
    }

    public static void GetOriginGpsInfo()
    {
        Debug.LogError("PlatformHelper GetOriginGpsInfo!");
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("initGPSPosition");
#endif
    }


    /// <summary>
    /// 应用是否拥有某个权限
    /// </summary>
    /// <param name="str">传入权限类型</param>
    public static void GetIsAppAnyEnable(string permissionName)
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("isAppAnyEnable",permissionName);
#endif
    }

    /// <summary>
    /// 开启应用详细信息界面
    /// </summary>
    public static void OpenAppDetail()
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("openAppDetail");
#endif
    }

    /// <summary>
    /// 打开设备设置界面
    /// </summary>
    public static void OpenDeviceSetting()
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("openDeviceSetting");
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        // openDeviceSetting();
#endif
    }

    /// <summary>
    /// 开启监听截图
    /// </summary>
    public static void StartScreenShotListen()
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("startScreenShotListen");
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        // startScreenShotListen();
#endif
    }

    /// <summary>
    /// 停止监听截图
    /// </summary>
    public static void StopScreenShotListen()
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("stopScreenShotListen");
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        // stopScreenShotListen();
#endif
    }

    public static void SaveImageToPhone(UnityEngine.UI.Image image, string fileName = "")
    {
        SaveImageToPhone(image.sprite, fileName);
    }

    public static void SaveImageToPhone(Sprite image, string fileName = "")
    {
        SaveImageToPhone(image.texture, fileName);
    }

    public static void SaveImageToPhone(Texture2D image, string fileName = "")
    {
        SaveImageToPhone(image.EncodeToPNG(), fileName);
    }

    public static void SaveImageToPhone(byte[] bytes, string fileName = "")
    {
        if (string.IsNullOrEmpty(fileName))
        {
            fileName = Util.GetTime() + ".jpg";
        }
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("saveImageToPhone", fileName, bytes);
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        FileUtils.SaveToFile(fileName, bytes);
#endif
    }

    /// <summary>
    /// 显示平台toast
    /// </summary>
    public static void ShowPlatformToast(string content)
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("showToast", content);
#endif
    }

    //=================================================================

    /// <summary>
    /// 微信初始化
    /// </summary>
    public static void InitWeChat(string appId, string appSecret)
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("initWeChat", appId, appSecret);
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        //byte[] bytes = System.Text.Encoding.UTF8.GetBytes(appId);
        //byte[] bytes2 = System.Text.Encoding.UTF8.GetBytes(appSecret);
        //initWeChat(bytes, bytes.Length, bytes2, bytes2.Length);
#endif
    }

    /// <summary>
    /// 授权登录，有回调
    /// </summary>
    public static void AuthLogin(int platformType)
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("authLogin", platformType);
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        authLogin(platformType);
#endif
    }

    /// <summary>
    /// 从相册获取图片路径
    /// </summary>
    public static void GetImagePathByPhoto()
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("getImagePathByPhoto");
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        //openPhotoLibraryAllowsEditing();
#endif
    }

    /// <summary>
    /// 数据交互
    /// </summary>
    public static void HandleData(string content)
    {
#if !UNITY_EDITOR && UNITY_ANDROID
        CallAndroidApi("handleData", content);
#endif
#if !UNITY_EDITOR && UNITY_IPHONE
        // handleData(content);
#endif
    }

}

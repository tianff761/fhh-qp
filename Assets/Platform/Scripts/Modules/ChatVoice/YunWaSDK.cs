using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using LuaInterface;
using LuaFramework;
using YunvaIM;


/// <summary>
/// 1.初始化语音 调用YunWaInit()
/// 2.登陆云娃 调用 YunWaLogin()
/// 3.开始录音 调用 RecordStartRequest()
/// 4.停止录音 调用RecordStopRequest()
/// 5.上传语音 上传至七牛云
/// 6.开始播放 
/// </summary>
public class YunWaSDK : TSingleton<YunWaSDK>
{
    //下载文件请求
    private string filePath = "";
    private string recordPath = string.Empty;//返回录音地址
    private string recordUrlPath = string.Empty;//返回录音url地址

    //开始录音回调
    private Action<string, int> startRequestCallback;

    /// <summary>
    /// 云娃初始化 
    /// </summary>
    private YunWaSDK() { }

    public void YunWaInit(uint appKey, Action<int> Response)
    {
#if !UNITY_EDITOR && UNITY_ANDROID || !UNITY_EDITOR && UNITY_IPHONE
        EventListenerManager.AddListener(ProtocolEnum.IM_RECORD_VOLUME_NOTIFY, ImRecordVolume);
        int init = YunVaImSDK.instance.YunVa_Init(0, appKey, Application.persistentDataPath, false);
        if (init == 0)
        {
            Debug.Log("===========云娃语音初始化==================初始化成功...");
        }
        else
        {
            Debug.Log("============================初始化失败...");
        }
        Response(init);
#endif
    }
    /// <summary>
    /// 云娃登录
    /// </summary>
    /// <param name="nickName"></param>
    /// <param name="uid"></param>
    /// <param name="Response"></param>
    public void YunWaLogin(string nickName, int uid, Action<string> Response)
    {
#if !UNITY_EDITOR && UNITY_ANDROID || !UNITY_EDITOR && UNITY_IPHONE
        string ttFormat = "{{\"nickname\":\"{0}\",\"uid\":\"{1}\"}}";
        string tt = string.Format(ttFormat, nickName, uid);
        string[] wildcard = new string[2];
        wildcard[0] = "0x001";
        wildcard[1] = "0x002";
        Debug.Log("==========云娃登陆返回结果===========" + JsonUtility.ToJson(Response).ToString());
        YunVaImSDK.instance.YunVaOnLogin(tt, "1", wildcard, 0, (data) =>
        {
            if (data.result == 0)
            {
                Debug.LogFormat("登录成功，昵称:{0},用户ID:{1}", data.nickName, data.userId);
                YunVaImSDK.instance.RecordSetInfoReq(true);//开启录音的音量大小回调
            }
            else
            {
                Debug.LogFormat("登录失败，错误消息：{0}", data.msg);
            }
            Response(JsonUtility.ToJson(data));
        });
#endif
    }

    /// <summary>
    /// 开始录音
    /// </summary>
    public void RecordStartRequest(Action<string, int> call)
    {
        startRequestCallback = call;
#if !UNITY_EDITOR && UNITY_ANDROID || !UNITY_EDITOR && UNITY_IPHONE
        filePath = string.Format("{0}/{1}.amr", Application.persistentDataPath, DateTime.Now.ToFileTime());
        YunVaImSDK.instance.RecordStartRequest(filePath, 1);
#endif
    }
    /// <summary>
    /// 录音停止
    /// </summary>
	public void RecordStopRequest(int isUpdateFile)
    {
//#if !UNITY_EDITOR && UNITY_ANDROID || !UNITY_EDITOR && UNITY_IPHONE
        YunVaImSDK.instance.RecordStopRequest((data) =>
        {
            recordPath = data.strfilepath;
            Debug.Log("停止录音返回:" + recordPath);
            if(startRequestCallback != null)
            {
                startRequestCallback(JsonUtility.ToJson(data),isUpdateFile);
            }
		});
//#endif
    }

    /// <summary>
    /// 上传文件请求
    /// </summary>
    /// <param name="filePath"></param>
    public void UploadFileRequest(string filePath, string remoteKey, Action<int, string> onUploadComplete)
    {
        QiniuApi.Upload(filePath, remoteKey, onUploadComplete);
    }

    /// <summary>
    /// 下载语音文件从七牛云缓存到本地
    /// </summary>
    /// <param name="url"></param>
    /// <param name="filePath"></param>
    /// <param name="fileid"></param>
    public void DownLoadFileRequest(string remoteKey, Action<int, string> onDownloadCompleted)
    {
        Debug.Log(">>>>>>>>>接收到下载七牛云资源" + remoteKey);
        QiniuApi.Download(remoteKey, onDownloadCompleted);
    }

    /// <summary>
    /// 开始播放语音
    /// </summary>
    /// <param name="filePath"></param>
    /// <param name="url"></param>
    public void RecordStartPlayRequest(string filePath, string url, Action<string> onPlayCompleted)
    {
#if !UNITY_EDITOR && UNITY_ANDROID || !UNITY_EDITOR && UNITY_IPHONE
        YunVaImSDK.instance.RecordStartPlayRequest(filePath, url, "", (data2) =>
        {
            if (data2.result == 0)
            {
                Debug.Log("播放成功");
            }
            else
            {
                Debug.Log("播放失败");
            }
            if(onPlayCompleted != null)
            {
                onPlayCompleted(JsonUtility.ToJson(data2));
            }
        });
#endif
    }

    /// <summary>
    /// 停止播放
    /// </summary>
    public void RecordStopPlayRequest()
    {
#if !UNITY_EDITOR && UNITY_ANDROID || !UNITY_EDITOR && UNITY_IPHONE
        YunVaImSDK.instance.RecordStopPlayRequest();
#endif
    }

    /// <summary>
    /// 音量大小控制
    /// </summary>
    /// <param name="data"></param>
    public void ImRecordVolume(object data)
    {
#if !UNITY_EDITOR && UNITY_ANDROID || !UNITY_EDITOR && UNITY_IPHONE
        ImRecordVolumeNotify RecordVolumeNotify = data as ImRecordVolumeNotify;
        Debug.Log("ImRecordVolumeNotify:v_volume=" + RecordVolumeNotify.v_volume);
#endif
    }

    /// <summary>
    /// 云娃登出
    /// </summary>
    public void YunWaLogOut()
    {
#if !UNITY_EDITOR && UNITY_ANDROID || !UNITY_EDITOR && UNITY_IPHONE
        YunVaImSDK.instance.YunVaLogOut();
#endif
    }

}


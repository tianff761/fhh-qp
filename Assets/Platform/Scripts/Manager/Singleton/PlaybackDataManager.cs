using UnityEngine;
using System;
using System.IO;
using LuaFramework;

public class PlaybackDataManager : TSingleton<PlaybackDataManager>
{
    private PlaybackDataManager() { }
    /// <summary>
    /// 是否初始化
    /// </summary>
    private bool isInit = false;

    public enum CodeType
    {
        /// <summary>
        /// 成功
        /// </summary>
        SUCCEED = 0,
        /// <summary>
        /// 失败
        /// </summary>
        FAILURE = 1,
        /// <summary>
        /// 超时
        /// </summary>
        TIMEOUT = 2,
    }
    /// <summary>
    /// 文件夹路径
    /// </summary>
    private string mDicPath = null;
    /// <summary>
    /// 文件夹Url路径
    /// </summary>
    private string mDicPathUrl = null;
    /// <summary>
    /// 获取战绩回调
    /// </summary>
    private Action<int, string> mCallback = null;

    /// <summary>
    /// 尝试下载次数
    /// </summary>
    private int retryCount = 0;
    /// <summary>
    /// 最大重试下载次数
    /// </summary>
    public int maxRetryDownCount = 3;
    /// <summary>
    /// 超时时间
    /// </summary>
    public float downTimeOut = 20f;

    /// <summary>
    /// 本地最大保存战绩数量
    /// </summary>
    public int maxSaveLocalCount = 50;

    /// <summary>
    /// 初始化
    /// </summary>
    public void Initialize()
    {
        this.mDicPath = Assets.RuntimeAssetsPath + "PlaybackData/";
        this.mDicPathUrl = Assets.RuntimeAssetsUrlPath + "PlaybackData/";
        isInit = true;
    }

    /// <summary>
    /// 获取文件夹路径
    /// </summary>
    /// <returns></returns>
    public string GetDicPath()
    {
        return mDicPath;
    }

    /// <summary>
    /// 获取文件夹Url路径
    /// </summary>
    /// <returns></returns>
    public string GetDicPathUrl()
    {
        return mDicPathUrl;
    }

    /// <summary>
    /// 获取战绩回放
    /// </summary>
    public void DownPlayback(string url, Action<int, string> callback)
    {

        if(string.IsNullOrEmpty(url))
        {
            Debug.LogError(">>>>>>> PlaybackDataManager > GetPlayback > url is nil");
            CallBack(CodeType.FAILURE, "");
            return;
        }


        mCallback = callback;

        retryCount = 0;

        CheckLocal(url);
    }

    /// <summary>
    /// 检查本地是否存在该数据
    /// </summary>
    public void CheckLocal(string url)
    {
        if (!isInit)
        {
            Initialize();
        }
        try
        {
            string md5 = Util.md5(url);

            string path = mDicPath + md5 + ".txt";
            if(File.Exists(path))
            {
                string fileText = File.ReadAllText(path, System.Text.Encoding.UTF8);
                CallBack(CodeType.SUCCEED, fileText);
            }
            else
            {
                DownPlaybackByUrl(url);
            }
        }
        catch(Exception ex)
        {
            Debug.Log(ex.ToString());
        }
    }


    /// <summary>
    /// 检查本地是否存在该数据
    /// </summary>
    /// <param name="url">查询链接</param>
    /// <param name="callback">回调</param>
    public void CheckLocal(string url, Action<int, string> callback)
    {
        if (!isInit)
        {
            Initialize();
        }
        try
        {
            string md5 = Util.md5(url);

            string path = mDicPath + md5 + ".txt";
            if (File.Exists(path))
            {
                string fileText = File.ReadAllText(path, System.Text.Encoding.UTF8);
                if (callback != null)
                {
                    callback((int)CodeType.SUCCEED, fileText);
                }
            }
            else
            {
                callback((int)CodeType.FAILURE, "");
            }
        }
        catch (Exception ex)
        {
            Debug.Log(ex.ToString());
        }
    }

    /// <summary>
    /// 通过链接下载回放数据
    /// </summary>
    public void DownPlaybackByUrl(string url)
    {
        HttpRequest httpDown = new HttpRequest(url);
        httpDown.SetTimeout(downTimeOut);
        httpDown.AddListener(OnComplete);
        httpDown.Connect();
    }

    /// <summary>
    /// 设置回调
    /// </summary>
    /// <param name="data"></param>
    void OnComplete(ResponseData data)
    {
        if (data.code == ResponseCode.SUCCESS)
        {
            CallBack(CodeType.SUCCEED, data.text);
            //写入本地文件
            WritePlaybackData(data.url, data.text);
        }
        else
        {
            //重试
            retryCount += 1;
            if (retryCount < maxRetryDownCount)
            {
                DownPlaybackByUrl(data.url);
            }
            else
            {
                CallBack((CodeType)data.code, "");
            }
        }
    }

    /// <summary>
    /// 写入回放战绩
    /// </summary>
    public void WritePlaybackData(string url, string text)
    {
        try
        {
            if(!Directory.Exists(mDicPath))
            {
                Directory.CreateDirectory(mDicPath);
            }

            CheckLocalMaxCount();

            string md5 = Util.md5(url);
            string path = mDicPath + md5 + ".txt";
            File.WriteAllText(path, text, System.Text.Encoding.UTF8);
        }
        catch(Exception ex)
        {
            Debug.Log(ex.ToString());
        }
    }

    /// <summary>
    /// 检查本地最大数量的战绩
    /// </summary>
    public void CheckLocalMaxCount()
    {
        try
        {
            DirectoryInfo dir = new DirectoryInfo(mDicPath);
            FileInfo[] fileInfos = dir.GetFiles();
            if(fileInfos.Length > maxSaveLocalCount)
            {
                FileInfo fileInfo = GetMinFileInfoByCreatTime(fileInfos);
                if(fileInfo != null)
                {
                    fileInfo.Delete();
                }
            }
        }
        catch(Exception ex)
        {
            Debug.Log(ex.ToString());
        }
    }

    /// <summary>
    /// 通过创建时间早获取文件信息
    /// </summary>
    FileInfo GetMinFileInfoByCreatTime(FileInfo[] fileInfos)
    {
        int index = 0;
        long time = long.MaxValue;
        for(int i = 0; i < fileInfos.Length; i++)
        {
            long ticks = fileInfos[i].CreationTime.Ticks;
            if(ticks < time)
            {
                time = fileInfos[i].CreationTime.Ticks;
                index = i;
            }
        }
        return fileInfos[index];
    }

    /// <summary>
    /// 回调
    /// </summary>
    /// <param name="str"></param>
    void CallBack(CodeType code, string str)
    {
        if(mCallback != null)
        {
            mCallback((int)code, str);
        }
    }

    /// <summary>
    /// 删除所有回放数据
    /// </summary>
    public void DestroyAllData()
    {
        try
        {
            if(Directory.Exists(mDicPath))
            {
                DirectoryInfo dir = new DirectoryInfo(mDicPath);
                FileInfo[] fileInfos = dir.GetFiles();
                for(int i = 0; i < fileInfos.Length; i++)
                {
                    fileInfos[i].Delete();
                }
            }
        }
        catch(Exception ex)
        {
            Debug.Log(ex.ToString());
        }
    }
}

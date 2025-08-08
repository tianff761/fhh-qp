using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// Http网络请求
/// </summary>
public class HttpApiRequest : Listener<HttpApiRequest, ResponseData>
{
    /// <summary>
    /// 请求的命令，用于出错等回调处理
    /// </summary>
    public int cmd = 0;

    protected WwwLoadTask loadTask = null;

    public HttpApiRequest()
    {
    }

    public HttpApiRequest(string url)
    {
        if(string.IsNullOrEmpty(url))
        {
            Debug.LogWarning(">> HttpApiRequest > 1 > url > IsNullOrEmpty.");
        }
        else
        {
            loadTask = new HttpLoadTask(url);
        }
    }

    public HttpApiRequest(string url, WWWForm _form)
    {
        if(string.IsNullOrEmpty(url))
        {
            Debug.LogWarning(">> HttpApiRequest > 2 > url > IsNullOrEmpty.");
        }
        else
        {
            loadTask = new HttpLoadTask(url, _form);
        }
    }

    public HttpApiRequest(string url, byte[] postData, Dictionary<string, string> header)
    {
        if(string.IsNullOrEmpty(url))
        {
            Debug.LogWarning(">> HttpApiRequest > 3 > url > IsNullOrEmpty.");
        }
        else
        {
            loadTask = new HttpLoadTask(url, postData, header);
        }
    }

    /// <summary>
    /// 设置超时，单位秒
    /// </summary>
    public void SetTimeout(float time)
    {
        if(loadTask != null)
        {
            loadTask.SetTimeout(time);
        }
    }

    /// <summary>
    /// 创建加载任务，用于重写覆盖
    /// </summary>
    protected virtual void CreateLoadTask() { }

    /// <summary>
    /// 加载完成回调
    /// </summary>
    protected virtual void LoadCompleted(ResponseData data)
    {
        if(loadTask != null)
        {
            loadTask.RemoveListener(LoadCompleted);
            loadTask = null;
        }
        Callback(this, data);
    }

    /// <summary>
    /// 请求连接，即开始加载
    /// </summary>
    public void Connect()
    {
        CreateLoadTask();
        if(loadTask != null)
        {
            loadTask.AddListener(LoadCompleted);
            loadTask.Run();
        }
        else
        {
            Debug.LogWarning(">> HttpApiRequest > Connect > loadTask is null.");
        }
    }

    /// <summary>
    /// 停止加载，可中断
    /// </summary>
    public virtual void Stop()
    {
        if(loadTask != null)
        {
            loadTask.Stop();
            loadTask = null;
        }
    }

}

using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Http网络请求
/// </summary>
public class HttpRequest : Listener<ResponseData>
{

    protected WwwLoadTask loadTask = null;

    public HttpRequest()
    {
    }

    public HttpRequest(string url)
    {
        loadTask = new HttpLoadTask(url);
    }

    public HttpRequest(string url, WWWForm _form)
    {
        loadTask = new HttpLoadTask(url, _form);
    }

    public HttpRequest(string url, byte[] postData, Dictionary<string, string> header)
    {
        loadTask = new HttpLoadTask(url, postData, header);
    }

    /// <summary>
    /// 设置超时
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
        Callback(data);
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

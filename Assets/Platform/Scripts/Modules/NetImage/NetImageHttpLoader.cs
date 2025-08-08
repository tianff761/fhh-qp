
/// <summary>
/// 网络图片加载
/// </summary>
public class NetImageHttpLoader : Listener<NetImageHttpLoader, ResponseData>
{
    protected WwwLoadTask loadTask = null;

    public NetImageHttpLoader() { }

    public NetImageLoadData loadData
    {
        get;
        private set;
    }

    public NetImageHttpLoader(NetImageLoadData loadData, string url, bool isHttp)
    {
        this.loadData = loadData;
        loadTask = new WwwLoadTask(url, isHttp);
    }

    protected virtual void CreateLoadTask() { }

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
    /// 设置超时，单位秒
    /// </summary>
    public void SetTimeout(float time)
    {
        if(loadTask != null)
        {
            loadTask.SetTimeout(time);
        }
    }

    public void Connect()
    {
        CreateLoadTask();
        if(loadTask != null)
        {
            loadTask.AddListener(LoadCompleted);
            loadTask.Run();
        }
    }

    public virtual void Stop()
    {
        if(loadTask != null)
        {
            loadTask.Stop();
            loadTask = null;
        }
    }

    public virtual void Clear()
    {
        loadData = null;
    }

}

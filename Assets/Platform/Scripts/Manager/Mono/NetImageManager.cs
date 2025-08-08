using LuaInterface;
using LuaFramework;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;
using System.IO;

/// <summary>
/// 网络图片管理
/// </summary>
public class NetImageManager : TMonoBehaviour<NetImageManager>
{

    /// <summary>
    /// 最大的加载完成缓存数
    /// </summary>
    public static int CacheMaxTotal = 1000;
    /// <summary>
    /// 检测缓存间隔时间
    /// </summary>
    public static float CacheCheckInterval = 60;
    /// <summary>
    /// 检测本地缓存间隔时间
    /// </summary>
    public static float LocalCheckInterval = 60;
    /// <summary>
    /// 缓存时间
    /// </summary>
    public static float CacheTime = 600;

    /// <summary>
    /// 最大的加载数
    /// </summary>
    public static int LoadMaxTotal = 30;

    /// <summary>
    /// 最大的重试次数
    /// </summary>
    public static int ReloadMaxTotal = 2;

    /// <summary>
    /// 加载超时时间，大于0才处理
    /// </summary>
    public static float LoadTimeout = 30;


    /// <summary>
    /// 是否初始化
    /// </summary>
    private bool mInited = false;
    /// <summary>
    /// 文件夹路径
    /// </summary>
    private string mDicPath = null;
    /// <summary>
    /// 文件夹Url路径
    /// </summary>
    private string mDicPathUrl = null;

    /// <summary>
    /// Url对应的MD5
    /// </summary>
    private Dictionary<string, string> mUrlMd5Dict = new Dictionary<string, string>();
    /// <summary>
    /// MD5对应的图片
    /// </summary>
    private Dictionary<string, NetImageLoadedData> mLoadedDataDict = new Dictionary<string, NetImageLoadedData>();

    /// <summary>
    /// 将要加载的数据
    /// </summary>
    private LinkedList<NetImageLoadData> mLoadDataList = new LinkedList<NetImageLoadData>();
    /// <summary>
    /// 加载中的数据
    /// </summary>
    private Dictionary<string, NetImageLoadData> mLoadingDataDict = new Dictionary<string, NetImageLoadData>();

    /// <summary>
    /// 上一次检测缓存时间
    /// </summary>
    private float mLastCheckCacheTime = 0;
    /// <summary>
    /// 上一次检测本地时间
    /// </summary>
    private float mLastCheckLocalTime = -60;

    /// <summary>
    /// 网络图片管理加载初始化
    /// </summary>
    public void Initialize()
    {
        if(this.mInited) { return; }
        this.mInited = true;
        this.mDicPath = Assets.RuntimeAssetsPath + "NetImage/";
        this.mDicPathUrl = Assets.RuntimeAssetsUrlPath + "NetImage/";
        if(!Directory.Exists(this.mDicPath))
        {
            Directory.CreateDirectory(this.mDicPath);
        }
        Debug.Log(this.mDicPath);
    }

    /// <summary>
    /// 清除
    /// </summary>
    public void Clear()
    {
        this.mLoadedDataDict.Clear();
    }

    /// <summary>
    /// 加载网络图片资源
    /// </summary>
    public void Load(string url, LuaFunction luaFunction, LuaTable luaTable)
    {
        this.Initialize();

        string md5 = this.GetMd5(url);

        //存在已经加载的就回调
        if (this.mLoadedDataDict.ContainsKey(md5))
        {
            this.Callback(luaFunction, luaTable);
            return;
        }

        NetImageLoadData loadData = null;
        //加载中检测，如果存在加载中，直接加入
        if(this.mLoadingDataDict.TryGetValue(md5, out loadData))
        {
            loadData.Add(luaFunction, luaTable);
            return;
        }

        //加载队列的检测
        loadData = null;
        foreach(NetImageLoadData tempLoadData in this.mLoadDataList)
        {
            if(tempLoadData.md5 == md5)
            {
                loadData = tempLoadData;
                break;
            }
        }

        if(loadData != null)
        {
            //存在就更新到队列前面去
            loadData.Add(luaFunction, luaTable);
            if(this.mLoadDataList.First.Value != loadData)
            {
                this.mLoadDataList.Remove(loadData);
                this.mLoadDataList.AddFirst(loadData);
            }
        }
        else
        {
            loadData = new NetImageLoadData(url, md5);
            loadData.Add(luaFunction, luaTable);
            this.StartLoad(loadData);
        }
    }

    /// <summary>
    /// 开始下载推动
    /// </summary>
    private void StartLoad(NetImageLoadData loadData)
    {
        ///如果当前下载数量过大，就加入在队列首
        if(this.mLoadingDataDict.Count >= LoadMaxTotal)
        {
            this.mLoadDataList.AddFirst(loadData);
            return;
        }

        //加入到下载中
        this.mLoadingDataDict.Add(loadData.md5, loadData);
        this.Load(loadData);
    }

    /// <summary>
    /// 加载下一个
    /// </summary>
    private void LoadNext()
    {
        if(this.mLoadingDataDict.Count >= LoadMaxTotal)
        {
            return;
        }

        if(this.mLoadDataList.Count < 1)
        {
            return;
        }

        NetImageLoadData loadData = mLoadDataList.First.Value;
        this.mLoadDataList.RemoveFirst();

        //加入到下载中
        this.mLoadingDataDict.Add(loadData.md5, loadData);
        this.Load(loadData);
    }

    /// <summary>
    /// 获取本地地址
    /// </summary>
    private string GetLocalFilePath(string md5)
    {
        return this.mDicPath + md5 + ".png";
    }

    /// <summary>
    /// 获取本地Url地址
    /// </summary>
    private string GetLocalUrlPath(string md5)
    {
        return this.mDicPathUrl + md5 + ".png";
    }

    /// <summary>
    /// 下载
    /// </summary>
    private void Load(NetImageLoadData loadData)
    {
        string localFilePath = this.GetLocalFilePath(loadData.md5);

        NetImageHttpLoader request = null;
        if(File.Exists(localFilePath))
        {
            localFilePath = this.GetLocalUrlPath(loadData.md5);
            request = new NetImageHttpLoader(loadData, localFilePath, false);
        }
        else
        {
            request = new NetImageHttpLoader(loadData, loadData.url, true);
        }
        //设置超时
        if(LoadTimeout > 0)
        {
            request.SetTimeout(LoadTimeout);
        }
        request.AddListener(this.OnHttpRequestCompleted);
        request.Connect();
    }

    /// <summary>
    /// 下载完成
    /// </summary>
    private void OnHttpRequestCompleted(NetImageHttpLoader loader, ResponseData response)
    {
        loader.RemoveListener(this.OnHttpRequestCompleted);

        NetImageLoadData loadData = loader.loadData;
        //成功
        if(response.code == ResponseCode.SUCCESS && response.texture != null)
        {
            //如果是网络下载，需要保存文件到本地
            if (response.isHttp)
            {
                string localFilePath = this.GetLocalFilePath(loadData.md5);
                Util.SaveToFile(localFilePath, response.bytes);
            }

            //缓存图片
            NetImageLoadedData loadedData = new NetImageLoadedData(loadData.md5, response.texture);
            this.mLoadedDataDict.Add(loadData.md5, loadedData);

            //从加载中队列移除
            this.mLoadingDataDict.Remove(loadData.md5);

            //回调
            this.Callback(loadData);

            //检测缓存
            this.CheckCacheState();

            //加载下一个
            this.LoadNext();
        }
        else
        {
            //失败，超出重试次数
            if(loadData.reloadCount >= ReloadMaxTotal)
            {
                //从加载中队列移除
                this.mLoadingDataDict.Remove(loadData.md5);
                //失败也回调
                this.Callback(loadData);
                //加载下一个
                this.LoadNext();
            }
            else
            {
                //重试
                loadData.reloadCount += 1;
                this.Load(loadData);
            }
        }
    }


    /// <summary>
    /// 回调
    /// </summary>
    private void Callback(NetImageLoadData loadData)
    {
        NetImageLoadLuaData luaData = null;
        for(int i = 0; i < loadData.luaDatas.Count; i++)
        {
            luaData = loadData.luaDatas[i];
            this.Callback(luaData.luaFunction, luaData.luaTable);
        }
        loadData.Clear();
    }

    /// <summary>
    /// 回调
    /// </summary>
    private void Callback(LuaFunction luaFunction, LuaTable luaTable)
    {
        if(luaFunction != null)
        {
            if(luaTable != null)
            {
                luaFunction.Call(luaTable);
            }
            else
            {
                luaFunction.Call();
            }
            luaFunction.Dispose();
        }
    }

    /// <summary>
    /// 获取MD5码
    /// </summary>
    private string GetMd5(string url)
    {
        string md5 = string.Empty;
        if(!this.mUrlMd5Dict.TryGetValue(url, out md5))
        {
            md5 = Util.md5(url);
            this.mUrlMd5Dict.Add(url, md5);
        }
        return md5;
    }

    /// <summary>
    /// 检测是否存在
    /// </summary>
    public bool Exists(string url)
    {
        string md5 = this.GetMd5(url);
        if(this.mLoadedDataDict.ContainsKey(md5))
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    /// <summary>
    /// 如果存在则返回，不存在返回空对象
    /// </summary>
    public Texture Get(string url)
    {
        string md5 = this.GetMd5(url);
        NetImageLoadedData loadedData = null;
        if(this.mLoadedDataDict.TryGetValue(md5, out loadedData))
        {
            loadedData.UpdatreLastTime();
            return loadedData.texture;
        }
        return null;
    }

    /// <summary>
    /// 如果存在则返回，不存在返回空对象
    /// </summary>
    public Sprite GetSprite(string url)
    {
        Texture texture = this.Get(url);
        if(texture != null)
        {
            Texture2D texture2D = texture as Texture2D;
            Rect spriteRect = new Rect(0, 0, texture2D.width, texture2D.height);
            Sprite sprite = Sprite.Create(texture2D, spriteRect, Vector2.zero);
            return sprite;
        }
        return null;
    }

    /// <summary>
    /// 设置图片的贴图，如果有图标设置，则返回true，没有则返回false
    /// </summary>
    public bool SetRawImage(RawImage rawImage, string url)
    {
        string md5 = this.GetMd5(url);
        NetImageLoadedData loadedData = null;
        if(!this.mLoadedDataDict.TryGetValue(md5, out loadedData))
        {
            return false;
        }
        loadedData.UpdatreLastTime();
        rawImage.texture = loadedData.texture;

        return true;
    }

    /// <summary>
    /// 设置图片的贴图，如果有图标设置，则返回true，没有则返回false
    /// </summary>
    public bool SetGORawImage(GameObject gameObject, string url)
    {
        return this.SetRawImage(gameObject.GetComponent<RawImage>(), url);
    }

    /// <summary>
    /// 设置图片的贴图，如果有图标设置，则返回true，没有则返回false
    /// </summary>
    public bool SetImage(Image image, string url)
    {
        string md5 = this.GetMd5(url);
        NetImageLoadedData loadedData = null;
        if(!this.mLoadedDataDict.TryGetValue(md5, out loadedData))
        {
            return false;
        }

        loadedData.UpdatreLastTime();

        if(loadedData.texture == null)
        {
            return false;
        }
        else
        {
            Texture2D texture2D = loadedData.texture as Texture2D;
            Rect spriteRect = new Rect(0, 0, texture2D.width, texture2D.height);
            Sprite sprite = Sprite.Create(texture2D, spriteRect, Vector2.zero);

            image.sprite = sprite;
            return true;
        }
    }

    /// <summary>
    /// 设置图片的贴图，如果有图标设置，则返回true，没有则返回false
    /// </summary>
    public bool SetGOImage(GameObject gameObject, string url)
    {
        return this.SetImage(gameObject.GetComponent<Image>(), url);
    }

    //================================================================

    /// <summary>
    /// 检测缓存状态，检测间隔至少为60秒
    /// </summary>
    public void CheckCacheState()
    {
        //缓存数量没有达到检测处理
        if(this.mLoadedDataDict.Count < CacheMaxTotal)
        {
            return;
        }

        float time = Time.realtimeSinceStartup;
        if(time - this.mLastCheckCacheTime < CacheCheckInterval)
        {
            return;
        }

        this.mLastCheckCacheTime = time;

        List<string> list = new List<string>();
        foreach(KeyValuePair<string, NetImageLoadedData> kv in this.mLoadedDataDict)
        {
            if(time - kv.Value.lastTime > CacheTime)
            {
                list.Add(kv.Key);
                kv.Value.Clear();
            }
        }

        //移除超时的
        for(int i = 0; i < list.Count; i++)
        {
            this.mLoadedDataDict.Remove(list[i]);
        }
    }

    /// <summary>
    /// 从内存缓存中移除
    /// </summary>
    public void RemoveCache(string url)
    {
        string md5 = this.GetMd5(url);
        if(!string.IsNullOrEmpty(md5))
        {
            mLoadedDataDict.Remove(md5);
        }
    }

    //================================================================

    /// <summary>
    /// 删除本地磁盘缓存
    /// </summary>
    public void DeleteLocal(string url)
    {
        this.Initialize();
        string md5 = this.GetMd5(url);
        string localFilePath = this.GetLocalFilePath(md5);
        Util.DeleteFile(localFilePath);
    }

    /// <summary>
    /// 间隔时间毫秒
    /// </summary>
    public void CheckLocal(int expire, string searchPattern = null)
    {
        this.Initialize();
        Debug.Log(">> NetImageManager > CheckLocal > expire = " + expire);

        float time = Time.realtimeSinceStartup;
        if(time - this.mLastCheckLocalTime < LocalCheckInterval)
        {
            return;
        }

        this.mLastCheckLocalTime = time;
        if(string.IsNullOrEmpty(searchPattern))
        {
            searchPattern = "*.png";
        }
        long nowTicks = DateTime.Now.Ticks;
        //Debug.Log(nowTicks);
        try
        {
            DirectoryInfo dirInfo = new DirectoryInfo(this.mDicPath);

            FileInfo[] files = dirInfo.GetFiles(searchPattern);
            int length = files.Length;

            FileInfo fileInfo = null;
            for(int i = 0; i < length; i++)
            {
                fileInfo = files[i];
                //Debug.Log(fileInfo.CreationTime.Ticks);
                if(nowTicks - fileInfo.CreationTime.Ticks > expire)
                {
                    fileInfo.Delete();
                }
            }
        }
        catch(Exception ex)
        {
            Debug.LogException(ex);
        }
    }

}

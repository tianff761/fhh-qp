using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 网络图片已经加载的数据
/// </summary>
public class NetImageLoadedData
{

    private string mMd5 = null;
    private Texture mTexture = null;
    /// <summary>
    /// 上一次更新时间
    /// </summary>
    private float mLastTime = 0;

    public NetImageLoadedData(string md5, Texture texture)
    {
        this.mMd5 = md5;
        this.mTexture = texture;
        this.mLastTime = Time.realtimeSinceStartup;
    }

    public void Clear()
    {
        this.mMd5 = null;
        this.mTexture = null;
    }

    public string md5
    {
        get { return this.mMd5; }
    }

    public Texture texture
    {
        get { return this.mTexture; }
    }

    public float lastTime
    {
        get { return this.mLastTime; }
        set { this.mLastTime = value; }
    }

    //================================================================

    /// <summary>
    /// 更新时间
    /// </summary>
    public void UpdatreLastTime()
    {
        this.mLastTime = Time.realtimeSinceStartup;
    }
}

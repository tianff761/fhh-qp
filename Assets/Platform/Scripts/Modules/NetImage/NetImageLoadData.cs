using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;

public class NetImageLoadData
{

    /// <summary>
    /// 下载链接
    /// </summary>
    private string mUrl = null;
    /// <summary>
    /// 链接的MD5码
    /// </summary>
    private string mMd5 = null;

    /// <summary>
    /// lua数据
    /// </summary>
    private List<NetImageLoadLuaData> mLuaDatas = new List<NetImageLoadLuaData>();



    public NetImageLoadData(string url, string md5)
    {
        this.mUrl = url;
        this.mMd5 = md5;
        this.reloadCount = 0;
    }

    public void Clear()
    {
        this.mUrl = null;
        this.mMd5 = null;

        mLuaDatas.Clear();
    }

    /// <summary>
    /// 同一个连接下的相同回调方法需要处理，即同一个方法不能重复
    /// </summary>
    public void Add(LuaFunction luaFunction, LuaTable luaTable)
    {
        NetImageLoadLuaData luaData = null;
        bool isExist = false;
        for(int i = 0; i < mLuaDatas.Count; i++)
        {
            luaData = mLuaDatas[i];
            if(luaData.luaFunction == luaFunction)
            {
                isExist = true;
                //更新参数
                luaData.luaTable = luaTable;
                break;
            }
        }

        if(!isExist)
        {
            mLuaDatas.Add(new NetImageLoadLuaData(luaFunction, luaTable));
        }
    }

    public string url
    {
        get { return this.mUrl; }
    }

    public string md5
    {
        get { return this.mMd5; }
    }

    /// <summary>
    /// 重新加载次数
    /// </summary>
    public int reloadCount
    {
        get;
        set;
    }

    public List<NetImageLoadLuaData> luaDatas
    {
        get { return this.mLuaDatas; }
    }

}

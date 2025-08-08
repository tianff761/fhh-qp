using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LitJson;
using LuaFramework;

/*
 * {
	"version": "9.0.8",
	"versionUrl": "https://fir.im/jzyjmj",
	"games": [{
		"name": "Base",
		"version": "9.0.8",
		"assetsPath": "https://lsmj-resources.10qp.com/v9.0.8/android/assets/",
        "sparePath": "https://lsmj-resources.10qp.com/v9.0.8/android/assets/"
	}, {
		"name": "ErQiShi",
		"version": "9.0.8",
		"assetsPath": "https://lsmj-resources.10qp.com/v9.0.8/android/assets/",
        "sparePath": "https://lsmj-resources.10qp.com/v9.0.8/android/assets/"
	}]
}*/

/// <summary>
/// 版本数据
/// </summary>
public class VersionData
{

    public string version;
    public string versionUrl;
    public List<VersionGameData> games;

    private int mVersionNum = 0;
    /// <summary>
    /// 获取数值版本
    /// </summary>
    public int GetVersionNum()
    {
        if(mVersionNum < 1)
        {
            if(!string.IsNullOrEmpty(version))
            {
                Version tVersion = new Version(version);
                mVersionNum = tVersion.Major * 10000;
                mVersionNum += tVersion.Minor * 100;
                mVersionNum += tVersion.Build;

            }
        }
        return mVersionNum;
    }

    /// <summary>
    /// 获取游戏版本
    /// </summary>
    public Version GetGameVersion(string gameName)
    {
        if(this.games != null)
        {
            VersionGameData versionGameData = null;
            for(int i = 0; i < this.games.Count; i++)
            {
                versionGameData = this.games[i];
                if(versionGameData != null && versionGameData.name == gameName)
                {
                    try
                    {
                        return new Version(versionGameData.version);
                    }
                    catch(Exception ex)
                    {
                        Debug.LogException(ex);
                    }
                }
            }
        }

        return null;
    }

    /// <summary>
    /// 获取游戏版本数值
    /// </summary>
    public int GetGameVersionNum(string gameName)
    {
        if(this.games != null)
        {
            VersionGameData versionGameData = null;
            for(int i = 0; i < this.games.Count; i++)
            {
                versionGameData = this.games[i];
                if(versionGameData != null && versionGameData.name == gameName)
                {
                    try
                    {
                        return versionGameData.GetVersionNum();
                    }
                    catch(Exception ex)
                    {
                        Debug.LogException(ex);
                    }
                }
            }
        }
        return 0;
    }

    /// <summary>
    /// 获取游戏版本字符串
    /// </summary>
    public string GetGameVersionStr(string gameName)
    {
        if(this.games != null)
        {
            VersionGameData versionGameData = null;
            for(int i = 0; i < this.games.Count; i++)
            {
                versionGameData = this.games[i];
                if(versionGameData != null && versionGameData.name == gameName)
                {
                    try
                    {
                        return versionGameData.version;
                    }
                    catch(Exception ex)
                    {
                        Debug.LogException(ex);
                    }
                }
            }
        }
        return "";
    }

    /// <summary>
    /// 获取游戏资源路径
    /// </summary>
    public string GetGameAssetsPath(string gameName)
    {
        if(this.games != null)
        {
            VersionGameData versionGameData = null;
            for(int i = 0; i < this.games.Count; i++)
            {
                versionGameData = this.games[i];
                if(versionGameData != null && versionGameData.name == gameName)
                {
                    //平台名称、游戏资源版本号；不用带游戏名称，因为files中有
                    string temp = "{0}/v{1}/";
                    return string.Format(temp, AppConst.GetUpgradePlatformName(), versionGameData.version);
                }
            }
        }
        return "";
    }
}

/// <summary>
/// 版本游戏数据
/// </summary>
public class VersionGameData
{
    public string name;
    public string version;
    public string assetsPath;
    public string sparePath;

    private int mVersionNum = 0;
    public int GetVersionNum()
    {
        if(mVersionNum < 1)
        {
            if(!string.IsNullOrEmpty(version))
            {
                Version tVersion = new Version(version);
                mVersionNum = tVersion.Major * 10000;
                mVersionNum += tVersion.Minor * 100;
                mVersionNum += tVersion.Build;

            }
        }
        return mVersionNum;
    }

    public void SetVersion(string version)
    {
        this.version = version;
        this.mVersionNum = 0;
    }

}

/// <summary>
/// 版本管理类
/// </summary>
public class VersionManager : TSingleton<VersionManager>
{

    private VersionManager() { }

    /// <summary>
    /// 远端版本
    /// </summary>
    private VersionData mRemoteVersionData = null;
    /// <summary>
    /// 本地版本
    /// </summary>
    private VersionData mLocalVersionData = null;

    /// <summary>
    /// 设置远端版本数据
    /// </summary>
    public void SetRemoteVersionData(string str)
    {
        if(string.IsNullOrEmpty(str))
        {
            Debug.LogWarning(">> VersionManager > SetRemoteVersionData > IsNullOrEmpty.");
            return;
        }

        try
        {
            this.mRemoteVersionData = JsonMapper.ToObject<VersionData>(str);
        }
        catch(Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    /// <summary>
    /// 应用的远端版本号字符串
    /// </summary>
    public string appRemoteVersionStr
    {
        get
        {
            if(this.mRemoteVersionData != null)
            {
                return this.mRemoteVersionData.version;
            }
            return string.Empty;
        }
    }

    /// <summary>
    /// 应用的远端数值版本号
    /// </summary>
    public int appRemoteVersionNum
    {
        get
        {
            if(this.mRemoteVersionData != null)
            {
                return this.mRemoteVersionData.GetVersionNum();
            }
            return 0;
        }
    }

    /// <summary>
    /// 应用的版本下载链接
    /// </summary>
    public string appRemoteVersionUrl
    {
        get
        {
            if(this.mRemoteVersionData != null)
            {
                return this.mRemoteVersionData.versionUrl;
            }
            return string.Empty;
        }
    }

    /// <summary>
    /// 获取游戏资源远端版本号
    /// </summary>
    public Version GetGameRemoteVersion(string gameName)
    {
        if(this.mRemoteVersionData != null)
        {
            return this.mRemoteVersionData.GetGameVersion(gameName);
        }
        return null;
    }

    /// <summary>
    /// 获取游戏资源远端数值版本号
    /// </summary>
    public int GetGameRemoteVersionNum(string gameName)
    {
        if(this.mRemoteVersionData != null)
        {
            return this.mRemoteVersionData.GetGameVersionNum(gameName);
        }
        return 0;
    }

    /// <summary>
    /// 获取游戏资源远端字符串版本号
    /// </summary>
    public string GetGameRemoteVersionStr(string gameName)
    {
        if(this.mRemoteVersionData != null)
        {
            return this.mRemoteVersionData.GetGameVersionStr(gameName);
        }
        return "";
    }

    /// <summary>
    /// 获取游戏资源路径
    /// </summary>
    public string GetGameAssetsPath(string gameName)
    {
        if(this.mRemoteVersionData != null)
        {
            return this.mRemoteVersionData.GetGameAssetsPath(gameName);
        }
        return "";
    }


    //================================================================

    /// <summary>
    /// 设置本地版本数据
    /// </summary>
    public void SetLocalVersionData(string str)
    {
        if(string.IsNullOrEmpty(str))
        {
            Debug.LogWarning(">> VersionManager > SetLocalVersionData > IsNullOrEmpty.");
            return;
        }

        try
        {
            this.mLocalVersionData = JsonMapper.ToObject<VersionData>(str);
        }
        catch(Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    private void CheckLoadLocalVersion()
    {
        if(this.mLocalVersionData == null)
        {
            this.mLocalVersionData = new VersionData();
            this.mLocalVersionData.version = "1.0.0";
            this.mLocalVersionData.versionUrl = "";
            this.mLocalVersionData.games = new List<VersionGameData>();
        }
    }

    /// <summary>
    /// 是否加载了版本版本文件
    /// </summary>
    /// <returns></returns>
    public bool IsLoadLocalVersion()
    {
        return this.mLocalVersionData != null;
    }

    /// <summary>
    /// 设置游戏资源版本号，用于缓存本地的版本号
    /// </summary>
    public void SetLocalGameVersion(string gameName, string verStr)
    {
        this.CheckLoadLocalVersion();
        if(this.mLocalVersionData.games == null)
        {
            this.mLocalVersionData.games = new List<VersionGameData>();
        }

        VersionGameData versionGameData = null;
        VersionGameData foundVersionGameData = null;
        for(int i = 0; i < this.mLocalVersionData.games.Count; i++)
        {
            versionGameData = this.mLocalVersionData.games[i];
            if(versionGameData != null && versionGameData.name == gameName)
            {
                foundVersionGameData = versionGameData;
            }
        }
        if(foundVersionGameData == null)
        {
            foundVersionGameData = new VersionGameData();
            foundVersionGameData.name = gameName;
            this.mLocalVersionData.games.Add(foundVersionGameData);
        }

        foundVersionGameData.SetVersion(verStr);
    }

    /// <summary>
    /// 获取本地数据Json字符串
    /// </summary>
    /// <returns></returns>
    public string GetLocalVersionJson()
    {
        this.CheckLoadLocalVersion();

        string json = "";
        try
        {
            json = JsonMapper.ToJson(this.mLocalVersionData);
        }
        catch(Exception ex)
        {
            Debug.LogException(ex);
        }
        return json;
    }

    /// <summary>
    /// 获取游戏资源本地版本号
    /// </summary>
    public Version GetGameLocalVersion(string gameName)
    {
        if(this.mLocalVersionData != null)
        {
            return this.mLocalVersionData.GetGameVersion(gameName);
        }
        return null;
    }

    /// <summary>
    /// 获取游戏资源本地数值版本号
    /// </summary>
    public int GetGameLocalVersionNum(string gameName)
    {
        if(this.mLocalVersionData != null)
        {
            return this.mLocalVersionData.GetGameVersionNum(gameName);
        }
        return 0;
    }

    /// <summary>
    /// 获取游戏资源本地字符串版本号
    /// </summary>
    public string GetGameLocalVersionStr(string gameName)
    {
        if(this.mLocalVersionData != null)
        {
            return this.mLocalVersionData.GetGameVersionStr(gameName);
        }
        return "";
    }

    //================================================================

    /// <summary>
    /// 检测游戏是否需要更新
    /// </summary>
    public bool CheckGameNeedUpgrade(string gameName)
    {
        if(AppConst.IsCheckUpgrade())
        {
            int localVersionNum = this.GetGameLocalVersionNum(gameName);
            if(localVersionNum < 1)
            {
                return true;
            }

            if(AppConst.IsCheckRemoteUpgrade)
            {
                int remoteVersionNum = this.GetGameRemoteVersionNum(gameName);
                if(remoteVersionNum < 1 || localVersionNum < remoteVersionNum)
                {
                    return true;
                }
            }
        }

        return false;
    }
}

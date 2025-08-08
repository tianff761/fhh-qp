using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

/// <summary>
/// 十点半资源打包
/// </summary>
public class SDBPackager : MonoBehaviour
{
    /// <summary>
    /// 资源名称
    /// </summary>
    private const string RES_NAME = "SDB";

    [MenuItem("Build Resources/" + RES_NAME + "/Build", false, 1201)]
    private static void Build()
    {
        List<AssetBundleBuild> builds = new List<AssetBundleBuild>();
        builds.AddRange(BasePackager.GetBuildConfigs(false));
        builds.AddRange(GetBuildConfigs(false));

        Packager.Build(RES_NAME, builds);
    }

    [MenuItem("Build Resources/" + RES_NAME + "/Mark", false, 1202)]
    private static void Mark()
    {
        List<AssetBundleBuild> builds = new List<AssetBundleBuild>();
        builds.AddRange(BasePackager.GetBuildConfigs(true));
        builds.AddRange(GetBuildConfigs(true));

        Packager.Mark(RES_NAME, builds);
    }

    /// <summary>
    /// 获取资源的Build配置
    /// </summary>
    /// <returns></returns>
    public static List<AssetBundleBuild> GetBuildConfigs(bool isMark)
    {
        List<AssetbundleConfigData> configDatas = new List<AssetbundleConfigData>();

        string resFolderName = RES_NAME.ToLower();
        string resFolderPath = string.Format("Platform/Project/Game/{0}/Res/", RES_NAME);

        if (!isMark)
        {
            Packager.CopyLuaBytesFiles(new string[] { string.Format("/Platform/Project/Game/{0}/", RES_NAME) });

            configDatas.Add(AssetbundleConfigData.New(resFolderName + "/" + resFolderName, "Lua/" + RES_NAME, "*.bytes", SearchOption.AllDirectories));
        }
        //面板
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/panels", resFolderPath + "Prefabs/Panels/", "*.prefab"));

        //游戏特效图片
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/sdbgameeff", resFolderPath + "Effects/GameEffs", "*.png", SearchOption.AllDirectories));

        //房间资源
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/sdbroom", resFolderPath + "Atlas/SDBRoom", "*.png"));

        //游戏快捷语音
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/chat", resFolderPath + "Sound/ChatSound", "*.mp3"));

        //游戏主音效
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/sound", resFolderPath + "Sound/Common", "*.mp3"));

        //游戏结果音效--男
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/sound", resFolderPath + "Sound/Putong_M", "*.mp3"));

        //游戏结果音效--女
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/sound", resFolderPath + "Sound/Putong_W", "*.mp3"));

        //游戏音乐
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/bgm", resFolderPath + "Music", "*.mp3"));

        //牌 
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/pokercard", resFolderPath + "Textures/SDBPokerCard/", "*.png"));
        //小型牌 
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/smallpokercard", resFolderPath + "Textures/SDBSmallPoker/", "*.png"));

        //结果
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/result", resFolderPath + "Textures/SDBResult/", "*.png"));

        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/loadsprites", resFolderPath + "Textures/SDBLoadSprites", "*.png"));

        //设置界面
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/sdbroom", resFolderPath + "Atlas/SDBSetting/", "*.png"));

        return Packager.GenerateAssetBundleBuildList(configDatas);
    }
}

using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

/// <summary>
/// 麻将资源打包
/// </summary>
public class Pin3Packager : MonoBehaviour
{
    /// <summary>
    /// 资源名称
    /// </summary>
    private const string RES_NAME = "Pin3";
    /// <summary>
    /// 菜单索引顺序
    /// </summary>
    private const int MENU_INDEX = 400;

    [MenuItem("Build Resources/" + RES_NAME + "/Build", false, MENU_INDEX + 1)]
    private static void Build()
    {
        List<AssetBundleBuild> builds = new List<AssetBundleBuild>();
        builds.AddRange(BasePackager.GetBuildConfigs(false));
        builds.AddRange(GetBuildConfigs(false));

        Packager.Build(RES_NAME, builds);
    }

    [MenuItem("Build Resources/" + RES_NAME + "/Mark", false, MENU_INDEX + 2)]
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

        //动画资源
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/pin3animation", resFolderPath + "DdzAnimaton/", "*.mat", SearchOption.AllDirectories));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/pin3animation", resFolderPath + "DdzAnimaton/", "*.png", SearchOption.AllDirectories));

        //面板
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/panels", resFolderPath + "Prefabs/Panels/", "*.prefab"));

        //其他prefab资源
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/otherprefabs", resFolderPath + "Prefabs/Others/", "*.prefab", SearchOption.AllDirectories));

        //牌资源
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/cardimgs", resFolderPath + "Atlas/DdzCards/", "*.png"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/gameimgs", resFolderPath + "Atlas/DdzGame/", "*.png"));

        //音效
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/audio", resFolderPath + "Audio/effect/", "*.mp3", SearchOption.AllDirectories));
        //背景音
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/music", resFolderPath + "Music/", "*.mp3", SearchOption.AllDirectories));
        //聊天音
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/chat", resFolderPath + "Audio/Chat", "*.mp3", SearchOption.AllDirectories));
        return Packager.GenerateAssetBundleBuildList(configDatas);
    }

}

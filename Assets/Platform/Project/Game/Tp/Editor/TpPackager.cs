using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

/// <summary>
/// Tp资源打包
/// </summary>
public class TpPackager : MonoBehaviour
{
    /// <summary>
    /// 资源名
    /// </summary>
    private const string RES_NAME = "Tp";
    /// <summary>
    /// 菜单索引顺序
    /// </summary>
    private const int MENU_INDEX = 800;

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
        //牌
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/cards", resFolderPath + "Atlas/TpCard/", "*.png"));
        //音效
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/music", resFolderPath + "Audio/Music/", "*.mp3"));
        //音效
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/audio", resFolderPath + "Audio/Card/", "*.mp3", SearchOption.AllDirectories));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/audio", resFolderPath + "Audio/Operation/", "*.mp3", SearchOption.AllDirectories));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/audio", resFolderPath + "Audio/Sound/", "*.mp3", SearchOption.AllDirectories));
        //聊天快捷语音
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/quick", resFolderPath + "Audio/Quick/", "*.mp3", SearchOption.AllDirectories));
        //特效
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/effects", resFolderPath + "Prefabs/Effects/", "*.prefab"));
        //背景
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/background", resFolderPath + "Textures/Background/", "*.png"));
        //面板
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/panels", resFolderPath + "Prefabs/Panels/", "*.prefab"));

        return Packager.GenerateAssetBundleBuildList(configDatas);
    }

}

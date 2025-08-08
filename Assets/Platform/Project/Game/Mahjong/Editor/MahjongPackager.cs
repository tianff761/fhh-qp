using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

/// <summary>
/// 麻将资源打包
/// </summary>
public class MahjongPackager : MonoBehaviour
{
    /// <summary>
    /// 资源名称
    /// </summary>
    private const string RES_NAME = "Mahjong";
    /// <summary>
    /// 菜单索引顺序
    /// </summary>
    private const int MENU_INDEX = 300;

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

        //麻将音效
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/music", resFolderPath + "Audio/Music/", "*.mp3"));
        //麻将音效
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/audio", resFolderPath + "Audio/Card/", "*.mp3", SearchOption.AllDirectories));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/audio", resFolderPath + "Audio/Operation/", "*.mp3", SearchOption.AllDirectories));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/audio", resFolderPath + "Audio/Sound/", "*.mp3", SearchOption.AllDirectories));
        //聊天快捷语音
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/quick", resFolderPath + "Audio/Quick/", "*.mp3", SearchOption.AllDirectories));
        //特效
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/effects", resFolderPath + "Prefabs/Effects/", "*.prefab"));
        //动画
        //configDatas.Add(AssetbundleConfigData.New(resFolderName + "/anim", resFolderPath + "Prefabs/Animation/", "*.prefab"));
        //背景
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/background", resFolderPath + "Textures/Background/", "*.png"));
        //面板
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/panels", resFolderPath + "Prefabs/Panels/", "*.prefab"));
        //分享结算
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/shareSettlement1", resFolderPath + "Atlas/MahjongShareSettlement/MahjongShareImage1", "*.png"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/shareSettlement2", resFolderPath + "Atlas/MahjongShareSettlement/MahjongShareImage2", "*.png"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/shareSettlement3", resFolderPath + "Atlas/MahjongShareSettlement/MahjongShareImage3", "*.png"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/share", resFolderPath + "Atlas/MahjongShare", "*.png"));

        return Packager.GenerateAssetBundleBuildList(configDatas);
    }

}

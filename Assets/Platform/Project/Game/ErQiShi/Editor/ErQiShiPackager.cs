using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

/// <summary>
/// 贰柒拾资源打包
/// </summary>
public class ErQiShiPackager : MonoBehaviour
{
    /// <summary>
    /// 资源名称
    /// </summary>
    private const string RES_NAME = "ErQiShi";
    /// <summary>
    /// 菜单索引顺序
    /// </summary>
    private const int MENU_INDEX = 700;

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
        //font
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/eqsfont", resFolderPath + "ArtFonts", "*.*", SearchOption.AllDirectories));

        //图片
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/eqseffectTex", resFolderPath + "Atlas/EqsEffect/", "*.png", SearchOption.AllDirectories));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/eqscard", resFolderPath + "Atlas/EqsCard/", "*.png", SearchOption.AllDirectories));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/eqsgame", resFolderPath + "Atlas/EqsGame/", "*.png", SearchOption.AllDirectories));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/bgtexture", resFolderPath + "Textures/", "*.png", SearchOption.AllDirectories));

        //面板
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/panels", resFolderPath + "Prefabs/Panels/", "*.prefab", SearchOption.AllDirectories));

        //Audio
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/eqsaudios", resFolderPath + "Audio/", "*.mp3", SearchOption.AllDirectories));

        //背景音乐
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/eqssound", resFolderPath + "Sound/", "*.mp3", SearchOption.AllDirectories));


        return Packager.GenerateAssetBundleBuildList(configDatas);
    }
}

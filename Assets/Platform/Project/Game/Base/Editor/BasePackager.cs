using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using LuaFramework;

/// <summary>
/// 基础资源打包
/// </summary>
public class BasePackager : MonoBehaviour
{
    /// <summary>
    /// 打包PC版本资源
    /// </summary>
    private static void BuildStandalone()
    {
        BuildAllByPlatform(BuildTarget.StandaloneWindows);
    }

    /// <summary>
    /// 打包iOS资源
    /// </summary>
    private static void BuildiOS()
    {
        BuildAllByPlatform(BuildTarget.iOS);
    }

    /// <summary>
    /// 打包Android资源
    /// </summary>
    private static void BuildAndroid()
    {
        BuildAllByPlatform(BuildTarget.Android);
    }

    /// <summary>
    /// 根据相应的平台打包资源
    /// </summary>
    /// <param name="buildTarget"></param>
    private static void BuildAllByPlatform(BuildTarget buildTarget)
    {
        List<AssetBundleBuild> builds = new List<AssetBundleBuild>();
        builds.AddRange(GetBuildConfigs(false));
        builds.AddRange(MahjongPackager.GetBuildConfigs(false));
        builds.AddRange(ErQiShiPackager.GetBuildConfigs(false));
        builds.AddRange(PaoDeKuaiPackager.GetBuildConfigs(false));
        builds.AddRange(Pin5Packager.GetBuildConfigs(false));
        //builds.AddRange(SDBPackager.GetBuildConfigs(false));
        builds.AddRange(Pin3Packager.GetBuildConfigs(false));
        builds.AddRange(LYCPackager.GetBuildConfigs(false));
        builds.AddRange(TpPackager.GetBuildConfigs(false));
        Packager.Build("all", builds, buildTarget);
        EditorUtility.DisplayDialog("Build All", "Build All完成！", "确定");
    }

    [MenuItem("Build Resources/Build All", false, 001)]
    private static void BuildAll()
    {
        BuildAllByPlatform(BuildTarget.NoTarget);
    }

    [MenuItem("Build Resources/Mark All", false, 002)]
    private static void MarkAll()
    {
        List<AssetBundleBuild> builds = new List<AssetBundleBuild>();
        builds.AddRange(GetBuildConfigs(true));
        builds.AddRange(MahjongPackager.GetBuildConfigs(true));
        builds.AddRange(ErQiShiPackager.GetBuildConfigs(true));
        builds.AddRange(PaoDeKuaiPackager.GetBuildConfigs(true));
        builds.AddRange(Pin5Packager.GetBuildConfigs(true));
        //builds.AddRange(SDBPackager.GetBuildConfigs(true));
        builds.AddRange(Pin3Packager.GetBuildConfigs(true));
        builds.AddRange(LYCPackager.GetBuildConfigs(true));
        Packager.Mark("all", builds);
        EditorUtility.DisplayDialog("Mark All", "Mark All完成！", "确定");
    }

    /// <summary>
    /// 资源名称
    /// </summary>
    private const string RES_NAME = "Base";

    [MenuItem("Build Resources/Build " + RES_NAME, false, 101)]
    private static void Build()
    {
        Packager.Build(RES_NAME, GetBuildConfigs(false));
        EditorUtility.DisplayDialog("Build Base", "Build Base完成！", "确定");
    }

    [MenuItem("Build Resources/Mark " + RES_NAME, false, 102)]
    private static void Mark()
    {
        Packager.Mark(RES_NAME, GetBuildConfigs(true));
        EditorUtility.DisplayDialog("Mark Base", "Mark Base完成！", "确定");
    }


    /// <summary>
    /// 获取资源的Build配置
    /// </summary>
    /// <returns></returns>
    public static List<AssetBundleBuild> GetBuildConfigs(bool isMark)
    {
        //打包初始化
        Packager.Init();
        //删除掉Lua临时文件
        Packager.DeleteLuaBytesFiles();

        List<AssetbundleConfigData> configDatas = new List<AssetbundleConfigData>();

        string resFolderName = RES_NAME.ToLower();
        string resFolderPath = string.Format("Platform/Project/Game/{0}/Res/", RES_NAME);
        if (!isMark)
        {
            //拷贝Lua脚本，便于生成Bundle
            Packager.CopyLuaBytesFiles(new string[] { "/LuaFramework/ToLua/" }, false);
            Packager.CopyLuaBytesFiles(new string[] { "/Platform/LuaCore/" });
            Packager.CopyLuaBytesFiles(new string[] { string.Format("/Platform/Project/Game/{0}/", RES_NAME) });

            //该处文件路径是相对于Assets文件路径
            configDatas.Add(AssetbundleConfigData.New(resFolderName + "/luacore", "Lua/LuaCore", "*.bytes", SearchOption.AllDirectories));
            configDatas.Add(AssetbundleConfigData.New(resFolderName + "/luacore", "Lua/ToLua", "*.bytes", SearchOption.AllDirectories));
            configDatas.Add(AssetbundleConfigData.New(resFolderName + "/" + resFolderName, "Lua/" + RES_NAME, "*.bytes", SearchOption.AllDirectories));
        }
        //================================================================

        //字体
        configDatas.AddRange(AssetbundleConfigData.GetConfigsBySingleFile(resFolderName, "Platform/Fonts/", SearchOption.AllDirectories));

        //登录
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/login", resFolderPath + "Atlas/Login/", "*.png"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/login", resFolderPath + "Prefabs/Panels/Login", "*.prefab"));

        //通用音效
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/sound", resFolderPath + "Audio/Sound/", "*.mp3"));

        //大厅背景音乐，每个文件单独一个包
        configDatas.AddRange(AssetbundleConfigData.GetConfigsBySingleFile(resFolderName, resFolderPath + "Audio/Music/"));
        //configDatas.Add(AssetbundleConfigData.New(resFolderName + "/music", resFolderPath + "Audio/Music/", "*.mp3"));

        //================================================================
        //头像
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/common", resFolderPath + "Atlas/Head/", "*.png"));
        //UI通用资源
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/common", resFolderPath + "Atlas/Common/", "*.png", SearchOption.AllDirectories));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/common", resFolderPath + "Atlas/Panel/", "*.png"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/common", resFolderPath + "Textures/Common/", "*.png"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/common", resFolderPath + "Textures/Common/", "*.jpg"));
        //UI通用面板
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/common", resFolderPath + "Prefabs/Panels/", "*.prefab"));

        //通用艺术字
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/fonts", resFolderPath + "Fonts/", "*.fontsettings", SearchOption.AllDirectories));

        //聊天动画和声音
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/chattex", resFolderPath + "Atlas/Chat/", "*.png", SearchOption.AllDirectories));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/chat", resFolderPath + "Prefabs/Chat/", "*.prefab"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/chat", resFolderPath + "Audio/ChatAnim/", "*.mp3"));

        //大厅图集资源
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/lobbyatlas", resFolderPath + "Atlas/Record/", "*.png", SearchOption.AllDirectories));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/lobbyatlas", resFolderPath + "Atlas/Lobby/", "*.png"));

        //大厅资源
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/lobby", resFolderPath + "Textures/", "*.png"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/lobby", resFolderPath + "Textures/", "*.jpg"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/lobby", resFolderPath + "Textures/Lobby/", "*.png"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/lobby", resFolderPath + "Textures/Lobby/", "*.jpg"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/lobby", resFolderPath + "Textures/Notice/", "*.png"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/lobby", resFolderPath + "Textures/Notice/", "*.jpg"));

        //================================================================

        //大厅面板
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/panels", resFolderPath + "Prefabs/Panels/Lobby", "*.prefab"));
        //创建房间相关
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/panels", resFolderPath + "Prefabs/Panels/CreateRoom", "*.prefab"));

        //屏蔽字库
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/sensitivewordstxt", resFolderPath + "Txt/", "*.txt", SearchOption.AllDirectories));

        //房间
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/room", resFolderPath + "Atlas/Room/Room", "*.png"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/room", resFolderPath + "Atlas/Room/RoomCommon", "*.png"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/room", resFolderPath + "Prefabs/Panels/Room", "*.prefab"));

        //桌子
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/roomdesk1", resFolderPath + "Atlas/Room/RoomDesk1", "*.jpg"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/roomdesk2", resFolderPath + "Atlas/Room/RoomDesk2", "*.jpg"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/roomdesk3", resFolderPath + "Atlas/Room/RoomDesk3", "*.jpg"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/roomdesk4", resFolderPath + "Atlas/Room/RoomDesk4", "*.jpg"));

        //普通扑克牌
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/pokercard", resFolderPath + "Atlas/Room/RoomPokerCard", "*.png"));
        //搓牌使用的扑克牌
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/rubpokercard", resFolderPath + "Atlas/Room/RoomRubPoker", "*.png"));
        //联盟
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/union", resFolderPath + "Atlas/Union", "*.png"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/union", resFolderPath + "Prefabs/Panels/Union", "*.prefab"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/union", resFolderPath + "Textures/Union/", "*.png"));
        configDatas.Add(AssetbundleConfigData.New(resFolderName + "/union", resFolderPath + "Textures/Union/", "*.jpg"));

        return Packager.GenerateAssetBundleBuildList(configDatas);
    }
}

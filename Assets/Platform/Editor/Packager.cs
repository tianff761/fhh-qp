using UnityEditor;
using UnityEngine;
using System;
using System.IO;
using System.Collections.Generic;
using LuaFramework;
using LitJson;
using System.Diagnostics;

public class Packager
{
    /// <summary>
    /// 打包所有资源处理
    /// </summary>
    public const string ResAll = "all";
    /// <summary>
    /// 资源文件目录名称
    /// </summary>
    public const string ResDirName = "res";
    /// <summary>
    /// 基础资源目录名称
    /// </summary>
    public const string BaseDirName = "base";

    /// <summary>
    /// 用于处理相同AB包中重复文件名称
    /// </summary>
    private static Dictionary<string, Dictionary<string, string>> RepeatFileDict = new Dictionary<string, Dictionary<string, string>>();

    private static List<string> dirs;
    private static double time;

    /// <summary>
    /// 打包前的处理
    /// </summary>
    public static void Init()
    {
        RepeatFileDict.Clear();
    }

    /// <summary>
    /// 获取Assets路径
    /// </summary>
    /// <returns></returns>
    public static string GetAssetsPath()
    {
        string dataPath = Application.dataPath;
        dataPath = dataPath.Replace('\\', '/');
        if (!dataPath.EndsWith("/"))
        {
            dataPath += "/";
        }
        return dataPath;
    }

    /// <summary>
    /// 获取StreamingAssets文件夹下的res文件目录路径
    /// </summary>
    /// <returns></returns>
    public static string GetResDirPath()
    {
        string temp = Application.dataPath + "/" + AppConst.StreamingAssetsDir + "/" + ResDirName + "/";
        temp = temp.Replace("\\", "/");
        return temp;
    }

    /// <summary>
    /// 打包
    /// </summary>
    public static void Build(string gameName, List<AssetBundleBuild> builds, BuildTarget buildTarget = BuildTarget.NoTarget)
    {
        UnityEngine.Debug.Log("Build AssetBundle Count :" + builds.Count);

        string tempGameName = gameName.ToLower();
        string resPath = GetResDirPath();
        //清除资源
        if (tempGameName == ResAll)
        {
            DeleteFilesByDirectory(resPath);
        }
        else
        {
            DeleteFilesByDirectory(resPath + BaseDirName + "/");
            DeleteFilesByDirectory(resPath + tempGameName + "/");
        }

        if (!Directory.Exists(resPath)) Directory.CreateDirectory(resPath);


        if (builds == null || builds.Count < 1)
        {
            UnityEngine.Debug.LogError(">> Build > builds is empty.");
            return;
        }

        if (buildTarget == BuildTarget.NoTarget)
        {
            buildTarget = EditorUserBuildSettings.activeBuildTarget;
        }

        double time = Util.GetTime();
        //1.打包
        BuildPipeline.BuildAssetBundles(resPath, builds.ToArray(), BuildAssetBundleOptions.ForceRebuildAssetBundle, buildTarget);
        //2.分别生成依赖文件，有包括Base
        dirs = GenerateDependencies();
        //3.处理AB加密
        HandleABFile(builds, OnEncryptionCallback);
        //OnEncryptionCallback();
    }

    /// <summary>
    /// 加密回调
    /// </summary>
    public static void OnEncryptionCallback()
    {
        //4.删除临时Lua文件
        DeleteLuaBytesFiles();
        //5.分别生成files文件和版本文件
        for(int i = 0; i < dirs.Count; i++)
        {
            GenerateMd5AndVersionFiles(dirs[i]);
        }

        AssetDatabase.Refresh();
        RepeatFileDict.Clear();

        DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1));
        // 当地时区
        DateTime dt = startTime.AddMilliseconds((Util.GetTime() - time));
        UnityEngine.Debug.Log("打包共计耗时:" + dt.Minute + "分钟," + dt.Second + "秒," + dt.Millisecond + "毫秒");

        AssetDatabase.Refresh();
    }

    /// <summary>
    /// 标记资源
    /// </summary>
    public static void Mark(string resName, List<AssetBundleBuild> builds)
    {
        //标记资源
        for (int i = 0; i < builds.Count; i++)
        {
            MarkAssetBundleBuild(builds[i]);
        }
        AssetDatabase.Refresh();
        RepeatFileDict.Clear();
    }

    /// <summary>
    /// 根据AssetBundleBuild进行标记
    /// </summary>
    static void MarkAssetBundleBuild(AssetBundleBuild abb)
    {
        string[] assetNames = abb.assetNames;

        if (assetNames == null || assetNames.Length < 1) { return; }
        UnityEngine.Debug.Log(">> ======================= > MarkAssetBundleBuild > " + abb.assetBundleName);
        for (int i = 0; i < assetNames.Length; i++)
        {
            string temp = assetNames[i];

            if (temp.EndsWith(".meta"))
            {
                continue;
            }

            AssetImporter importer = AssetImporter.GetAtPath(temp);
            if (importer != null)
            {
                importer.assetBundleName = abb.assetBundleName;
                importer.assetBundleVariant = null;
            }
            else
            {
                UnityEngine.Debug.LogWarning(">> AssetImporter > " + temp);
            }
        }
    }

    /// <summary>
    /// 拷贝临时的Lua文件
    /// </summary>
    public static void CopyLuaBytesFiles(string[] luaDirPaths, bool isEncryption = true)
    {
        if (luaDirPaths == null || luaDirPaths.Length < 1)
        {
            return;
        }

        string luaTempDir = Application.dataPath + "/" + AppConst.LuaTempDir;
        if (!Directory.Exists(luaTempDir)) Directory.CreateDirectory(luaTempDir);

        string luaDirPath = "";
        DirectoryInfo dirInfo = null;
        for (int i = 0; i < luaDirPaths.Length; i++)
        {
            luaDirPath = luaDirPaths[i];

            dirInfo = new DirectoryInfo(luaDirPath);
            ToLuaMenu.CopyLuaBytesFiles(Application.dataPath + luaDirPath, luaTempDir + dirInfo.Name + "/");
        }

        AssetDatabase.Refresh();
    }

    public static void ToLuaBytesFiles(string sourceDir, string searchPattern = "*.lua")
    {

        string[] files = Directory.GetFiles(sourceDir, searchPattern, SearchOption.AllDirectories);
        int len = sourceDir.Length;

        if (sourceDir[len - 1] == '/' || sourceDir[len - 1] == '\\')
        {
            --len;
        }

        for (int i = 0; i < files.Length; i++)
        {
            string fileName = files[i];
            //dest += ".bytes";
            string ex = Path.GetExtension(fileName);
            if (ex == ".lua")
            {
                fileName += ".bytes";
                File.Copy(files[i], fileName);
                File.Delete(files[i]);
            }
        }
    }

    /// <summary>
    /// 删除临时拷贝的Lua文件
    /// </summary>
    public static void DeleteLuaBytesFiles()
    {
        string luaTempDir = Application.dataPath + "/" + AppConst.LuaTempDir;
        if (Directory.Exists(luaTempDir)) Directory.Delete(luaTempDir, true);
    }

    /// <summary>
    /// 删除指定文件夹
    /// </summary>
    public static void DeleteDirectory(string dirPath)
    {
        if (Directory.Exists(dirPath)) Directory.Delete(dirPath, true);
    }

    /// <summary>
    /// 删除生成的Unity3D文件
    /// </summary>
    public static void DeleteFilesByDirectory(string dirPath)
    {
        if (Directory.Exists(dirPath))
        {
            //删除生成的文件
            string[] files = Directory.GetFiles(dirPath, "*" + AppConst.AssetExtName, SearchOption.AllDirectories);
            for (int i = 0; i < files.Length; i++)
            {
                File.Delete(files[i]);
            }
        }
    }

    /// <summary>
    /// 根据配置生成AssetBundleBuild列表
    /// </summary>
    /// <param name="list"></param>
    public static List<AssetBundleBuild> GenerateAssetBundleBuildList(List<AssetbundleConfigData> list)
    {
        List<AssetBundleBuild> builds = new List<AssetBundleBuild>();
        for (int i = 0; i < list.Count; i++)
        {
            builds.AddRange(GenerateAssetBundleBuildsByConfigData(list[i]));
        }
        return builds;
    }

    /// <summary>
    /// 通过单个AssetbundleConfigData配置数据生成AssetBundleBuild列表
    /// </summary>
    /// <param name="configData"></param>
    /// <returns></returns>
    private static List<AssetBundleBuild> GenerateAssetBundleBuildsByConfigData(AssetbundleConfigData configData)
    {
        List<AssetBundleBuild> builds = new List<AssetBundleBuild>();

        string bundleName = configData.bundleName;
        string ext = configData.ext;
        string path = configData.folderName;
        SearchOption option = configData.option;

        string dataPath = Application.dataPath;
        dataPath = dataPath.Replace('\\', '/').Replace("Assets", "");

        Dictionary<string, string> tempRepeatFileDict = null;
        if (RepeatFileDict.ContainsKey(bundleName))
        {
            tempRepeatFileDict = RepeatFileDict[bundleName];
        }
        else
        {
            tempRepeatFileDict = new Dictionary<string, string>();
            RepeatFileDict.Add(bundleName, tempRepeatFileDict);
        }

        if (!string.IsNullOrEmpty(path))
        {
            string tempPath = "Assets/" + path;
            if (Directory.Exists(tempPath))
            {
                string[] files = Directory.GetFiles(tempPath, ext, option);

                for (int i = 0; i < files.Length; i++)
                {
                    //检查重复文件
                    FileInfo fileInfo = new FileInfo(files[i]);
                    string key = fileInfo.Name;
                    if (tempRepeatFileDict.ContainsKey(key))
                    {
                        UnityEngine.Debug.LogError(">> Repeat file name > " + bundleName + " > path1 = " + tempRepeatFileDict[key]);
                        UnityEngine.Debug.LogError(">> Repeat file name > " + bundleName + " > path2 = " + fileInfo.FullName);
                    }
                    else
                    {
                        tempRepeatFileDict.Add(key, fileInfo.FullName);
                    }
                    files[i] = files[i].Replace('\\', '/').Replace(dataPath, "");
                }

                if (files.Length > 0)
                {
                    AssetBundleBuild build = new AssetBundleBuild();
                    build.assetBundleName = bundleName;
                    //UnityEngine.Debug.LogWarning(files[0]);
                    build.assetNames = files;
                    builds.Add(build);
                }
            }
        }

        if (configData.fileList.Count > 0)
        {
            CheckRepeatFile(bundleName, configData.fileList, tempRepeatFileDict);

            AssetBundleBuild build = new AssetBundleBuild();
            build.assetBundleName = bundleName;
            //UnityEngine.Debug.LogWarning(configData.fileList[0]);
            build.assetNames = configData.fileList.ToArray();
            builds.Add(build);
        }

        return builds;
    }

    /// <summary>
    /// 检测重复文件
    /// </summary>
    private static void CheckRepeatFile(string bundleName, List<string> fileList, Dictionary<string, string> repeatFileDict)
    {
        //检查重复文件
        for (int i = 0; i < fileList.Count; i++)
        {
            FileInfo fileInfo = new FileInfo(fileList[i]);
            string key = fileInfo.Name;
            if (repeatFileDict.ContainsKey(key))
            {
                UnityEngine.Debug.LogError(">> Repeat file name > " + bundleName + " > path1 = " + repeatFileDict[key]);
                UnityEngine.Debug.LogError(">> Repeat file name > " + bundleName + " > path2 = " + fileInfo.FullName);
            }
            else
            {
                repeatFileDict.Add(key, fileInfo.FullName);
            }
        }
    }

    //================================================================================

    /// <summary>
    /// 生成依赖文件
    /// </summary>
    private static List<string> GenerateDependencies()
    {
        string resPath = GetResDirPath();
        AssetBundle ab = AssetBundle.LoadFromFile(resPath + ResDirName);
        AssetBundleManifest assetBundleManifest = ab.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
        string[] assetBundles = assetBundleManifest.GetAllAssetBundles();
        string fileName = null;
        string resFolderName = null;
        string[] dependencies = null;
        //用于存储所有生成的游戏的资源
        Dictionary<string, DependenciesData> dependenciesDataDic = new Dictionary<string, DependenciesData>();
        DependenciesData dependenciesData = null;
        DependenciesSingleData dependenciesSingleData = null;

        for (int i = 0; i < assetBundles.Length; i++)
        {
            fileName = assetBundles[i];

            resFolderName = fileName.Substring(0, fileName.IndexOf("/"));
            if (!dependenciesDataDic.TryGetValue(resFolderName, out dependenciesData))
            {
                dependenciesData = new DependenciesData();
                dependenciesDataDic.Add(resFolderName, dependenciesData);
            }

            UnityEngine.Debug.Log(">> GenerateDependencies > fileName = " + fileName);
            UnityEngine.Debug.Log(">> GenerateDependencies > resFolderName = " + resFolderName);


            dependencies = assetBundleManifest.GetAllDependencies(fileName);
            if (dependencies != null && dependencies.Length > 0)
            {
                dependenciesSingleData = new DependenciesSingleData(fileName);
                dependenciesSingleData.dependencies.AddRange(dependencies);
                dependenciesData.infos.Add(fileName, dependenciesSingleData);
            }
        }
        //当次打包涉及到的游戏目录
        List<string> dirs = new List<string>();

        //分开写依赖文件
        foreach (KeyValuePair<string, DependenciesData> kvPair in dependenciesDataDic)
        {
            dirs.Add(kvPair.Key);
            string dependenciesFilePath = resPath + kvPair.Key + "/dependencies.json";
            string dependenciesJson = JsonMapper.ToJson(kvPair.Value);
            UnityEngine.Debug.Log(">> Dependencies File > " + dependenciesFilePath);
            File.WriteAllText(dependenciesFilePath, dependenciesJson);
        }
        return dirs;
    }

    /// <summary>
    /// 分别生成files文件和版本文件
    /// </summary>
    public static void GenerateMd5AndVersionFiles(string gameName)
    {
        string resPath = GetResDirPath();
        string gameDirPath = resPath + gameName + "/";
        string filesPath = gameDirPath + "files.json";

        //如果存在，需要进行MD5码对比，如果相同就不进行版本号的升级
        Md5FilesData oldMd5FilesData = null;
        Dictionary<string, string> oldMd5Dic = new Dictionary<string, string>();
        if (File.Exists(filesPath))
        {
            try
            {
                oldMd5FilesData = JsonMapper.ToObject<Md5FilesData>(File.ReadAllText(filesPath));
                if (oldMd5FilesData.datas != null)
                {
                    for (int i = 0; i < oldMd5FilesData.datas.Count; i++)
                    {
                        Md5FileSingleData temp = oldMd5FilesData.datas[i];
                        oldMd5Dic.Add(temp.name, temp.md5);
                    }
                }
            }
            catch (Exception ex)
            {
                UnityEngine.Debug.LogException(ex);
            }
            File.Delete(filesPath);
        }

        DirectoryInfo directoryInfo = new DirectoryInfo(gameDirPath);

        List<FileInfo> files = new List<FileInfo>();
        files.AddRange(directoryInfo.GetFiles("*.json"));
        files.AddRange(directoryInfo.GetFiles("*" + AppConst.AssetExtName));
        bool isModify = false;
        Md5FilesData md5FilesData = new Md5FilesData();
        foreach (FileInfo fileInfo in files)
        {
            string name = fileInfo.FullName.Replace("\\", "/").Replace(resPath, "");
            string md5 = Util.md5file(fileInfo.FullName);

            if (!isModify && (!oldMd5Dic.ContainsKey(name) || oldMd5Dic[name] != md5))
            {
                isModify = true;
            }

            md5FilesData.datas.Add(new Md5FileSingleData(name, md5, (int)fileInfo.Length));
        }
        File.WriteAllText(filesPath, JsonMapper.ToJson(md5FilesData));

        //删除Manifest文件
        FileInfo[] tempFileInfos = directoryInfo.GetFiles("*.manifest");
        foreach (FileInfo fileInfo in tempFileInfos)
        {
            fileInfo.Delete();
        }

        //string versionPath = gameDirPath + "version.txt";
        ////是否有修改，有修改或者没有版本文件都需要生成新的版本文件
        //if (isModify || !File.Exists(versionPath))
        //{
        //    //GenerateVersion(gameName);关闭版本文件的生成，出包时人工填写
        //}
        //else
        //{
        //    UnityEngine.Debug.Log(">> 文件没有修改，不生成版本文件 > gameName = " + gameName + ", buildPlatform = " + EditorUserBuildSettings.activeBuildTarget);
        //}
    }


    /// <summary>
    /// 分别生成版本文件
    /// </summary>
    private static void GenerateVersion(string gameName)
    {
        string resPath = GetResDirPath();
        string newVersionPath = resPath + gameName + "/" + "version.txt";
        if (File.Exists(newVersionPath)) File.Delete(newVersionPath);

        VersionData versionData = null;

        string backupVersionPath = Application.dataPath;
        backupVersionPath = backupVersionPath.Replace("\\", "/").Replace("Assets", "");
        backupVersionPath = backupVersionPath + "version.txt";
        if (File.Exists(backupVersionPath))
        {
            try
            {
                versionData = JsonMapper.ToObject<VersionData>(File.ReadAllText(backupVersionPath));
            }
            catch (Exception ex)
            {
                UnityEngine.Debug.LogException(ex);
            }
        }

        if (versionData == null)
        {
            versionData = new VersionData();
        }

        if (versionData.games == null)
        {
            versionData.games = new List<VersionGameData>();
        }

        Version backupVersion = versionData.GetGameVersion(gameName);

        if (backupVersion == null)
        {
            backupVersion = new Version("1.0.0");
        }

        int Build = backupVersion.Build + 1;
        int Minor = backupVersion.Minor;
        if (Build > 99)
        {
            Build = Build % 100;
            Minor++;
        }

        Version tempVersionVersion = new Version(backupVersion.Major, Minor, Build);
        string newVersionStr = tempVersionVersion.ToString();

        VersionGameData versionGameData = null;
        for (int i = 0; i < versionData.games.Count; i++)
        {
            if (versionData.games[i].name == gameName)
            {
                versionGameData = versionData.games[i];
                break;
            }
        }

        if (versionGameData == null)
        {
            versionGameData = new VersionGameData();
            versionGameData.name = gameName;
            versionGameData.version = newVersionStr;
            versionData.games.Add(versionGameData);
        }
        else
        {
            versionGameData.version = newVersionStr;
        }

        File.WriteAllText(backupVersionPath, JsonMapper.ToJson(versionData));
        File.WriteAllText(newVersionPath, newVersionStr);

        UnityEngine.Debug.Log(">> 生成版本文件 > gameName = " + gameName + "， version = " + newVersionStr + ", buildPlatform = " + EditorUserBuildSettings.activeBuildTarget);
    }


    //================================================================================

    /// <summary>
    /// 遍历目录及其子目录
    /// </summary>
    static List<string> Recursive(string path)
    {
        string[] names = Directory.GetFiles(path, "*.lua", SearchOption.AllDirectories);
        List<string> files = new List<string>();
        foreach (string filename in names)
        {
            string ext = Path.GetExtension(filename);
            if (ext.Equals(".meta")) continue;
            files.Add(filename.Replace('\\', '/'));
        }
        return files;
    }


    /// <summary>
    /// 数据目录
    /// </summary>
    static string AppDataPath
    {
        get { return Application.dataPath; }
    }

    static void UpdateProgress(int progress, int progressMax, string desc)
    {
        string title = "Processing...[" + progress + " - " + progressMax + "]";
        float value = (float)progress / (float)progressMax;
        EditorUtility.DisplayProgressBar(title, desc, value);
    }


    static void HandleABFile(BuildTarget buildTarget, string tempGameName, Action callback)
    {
        //处理AB加密
        if (tempGameName == ResAll)
        {
            DirectoryInfo info = new DirectoryInfo(GetResDirPath());
            FileInfo[] files = info.GetFiles("*.unity3d", SearchOption.AllDirectories);
            EncryptionABFile(files, callback);
        }
        else
        {
            //base 必定build
            List<FileInfo> files = new List<FileInfo>();
            DirectoryInfo info = new DirectoryInfo(GetResDirPath() + BaseDirName + "/");
            FileInfo[] tempFiles = info.GetFiles("*.unity3d", SearchOption.AllDirectories);

            for (int i = 0; i < tempFiles.Length; i++)
            {
                files.Add(tempFiles[i]);
            }
            //build不是base
            if (!tempGameName.Equals(BaseDirName))
            {
                info = new DirectoryInfo(GetResDirPath() + tempGameName + "/");
                tempFiles = info.GetFiles("*.unity3d", SearchOption.AllDirectories);
                for (int i = 0; i < tempFiles.Length; i++)
                {
                    files.Add(tempFiles[i]);
                }
            }
            EncryptionABFile(files.ToArray(), callback);
        }
    }

    static void HandleABFile(List<AssetBundleBuild> builds, Action callback = null)
    {
        string path = "";
        List<FileInfo> files = new List<FileInfo>();
        bool contains = false;
        for (int i = 0; i < builds.Count; i++)
        {
            path = GetResDirPath() + builds[i].assetBundleName;
            if (path.EndsWith(".unity3d"))
            {
                contains = false;
                FileInfo fi = new FileInfo(path);
                for (int j = 0; j < files.Count; j++)
                {
                    if (files[j].FullName == fi.FullName)
                    {
                        contains = true;
                        break;
                    }
                }
                if (!contains)
                {
                    files.Add(fi);
                }
            }
        }
        EncryptionABFile(files.ToArray(), callback);
    }

    /// <summary>
    /// 加密文件
    /// </summary>
    static void EncryptionFile(string path)
    {
        if (File.Exists(path))
        {
            byte[] bytes = File.ReadAllBytes(path);
            bytes = Encryption.Encode(bytes);
            File.WriteAllBytes(path, bytes);
        }
    }

    /// <summary>
    /// 处理AB文件
    /// </summary>
    static void EncryptionABFile(FileInfo[] files, Action callback)
    {
        int startIndex = 0;
        int filesLen = files.Length;

        EditorApplication.update = delegate ()
        {
            FileInfo file = files[startIndex];
            bool isCancel = EditorUtility.DisplayCancelableProgressBar("加密资源中(" + startIndex + "/" + filesLen + ")", file.FullName, (float)startIndex / (float)files.Length);

            EncryptionFile(file.FullName);

            startIndex++;
            if (isCancel || startIndex >= filesLen)
            {
                EditorUtility.ClearProgressBar();
                EditorApplication.update = null;
                startIndex = 0;
                AssetDatabase.Refresh();
                UnityEngine.Debug.Log("加密完成");
                if (callback != null)
                {
                    callback.Invoke();
                }
            }
        };
    }
    struct ABConfigs
    {
        public Dictionary<string, List<ABConfig>> games;
    }

    struct ABConfig
    {
        public string bundleName;
        public string bundleGuid;
        public List<string> guids;
        public List<string> md5s;
        public string folderName;
        public string ext;
        public SearchOption option;
    }

    public static List<AssetbundleConfigData> CheckLocalABGuid(string resFolderName, List<AssetbundleConfigData> configDatas)
    {
        return configDatas;

        List<AssetbundleConfigData> newConfigDatas = new List<AssetbundleConfigData>();
        List<ABConfig> newABDir = new List<ABConfig>();
        string path = Application.dataPath.Replace("Assets", "AssetBundleConfig") + "/abFileconfig.txt";

        ABConfigs abConfigs;

        List<ABConfig> abConfigList;
        if (File.Exists(path))
        {
            string json = File.ReadAllText(path);
            abConfigs = JsonMapper.ToObject<ABConfigs>(json);
            if (abConfigs.games.ContainsKey(resFolderName))
            {
                abConfigList = abConfigs.games[resFolderName];
            }
            else
            {
                abConfigList = new List<ABConfig>();
            }
        }
        else
        {
            abConfigList = new List<ABConfig>();
            abConfigs = new ABConfigs
            {
                games = new Dictionary<string, List<ABConfig>>()
            };
        }

        string abName = "";
        for (int i = 0; i < configDatas.Count; i++)
        {
            abName = configDatas[i].bundleName;
            ABConfig abConfig = CheckConfigData(configDatas[i]);
            if (abConfig.ext == "*.bytes")
            {
                newConfigDatas.Add(configDatas[i]);
            }
            else
            {
                string streamPath = GetResDirPath() + configDatas[i].bundleName;
                FileInfo fi = new FileInfo(streamPath);
                if (File.Exists(streamPath) || fi.Exists)
                {
                    bool isSame = false;
                    for (int j = 0; j < abConfigList.Count; j++)
                    {
                        if (CheckABConfigSame(abConfigList[j], abConfig))
                        {
                            abConfig.bundleGuid = abConfigList[j].bundleGuid;
                            isSame = CheckStreamAssets(abConfigList[j]);
                            break;
                        }
                    }
                    if (!isSame)
                    {
                        newConfigDatas.Add(configDatas[i]);
                    }
                }
                else
                {
                    UnityEngine.Debug.Log("路径不存在:" + streamPath);
                    newConfigDatas.Add(configDatas[i]);
                }
            }
            newABDir.Add(abConfig);
        }

        abConfigs.games[resFolderName] = newABDir;

        FileUtils.CheckCrateDir(Path.GetDirectoryName(path));

        File.WriteAllText(path, JsonMapper.ToJson(abConfigs));

        return newConfigDatas;
    }

    /// <summary>
    /// 检测获取AssetbundleConfigData配置
    /// </summary>
    /// <param name="assetbundleConfigData"></param>
    /// <returns></returns>
    static ABConfig CheckConfigData(AssetbundleConfigData assetbundleConfigData)
    {
        ABConfig abConfig = new ABConfig
        {
            bundleName = assetbundleConfigData.bundleName,
            guids = new List<string>(),
            md5s = new List<string>(),
            folderName = assetbundleConfigData.folderName == null ? "" : assetbundleConfigData.folderName,
            ext = assetbundleConfigData.ext == null ? "" : assetbundleConfigData.ext,
            option = assetbundleConfigData.option
        };

        //读取文件夹中的文件(加入fileList列表)
        if (!string.IsNullOrEmpty(assetbundleConfigData.folderName) && !string.IsNullOrEmpty(assetbundleConfigData.ext))
        {
            if (Directory.Exists(Application.dataPath + "/" + assetbundleConfigData.folderName))
            {
                DirectoryInfo di = new DirectoryInfo(Application.dataPath + "/" + assetbundleConfigData.folderName);
                FileInfo[] fi = di.GetFiles(assetbundleConfigData.ext, assetbundleConfigData.option);
                if (fi.Length == 0)
                {
                    UnityEngine.Debug.LogError(assetbundleConfigData.folderName + " 该文件夹中" + assetbundleConfigData.ext + "类型为空");
                }

                FileInfo[] fi1 = new FileInfo[0];
                if (assetbundleConfigData.ext != "*.*")
                {
                    fi1 = di.GetFiles(assetbundleConfigData.ext + ".meta", assetbundleConfigData.option);
                }

                for (int j = 0; j < fi.Length; j++)
                {
                    abConfig.guids.Add(Util.md5(File.ReadAllText(fi[j].FullName)));
                }

                for (int j = 0; j < fi1.Length; j++)
                {
                    abConfig.md5s.Add(Util.md5(File.ReadAllText(fi1[j].FullName)));
                }
            }
            else
            {
                UnityEngine.Debug.LogError(assetbundleConfigData.folderName + " 不存在该文件夹");
            }
        }

        for (int j = 0; j < assetbundleConfigData.fileList.Count; j++)
        {
            abConfig.guids.Add(Util.md5(File.ReadAllText(assetbundleConfigData.fileList[j])));
            abConfig.md5s.Add(Util.md5(File.ReadAllText(assetbundleConfigData.fileList[j] + ".meta")));
        }
        return abConfig;
    }

    /// <summary>
    /// 对比ABConfig是否相同
    /// </summary>
    /// <param name="abConfig1"></param>
    /// <param name="abConfig2"></param>
    /// <returns></returns>
    static bool CheckABConfigSame(ABConfig abConfig1, ABConfig abConfig2)
    {
        if (!abConfig1.bundleName.Equals(abConfig2.bundleName))
        {
            return false;
        }

        if (abConfig1.ext != abConfig2.ext)
        {
            return false;
        }

        if (abConfig1.folderName != abConfig2.folderName)
        {
            return false;
        }

        if (!abConfig1.option.Equals(abConfig2.option))
        {
            return false;
        }

        if (abConfig1.guids.Count != abConfig2.guids.Count)
        {
            return false;
        }

        if (abConfig1.md5s.Count != abConfig2.md5s.Count)
        {
            return false;
        }

        for (int i = 0; i < abConfig1.guids.Count; i++)
        {
            if (!abConfig2.guids.Contains(abConfig1.guids[i]))
            {
                return false;
            }
        }

        for (int i = 0; i < abConfig1.md5s.Count; i++)
        {
            if (!abConfig2.md5s.Contains(abConfig1.md5s[i]))
            {
                return false;
            }
        }

        return true;
    }

    /// <summary>
    /// 设置assetbundle包的guid 到配置文件中
    /// </summary>
    /// <param name="resFolderName"></param>
    static void CheckAbGuid(string resFolderName)
    {
        return;
        string path = Application.dataPath.Replace("Assets", "AssetBundleConfig") + "/abFileconfig.txt";
        ABConfigs abConfigs;
        if (File.Exists(path))
        {
            string json = File.ReadAllText(path);
            abConfigs = JsonMapper.ToObject<ABConfigs>(json);
        }
        else
        {
            return;
        }
        abConfigs = CheckAbGuid2(resFolderName, abConfigs);
        File.WriteAllText(path, JsonMapper.ToJson(abConfigs));
    }

    static ABConfigs CheckAbGuid2(string resFolderName, ABConfigs abConfigs)
    {
        resFolderName = resFolderName.ToLower();
        List<string> ress = new List<string>();
        string dirPath = GetResDirPath() + resFolderName;
        if (resFolderName == ResAll)
        {
            dirPath = GetResDirPath();
            DirectoryInfo di = new DirectoryInfo(dirPath);
            DirectoryInfo[] di2 = di.GetDirectories();

            for (int i = 0; i < di2.Length; i++)
            {
                ress.Add(di2[i].Name);
            }
        }
        else
        {
            ress.Add(resFolderName);
        }

        for (int i = 0; i < ress.Count; i++)
        {
            dirPath = GetResDirPath() + ress[i];
            DirectoryInfo di = new DirectoryInfo(dirPath);

            FileInfo[] fi = di.GetFiles("*.unity3d", SearchOption.AllDirectories);
            List<ABConfig> abConfigList;
            if (abConfigs.games.ContainsKey(ress[i]))
            {
                abConfigList = abConfigs.games[ress[i]];
            }
            else
            {
                continue;
            }

            for (int j = 0; j < fi.Length; j++)
            {
                for (int m = 0; m < abConfigList.Count; m++)
                {
                    if (abConfigList[m].bundleName == ress[i] + "/" + fi[j].Name)
                    {
                        ABConfig ab = abConfigList[m];
                        ab.bundleGuid = GetGuild(fi[j].FullName);
                        abConfigList[m] = ab;
                    }
                }
            }
            abConfigs.games[ress[i]] = abConfigList;
        }
        return abConfigs;
    }

    static string GetGuild(string path)
    {
        path = path.Replace("\\", "/");
        path = path.Replace(Application.dataPath + "/", "Assets/");
        return AssetDatabase.AssetPathToGUID(path);
    }

    /// <summary>
    /// 检测streamassets资源中的包的guid对比
    /// </summary>
    /// <param name="abConfig"></param>
    /// <returns></returns>
    static bool CheckStreamAssets(ABConfig abConfig)
    {
        string path = GetResDirPath() + abConfig.bundleName;
        if (!File.Exists(path))
        {
            return false;
        }
        if (abConfig.bundleGuid != GetGuild(path))
        {
            return false;
        }
        return true;
    }
}
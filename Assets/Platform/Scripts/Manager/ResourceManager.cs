using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using LuaInterface;
using LitJson;
using UnityEngine.Networking;
using UObject = UnityEngine.Object;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace LuaFramework
{
    /// <summary>
    /// 资源的Type
    /// </summary>
    public class AssetType
    {
        /// <summary>
        /// GameObject
        /// </summary>
        public static Type GAME_OBJECT = typeof(GameObject);
        /// <summary>
        /// Sprite
        /// </summary>
        public static Type SPRITE = typeof(Sprite);
        /// <summary>
        /// Texture
        /// </summary>
        public static Type TEXTURE = typeof(Texture);
        /// <summary>
        /// TextAsset
        /// </summary>
        public static Type TEXT_ASSET = typeof(TextAsset);
        /// <summary>
        /// AudioClip
        /// </summary>
        public static Type AUDIO_CLIP = typeof(AudioClip);
    }

    /// <summary>
    /// 加载状态
    /// </summary>
    public enum LoadState
    {
        /// <summary>
        /// 无状态
        /// </summary>
        None = 1,
        /// <summary>
        /// 下载中
        /// </summary>
        Loading = 2,
        /// <summary>
        /// 下载完成
        /// </summary>
        Loaded = 3,
    }

    /// <summary>
    /// AB包信息
    /// </summary>
    public class AssetBundleInfo
    {
        /// <summary>
        /// AB包名称，依赖文件中的名称
        /// </summary>
        private string mName = null;
        /// <summary>
        /// 加载状态
        /// </summary>
        public LoadState loadState = LoadState.None;
        /// <summary>
        /// AssetBundle资源包
        /// </summary>
        public AssetBundle assetBundle = null;
        /// <summary>
        /// 依赖引用计数，即被多少AB包依赖引用了
        /// </summary>
        public int referencedCount = 0;
        /// <summary>
        /// 资源请求列表
        /// </summary>
        public List<AssetLoadRequest> assetRequests = new List<AssetLoadRequest>();
        /// <summary>
        /// 是否处于激活状态，没激活的将要被卸载
        /// </summary>
        public bool active = true;
        /// <summary>
        /// 是否彻底的卸载，用于加载完成处于不激活
        /// </summary>
        public bool isThoroughUnload = false;

        public AssetBundleInfo(string name)
        {
            this.mName = name;
        }

        public string name
        {
            get { return this.mName; }
        }

        /// <summary>
        /// 清除
        /// </summary>
        public void Clear()
        {
            if (this.assetBundle != null)
            {
                this.assetBundle.Unload(this.isThoroughUnload);
            }

            for (int i = 0; i < this.assetRequests.Count; i++)
            {
                this.assetRequests[i].Clear();
            }
            this.assetRequests.Clear();
        }
    }

    /// <summary>
    /// 资源加载请求
    /// </summary>
    public class AssetLoadRequest
    {
        /// <summary>
        /// 资源类型
        /// </summary>
        public Type assetType;
        /// <summary>
        /// 资源名称
        /// </summary>
        public string[] assetNames;
        /// <summary>
        /// C#层回调
        /// </summary>
        public Action<UObject[]> callback;
        /// <summary>
        /// Lua层回调
        /// </summary>
        public LuaFunction luaFunction;
        /// <summary>
        /// Lua参数
        /// </summary>
        public LuaTable luaTable;

        /// <summary>
        /// 清除
        /// </summary>
        public void Clear()
        {
            if (this.callback != null)
            {
                this.callback = null;
            }
            if (this.luaFunction != null)
            {
                this.luaFunction.Dispose();
                this.luaFunction = null;
            }
            this.luaTable = null;
        }
    }

    /// <summary>
    /// 资源加载管理
    /// </summary>
    public class ResourceManager : Manager
    {
        /// <summary>
        /// res资源目录Url路径
        /// </summary>
        private string mResDirUrlPath = "";
        /// <summary>
        /// res资源目录路径
        /// </summary>
        private string mResDirPath = "";
        /// <summary>
        /// 依赖数据
        /// </summary>
        private Dictionary<string, DependenciesData> mDependenciesDataDict = new Dictionary<string, DependenciesData>();
        /// <summary>
        /// 依赖缓存
        /// </summary>
        private Dictionary<string, string[]> mDependenciesDict = new Dictionary<string, string[]>();

        /// <summary>
        /// AB包信息
        /// </summary>
        private Dictionary<string, AssetBundleInfo> mAssetBundleInfoDict = new Dictionary<string, AssetBundleInfo>();
        /// <summary>
        /// AB下载中列表
        /// </summary>
        private List<AssetBundleInfo> mLoadingAssetBundles = new List<AssetBundleInfo>();

        /// <summary>
        /// 加载中的AssetBundleInfo
        /// </summary>
        private AssetBundleInfo mLoadingAssetBundleInfo = null;


        //================================================================

        /// <summary>
        /// 初始化
        /// </summary>
        public void Initialize()
        {
            mResDirUrlPath = Util.AssetsUrlPath + AppConst.ResPathName + "/";
            mResDirPath = Util.AssetsPath + AppConst.ResPathName + "/";
        }


        //================================================================

        /// <summary>
        /// 添加依赖
        /// </summary>
        public void AddDependencies(string folderName)
        {
            if (string.IsNullOrEmpty(folderName))
            {
                Debug.LogWarning(">> ResourceManager > AddDependencies > resFolderName is NullOrEmpty.");
                return;
            }

            string fileName = Util.AssetsPath + AppConst.ResPathName + "/" + folderName + "/dependencies.json";
            try
            {
                if (File.Exists(fileName))
                {
                    string str = File.ReadAllText(fileName);
                    if (!string.IsNullOrEmpty(str))
                    {
                        DependenciesData dependenciesData = JsonMapper.ToObject<DependenciesData>(str);
                        mDependenciesDataDict[folderName] = dependenciesData;
                    }
                    else
                    {
                        Debug.LogWarning(">> ResourceManager > AddDependencies > IsNullOrEmpty > " + fileName);
                    }
                }
                else
                {
                    Debug.LogWarning(">> ResourceManager > AddDependencies > Not Exists > " + fileName);
                }
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }

        /// <summary>
        /// 移除依赖
        /// </summary>
        public void RemoveDependencies(string folderName)
        {
            if (!string.IsNullOrEmpty(folderName))
            {
                this.mDependenciesDataDict.Remove(folderName);
            }
        }

        /// <summary>
        /// 获取单个AB包的依赖文件列表
        /// </summary>
        public string[] GetDependenciesByName(string abName)
        {
            //直接缓存中查找
            if (this.mDependenciesDict.ContainsKey(abName))
            {
                return this.mDependenciesDict[abName];
            }

            //数据中查找
            string folderName = null;
            if (abName.Contains("/"))
            {
                folderName = abName.Substring(0, abName.IndexOf("/"));
            }
            else if (abName.EndsWith(AppConst.AssetExtName))
            {
                folderName = abName.Replace(AppConst.AssetExtName, "");
            }
            else
            {
                folderName = abName;
            }

            string[] dependencies = null;

            DependenciesData dependenciesData = null;
            if (this.mDependenciesDataDict.TryGetValue(folderName, out dependenciesData))
            {
                dependencies = dependenciesData.GetAllDependencies(abName);
            }

            this.mDependenciesDict.Add(abName, dependencies);

            return dependencies;
        }

        /// <summary>
        /// 删除单个AB包的依赖文件列表
        /// </summary>
        public void DeleteDependenciesByName(string abName)
        {
            if (this.mDependenciesDict.ContainsKey(abName))
            {
                this.mDependenciesDict.Remove(abName);
            }
        }

        //================================================================

        /// <summary>
        /// 加载单个GameObject
        /// </summary>
        public void LoadPrefab(string abName, string assetName, Action<UObject[]> callback)
        {
            LoadAsset(AssetType.GAME_OBJECT, abName, assetName, callback);
        }

        /// <summary>
        /// 加载单个GameObject
        /// </summary>
        public void LoadPrefab(string abName, string assetName, LuaFunction luaFunction, LuaTable luaTable)
        {
            LoadAsset(AssetType.GAME_OBJECT, abName, assetName, luaFunction, luaTable);
        }

        /// <summary>
        /// 加载GameObject数组
        /// </summary>
        public void LoadPrefabs(string abName, string[] assetNames, Action<UObject[]> callback)
        {
            LoadAssets(AssetType.GAME_OBJECT, abName, assetNames, callback);
        }

        /// <summary>
        /// 加载GameObject数组
        /// </summary>
        public void LoadPrefabs(string abName, string[] assetNames, LuaFunction luaFunction, LuaTable luaTable)
        {
            LoadAssets(AssetType.GAME_OBJECT, abName, assetNames, luaFunction, luaTable);
        }

        //----------------------------------------------------------------

        /// <summary>
        /// 加载单个图片精灵
        /// </summary>
        public void LoadSprite(string abName, string assetName, Action<UObject[]> callback)
        {
            LoadAsset(AssetType.SPRITE, abName, assetName, callback);
        }

        /// <summary>
        /// 加载单个图片精灵
        /// </summary>
        public void LoadSprite(string abName, string assetName, LuaFunction luaFunction, LuaTable luaTable)
        {
            LoadAsset(AssetType.SPRITE, abName, assetName, luaFunction, luaTable);
        }

        /// <summary>
        /// 加载单个精灵数组
        /// </summary>
        public void LoadSprites(string abName, string[] assetNames, Action<UObject[]> callback)
        {
            LoadAssets(AssetType.SPRITE, abName, assetNames, callback);
        }

        /// <summary>
        /// 加载图片精灵数组
        /// </summary>
        public void LoadSprites(string abName, string[] assetNames, LuaFunction luaFunction, LuaTable luaTable)
        {
            LoadAssets(AssetType.SPRITE, abName, assetNames, luaFunction, luaTable);
        }

        //----------------------------------------------------------------

        /// <summary>
        /// 加载音频文件
        /// </summary>
        public void LoadAudioClip(string abName, string assetName, Action<UObject[]> callback)
        {
            LoadAsset(AssetType.AUDIO_CLIP, abName, assetName, callback);
        }

        /// <summary>
        /// 加载音频文件
        /// </summary>
        public void LoadAudioClip(string abName, string assetName, LuaFunction luaFunction, LuaTable luaTable)
        {
            LoadAsset(AssetType.AUDIO_CLIP, abName, assetName, luaFunction, luaTable);
        }

        /// <summary>
        /// 加载单个音频数组
        /// </summary>
        public void LoadAudioClips(string abName, string[] assetNames, Action<UObject[]> callback)
        {
            LoadAssets(AssetType.AUDIO_CLIP, abName, assetNames, callback);
        }

        /// <summary>
        /// 加载音频数组
        /// </summary>
        public void LoadAudioClips(string abName, string[] assetNames, LuaFunction luaFunction, LuaTable luaTable)
        {
            LoadAssets(AssetType.AUDIO_CLIP, abName, assetNames, luaFunction, luaTable);
        }

        //================================================================

        /// <summary>
        /// 加载单个资源
        /// </summary>
        public void LoadAsset(Type type, string abName, string assetName, Action<UObject[]> func)
        {
            InternalLoadAsset(type, abName, new string[] { assetName }, func, null, null);
        }

        /// <summary>
        /// 加载单个资源
        /// </summary>
        public void LoadAsset(Type type, string abName, string assetName, LuaFunction func, LuaTable luaTable)
        {
            InternalLoadAsset(type, abName, new string[] { assetName }, null, func, luaTable);
        }

        /// <summary>
        /// 加载资源数组
        /// </summary>
        public void LoadAssets(Type type, string abName, string[] assetNames, Action<UObject[]> func)
        {
            InternalLoadAsset(type, abName, assetNames, func, null, null);
        }

        /// <summary>
        /// 加载资源数组
        /// </summary>
        public void LoadAssets(Type type, string abName, string[] assetNames, LuaFunction func, LuaTable luaTable)
        {
            InternalLoadAsset(type, abName, assetNames, null, func, luaTable);
        }


        //================================================================

        /// <summary>
        /// 获取检测AB包的名称
        /// </summary>
        public string CheckRealAssetPath(string abName)
        {
            if (!abName.EndsWith(AppConst.AssetExtName))
            {
                abName += AppConst.AssetExtName;
            }

            return abName;
        }


        /// <summary>
        /// 内部加载资源，加载资源的底层接口
        /// </summary>
        private void InternalLoadAsset(Type type, string abName, string[] assetNames, Action<UObject[]> callback = null, LuaFunction luaFunction = null, LuaTable luaTable = null)
        {

            Debug.Log(">> ResourceManager > InternalLoadAsset > abName = " + abName);

            abName = this.CheckRealAssetPath(abName);

            AssetLoadRequest request = new AssetLoadRequest();
            request.assetType = type;
            request.assetNames = assetNames;
            request.luaFunction = luaFunction;
            request.callback = callback;
            request.luaTable = luaTable;

            AssetBundleInfo abInfo = null;

            if (this.mAssetBundleInfoDict.TryGetValue(abName, out abInfo))
            {
                //重设激活标识
                abInfo.active = true;
            }
            else
            {
                abInfo = new AssetBundleInfo(abName);
                this.mAssetBundleInfoDict.Add(abName, abInfo);
            }

            //如果不是下载完成，且不存在加载中，说明是依赖下载，需要添加到加载列表中
            if (abInfo.loadState != LoadState.Loaded)
            {
                bool isExist = false;
                for (int i = 0; i < this.mLoadingAssetBundles.Count; i++)
                {
                    if (this.mLoadingAssetBundles[i].name == abName)
                    {
                        isExist = true;
                        break;
                    }
                }
                if (!isExist)
                {
                    this.mLoadingAssetBundles.Add(abInfo);
                }
            }

            //把资源请求添加到列表中
            this.AddAndLoadAsset(abInfo, request);

            //推动下载
            this.StartAssetBundleLoad();
        }

        /// <summary>
        /// 添加和加载资源
        /// </summary>
        private void AddAndLoadAsset(AssetBundleInfo abInfo, AssetLoadRequest request)
        {
            if (abInfo.loadState == LoadState.Loaded)
            {
                //AB下载完成，推动资源下载，该处必须先判断数量，再添加
                if (abInfo.assetRequests.Count < 1)
                {
                    abInfo.assetRequests.Add(request);
                    //推动资源加载
                    this.StartAssetLoad(abInfo);
                }
                else
                {
                    abInfo.assetRequests.Add(request);
                }
            }
            else
            {
                //AB未下载，直接把下载请求加入到队列
                abInfo.assetRequests.Add(request);
            }
        }

        //----------------------------------------------------------------

        /// <summary>
        /// 开始AB包加载
        /// </summary>
        private void StartAssetBundleLoad()
        {
            if (this.mLoadingAssetBundleInfo == null)
            {
                StartCoroutine(this.OnStartAssetBundleLoad());
            }
            else
            {
                Debug.Log(">> ResourceManager > StartAssetBundleLoad > Waiting > abName = " + this.mLoadingAssetBundleInfo.name);
            }
        }

        /// <summary>
        /// 开始AB包加载，AB包为队列加载
        /// </summary>
        IEnumerator OnStartAssetBundleLoad()
        {
            if (this.mLoadingAssetBundles.Count > 0)
            {
                this.mLoadingAssetBundleInfo = this.mLoadingAssetBundles[0];
                this.mLoadingAssetBundles.RemoveAt(0);

                AssetBundleInfo abInfo = this.mLoadingAssetBundleInfo;

                //Debug.Log(">> ResourceManager > OnStartAssetBundleLoad > abName > " + abInfo.name);

#if UNITY_EDITOR
                bool isEditorAssets = EditorConst.editorAssetsType == EditorAssetsType.Editor;
                if (isEditorAssets)
                {
                    Debug.Log(">> ResourceManager > OnStartAssetBundleLoad > Editor > " + abInfo.name + " > load finish.");
                    abInfo.loadState = LoadState.Loaded;
                    yield return null;
                }
                else
#endif
                {
                    if (abInfo.loadState == LoadState.None)
                    {
                        yield return StartCoroutine(this.OnLoadAssetBundle(abInfo));
                    }
                    else
                    {
                        yield return null;
                    }
                    Debug.Log(">> ResourceManager > OnStartAssetBundleLoad > " + abInfo.name + " > load finish." + "  " + abInfo.referencedCount);
                }

                if (abInfo.active)
                {
                    this.StartAssetLoad(abInfo);
                }
                else
                {
                    this.InternalUnloadAssetBundle(abInfo);
                }
                this.mLoadingAssetBundleInfo = null;
                //继续加载列表中的
                this.StartAssetBundleLoad();
            }
            else
            {
                yield return null;
            }
        }


        /// <summary>
        /// 开始资源加载
        /// </summary>
        private void StartAssetLoad(AssetBundleInfo abInfo)
        {
            //Debug.Log(">> ResourceManager > StartAssetLoad > abName > " + abInfo.name);
            StartCoroutine(OnStartAssetLoad(abInfo));
        }

        /// <summary>
        /// 开始资源加载
        /// </summary>
        IEnumerator OnStartAssetLoad(AssetBundleInfo abInfo)
        {
            List<AssetLoadRequest> list = abInfo.assetRequests;
            string abName = abInfo.name;
            AssetLoadRequest assetLoadRequest = null;
#if UNITY_EDITOR
            bool isEditorAssets = EditorConst.editorAssetsType == EditorAssetsType.Editor;
#endif

            for (int i = 0; i < list.Count; i++)
            {
                assetLoadRequest = list[i];
                string[] assetNames = assetLoadRequest.assetNames;
                List<UObject> result = new List<UObject>();
                Debug.Log(">> ResourceManager > OnStartAssetLoad > abName = " + abName + ", assetNames Length = " + assetNames.Length);
#if UNITY_EDITOR
                if (isEditorAssets)
                {
                    for (int j = 0; j < assetNames.Length; j++)
                    {
                        UObject obj = LoadAssetInEditor(abName, assetNames[j], assetLoadRequest.assetType);
                        if (obj != null)
                        {
                            Debug.Log(">> ResourceManager > Editor > LoadAsset > abName = " + abName + ", assetName = " + assetNames[j]);
                            result.Add(obj);
                        }
                        else
                        {
                            Debug.LogWarning(">> ResourceManager > Editor > LoadAsset error > abName = " + abName + ", assetName = " + assetNames[j]);
                        }
                    }
                    yield return null;
                }
                else
#endif
                {
                    if (abInfo.assetBundle != null)
                    {
                        AssetBundle ab = abInfo.assetBundle;
                        for (int j = 0; j < assetNames.Length; j++)
                        {
                            string assetName = assetNames[j];
                            AssetBundleRequest request = ab.LoadAssetAsync(assetName, assetLoadRequest.assetType);
                            yield return request;
                            if (request.asset != null)
                            {
                                Debug.Log(">> ResourceManager > OnStartAssetLoad > LoadAsset > abName = " + abName + ", assetName = " + assetNames[j]);
                                result.Add(request.asset);
                            }
                            else
                            {
                                Debug.LogWarning(">> ResourceManager > OnStartAssetLoad > LoadAsset Empty > abName = " + abName + ", assetName = " + assetName);
                            }
                        }
                    }
                }

                if (assetLoadRequest.callback != null)
                {
                    assetLoadRequest.callback(result.ToArray());
                    assetLoadRequest.callback = null;
                }
                if (assetLoadRequest.luaFunction != null)
                {
                    assetLoadRequest.luaFunction.Call((object)result.ToArray(), assetLoadRequest.luaTable);
                    assetLoadRequest.luaFunction.Dispose();
                    assetLoadRequest.luaFunction = null;
                    assetLoadRequest.luaTable = null;
                }
            }
            abInfo.assetRequests.Clear();
        }

        //================================================================

#if UNITY_EDITOR
        /// <summary>
        /// 编辑器下读取资源
        /// </summary>
        private UObject LoadAssetInEditor(string abName, string assetName, Type assetType)
        {
            string[] assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(abName, assetName);
            if (assetPaths.Length < 1)
            {
                Util.LogError(">> ResourceManager > There is no asset with name \"" + assetName + "\" in " + abName);
                return null;
            }
            else
            {
                for (int i = 0; i < assetPaths.Length; i++)
                {
                    UObject obj = AssetDatabase.LoadAssetAtPath(assetPaths[i], assetType);
                    if (obj != null)
                    {
                        return obj;
                    }
                }
                return null;
            }
        }
#endif


        /// <summary>
        /// 加载AB包，abName名称为依赖文件中使用的名称
        /// </summary>
        IEnumerator OnLoadAssetBundle(AssetBundleInfo abInfo)
        {
            abInfo.loadState = LoadState.Loading;
            string abName = abInfo.name;
            Debug.Log(">> ResourceManager > OnLoadAssetBundle > abName = " + abName + "  " + abInfo.referencedCount);

            string[] dependencies = this.GetDependenciesByName(abName);
            if (dependencies != null && dependencies.Length > 0)
            {
                for (int i = 0; i < dependencies.Length; i++)
                {
                    string depName = dependencies[i];
                    AssetBundleInfo assetBundleInfo = null;
                    if (!this.mAssetBundleInfoDict.TryGetValue(depName, out assetBundleInfo))
                    {
                        assetBundleInfo = new AssetBundleInfo(depName);
                        this.mAssetBundleInfoDict.Add(depName, assetBundleInfo);
                    }

                    if (assetBundleInfo.loadState == LoadState.None)
                    {
                        yield return StartCoroutine(this.OnLoadAssetBundle(assetBundleInfo));
                    }
                    else if (assetBundleInfo.loadState == LoadState.Loaded)
                    {
                        //加载完成的，不进行依赖的计数处理，直接处理该AB包的计数+1
                        assetBundleInfo.referencedCount++;
                    }
                }
            }

            string path = mResDirPath + abName;
            //#if UNITY_IPHONE || UNITY_ANDROID
            //            string url = mResDirUrlPath + abName;
            //            Debug.Log(">> ResourceManager >加载中 OnLoadAssetBundle > url = " + url + " " + abInfo.referencedCount);
            //            string md5 = Util.md5file(path);
            //            Hash128 hash128 = Hash128.Parse(md5);
            //            WWW download = WWW.LoadFromCacheOrDownload(url, hash128, 0);
            //            yield return download;
            //            //Debug.Log(">> ResourceManager >加载完成 OnLoadAssetBundle > " + abName + " > load finish." + abInfo.referencedCount);
            //            AssetBundle assetBundle = download.assetBundle;

            //#elif  UNITY_STANDALONE_WIN
            byte[] stream = File.ReadAllBytes(path);
            yield return null;
            //解密
            stream = SecretHelper.Decode(stream);
            AssetBundle assetBundle = AssetBundle.LoadFromMemory(stream);
            //#endif
            yield return null;

            if (assetBundle != null)
            {
                abInfo.assetBundle = assetBundle;
            }
            else
            {
                Debug.LogWarning(">> ResourceManager > OnLoadAssetBundle > Not load AssetBundle.");
            }
            abInfo.referencedCount++;
            abInfo.loadState = LoadState.Loaded;
        }

        //----------------------------------------------------------------

        /// <summary>
        /// 此函数交给外部卸载专用，自己调整是否需要彻底清除AB
        /// </summary>
        public void UnloadAssetBundle(string abName, bool isThorough = false)
        {
            abName = CheckRealAssetPath(abName);
            AssetBundleInfo abInfo = null;
            if (mAssetBundleInfoDict.TryGetValue(abName, out abInfo))
            {
                Debug.Log(">> ResourceManager >开始卸载 UnloadAssetBundle > abName = " + abName + " " + abInfo.referencedCount);
                abInfo.isThoroughUnload = isThorough;
                if (abInfo.loadState == LoadState.Loaded)
                {
                    this.InternalUnloadAssetBundle(abInfo);
                }
                else
                {
                    abInfo.active = false;
                }
            }
        }


        /// <summary>
        /// 内部卸载AssetBundle
        /// </summary>
        private void InternalUnloadAssetBundle(AssetBundleInfo abInfo)
        {
            abInfo.referencedCount--;

            if (abInfo.referencedCount < 1)
            {
                //如果该AB包确定要卸载，才处理依赖的计数
                string abName = abInfo.name;
                string[] dependencies = this.GetDependenciesByName(abName);
                AssetBundleInfo tempAssetBundleInfo = null;
                if (dependencies != null && dependencies.Length > 0)
                {
                    for (int i = 0; i < dependencies.Length; i++)
                    {
                        if (this.mAssetBundleInfoDict.TryGetValue(dependencies[i], out tempAssetBundleInfo))
                        {
                            tempAssetBundleInfo.isThoroughUnload = abInfo.isThoroughUnload;
                            Debug.Log("ResourceManager 有依赖，开始卸载依赖" + abInfo.name + " " + tempAssetBundleInfo.name + "  " + tempAssetBundleInfo.referencedCount);
                            //用了依赖的文件计数减一次
                            this.InternalUnloadAssetBundle(tempAssetBundleInfo);
                        }
                    }
                }

                this.mAssetBundleInfoDict.Remove(abName);
                this.RemoveLoadingAssetBundle(abName);
                abInfo.Clear();
                this.DeleteDependenciesByName(abName);

                Debug.Log(">> ResourceManager > InternalUnloadAssetBundle > " + abName + " has been unloaded successfully.");
            }
            else
            {
                Debug.Log(">> ResourceManager > InternalUnloadAssetBundle > " + abInfo.name + " has be depended on.");
            }
        }

        /// <summary>
        /// 移除加载列表中的
        /// </summary>
        private void RemoveLoadingAssetBundle(string abName)
        {
            for (int i = 0; i < this.mLoadingAssetBundles.Count; i++)
            {
                if (this.mLoadingAssetBundles[i].name == abName)
                {
                    Debug.Log(">> ResourceManager > RemoveLoadingAssetBundle > abName = " + abName);
                    this.mLoadingAssetBundles.RemoveAt(i);
                    break;
                }
            }
        }

        //================================================================

        /// <summary>
        /// 同步加载资源，需要预先加载AB包，如果是没有依赖的单独AB包则可以不使用预加载，使用时需要注意
        /// </summary>
        public UnityEngine.Object LoadAssetBySynch(Type type, string abName, string assetName)
        {
            if (string.IsNullOrEmpty(abName))
            {
                Debug.LogWarning("ResourceManager > LoadAssetBySynch > abName is NullOrEmpty.");
                return null;
            }
            if (string.IsNullOrEmpty(assetName))
            {
                Debug.LogWarning("ResourceManager > LoadAssetBySynch > assetName is NullOrEmpty.");
                return null;
            }

            abName = this.CheckRealAssetPath(abName);

#if UNITY_EDITOR
            bool isEditorAssets = EditorConst.editorAssetsType == EditorAssetsType.Editor;
            if (isEditorAssets)
            {
                UObject obj = LoadAssetInEditor(abName, assetName, type);
                return obj;
            }
#endif
            AssetBundleInfo assetBundleInfo = null;

            //没有则加载
            if (!this.mAssetBundleInfoDict.TryGetValue(abName, out assetBundleInfo))
            {
                this.LoadBundleBySynch(abName);
            }

            if (this.mAssetBundleInfoDict.TryGetValue(abName, out assetBundleInfo))
            {
                AssetBundle bundle = assetBundleInfo.assetBundle;
                if (bundle != null)
                {
                    return bundle.LoadAsset(assetName, type);
                }
                else
                {
                    Debug.LogWarning("ResourceManager > LoadAssetBySynch > no asset > assetName = " + assetName);
                }
            }
            else
            {
                Debug.LogWarning("ResourceManager > LoadAssetBySynch > not load ab > abName = " + abName);
            }
            return null;
        }

        /// <summary>
        /// 同步加载资源，如果有异步加载，则加载失败
        /// </summary>
        public AssetBundle LoadBundleBySynch(string abName)
        {
            if (string.IsNullOrEmpty(abName))
            {
                Debug.LogWarning("ResourceManager > LoadBundleBySynch > abName is NullOrEmpty.");
                return null;
            }
            abName = this.CheckRealAssetPath(abName);

            AssetBundleInfo assetBundleInfo = null;
            if (!this.mAssetBundleInfoDict.TryGetValue(abName, out assetBundleInfo))
            {
                assetBundleInfo = new AssetBundleInfo(abName);
                this.mAssetBundleInfoDict.Add(abName, assetBundleInfo);
            }

            if (assetBundleInfo.loadState == LoadState.None)
            {
                LoadAssetBundleInfoBySynch(assetBundleInfo);
                //加载完成才计数
                assetBundleInfo.referencedCount++;
            }
            else if (assetBundleInfo.loadState == LoadState.Loading)
            {
                Debug.LogWarning("ResourceManager > LoadBundleBySynch > is loading > abName = " + abName);
            }
            Debug.Log("ResourceManager > LoadBundleBySynch > is loaded > abName = " + abName);
            return assetBundleInfo.assetBundle;
        }

        /// <summary>
        /// 同步加载AssetBundleInfo
        /// </summary>
        private void LoadAssetBundleInfoBySynch(AssetBundleInfo abInfo)
        {
            //检查依赖项目
            this.CheckLoadBundleByDependencies(abInfo.name);

            string path = mResDirPath + abInfo.name;
            if (File.Exists(path))
            {
                byte[] stream = null;
                try
                {
                    stream = File.ReadAllBytes(path);
                    stream = SecretHelper.Decode(stream);
                    //关联数据的素材绑定
                    AssetBundle bundle = AssetBundle.LoadFromMemory(stream);
                    abInfo.assetBundle = bundle;
                }
                catch (Exception ex)
                {
                    Debug.LogException(ex);
                }
            }
            else
            {
                Debug.LogWarning(">> ResourceManager > LoadAssetBundleInfoBySynch > file not exidsts > path = " + path);
            }
            abInfo.loadState = LoadState.Loaded;
        }

        /// <summary>
        /// 检查依赖
        /// </summary>
        private void CheckLoadBundleByDependencies(string abName)
        {
            string[] dependencies = this.GetDependenciesByName(abName);
            if (dependencies != null)
            {
                for (int i = 0; i < dependencies.Length; i++)
                {
                    string depName = dependencies[i];
                    AssetBundleInfo assetBundleInfo = null;
                    if (!this.mAssetBundleInfoDict.TryGetValue(depName, out assetBundleInfo))
                    {
                        assetBundleInfo = new AssetBundleInfo(depName);
                        this.mAssetBundleInfoDict.Add(depName, assetBundleInfo);
                    }

                    //被依赖引用计数，被依赖就计数加一次
                    assetBundleInfo.referencedCount++;

                    if (assetBundleInfo.loadState == LoadState.None)
                    {
                        LoadAssetBundleInfoBySynch(assetBundleInfo);
                    }
                    else if (assetBundleInfo.loadState == LoadState.Loading)
                    {
                        Debug.LogWarning("ResourceManager > LoadBundleBySynch > is loading > depName = " + depName);
                    }
                }
            }
        }

    }

}

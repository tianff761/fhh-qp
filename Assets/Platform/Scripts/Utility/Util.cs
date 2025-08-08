using UnityEngine;
using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using LuaInterface;
using LuaFramework;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace LuaFramework
{
    public class Util
    {
        private static List<string> luaPaths = new List<string>();

        public static int Int(object o)
        {
            return Convert.ToInt32(o);
        }

        public static float Float(object o)
        {
            return (float)Math.Round(Convert.ToSingle(o), 2);
        }

        public static long Long(object o)
        {
            return Convert.ToInt64(o);
        }

        public static int Random(int min, int max)
        {
            return UnityEngine.Random.Range(min, max);
        }

        public static float Random(float min, float max)
        {
            return UnityEngine.Random.Range(min, max);
        }

        public static string Uid(string uid)
        {
            int position = uid.LastIndexOf('_');
            return uid.Remove(0, position + 1);
        }

        public static double GetTime()
        {
            TimeSpan ts = new TimeSpan(DateTime.UtcNow.Ticks - new DateTime(1970, 1, 1, 0, 0, 0).Ticks);
            return (long)ts.TotalMilliseconds;
        }

        public static string GetTimeData(double timestamp, string str)
        {
            DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1));
            // 当地时区
            DateTime dt = startTime.AddMilliseconds(timestamp);
            return dt.ToString(str);
        }

        /// <summary>
        /// 搜索子物体组件-GameObject版
        /// </summary>
        public static T Get<T>(GameObject go, string subnode) where T : Component
        {
            if (go != null)
            {
                Transform sub = go.transform.Find(subnode);
                if (sub != null) return sub.GetComponent<T>();
            }
            return null;
        }

        /// <summary>
        /// 搜索子物体组件-Transform版
        /// </summary>
        public static T Get<T>(Transform go, string subnode) where T : Component
        {
            if (go != null)
            {
                Transform sub = go.Find(subnode);
                if (sub != null) return sub.GetComponent<T>();
            }
            return null;
        }

        /// <summary>
        /// 搜索子物体组件-Component版
        /// </summary>
        public static T Get<T>(Component go, string subnode) where T : Component
        {
            return go.transform.Find(subnode).GetComponent<T>();
        }

        /// <summary>
        /// 添加组件
        /// </summary>
        public static T Add<T>(GameObject go) where T : Component
        {
            if (go != null)
            {
                T[] ts = go.GetComponents<T>();
                for (int i = 0; i < ts.Length; i++)
                {
                    if (ts[i] != null) GameObject.Destroy(ts[i]);
                }
                return go.gameObject.AddComponent<T>();
            }
            return null;
        }

        /// <summary>
        /// 添加组件
        /// </summary>
        public static T Add<T>(Transform go) where T : Component
        {
            return Add<T>(go.gameObject);
        }

        /// <summary>
        /// 查找子对象
        /// </summary>
        public static GameObject Child(GameObject go, string subnode)
        {
            return Child(go.transform, subnode);
        }

        /// <summary>
        /// 查找子对象
        /// </summary>
        public static GameObject Child(Transform go, string subnode)
        {
            Transform tran = go.Find(subnode);
            if (tran == null) return null;
            return tran.gameObject;
        }

        /// <summary>
        /// 取平级对象
        /// </summary>
        public static GameObject Peer(GameObject go, string subnode)
        {
            return Peer(go.transform, subnode);
        }

        /// <summary>
        /// 取平级对象
        /// </summary>
        public static GameObject Peer(Transform go, string subnode)
        {
            Transform tran = go.parent.Find(subnode);
            if (tran == null) return null;
            return tran.gameObject;
        }

        /// <summary>
        /// 计算字符串的MD5值
        /// </summary>
        public static string md5(string source)
        {
            MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider();
            byte[] data = System.Text.Encoding.UTF8.GetBytes(source);
            byte[] md5Data = md5.ComputeHash(data, 0, data.Length);
            md5.Clear();

            string destString = "";
            for (int i = 0; i < md5Data.Length; i++)
            {
                destString += System.Convert.ToString(md5Data[i], 16).PadLeft(2, '0');
            }
            destString = destString.PadLeft(32, '0');
            return destString;
        }

        /// <summary>
        /// 计算文件的MD5值
        /// </summary>
        public static string md5file(string file)
        {
            try
            {
                FileStream fs = new FileStream(file, FileMode.Open);
                System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
                byte[] retVal = md5.ComputeHash(fs);
                fs.Close();

                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < retVal.Length; i++)
                {
                    sb.Append(retVal[i].ToString("x2"));
                }
                return sb.ToString();
            }
            catch (Exception ex)
            {
                throw new Exception("md5file() fail, error:" + ex.Message);
            }
        }

        public static string GetMd5ByBytes(byte[] buffer)
        {
            try
            {
                System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
                byte[] retVal = md5.ComputeHash(buffer);
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < retVal.Length; i++)
                {
                    sb.Append(retVal[i].ToString("x2"));
                }
                return sb.ToString();
            }
            catch (Exception ex)
            {
                throw new Exception("GetMd5ByBytes() fail, error:" + ex.Message);
            }
        }

        /// <summary>
        /// 清除所有子节点
        /// </summary>
        public static void ClearChild(Transform go)
        {
            if (go == null) return;
            for (int i = go.childCount - 1; i >= 0; i--)
            {
                GameObject.Destroy(go.GetChild(i).gameObject);
            }
        }

        /// <summary>
        /// 清理内存
        /// </summary>
        public static void ClearMemory()
        {
            LuaManager mgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
            if (mgr != null) mgr.LuaGC();
            GC.Collect();
            Resources.UnloadUnusedAssets();
        }

        /// <summary>
        /// 单独GC
        /// </summary>
        public static void Collect()
        {
            GC.Collect();
        }

        /// <summary>
        /// 单独UnloadUnusedAssets
        /// </summary>
        public static AsyncOperation UnloadUnusedAssets()
        {
            return Resources.UnloadUnusedAssets();
        }

        /// <summary>
        /// 单独LuaGC
        /// </summary>
        public static void LuaGC()
        {
            LuaManager mgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
            if (mgr != null) mgr.LuaGC();
        }


        /// <summary>
        /// 获取项目路径，一般用于编辑器或PC端
        /// </summary>
        public static string GetProjectPath()
        {
            string result = Application.dataPath;
            result = result.Replace("/Assets", "").Replace("\\", "/");

            if (!result.EndsWith("/"))
            {
                result += "/";
            }
            return result;
        }


        /// <summary>
        /// 保存到文件
        /// </summary>
        public static void SaveToFile(string filePath, byte[] bytes)
        {
            if (bytes == null || bytes.Length < 1)
            {
                return;
            }

            try
            {
                File.WriteAllBytes(filePath, bytes);
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }

        /// <summary>
        /// 保存到文件
        /// </summary>
        public static void SaveToFile(string filePath, string text)
        {
            if (text == null)
            {
                return;
            }

            try
            {
                File.WriteAllText(filePath, text);
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }

        /// <summary>
        /// 获取文件夹下所有文件名
        /// </summary>
        /// <param name="path">文件夹路径</param>
        /// <param name="searchPattern">"*.*",获取的文件后缀</param>
        /// <param name="isAllDirectories">是否获取子文件夹下的</param>
        /// <returns></returns>
        public static string[] GetFilesByFolderPath(string path, string searchPattern = "*.*", bool isAllDirectories = true)
        {
            try
            {
                if (Directory.Exists(path))
                {
                    return Directory.GetFiles(path, searchPattern, isAllDirectories ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly);
                }
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
            return null;
        }

        /// <summary>
        /// 删除文件夹（强制删除非空文件夹）
        /// </summary>
        public static void DeleteFolder(string path)
        {
            try
            {
                if (Directory.Exists(path))
                {
                    DirectoryInfo info = new DirectoryInfo(path);
                    info.Delete(true);
                }
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }

        /// <summary>
        /// 删除文件
        /// </summary>
        public static void DeleteFile(string filepath)
        {
            try
            {
                if (File.Exists(filepath))
                {
                    File.Delete(filepath);
                }
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }


        /// <summary>
        /// 删除文件夹下所有文件
        /// </summary>
        public static void DeleteFilesOnFolder(string folderPath)
        {
            try
            {
                if (string.IsNullOrEmpty(folderPath))
                {
                    return;
                }

                if (Directory.Exists(folderPath))
                {
                    string[] filePaths = Directory.GetFiles(folderPath);
                    ///删除所有文件
                    for (int i = 0; i < filePaths.Length; i++)
                    {
                        File.Delete(filePaths[i]);
                    }
                }
                else
                {
                    Debug.LogWarning("要删除文件夹的不存在");
                }
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }

        /// <summary>
        /// 获取文件的文本内容
        /// </summary>
        public static string GetFileText(string filePath)
        {
            try
            {
                if (File.Exists(filePath))
                {
                    return File.ReadAllText(filePath);
                }
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
            return null;
        }

        /// <summary>
        /// 网络可用
        /// </summary>
        public static bool NetAvailable
        {
            get
            {
                return Application.internetReachability != NetworkReachability.NotReachable;
            }
        }

        /// <summary>
        /// 是否是无线
        /// </summary>
        public static bool IsWifi
        {
            get
            {
                return Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork;
            }
        }

        /// <summary>
        /// 资源路径
        /// </summary>
        public static string AssetsPath
        {
            get
            {
#if UNITY_EDITOR
                if (EditorConst.editorAssetsType == EditorAssetsType.Release)
                {
                    return Assets.RuntimeAssetsPath;
                }
                else
                {
                    return Assets.StreamingAssetsPath;
                }
#elif UNITY_ANDROID
                return Assets.RuntimeAssetsPath;
#elif UNITY_IPHONE
                return Assets.RuntimeAssetsPath;
#else
                //PC版本使用
                return Assets.StreamingAssetsPath;
#endif
            }
        }

        /// <summary>
        /// 资源Url路径
        /// </summary>
        public static string AssetsUrlPath
        {
            get
            {
#if UNITY_EDITOR
                if (EditorConst.editorAssetsType == EditorAssetsType.Release)
                {
                    return Assets.RuntimeAssetsUrlPath;
                }
                else
                {
                    return Assets.StreamingAssetsUrlPath;
                }
#elif UNITY_ANDROID
                return Assets.RuntimeAssetsUrlPath;
#elif UNITY_IPHONE
                return Assets.RuntimeAssetsUrlPath;
#else
                //PC版本使用
                return Assets.StreamingAssetsUrlPath;
#endif
            }
        }

        //================================================================

        /// <summary>
        /// 设置日志打印是否开启
        /// </summary>
        public static void SetLogEnabled(bool logEnabled)
        {
            Debug.unityLogger.logEnabled = logEnabled;
        }

        public static void Log(string str)
        {
            string logstr = DateTime.Now.ToString("[MM-dd HH:mm:ss.fff] ") + str;
            Debug.Log(logstr);
        }

        public static void LogWarning(string str)
        {
            string logstr = DateTime.Now.ToString("[MM-dd HH:mm:ss.fff] ") + str;
            Debug.LogWarning(logstr);
        }

        public static void LogError(string str)
        {
            string logstr = DateTime.Now.ToString("[MM-dd HH:mm:ss.fff] ") + str;
            Debug.LogError(logstr);
        }

        //================================================================

        /// <summary>
        /// 执行Lua方法
        /// </summary>
        public static object[] CallMethod(string module, string func, params object[] args)
        {
            LuaManager luaMgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
            if (luaMgr == null) return null;
            return luaMgr.CallFunction(module + "." + func, args);
        }

        /// <summary>
        /// 防止初学者不按步骤来操作
        /// </summary>
        /// <returns></returns>
        public static int CheckRuntimeFile()
        {
            if (!Application.isEditor) return 0;
            string sourceDir = AppConst.LuaFrameworkRoot + "/ToLua/Source/Generate/";
            if (!Directory.Exists(sourceDir))
            {
                return -2;
            }
            else
            {
                string[] files = Directory.GetFiles(sourceDir);
                if (files.Length == 0) return -2;
            }
            return 0;
        }

        /// <summary>
        /// 检查运行环境
        /// </summary>
        public static bool CheckEnvironment()
        {
#if UNITY_EDITOR
            int resultId = Util.CheckRuntimeFile();
            if (resultId == -1)
            {
                Debug.LogError("没有找到框架所需要的资源，单击Game菜单下Build xxx Resource生成！！");
                EditorApplication.isPlaying = false;
                return false;
            }
            else if (resultId == -2)
            {
                Debug.LogError("没有找到Wrap脚本缓存，单击Lua菜单下Gen Lua Wrap Files生成脚本！！");
                EditorApplication.isPlaying = false;
                return false;
            }

#endif
            return true;
        }

        //每个对象只能添加一个相同的lua组件
        public static LuaTable AddLuaComponent(GameObject go, string lua)
        {
            if (lua == "" || go == null)
            {
                Util.LogError("AddLuaComponent参数错误！");
                return null;
            }
            LuaComponent[] cmps = go.GetComponents<LuaComponent>();
            for (int i = 0; i < cmps.Length; i++)
            {
                if (cmps[i].luaComponentName.Equals(lua))
                {
                    GameObject.DestroyImmediate(cmps[i]);
                }
            }
            var cmp = go.AddComponent<LuaComponent>();
            var table = CallMethod(lua, "New");
            if (table == null)
            {
                Util.LogWarning("AddLuaComponent不存在：" + lua + ".New()");
                return null;
            }
            cmp.luaComponentName = lua;
            cmp.luaTable = (LuaTable)table[0];
            cmp.luaTable["transform"] = cmp.transform;
            cmp.luaTable["gameObject"] = cmp.gameObject;
            cmp.luaTable["luaComponent"] = cmp;
            cmp.luaTable["isValid"] = true;
            cmp.luaTable.Call<LuaTable>("Awake", cmp.luaTable);
            return cmp.luaTable;
        }

        public static LuaTable GetLuaComponent(GameObject go, string lua)
        {
            if (lua == "" || go == null)
            {
                Util.LogError("GetLuaComponent参数错误！");
                return null;
            }
            LuaComponent[] cmps = go.GetComponents<LuaComponent>();
            for (int i = 0; i < cmps.Length; i++)
            {
                if (cmps[i].luaComponentName == lua)
                {
                    return cmps[i].luaTable;
                }
            }
            return null;
        }

        /// <summary>
        /// 添加Lua文件的搜索AB包
        /// </summary>
        public static void AddSearchBundle(string path, string bundle)
        {
            if (string.IsNullOrEmpty(path) || string.IsNullOrEmpty(bundle))
            {
                Debug.LogWarning(">> Uitl > AddSearchBundle > NullOrEmpty.");
                return;
            }

            if (!path.EndsWith("/"))
            {
                path = path + "/";
            }

            LuaManager luaMgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
            luaMgr.AddBundle(path, bundle);
        }

        /// <summary>
        /// 移除Lua文件的搜索AB包
        /// </summary>
        public static void RemoveSearchBundle(string bundle)
        {
            LuaManager luaMgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
            luaMgr.RemoveBundle(bundle);
        }
        /// <summary>
        /// 替换名称中的敏感字
        /// </summary>
        /// <param name="nickName">名称</param>
        /// <param name="words">敏感词库</param>
        /// <param name="regexString">正则特殊字库</param>
        /// <param name="symbol">替换后的标点</param>
        /// <returns></returns>
        public static string FilterSentiveWords(string nickName, string[] words, string regexString, string symbol)
        {
            if (string.IsNullOrEmpty(nickName))
            {
                return "";
            }
            string pattern = regexString;
            string symbolStr = "";
            if (!string.IsNullOrEmpty(symbol))
            {
                symbolStr = symbol;
            }
            string newStr = Regex.Replace(nickName, pattern, symbolStr);
            for (int i = 0; i < words.Length; i++)
            {
                if (newStr.Contains(words[i]))
                {
                    int len = words[i].Length;
                    string markStr = "";
                    for (int j = 0; j < len; j++)
                    {
                        markStr += symbolStr;
                    }
                    newStr = newStr.Replace(words[i], markStr);
                }
            }

            return newStr;
        }

        //从Animator上获取AnimatorStateMachine 
        public static AnimatorStateMachine GetAnimatorStateMachine(Animator ani)
        {
            if (ani == null)
            {
                Debug.LogWarning(">> Uitl > AnimatorStateMachine > ani > NullOrEmpty.");
                return null;
            }
            return ani.GetBehaviour<AnimatorStateMachine>();
        }
    }
}
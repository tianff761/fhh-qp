using UnityEngine;
using System.Collections;
using System.IO;
using LuaInterface;

namespace LuaFramework
{
    /// <summary>
    /// 集成自LuaFileUtils，重写里面的ReadFile，
    /// </summary>
    public class LuaLoader : LuaFileUtils
    {
        private ResourceManager m_resMgr;

        ResourceManager resMgr
        {
            get
            {
                if (m_resMgr == null)
                    m_resMgr = AppFacade.Instance.GetManager<ResourceManager>(ManagerName.Resource);
                return m_resMgr;
            }
        }

        public LuaLoader()
        {
            instance = this;
        }

        /// <summary>
        /// 相对于res资源目录路径
        /// </summary>
        public void AddBundle(string dir, string name)
        {
            //Debug.Log(">> LuaLoader > AddBundle > name = " + name);
            //由于设计Lua文件只会在运行目录下读取，编辑器下开发的时候不会在StreamingAssets中读取
            if (!zipMap.ContainsKey(name))
            {
                string url = Util.AssetsPath + AppConst.ResPathName + "/" + dir + name + AppConst.AssetExtName;
                if (File.Exists(url))
                {
                    try
                    {
                        byte[] stream = File.ReadAllBytes(url);
                        stream = SecretHelper.Decode(stream);
                        AssetBundle bundle = AssetBundle.LoadFromMemory(stream);
                        if (bundle != null)
                        {
                            base.AddSearchBundle(name, bundle);
                        }
                    }
                    catch (System.Exception ex)
                    {
                        Debug.LogException(ex);
                    }
                }
                else
                {
                    Debug.LogWarning(">> LuaLoader > AddBundle > File not exists > url = " + url);
                }
            }
        }

        public void RemoveBundle(string name)
        {
            base.RemoveSearchBundle(name);
        }

        /// <summary>
        /// 当LuaVM加载Lua文件的时候，这里就会被调用，
        /// 用户可以自定义加载行为，只要返回byte[]即可。
        /// </summary>
        /// <param name="fileName"></param>
        /// <returns></returns>
        public override byte[] ReadFile(string fileName)
        {
            return base.ReadFile(fileName);
        }
    }
}
using UnityEngine;
using System.Collections;
using LuaInterface;
using System.IO;
using LitJson;
using System;

namespace LuaFramework
{
    public class LuaManager : Manager
    {
        private LuaState lua;
        private LuaLoader loader;
        private LuaLooper loop = null;


        void Awake()
        {
            loader = new LuaLoader();
            lua = new LuaState();
            this.OpenLibs();
            lua.LuaSetTop(0);

            LuaBinder.Bind(lua);
            DelegateFactory.Init();
            LuaCoroutine.Register(lua, this);
        }

        public void InitStart()
        {
            InitLuaPath();
            InitLuaBundle();
            this.lua.Start();    //启动LUAVM
            this.StartMain();
            this.StartLooper();
        }

        void StartLooper()
        {
            loop = gameObject.AddComponent<LuaLooper>();
            loop.luaState = lua;
        }

        //cjson 比较特殊，只new了一个table，没有注册库，这里注册一下
        protected void OpenCJson()
        {
            lua.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
            lua.OpenLibs(LuaDLL.luaopen_cjson);
            lua.LuaSetField(-2, "cjson");

            lua.OpenLibs(LuaDLL.luaopen_cjson_safe);
            lua.LuaSetField(-2, "cjson.safe");
        }

        void StartMain()
        {
            lua.DoFile("Main.lua");

            LuaFunction main = lua.GetFunction("Main");
            main.Call();
            main.Dispose();
            main = null;
        }

        /// <summary>
        /// 初始化加载第三方库
        /// </summary>
        void OpenLibs()
        {
            lua.OpenLibs(LuaDLL.luaopen_pb);
            // lua.OpenLibs(LuaDLL.luaopen_sproto_core);
            // lua.OpenLibs(LuaDLL.luaopen_protobuf_c);
            lua.OpenLibs(LuaDLL.luaopen_lpeg);
            lua.OpenLibs(LuaDLL.luaopen_bit);
            lua.OpenLibs(LuaDLL.luaopen_socket_core);

            this.OpenCJson();


            //Lua断点测试代码
            lua.BeginPreLoad();
            lua.RegFunction("socket.core", LuaOpen_Socket_Core);
            lua.RegFunction("mime.core", LuaOpen_Mime_Core);
            lua.EndPreLoad();
        }

        /// <summary>
        /// 初始化Lua代码加载路径
        /// </summary>
        void InitLuaPath()
        {
#if UNITY_EDITOR
            if(EditorConst.editorAssetsType == EditorAssetsType.Editor || EditorConst.editorAssetsType == EditorAssetsType.StreamingAssets)
            {
                string dataPath = Application.dataPath;
                lua.AddSearchPath(AppConst.LuaFrameworkRoot + "/ToLua/Lua");
                lua.AddSearchPath(dataPath + "/Platform/LuaCore");
                lua.AddSearchPath(dataPath + "/Platform/Project/Game");
                loader.beZip = false;
            }
            else
#endif
            {
                loader.beZip = AppConst.LuaBundleMode;
                lua.AddSearchPath(Util.AssetsPath + AppConst.ResPathName + "/lua");
            }
        }

        /// <summary>
        /// 初始化LuaBundle
        /// </summary>
        void InitLuaBundle()
        {
            AddBundle("base/", LuaConst.LuaCoreAssetBundleName);
        }


        //================================================================

        /// <summary>
        /// 添加Lua文件的搜索路径
        /// </summary>
        public void AddSearchPath(string path)
        {
            lua.AddSearchPath(path);
        }

        /// <summary>
        /// 执行Lua文件
        /// </summary>
        public void DoFile(string filename)
        {
            lua.DoFile(filename);
        }

        /// <summary>
        /// 添加Lua脚本的AB资源包，不用带文件后缀；文件路径是相对于res目录，dir格式为文件夹名称+斜杠，例如“base/”
        /// </summary>
        /// <param name="name"></param>
        public void AddBundle(string dir, string name)
        {
            if (loader.beZip)
            {
                loader.AddBundle(dir, name);
            }
        }

        /// <summary>
        /// 移除Lua脚本的AB资源包，不用带文件后缀
        /// </summary>
        /// <param name="name"></param>
        public void RemoveBundle(string name)
        {
            if (loader.beZip)
            {
                loader.RemoveBundle(name);
            }
        }

        //================================================================

        // Update is called once per frame
        public object[] CallFunction(string funcName, params object[] args)
        {
            LuaFunction func = lua.GetFunction(funcName);
            if (func != null)
            {
                return func.LazyCall(args);
            }
            return null;
        }

        public void LuaGC()
        {
            lua.LuaGC(LuaGCOptions.LUA_GCCOLLECT);
        }

        public void Close()
        {
            if (loop != null)
            {
                loop.Destroy();
                loop = null;
            }

            if (lua != null)
            {
                lua.Dispose();
                lua = null;
            }

            loader = null;
        }

        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int LuaOpen_Socket_Core(IntPtr L)
        {
            return LuaDLL.luaopen_socket_core(L);
        }

        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int LuaOpen_Mime_Core(IntPtr L)
        {
            return LuaDLL.luaopen_mime_core(L);
        }
    }
}
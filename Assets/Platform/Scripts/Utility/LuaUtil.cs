using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaFramework;

public class LuaUtil
{
    /// <summary>
    /// 执行Lua方法
    /// </summary>
    public static object[] CallMethod(string module, string func, params object[] args)
    {
        LuaManager luaMgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
        if(luaMgr == null) return null;
        return luaMgr.CallFunction(module + "." + func, args);
    }

}

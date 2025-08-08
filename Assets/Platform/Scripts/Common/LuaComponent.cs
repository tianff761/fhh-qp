using LuaInterface;
using UnityEngine;

public class LuaComponent : MonoBehaviour
{
    public string luaComponentName = "";
    public LuaTable luaTable = null;

    void Awake()
    {

    }

    private void Start()
    {
        if(luaTable != null)
        {
            luaTable.Call<LuaTable>("Start", luaTable);
        }
    }

    private void OnEnable()
    {
        if(luaTable != null)
        {
            luaTable.Call<LuaTable>("OnEnable", luaTable);
        }
    }

    private void OnDisable()
    {
        if(luaTable != null)
        {
            luaTable.Call<LuaTable>("OnDisable", luaTable);
        }
    }

    private void OnDestroy()
    {
        if(luaTable != null)
        {
            luaTable["gameObject"] = gameObject;
            luaTable.Call<LuaTable>("OnDestroy", luaTable);
            luaTable.Dispose();
            luaTable = null;
        }
    }
}

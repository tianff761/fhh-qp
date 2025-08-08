using LuaInterface;

/// <summary>
/// 网络图片下载的Lua数据
/// </summary>
public class NetImageLoadLuaData
{
    /// <summary>
    /// LUA回调方法
    /// </summary>
    private LuaFunction mLuaFunction = null;
    /// <summary>
    /// LUA回调参数
    /// </summary>
    private LuaTable mLuaTable = null;


    public NetImageLoadLuaData(LuaFunction luaFunction, LuaTable luaTable)
    {
        this.mLuaFunction = luaFunction;
        this.mLuaTable = luaTable;
    }

    public void Clear()
    {
        this.mLuaFunction = null;
        this.mLuaTable = null;
    }


    public LuaFunction luaFunction
    {
        get { return this.mLuaFunction; }
    }

    public LuaTable luaTable
    {
        get { return this.mLuaTable; }
        set { this.mLuaTable = value; }
    }
}
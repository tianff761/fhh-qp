using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TUtility
{
    //工具类方便解析json数据


    /**
     * 取值字符串
     */
    public static string TryGetValueStr(Hashtable ht, string keyName, string defValue)
    {
        try
        {
            if (ht.ContainsKey(keyName))
            {
                return ht[keyName].ToString();
            }
            return defValue;
        }
        catch (System.Exception ex)
        {
            ULogSys(ex.Message + "====" + keyName);
            return defValue;
        }

    }

    /**
     * 取值List
     */
    public static ArrayList TryGetValueArr(Hashtable ht, string keyName)
    {
        try
        {
            if (ht.ContainsKey(keyName))
            {
                return (ArrayList)ht[keyName];
            }
        }
        catch (System.Exception ex)
        {
            ULogSys(ex.Message + "====" + keyName);
        }
        return null;

    }

    /**
     * 取值List
     */
    public static ArrayList TryGetValueArr(Hashtable ht, string keyName, ArrayList defValue)
    {
        try
        {
            if (ht.ContainsKey(keyName))
            {
                return (ArrayList)ht[keyName];
            }
            return defValue;
        }
        catch (System.Exception ex)
        {
            ULogSys(ex.Message + "====" + keyName);
            return defValue;
        }

    }

    /**
     * 取值int
     */
    public static int TryGetValuei(Hashtable ht, string keyName, int defValue)
    {
        try
        {
            if (ht.ContainsKey(keyName))
            {
                return int.Parse(ht[keyName].ToString());
            }
            return defValue;

        }
        catch (System.Exception ex)
        {
            ULogSys(ex.Message + "====" + keyName);
            return defValue;
        }

    }

    /**
     * 取值long
     */
    public static long TryGetValueLong(Hashtable ht, string keyName, long defValue)
    {
        try
        {
            if (ht.ContainsKey(keyName))
            {
                return long.Parse(ht[keyName].ToString());
            }
            return defValue;

        }
        catch (System.Exception ex)
        {
            ULogSys(ex.Message + "====" + keyName);
            return defValue;
        }

    }

    /**
     * 取值float
     */
    public static float TryGetValuef(Hashtable ht, string keyName, float defValue)
    {
        try
        {
            if (ht.ContainsKey(keyName))
            {
                return float.Parse(ht[keyName].ToString());
            }
            return defValue;
        }
        catch (System.Exception ex)
        {
            ULogSys(ex.Message + "====" + keyName);
            return defValue;
        }

    }


    //编辑器模式下看log
    public static void ULogSys(string str)
    {
        if (Application.platform == RuntimePlatform.WindowsEditor)
        {
            Debug.Log(str);
        }
    }

}

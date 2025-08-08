using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LitJson;

public class JsonUtil
{
    public static string GetString(JsonData jsonData, string name)
    {
        JsonData temp = jsonData[name];
        if (temp != null)
        {
            return temp.ToString();
        }
        return null;
    }

    public static string GetString(JsonData jsonData, string name, string defaultValue)
    {
        JsonData temp = jsonData[name];
        if (temp != null)
        {
            return temp.ToString();
        }
        return defaultValue;
    }

    public static int GetInt(JsonData jsonData, string name)
    {
        JsonData temp = jsonData[name];
        if (temp != null)
        {
            return (int)temp;
        }
        return 0;
    }

    public static int GetInt(JsonData jsonData, string name, int defaultValue)
    {
        JsonData temp = jsonData[name];
        if (temp != null)
        {
            return (int)temp;
        }
        return defaultValue;
    }

    public static bool GetBool(JsonData jsonData, string name)
    {
        JsonData temp = jsonData[name];
        if (temp != null)
        {
            return (bool)temp;
        }
        return false;
    }

    public static bool GetBool(JsonData jsonData, string name, bool defalutValue)
    {
        JsonData temp = jsonData[name];
        if (temp != null)
        {
            return (bool)temp;
        }
        return defalutValue;
    }

}

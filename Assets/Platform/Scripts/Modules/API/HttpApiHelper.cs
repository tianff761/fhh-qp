using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Text;
using LuaFramework;
using LuaInterface;

public class HttpApiHelper
{

    private static Dictionary<string, string> mHeader = null;
    public static Dictionary<string, string> Header
    {
        get
        {
            if(mHeader == null)
            {
                mHeader = new Dictionary<string, string>();
                mHeader.Add("Content-Type", "text/html; charset=utf-8");
                mHeader.Add("Accept", "*/*");
            }
            return mHeader;
        }
    }

    /// <summary>
    /// 回调，需要提前设置
    /// </summary>
    public static LuaFunction LuaCallback = null;
    /// <summary>
    /// Http请求超时时间，单位秒，0表示不处理超时时间
    /// </summary>
    public static float HttpTimeout = 0;

    /// <summary>
    /// Http请求
    /// </summary>
    public static void Request(int cmd, string jsonString)
    {
        Request(AppConst.HttpServerUrl, cmd, jsonString);
    }

    /// <summary>
    /// Http请求，自带服务器URL
    /// </summary>
    public static void Request(string httpServerUrl, int cmd, string jsonString)
    {
        if(string.IsNullOrEmpty(jsonString))
        {
            Debug.LogWarning(">> HttpApiManager > Request > jsonString IsNullOrEmpty.");
            return;
        }

        byte[] postData = Encoding.UTF8.GetBytes(jsonString);

        HttpApiRequest httpRequest = new HttpApiRequest(httpServerUrl, postData, Header);
        if(HttpTimeout > 0)
        {
            httpRequest.SetTimeout(HttpTimeout);
        }
        httpRequest.cmd = cmd;
        httpRequest.AddListener(OnHttpRequest);
        httpRequest.Connect();
    }

    private static void OnHttpRequest(HttpApiRequest httpRequest, ResponseData responseData)
    {
        httpRequest.RemoveListener(OnHttpRequest);
        if(responseData.code == ResponseCode.SUCCESS)
        {
            Callback(httpRequest.cmd, responseData.code, responseData.text);
        }
        else if(responseData.code == ResponseCode.TIMEOUT)
        {
            Callback(httpRequest.cmd, responseData.code, "");
        }
        else
        {
            Callback(httpRequest.cmd, responseData.code, responseData.error);
        }
    }

    private static void Callback(int cmd, int code, string data)
    {
        if(LuaCallback != null)
        {
            LuaCallback.Call(cmd, code, data);
        }
    }

}

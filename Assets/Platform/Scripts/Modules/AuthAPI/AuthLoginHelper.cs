using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LitJson;
using System;

public class AuthLoginHelper
{
    /// <summary>
    /// 保存上次的code，用于处理连续多次的调用
    /// </summary>
    private static string mLastCode = "";


    public static void AuthLogin(string data)
    {
        try
        {
            JsonData jsonData = JsonMapper.ToObject(data);
            int code = int.Parse(jsonData["code"].ToString());
            if (code != 0)//错误就只向Lua中发送
            {
                SendAuthLoginData(data);
                return;
            }

            int platformType = int.Parse(jsonData["platformType"].ToString());
            string appId = jsonData["appId"].ToString();
            string appSecret = jsonData["appSecret"].ToString();
            string appCode = jsonData["appCode"].ToString();

            Debug.LogWarning(appCode);

            if (appCode == mLastCode)//连续一样的CODE不处理
            {
                return;
            }
            mLastCode = appCode;
            SendAuthLoginData(data);

            ApiHelper apiHelper = null;
            if (platformType == PlatformType.WECHAT)
            {
                apiHelper = new WeChatApiHelper();
            }
            else if (platformType == PlatformType.XIANLIAO)
            {
                apiHelper = new XianLiaoApiHelper();
            }
            apiHelper.AddListener(OnApiHelperCompleted);
            apiHelper.Request(appId, appSecret, appCode);
        }
        catch (Exception ex)
        {
            Debug.LogError(ex.ToString());
        }
    }

    public static void OnApiHelperCompleted(ApiHelper apiHelper, string data)
    {
        apiHelper.RemoveListener(OnApiHelperCompleted);
        LuaUtil.CallMethod(PlatformManager.LuaScriptName, "LoginCallback", data);//回调LUA中
    }

    /// <summary>
    /// 发送授权到Lua中
    /// </summary>
    /// <param name="data"></param>
    private static void SendAuthLoginData(string data)
    {
        try
        {
            JsonData jsonData = JsonMapper.ToObject(data);
            jsonData["appId"] = "";
            jsonData["appSecret"] = "";
            jsonData["appCode"] = "";//回调Lua的清除

            LuaUtil.CallMethod(PlatformManager.LuaScriptName, "AuthCallback", jsonData.ToJson());//回调Lua中
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
        }
    }

}

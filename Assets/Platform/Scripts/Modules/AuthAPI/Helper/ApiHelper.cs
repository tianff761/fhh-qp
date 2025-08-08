using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LitJson;

public class ApiHelper : Listener<ApiHelper, string>
{
    protected int mPlatformType = PlatformType.NONE;

    public virtual void Request(string appId, string appSecret, string code)
    {

    }

    protected virtual void SendData(AuthLoginData data)
    {
        data.platformType = mPlatformType;
        string json = JsonMapper.ToJson(data);
        Callback(this, json);
    }

}

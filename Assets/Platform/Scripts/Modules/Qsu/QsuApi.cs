using System;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Text;
using UnityEngine;


public class QsuApi : TSingleton<QsuApi>
{
    private QsuApi() { }

    //#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
    [DllImport("WinSdk")]
    private static extern int sdk_Initialize(string qsuCard);

    [DllImport("WinSdk")]
    private static extern int sdk_CreateSisle(string host, int port);
    //#endif


    public void qsuInit(string qsuCard)
    {
        try
        {
#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
            sdk_Initialize(qsuCard);
#endif
        }
        catch (Exception)
        {
            throw;
        }
    }


    public void getQsuSecurityPort(string host, int port)
    {
        try
        {
#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
            //Debug.Log("请求超级盾>:" + host + " port:" + port);
            int mPost = sdk_CreateSisle(host, port);
            //Debug.Log("请求超级盾返回: port:" + mPost);
            string content = "1|127.0.0.1|" + mPost + "|6|2";
            //PlatformManager.Instance.GetShieldPortCallback(content);
#endif
        }
        catch (Exception)
        {
            string content = -1 + "|127.0.0.1|" + port + "|6|2";
            //PlatformManager.Instance.GetShieldPortCallback(content);
            throw;
        }
    }
}
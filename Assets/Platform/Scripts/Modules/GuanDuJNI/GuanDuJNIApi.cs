using System;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Text;
using UnityEngine;


public class GuanDuJNIApi : TSingleton<GuanDuJNIApi>
{
    private GuanDuJNIApi() { }

#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
    [DllImport("libguandu")]
    private static extern bool GD_Init();

    [DllImport("libguandu")]
    private static extern int GD_API_GetConnectIPandPort(StringBuilder ServerIPAddr, out int ServerPort, string host, int port, int protocol);
#endif


    public void GuanDuJNIInit()
    {
        try
        {
#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
            if (GD_Init())
            {
                Debug.Log("windows guanDuJni 初始化成功");
            }
            else
            {
                Debug.Log("windows guanDuJni 初始化失败");
            }
#endif

        }
        catch (Exception)
        {
            throw;
        }
    }


    public void GetSecurityServerIPAndPort(string host, int port, int protocol)
    {
        try
        {
#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
            StringBuilder ServerIPAddr = new StringBuilder(128, 128);
            int ServerPort = 0;
            int code = GD_API_GetConnectIPandPort(ServerIPAddr, out ServerPort, host, port, protocol);

            string mIp = ServerIPAddr.ToString();
            int mPort = ServerPort;

            string content = code + "|" + mIp + "|" + mPort + "|" + protocol + "|1";
            //PlatformManager.Instance.GetShieldPortCallback(content);
#else
            string content = -1 + "|" + host + "|" + port + "|" + protocol + "|1";
            //PlatformManager.Instance.GetShieldPortCallback(content);
#endif
        }
        catch (Exception)
        {
            string content = -1 + "|" + host + "|" + port + "|" + protocol + "|1";
            //ssPlatformManager.Instance.GetShieldPortCallback(content);
            throw;
        }
    }
}

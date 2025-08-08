using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.InteropServices;

public class YunDunSecurityConnection {
    public string ip;
    public int port;
}

public class YunDunManagerr : TSingleton<YunDunManagerr>
{
	private YunDunManagerr() { }

#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
	[DllImport("appvest")]
	private static extern int init(string accesskey, string uuid);

	[DllImport("appvest")]
	private static extern int getServerIPAndPort(YunDunSecurityConnection conn, string host, int port);
#endif


    public void InitYunDun(string accesskey, string uuid) 
	{
//#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
//        int code = init(accesskey, uuid);
//        PlatformManager.Instance.InitYunDunCallback("" + code);
//#endif
    }

    public void GetYunDunIpAndPort(string host, int port) 
	{
//        try
//        {
//#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
//            //YunDunSecurityConnection securityConnection = new YunDunSecurityConnection();
//            //int code = getServerIPAndPort(securityConnection, host, port);
//            //string content = "{0}|{1}|{2}|6|2";
//            //if (code == 0)
//            //{
//            //    content = string.Format("{0}|{1}|{2}|6|3", 1, securityConnection.ip, securityConnection.port);
//            //}
//            //else 
//            //{
//            //    content = string.Format("{0}|{1}|{2}|6|3", -1, "127.0.0.1", port);
//            //}
//            //PlatformManager.Instance.GetShieldPortCallback(content);
//#endif
//        }
//        catch (Exception)
//        {
//            //string content = -1 + "|127.0.0.1|" + port + "|6|3";
//            //PlatformManager.Instance.GetShieldPortCallback(content);
//            throw;
        //}
    }

}

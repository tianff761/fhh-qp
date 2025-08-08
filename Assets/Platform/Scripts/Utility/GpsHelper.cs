using System;
using System.Collections;
using UnityEngine;

public class GpsHelper
{

    /// <summary>
    /// 位置信息是否开启
    /// </summary>
    public static bool LocationEnabled = false;

    /// <summary>
    /// 是否在检测中
    /// </summary>
    public static bool IsChecking = false;
    /// <summary>
    /// 上一次检测的时间
    /// </summary>
    public static float LastCheckTime = 0;
    /// <summary>
    /// 纬度
    /// </summary>
    public static float Latitude = 0;
    /// <summary>
    /// 经度
    /// </summary>
    public static float Longitude = 0;

    /// <summary>
    /// 检测和获取
    /// </summary>
    public static void Check(Action<float, float> callback)
    {
//        Debug.Log("GpsHelper Check");
        if(!IsChecking || Time.realtimeSinceStartup - LastCheckTime > 10)
        {
            IsChecking = true;
            LastCheckTime = Time.realtimeSinceStartup;
            CoroutineManager.Instance.StartCoroutine(StartCheckGps(callback));
        }
    }

    /// <summary>
    /// 检测完成
    /// </summary>
    private static void CheckGpsCompleted(Action<float, float> callback)
    {
        IsChecking = false;
        if(callback != null)
        {
            callback.Invoke(Latitude, Longitude);
        }
    }

    static IEnumerator StartCheckGps(Action<float, float> callback)
    {
        yield return null;

        Latitude = 0;
        Longitude = 0;

        LocationEnabled = Input.location.isEnabledByUser;

        if(!LocationEnabled)
        {
            Debug.LogWarning(">> GpsHelper > LocationEnabled = false.");
            CheckGpsCompleted(callback);
            yield break;
        }

        Input.location.Start();

        int maxWait = 60;
        WaitForSeconds waitForSeconds = new WaitForSeconds(1);
        while(Input.location.status == LocationServiceStatus.Initializing && maxWait > 0)
        {
            yield return waitForSeconds;
            maxWait--;
        }

        if(maxWait < 1)
        {
            Debug.LogWarning(">> GpsHelper > Get > Timeout.");
            Input.location.Stop();
            CheckGpsCompleted(callback);
            yield break;
        }

        if(Input.location.status == LocationServiceStatus.Failed)
        {
            Debug.LogWarning(">> GpsHelper > Get > Failed.");
            Input.location.Stop();
            CheckGpsCompleted(callback);
            yield break;
        }
        else
        {
            Latitude = Input.location.lastData.latitude;
            Longitude = Input.location.lastData.longitude;
            Debug.LogWarning(">> GpsHelper > Get > Success.");
        }
        Input.location.Stop();
        CheckGpsCompleted(callback);
    }
}

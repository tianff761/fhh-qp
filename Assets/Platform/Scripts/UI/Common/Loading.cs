using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Loading
{
    /// <summary>
    /// 快速的进度条
    /// </summary>
    public const float SPEED_FAST = 1.2f;
    /// <summary>
    /// 慢速的进度条
    /// </summary>
    public const float SPEED_SLOW = 0.1f;
    /// <summary>
    /// 正常的进度条
    /// </summary>
    public const float SPEED_NORMAL = 0.4f;
    /// <summary>
    /// 更新资源的进度条
    /// </summary>
    public const float SPEED_UPGRADE = 0.2f;
    /// <summary>
    /// 非常慢速的进度条
    /// </summary>
    public const float SPEED_SLOWEST = 0.01f;


    private static LoadingPanel mLoadingPanel = null;

    /// <summary>
    /// 开始显示Loading面板，一个事务只需要调用一次
    /// </summary>
    public static void Begin(string tipsMsg, Action onFinished, bool isShowPercent = true, float speed = 0)
    {
        InitUpdatePanel();
        if(mLoadingPanel != null)
        {
            mLoadingPanel.Begin(tipsMsg, onFinished, isShowPercent, speed);
        }
    }

    public static void SetProgress(float progress)
    {
        if(mLoadingPanel != null)
        {
            mLoadingPanel.SetProgress(progress);
        }
    }

    public static void Stop()
    {
        if(mLoadingPanel != null)
        {
            mLoadingPanel.Stop();
        }
    }

    public static void SetSpeed(float speed)
    {
        if(mLoadingPanel != null)
        {
            mLoadingPanel.SetSpeed(speed);
        }
    }

    public static void SetTips(string tipsMsg)
    {
        if(mLoadingPanel != null)
        {
            mLoadingPanel.SetTips(tipsMsg);
        }
    }

    public static void SetFinishedCallback(Action onFinished)
    {
        if(mLoadingPanel != null)
        {
            mLoadingPanel.SetFinishedCallback(onFinished);
        }
    }

    public static void Hidden()
    {
        if(mLoadingPanel != null)
        {
            GameObject.Destroy(mLoadingPanel.gameObject);
            mLoadingPanel = null;
        }
    }

    /// <summary>
    /// 初始更新面板
    /// </summary>
    private static void InitUpdatePanel()
    {
        if(mLoadingPanel != null) { return; }

        GameObject go = UIManager.Instance.OpenInternalPanel("LoadingPanel", 6);
        if(go != null)
        {
            mLoadingPanel = go.GetComponent<LoadingPanel>();
        }
    }

    //================================================================

}

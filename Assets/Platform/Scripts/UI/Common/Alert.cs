using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum AlertType
{
    /// <summary>
    /// Sure按钮和Cancel按钮
    /// </summary>
    Prompt = 0,
    /// <summary>
    /// 仅存在OK按钮
    /// </summary>
    Ok,
}

public enum AlertLevel
{
    /// <summary>
    /// 信息提示等级，默认为最低级，可以被高级覆盖
    /// </summary>
    Normal = 0,
    Alert,
    Error,
    System,
}

public class Alert
{
    private static AlertPanel mAlertPanel = null;

    /// <summary>
    /// 检测面板
    /// </summary>
    private static void CheckPanel()
    {
        if(mAlertPanel != null) { return; }

        GameObject go = UIManager.Instance.OpenInternalPanel("AlertPanel", 9);
        if(go != null)
        {
            mAlertPanel = go.GetComponent<AlertPanel>();
        }
    }

    /// <summary>
    /// 是否激活显示
    /// </summary>
    public static bool IsActive()
    {
        if(mAlertPanel == null) { return false; }


        return mAlertPanel.gameObject.activeSelf;
    }

    //================================================================

    /// <summary>
    /// 单OK按钮，如果想用默认文本，请传递空字符串""即可
    /// </summary>
    public static void Show(string msg, Action onOkCallback = null)
    {
        Show(msg, null, onOkCallback, AlertLevel.Normal);
    }

    /// <summary>
    /// 单OK按钮
    /// </summary>
    public static void Show(string msg, string okBtnTxt, Action onOkCallback = null, AlertLevel level = AlertLevel.Normal)
    {
        Show(msg, AlertType.Ok, okBtnTxt, onOkCallback, "", null, level);
    }

    /// <summary>
    /// 双按钮
    /// </summary>
    public static void Show(string msg, Action onOkCallback, Action onCancelCallback)
    {
        Show(msg, AlertType.Prompt, "", onOkCallback, "", onCancelCallback, AlertLevel.Normal);
    }

    public static void Show(string msg, AlertType type, string okBtnTxt, Action onOkCallback, string cancelBtnTxt, Action onCancelCallback, AlertLevel level = AlertLevel.Normal)
    {
        CheckPanel();
        if(mAlertPanel != null)
        {
            mAlertPanel.Open(msg, type, okBtnTxt, onOkCallback, cancelBtnTxt, onCancelCallback, level);
        }
    }

    public static void Hide()
    {
        if(mAlertPanel != null)
        {
            mAlertPanel.Close();
        }
    }
}

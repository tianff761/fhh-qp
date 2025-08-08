using UnityEngine;
using System;
using UnityEngine.EventSystems;

/// <summary>
/// UI click listener.
/// </summary>
public class UIClickListener : MonoBehaviour, IPointerClickHandler
{

    static public UIClickListener Get(GameObject go)
    {
        UIClickListener listener = go.GetComponent<UIClickListener>();
        if(listener == null) listener = go.AddComponent<UIClickListener>();
        return listener;
    }

    public Action<UIClickListener> onClick;
    /// <summary>
    /// 点击间隔时间，控制连续点击
    /// </summary>
    public float clickInterval = 0;
    /// <summary>
    /// 时间记录
    /// </summary>
    private float mTime = 0;

    public void OnPointerClick(PointerEventData eventData)
    {
        if(onClick != null)
        {
            if(clickInterval > 0)
            {
                if(mTime > Time.time)
                {
                    return;
                }
                mTime = Time.time + clickInterval;
            }
            onClick.Invoke(this);
        }
    }

    public void Reset()
    {
        mTime = 0;
    }
}

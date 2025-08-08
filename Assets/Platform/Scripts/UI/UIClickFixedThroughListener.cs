using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using System;
using System.Collections;
using System.Collections.Generic;

public class UIClickFixedThroughListener : MonoBehaviour, IPointerClickHandler
{
    static public UIClickFixedThroughListener Get(GameObject go)
    {
        UIClickFixedThroughListener listener = go.GetComponent<UIClickFixedThroughListener>();
        if(listener == null) listener = go.AddComponent<UIClickFixedThroughListener>();
        return listener;
    }

    public Action<UIClickFixedThroughListener, PointerEventData> onClick;

    /// <summary>
    /// 穿透的层级索引，只有该层级才响应事件
    /// </summary>
    public int passIndex = 1;
    /// <summary>
    /// 点击间隔时间，控制连续点击
    /// </summary>
    public float clickInterval = 0;
    /// <summary>
    /// 时间记录
    /// </summary>
    private float mTime = 0;
    /// <summary>
    /// 射线列表
    /// </summary>
    private List<RaycastResult> mRaycastResults = new List<RaycastResult>();

    //监听点击
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
            onClick.Invoke(this, eventData);
        }
        //处理事件穿透
        mRaycastResults.Clear();
        EventSystem.current.RaycastAll(eventData, mRaycastResults);
        ThroughEvent(eventData, ExecuteEvents.submitHandler);
        ThroughEvent(eventData, ExecuteEvents.pointerClickHandler);
    }

    public void Reset()
    {
        mTime = 0;
    }

    //把事件透下去
    private void ThroughEvent<T>(PointerEventData data, ExecuteEvents.EventFunction<T> function)
        where T : IEventSystemHandler
    {
        if(passIndex < mRaycastResults.Count && mRaycastResults[passIndex].gameObject != null)
        {
            ExecuteEvents.Execute(mRaycastResults[passIndex].gameObject, data, function);
        }
    }

}
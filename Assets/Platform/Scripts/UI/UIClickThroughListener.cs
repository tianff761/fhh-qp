using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using System;
using System.Collections;
using System.Collections.Generic;

public class UIClickThroughListener : MonoBehaviour, IPointerClickHandler
{
    static public UIClickThroughListener Get(GameObject go)
    {
        UIClickThroughListener listener = go.GetComponent<UIClickThroughListener>();
        if(listener == null) listener = go.AddComponent<UIClickThroughListener>();
        return listener;
    }

    /// <summary>
    /// 点击事件
    /// </summary>
    public Action<UIClickThroughListener, PointerEventData> onClick;
    /// <summary>
    /// 穿透的层级数
    /// </summary>
    public int passCount = 1;
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
    public void ThroughEvent<T>(PointerEventData data, ExecuteEvents.EventFunction<T> function)
        where T : IEventSystemHandler
    {
        GameObject current = data.pointerCurrentRaycast.gameObject;
        int count = 0;
        for(int i = 0; i < mRaycastResults.Count; i++)
        {
            if(current != mRaycastResults[i].gameObject)
            {
                ExecuteEvents.Execute(mRaycastResults[i].gameObject, data, function);
                count++;
                if(count >= passCount)
                {
                    break;
                }
                //RaycastAll后ugui会自己排序，如果你只想响应透下去的最近的一个响应，这里ExecuteEvents.Execute后直接break就行。
            }
        }
    }
}
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using System;
using System.Collections;
using System.Collections.Generic;

public class UIDragFixedThroughListener : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IDragHandler
{
    static public UIDragFixedThroughListener Get(GameObject go)
    {
        UIDragFixedThroughListener listener = go.GetComponent<UIDragFixedThroughListener>();
        if(listener == null) listener = go.AddComponent<UIDragFixedThroughListener>();
        return listener;
    }

    public Action<UIDragFixedThroughListener, PointerEventData> onDown;
    public Action<UIDragFixedThroughListener, PointerEventData> onUp;
    public Action<UIDragFixedThroughListener, PointerEventData> onDrag;

    /// <summary>
    /// 穿透的层级索引，只有该层级才响应事件
    /// </summary>
    public int passIndex = 1;

    private List<RaycastResult> mRaycastResults = new List<RaycastResult>();

    //监听按下
    public void OnPointerDown(PointerEventData eventData)
    {
        if(onDown != null) onDown.Invoke(this, eventData);
        mRaycastResults.Clear();
        EventSystem.current.RaycastAll(eventData, mRaycastResults);
        ThroughEvent(eventData, ExecuteEvents.pointerDownHandler);
    }

    //监听抬起
    public void OnPointerUp(PointerEventData eventData)
    {
        if(onUp != null) onUp.Invoke(this, eventData);
        ThroughEvent(eventData, ExecuteEvents.pointerUpHandler);
        mRaycastResults.Clear();
    }

    public void OnDrag(PointerEventData eventData)
    {
        if(onDrag != null) onDrag.Invoke(this, eventData);
        ThroughEvent(eventData, ExecuteEvents.dragHandler);
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
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using System;
using System.Collections;
using System.Collections.Generic;

public class UIDownUpThroughListener : MonoBehaviour, IPointerClickHandler, IPointerDownHandler, IPointerUpHandler
{
    static public UIDownUpThroughListener Get(GameObject go)
    {
        UIDownUpThroughListener listener = go.GetComponent<UIDownUpThroughListener>();
        if(listener == null) listener = go.AddComponent<UIDownUpThroughListener>();
        return listener;
    }

    public Action<UIDownUpThroughListener, PointerEventData> onClick;
    public Action<UIDownUpThroughListener, PointerEventData> onDown;
    public Action<UIDownUpThroughListener, PointerEventData> onUp;

    /// <summary>
    /// 穿透的层级数
    /// </summary>
    public int passCount = 1;

    void IPointerClickHandler.OnPointerClick(PointerEventData eventData)
    {
        if(onClick != null)
        {
            onClick.Invoke(this, eventData);
        }
        ThroughEvent(eventData, ExecuteEvents.pointerClickHandler);
    }

    void IPointerDownHandler.OnPointerDown(PointerEventData eventData)
    {
        if(onDown != null)
        {
            onDown.Invoke(this, eventData);
        }
        ThroughEvent(eventData, ExecuteEvents.pointerDownHandler);
    }

    void IPointerUpHandler.OnPointerUp(PointerEventData eventData)
    {
        if(onUp != null)
        {
            onUp.Invoke(this, eventData);
        }
        ThroughEvent(eventData, ExecuteEvents.pointerUpHandler);
    }

    //把事件透下去
    public void ThroughEvent<T>(PointerEventData data, ExecuteEvents.EventFunction<T> function)
        where T : IEventSystemHandler
    {
        List<RaycastResult> results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(data, results);
        GameObject current = data.pointerCurrentRaycast.gameObject;
        int count = 0;
        for(int i = 0; i < results.Count; i++)
        {
            if(current != results[i].gameObject)
            {
                ExecuteEvents.Execute(results[i].gameObject, data, function);
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
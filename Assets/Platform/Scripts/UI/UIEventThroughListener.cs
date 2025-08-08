using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using System;
using System.Collections;
using System.Collections.Generic;

public class UIEventThroughListener : EventTrigger
{
    static public UIEventThroughListener Get(GameObject go)
    {
        UIEventThroughListener listener = go.GetComponent<UIEventThroughListener>();
        if(listener == null) listener = go.AddComponent<UIEventThroughListener>();
        return listener;
    }

    public Action<UIEventThroughListener, PointerEventData> onClick;
    public Action<UIEventThroughListener, PointerEventData> onDown;
    public Action<UIEventThroughListener, PointerEventData> onEnter;
    public Action<UIEventThroughListener, PointerEventData> onExit;
    public Action<UIEventThroughListener, PointerEventData> onUp;
    public Action<UIEventThroughListener, PointerEventData> onDrop;
    public Action<UIEventThroughListener, PointerEventData> onDrag;
    public Action<UIEventThroughListener, PointerEventData> onEndDrag;

    /// <summary>
    /// 穿透的层级数
    /// </summary>
    public int passCount = 1;
    /// <summary>
    /// 是否在该脚本执行之前穿透
    /// </summary>
    public bool isBeforeThrough = false;

    public override void OnPointerClick(PointerEventData eventData)
    {
        if(onClick != null)
        {
            if(isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.pointerClickHandler);
            }
            //
            onClick.Invoke(this, eventData);
            //
            if(!isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.pointerClickHandler);
            }
        }
    }

    public override void OnPointerDown(PointerEventData eventData)
    {
        if(onDown != null)
        {
            if(isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.pointerDownHandler);
            }
            //
            onDown.Invoke(this, eventData);
            //
            if(!isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.pointerDownHandler);
            }
        }
    }

    public override void OnPointerEnter(PointerEventData eventData)
    {
        if(onEnter != null)
        {
            if(isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.pointerEnterHandler);
            }
            //
            onEnter.Invoke(this, eventData);
            //
            if(!isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.pointerEnterHandler);
            }
        }
    }

    public override void OnPointerExit(PointerEventData eventData)
    {
        if(onExit != null)
        {
            if(isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.pointerExitHandler);
            }
            //
            onExit.Invoke(this, eventData);
            //
            if(!isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.pointerExitHandler);
            }
        }
    }

    public override void OnPointerUp(PointerEventData eventData)
    {
        if(onUp != null)
        {
            if(isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.pointerUpHandler);
            }
            //
            onUp.Invoke(this, eventData);
            //
            if(!isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.pointerUpHandler);
            }
        }
    }

    public override void OnDrop(PointerEventData eventData)
    {
        if(onDrop != null)
        {
            if(isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.dropHandler);
            }
            //
            onDrop.Invoke(this, eventData);
            //
            if(!isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.dropHandler);
            }
        }
    }

    public override void OnDrag(PointerEventData eventData)
    {
        if(onDrag != null)
        {
            if(isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.dragHandler);
            }
            //
            onDrag.Invoke(this, eventData);
            //
            if(!isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.dragHandler);
            }
        }
    }

    public override void OnEndDrag(PointerEventData eventData)
    {
        if(onEndDrag != null)
        {
            if(isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.endDragHandler);
            }
            //
            onEndDrag.Invoke(this, eventData);
            //
            if(!isBeforeThrough)
            {
                ThroughEvent(eventData, ExecuteEvents.endDragHandler);
            }
        }
    }

    //把事件透下去
    public void ThroughEvent<T>(PointerEventData data, ExecuteEvents.EventFunction<T> function)
        where T : IEventSystemHandler
    {
        GameObject current = data.pointerCurrentRaycast.gameObject;
        if(current != this.gameObject)
        {
            return;
        }

        List<RaycastResult> results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(data, results);

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
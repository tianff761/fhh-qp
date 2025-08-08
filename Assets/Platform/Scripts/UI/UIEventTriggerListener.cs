using System;
using UnityEngine.EventSystems;
using UnityEngine;

public class UIEventTriggerListener : EventTrigger
{
    static public UIEventTriggerListener Get(GameObject go)
    {
        UIEventTriggerListener listener = go.GetComponent<UIEventTriggerListener>();
        if(listener == null) listener = go.AddComponent<UIEventTriggerListener>();
        return listener;
    }

    public Action<UIEventTriggerListener, PointerEventData> onClick;
    public Action<UIEventTriggerListener, PointerEventData> onDown;
    public Action<UIEventTriggerListener, PointerEventData> onEnter;
    public Action<UIEventTriggerListener, PointerEventData> onExit;
    public Action<UIEventTriggerListener, PointerEventData> onUp;
    public Action<UIEventTriggerListener, PointerEventData> onDrop;
    public Action<UIEventTriggerListener, PointerEventData> onDrag;
    public Action<UIEventTriggerListener, PointerEventData> onEndDrag;

    public override void OnPointerClick(PointerEventData eventData)
    {
        if(onClick != null) onClick.Invoke(this, eventData);
    }

    public override void OnPointerDown(PointerEventData eventData)
    {
        if(onDown != null) onDown.Invoke(this, eventData);
    }

    public override void OnPointerEnter(PointerEventData eventData)
    {
        if(onEnter != null) onEnter.Invoke(this, eventData);
    }

    public override void OnPointerExit(PointerEventData eventData)
    {
        if(onExit != null) onExit.Invoke(this, eventData);
    }

    public override void OnPointerUp(PointerEventData eventData)
    {
        if(onUp != null) onUp.Invoke(this, eventData);
    }

    public override void OnDrop(PointerEventData eventData)
    {
        if(onDrop != null) onDrop.Invoke(this, eventData);
    }

    public override void OnDrag(PointerEventData eventData)
    {
        if(onDrag != null) onDrag.Invoke(this, eventData);
    }

    public override void OnEndDrag(PointerEventData eventData)
    {
        if(onEndDrag != null) onEndDrag.Invoke(this, eventData);
    }

}
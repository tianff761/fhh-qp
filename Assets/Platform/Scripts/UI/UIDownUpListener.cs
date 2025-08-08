using UnityEngine;
using UnityEngine.EventSystems;
using System;

public class UIDownUpListener : MonoBehaviour, IPointerClickHandler, IPointerDownHandler, IPointerUpHandler
{
    public static UIDownUpListener Get(GameObject go)
    {
        UIDownUpListener listener = go.GetComponent<UIDownUpListener>();
        if(listener == null) listener = go.AddComponent<UIDownUpListener>();
        return listener;
    }

    public Action<UIDownUpListener, PointerEventData> onClick;
    public Action<UIDownUpListener, PointerEventData> onDown;
    public Action<UIDownUpListener, PointerEventData> onUp;

    private RectTransform mRectTransform;

    public RectTransform GetRectTransform()
    {
        if(this.mRectTransform == null)
        {
            this.mRectTransform = this.GetComponent<RectTransform>();
        }
        return this.mRectTransform;
    }

    void IPointerClickHandler.OnPointerClick(PointerEventData eventData)
    {
        if(onClick != null)
        {
            onClick.Invoke(this, eventData);
        }
    }

    void IPointerDownHandler.OnPointerDown(PointerEventData eventData)
    {
        if(onDown != null)
        {
            onDown.Invoke(this, eventData);
        }
    }

    void IPointerUpHandler.OnPointerUp(PointerEventData eventData)
    {
        if(onUp != null)
        {
            onUp.Invoke(this, eventData);
        }
    }

}

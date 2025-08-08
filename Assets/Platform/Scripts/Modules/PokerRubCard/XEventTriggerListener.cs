using UnityEngine.Events;
using UnityEngine.EventSystems;

public class XEventTriggerListener : EventTrigger
{
    public XPointerEvent onBeginDragHandler = new XPointerEvent();
    public XPointerEvent onDragHandler = new XPointerEvent();
    public XPointerEvent onEndDragHandler = new XPointerEvent();
    public XPointerEvent onInitializePotentialDragHandler = new XPointerEvent();
    public XPointerEvent onPointerClickHandler = new XPointerEvent();
    public XPointerEvent onPointerDownHandler = new XPointerEvent();
    public XPointerEvent onPointerEnterHandler = new XPointerEvent();
    public XPointerEvent onPointerExitHandler = new XPointerEvent();
    public XPointerEvent onPointerUpHandler = new XPointerEvent();
    public XAxisEvent onMoveHandler = new XAxisEvent();

    public override void OnBeginDrag(PointerEventData eventData)
    {
        onBeginDragHandler.Invoke(eventData);
    }
    
    public override void OnDrag(PointerEventData eventData)
    {
        onDragHandler.Invoke(eventData);
    }
    
    public override void OnEndDrag(PointerEventData eventData)
    {
        onEndDragHandler.Invoke(eventData);
    }

    public override void OnInitializePotentialDrag(PointerEventData eventData)
    {
        onInitializePotentialDragHandler.Invoke(eventData);
    }

    public override void OnPointerClick(PointerEventData eventData)
    {
        onPointerClickHandler.Invoke(eventData);
    }

    public override void OnPointerDown(PointerEventData eventData)
    {
        onPointerDownHandler.Invoke(eventData);
    }

    public override void OnPointerEnter(PointerEventData eventData)
    {
        onPointerEnterHandler.Invoke(eventData);
    }

    public override void OnPointerExit(PointerEventData eventData)
    {
        onPointerExitHandler.Invoke(eventData);
    }

    public override void OnPointerUp(PointerEventData eventData)
    {
        onPointerUpHandler.Invoke(eventData);
    }

    public override void OnMove(AxisEventData eventData)
    {
        onMoveHandler.Invoke(eventData);
    }



    public class XPointerEvent : UnityEvent<PointerEventData>
    {
    }
    public class XAxisEvent : UnityEvent<AxisEventData>
    { }

}


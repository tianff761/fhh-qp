using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using LuaFramework;
using System;

public class ButtonSpeech : MonoBehaviour {

    Action<float> touchDownBackCall;
    Action<float> touchUpBackCall;
    Action<float> touchMoveBackCall;

    void Start () {
		UnityAction<BaseEventData> downevent = new UnityAction<BaseEventData> (OnTouchDown);
		EventTrigger.Entry touchdown = new EventTrigger.Entry ();
		touchdown.eventID = EventTriggerType.PointerDown;
		touchdown.callback.AddListener (downevent);

		EventTrigger trigger = gameObject.AddComponent<EventTrigger> ();
		trigger.triggers.Add (touchdown);

		UnityAction<BaseEventData> upevent = new UnityAction<BaseEventData> (OnTouchUp);
		EventTrigger.Entry touchup = new EventTrigger.Entry ();
		touchup.eventID = EventTriggerType.PointerUp;
		touchup.callback.AddListener (upevent);
		trigger.triggers.Add (touchup);

		UnityAction<BaseEventData> moveevent = new UnityAction<BaseEventData> (OnTouchMove);
		EventTrigger.Entry touchmove = new EventTrigger.Entry ();
		touchmove.eventID = EventTriggerType.Drag;
		touchmove.callback.AddListener (moveevent);
		trigger.triggers.Add (touchmove);
	}
	
    public void Init(Action<float> mTouchDownBackCall, Action<float> mTouchUpBackCall, Action<float> mTouchMoveBackCall)
    {
        touchDownBackCall = mTouchDownBackCall;
        touchUpBackCall = mTouchUpBackCall;
        touchMoveBackCall = mTouchMoveBackCall;
    }

    public void RemoveAllEvent()
    {
        touchDownBackCall = null;
        touchUpBackCall = null;
        touchMoveBackCall = null;
    }

	void OnTouchDown(BaseEventData data) {
        if (touchDownBackCall != null)
        {
            touchDownBackCall.Invoke(data.currentInputModule.input.mousePosition.y);
        }
	}

	void OnTouchUp(BaseEventData data) {
        if (touchUpBackCall != null)
        {
            touchUpBackCall.Invoke(data.currentInputModule.input.mousePosition.y);
        }
	}

	void OnTouchMove(BaseEventData data) {
        if (touchMoveBackCall != null)
        {
            touchMoveBackCall.Invoke(data.currentInputModule.input.mousePosition.y);
        }
	}


}

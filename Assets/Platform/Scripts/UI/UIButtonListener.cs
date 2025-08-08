using UnityEngine;
using UnityEngine.UI;
using System;

public class UIButtonListener : MonoBehaviour
{

    public static UIButtonListener Get(GameObject go)
    {
        UIButtonListener listener = go.GetComponent<UIButtonListener>();
        if(listener == null) listener = go.AddComponent<UIButtonListener>();
        return listener;
    }

    public static void AddListener(GameObject go, Action<UIButtonListener> callback)
    {
        UIButtonListener listener = Get(go);
        listener.AddClick(callback);
    }

    public static void RemoveListener(GameObject go)
    {
        UIButtonListener listener = go.GetComponent<UIButtonListener>();
        if(listener != null)
        {
            listener.RemoveClick();
        }
    }

    private Button mButton = null;

    private Action<UIButtonListener> mOnClick = null;

    private void CheckButton()
    {
        if(this.mButton == null)
        {
            this.mButton = this.gameObject.GetComponent<Button>();
        }
    }

    public void AddClick(Action<UIButtonListener> callback)
    {
        this.mOnClick = callback;
        this.CheckButton();
        if(this.mButton != null)
        {
            this.mButton.onClick.AddListener(this.OnButtonClick);
        }
    }

    public void RemoveClick()
    {
        this.Clear();
    }

    private void OnButtonClick()
    {
        if(this.mOnClick != null)
        {
            this.mOnClick.Invoke(this);
        }
    }

    private void Clear()
    {
        if(this.mButton != null)
        {
            this.mButton.onClick.RemoveListener(this.OnButtonClick);
            this.mButton = null;
        }
        this.mOnClick = null;
    }

    public void OnDestroy()
    {
        this.Clear();
    }

}

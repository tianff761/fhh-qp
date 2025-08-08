using UnityEngine;
using UnityEngine.UI;
using System;

public class UIToggleListener : MonoBehaviour
{
    public static UIToggleListener Get(GameObject go)
    {
        UIToggleListener listener = go.GetComponent<UIToggleListener>();
        if(listener == null) listener = go.AddComponent<UIToggleListener>();
        return listener;
    }

    public static void AddListener(GameObject go, Action<bool, UIToggleListener> callback)
    {
        UIToggleListener listener = Get(go);
        listener.AddValueChanged(callback);
    }

    public static void RemoveListener(GameObject go)
    {
        UIToggleListener listener = go.GetComponent<UIToggleListener>();
        if(listener != null)
        {
            listener.RemoveValueChanged();
        }
    }

    private Toggle mToggle = null;
    private Action<bool, UIToggleListener> mOnValueChanged = null;

    private void CheckToggle()
    {
        if(this.mToggle == null)
        {
            this.mToggle = this.gameObject.GetComponent<Toggle>();
            if(this.mToggle != null)
            {
                this.mToggle.onValueChanged.AddListener(this.OnValueChanged);
            }
        }
    }

    public void AddValueChanged(Action<bool, UIToggleListener> callback)
    {
        this.mOnValueChanged = callback;
        this.CheckToggle();
    }

    public void RemoveValueChanged()
    {
        this.Clear();
    }

    private void OnValueChanged(bool isOn)
    {
        if(this.mOnValueChanged != null)
        {
            this.mOnValueChanged.Invoke(isOn, this);
        }
    }

    private void Clear()
    {
        if(this.mToggle != null)
        {
            this.mToggle.onValueChanged.RemoveListener(this.OnValueChanged);
            this.mToggle = null;
        }
        this.mOnValueChanged = null;
    }

    public void OnDestroy()
    {
        this.Clear();
    }

}

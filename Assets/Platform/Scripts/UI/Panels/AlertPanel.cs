using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AlertPanel : MonoBehaviour
{
    Text msgTet;

    Button okCenterBtn;
    Button okBtn;
    Button cancelBtn;

    private Action mOnOkCallback = null;
    private Action mOnCancelCallback = null;
    private AlertLevel mAlertLevel = AlertLevel.Normal;

    private WindowTweener tweener = null;
    private int clickBtnType = 0;

    void Awake()
    {
        msgTet = transform.Find("Content/MsgTxt").GetComponent<Text>();
        okCenterBtn = transform.Find("Content/OkCenterButton").GetComponent<Button>();
        okBtn = transform.Find("Content/OkButton").GetComponent<Button>();
        cancelBtn = transform.Find("Content/CancelButton").GetComponent<Button>();

        tweener = this.GetComponentInChildren<WindowTweener>();
    }

    void Start()
    {
        okBtn.onClick.AddListener(OnOkBtnClick);
        okCenterBtn.onClick.AddListener(OnOkBtnClick);
        cancelBtn.onClick.AddListener(OnCancelBtnClick);
    }

    private void OnOkBtnClick()
    {
        this.clickBtnType = 0;
        this.InternalClose();

    }

    private void OnCancelBtnClick()
    {
        this.clickBtnType = 1;
        this.InternalClose();
    }

    public void Open(string msg, AlertType type, string okBtnTxt, Action onOkCallback, string cancelBtnTxt,
        Action onCancelCallback, AlertLevel level = AlertLevel.Normal)
    {
        SetObjActive(this.gameObject, true);

        if (mAlertLevel > level)
        {
            return;
        }

        this.msgTet.text = msg;
        mAlertLevel = level;
        mOnOkCallback = onOkCallback;
        mOnCancelCallback = onCancelCallback;
        if (type == AlertType.Ok)
        {
            SetObjActive(okCenterBtn.gameObject, true);
            SetObjActive(okBtn.gameObject, false);
            SetObjActive(cancelBtn.gameObject, false);
        }
        else
        {
            SetObjActive(okCenterBtn.gameObject, false);
            SetObjActive(okBtn.gameObject, true);
            SetObjActive(cancelBtn.gameObject, true);
        }
    }

    private void SetObjActive(GameObject go, bool value)
    {
        if (value)
        {
            if (!go.activeSelf)
            {
                go.SetActive(true);
            }
        }
        else
        {
            if (go.activeSelf)
            {
                go.SetActive(false);
            }
        }
    }

    private void Clear()
    {
        msgTet.text = "";
        mOnOkCallback = null;
        mOnCancelCallback = null;
        mAlertLevel = AlertLevel.Normal;
    }

    public void Close()
    {
        SetObjActive(this.gameObject, false);
        Clear();
    }

    private void InternalClose() 
    {
        if (this.tweener != null)
        {
            this.tweener.PlayCloseAnim(this.OnCompleted);
        }
        else 
        {
            this.OnCompleted();
        }
    }

    private void OnCompleted() 
    {
        SetObjActive(this.gameObject, false);
        if (this.clickBtnType == 0)
        {
            if (mOnOkCallback != null)
            {
                mOnOkCallback.Invoke();
            }
        }
        else 
        {
            if (mOnCancelCallback != null)
            {
                mOnCancelCallback.Invoke();
            }
        }
        Clear();
    }
}
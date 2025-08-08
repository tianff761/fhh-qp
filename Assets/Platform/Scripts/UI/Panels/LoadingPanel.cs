using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;
using LuaFramework;

public class LoadingPanel : MonoBehaviour
{
    /// <summary>
    /// Loading计算速度，每秒百分之多少进度
    /// </summary>
    private const float LOADING_SPEED = 0.4f;

    public Image background;
    public Transform bgArmature;

    public Slider sliderProgress;
    public Text tipsTxt;
    public Text percentTxt;
    public Text versionTxt;

    //----------------------------------------------------------------

    private bool mIsShowPercent = true;
    private float mTargetValue = 0;
    private float mCurrValue = 0;
    private float mTempValue = 0;
    private float mSpeed = 0;
    /// <summary>
    /// 是否完成，用于标识完成，然后延迟回调
    /// </summary>
    private bool mIsFinished = false;
    private float mFinishDelay = 0;
    private Action mOnFinished = null;

    private void Awake()
    {
        DelegateManager.Instance.AddListener(DelegateCommand.AppVersionUpdate, OnAppVersionUpdate);
    }

    void Start()
    {
        if (background != null)
        {
            UIUtil.SetBackgroundAdaptationByHorizontal(background);
        }
        if (bgArmature != null)
        {
            UIUtil.SetBackgroundAnimAdaptation(bgArmature, 1560, 720);
        }
        this.UpdateAppVersionDisplay(AppConst.BaseName);
    }

    void OnDestroy()
    {
        DelegateManager.Instance.RemoveListener(DelegateCommand.AppVersionUpdate, OnAppVersionUpdate);
    }

    void Update()
    {
        if (mTargetValue > mCurrValue)
        {
            mCurrValue += mSpeed * Time.deltaTime;
            if (mCurrValue > mTargetValue)
            {
                mCurrValue = mTargetValue;
            }
            if (mCurrValue >= 1)
            {
                mIsFinished = true;
            }
            ShowProgress();
        }
        else if (mIsFinished)
        {
            mFinishDelay += Time.deltaTime;
            if (mFinishDelay > 0.12f)
            {
                mIsFinished = false;
                if (mOnFinished != null)
                {
                    mOnFinished.Invoke();
                }
            }
        }
    }

    /// <summary>
    /// 开始使用Loading面板时，需要调用一次该方法来进行初始处理
    /// </summary>
    public void Begin(string tipsMsg, Action onFinished, bool isShowPercent = true, float speed = 0)
    {
        tipsTxt.text = tipsMsg;
        mOnFinished = onFinished;
        mIsShowPercent = isShowPercent;
        mSpeed = speed > 0 ? speed : LOADING_SPEED;

        //----------------
        mIsFinished = false;
        mFinishDelay = 0;
        mTargetValue = 0;
        mCurrValue = 0;
        if (sliderProgress != null)
        {
            sliderProgress.value = mCurrValue;
        }
        if (!mIsShowPercent)
        {
            percentTxt.text = "";
        }
        else
        {
            percentTxt.text = "0%";
        }
    }


    public void SetProgress(float progress)
    {
        this.mTargetValue = progress;
        if (this.mCurrValue > this.mTargetValue)
        {
            this.mCurrValue = this.mTargetValue;
            ShowProgress();
        }
    }

    public void Stop()
    {
        if (this.mTargetValue > this.mCurrValue)
        {
            this.mTargetValue = this.mCurrValue - 0.001f;
            if (this.mTargetValue < 0)
            {
                this.mTargetValue = 0;
            }
        }
    }

    public void SetSpeed(float speed)
    {
        this.mSpeed = speed;
    }

    public void SetTips(string tipsMsg)
    {
        tipsTxt.text = tipsMsg;
    }

    public void SetFinishedCallback(Action onFinished)
    {
        this.mOnFinished = onFinished;
        //设置新回调时，如果进度Loading结束，直接回调
        if (this.mOnFinished != null && mIsFinished)
        {
            this.mOnFinished.Invoke();
        }
    }

    private void ShowProgress()
    {
        if (mIsShowPercent)
        {
            float temp = mCurrValue * 100;
            string progresstxt = temp.ToString("0.0");
            percentTxt.text = progresstxt + "%";
        }
        mTempValue = mCurrValue;
        if (mTempValue > 1)
        {
            mTempValue = 1;
        }
        if (sliderProgress != null)
        {
            sliderProgress.value = mTempValue;
        }
    }

    //================================================================
    /// <summary>
    /// 版本号更新
    /// </summary>
    private void OnAppVersionUpdate(object[] objs)
    {
        if (objs != null && objs.Length > 0)
        {
            this.UpdateAppVersionDisplay(objs[0] as string);
        }
    }

    /// <summary>
    /// 更新版本号的显示
    /// </summary>
    private void UpdateAppVersionDisplay(string gameName)
    {
        string temp = AppConst.AppVerStr;

        if (VersionManager.Instance.GetGameLocalVersionNum(gameName) > 0)
        {
            string gameVerStr = VersionManager.Instance.GetGameLocalVersionStr(gameName);
            if (string.IsNullOrEmpty(gameVerStr))
            {
                gameVerStr = "1.0.1";
            }
            temp += "." + gameVerStr.Substring(4);
        }
        else
        {
            temp += ".1";
        }
        if (versionTxt != null)
        {
            versionTxt.text = temp;
        }
    }

}

using System.Collections.Generic;
using System;

public class GameUpgradeManager : TSingleton<GameUpgradeManager>
{
    private GameUpgradeManager() { }

    /// <summary>
    /// 检测完成回调
    /// </summary>
    public Action mOnCheckFinshCallback = null;
    /// <summary>
    /// 初始更新的游戏
    /// </summary>
    private List<string> mGames = new List<string> { "Base"};
    /// <summary>
    /// 当前更新的索引
    /// </summary>
    private int mIndex = 0;
    /// <summary>
    /// 更新状态
    /// </summary>
    private int mUpgradeStatus = UpgradeStatus.NONE;

    /// <summary>
    /// 每个游戏占的百分比
    /// </summary>
    private float mPercent = 1;
    /// <summary>
    /// 当前进度
    /// </summary>
    private float mProgress = 0;
    /// <summary>
    /// 更新所占的总进度
    /// </summary>
    private float mTotalProgress = 0.7f;


    /// <summary>
    /// 检测资源，主要是处理多个游戏初始化
    /// </summary>
    public void Check(Action onCheckFinshCallback)
    {
        this.mOnCheckFinshCallback = onCheckFinshCallback;
        this.mIndex = 0;
        this.mPercent = 1.0f / this.mGames.Count;
        this.mProgress = 0;
        this.LoadNext();
    }

    private void LoadNext()
    {
        if(this.mGames.Count > this.mIndex)
        {
            //第一个更新，需要检测远端版本号，第二个就不需要了
            if(this.mIndex == 0)
            {
                UpgradeManager.Instance.Check(this.mGames[this.mIndex], this.OnCheckFinshCallback, this.OnProgressCallback);
            }
            else
            {
                UpgradeManager.Instance.CheckWithoutVersion(this.mGames[this.mIndex], this.OnCheckFinshCallback, this.OnProgressCallback);
            }
        }
    }

    private void OnCheckFinshCallback()
    {
        this.mIndex += 1;
        this.mProgress = this.mPercent * this.mIndex * this.mTotalProgress;
        if(this.mIndex < this.mGames.Count)
        {
            this.LoadNext();
        }
        else
        {
            if(this.mOnCheckFinshCallback != null)
            {
                this.mOnCheckFinshCallback.Invoke();
            }
        }
    }

    private void OnProgressCallback(int status, float progress)
    {
        if(status != this.mUpgradeStatus)
        {
            this.mUpgradeStatus = status;
            if(this.mUpgradeStatus == UpgradeStatus.BEGIN)
            {
                if(this.mIndex == 0)
                {
                    Loading.Begin(UpgradeStatus.BeginTipsTxt, null);
                }
            }
            else if(this.mUpgradeStatus == UpgradeStatus.CHECK)
            {
                Loading.SetTips(UpgradeStatus.CheckTipsTxt);
                Loading.SetSpeed(Loading.SPEED_SLOWEST);
            }
            else if(this.mUpgradeStatus == UpgradeStatus.COPY)
            {
                Loading.SetTips(UpgradeStatus.CopyTipsTxt);
                Loading.SetSpeed(Loading.SPEED_UPGRADE);
            }
            else if(this.mUpgradeStatus == UpgradeStatus.DOWNLOAD)
            {
                Loading.SetTips(UpgradeStatus.DownloadTipsTxt);
                Loading.SetSpeed(Loading.SPEED_UPGRADE);
            }
            else if(this.mUpgradeStatus == UpgradeStatus.FINISHED)
            {
            }
            else if(this.mUpgradeStatus == UpgradeStatus.STOP)
            {
            }
        }

        Loading.SetProgress(this.mProgress + progress * this.mPercent);
    }

}

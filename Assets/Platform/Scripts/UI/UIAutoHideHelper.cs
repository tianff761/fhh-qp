using System;
using UnityEngine;

public class UIAutoHideHelper : MonoBehaviour
{
    /// <summary>
    /// 忽略TimeScale
    /// </summary>
    public bool ignoreTimeScale = false;
    /// <summary>
    /// 时间
    /// </summary>
    public float time = 0;
    /// <summary>
    /// 完成回调
    /// </summary>
    public Action onCompleted = null;
    /// <summary>
    /// 计时使用
    /// </summary>
    private float mTime = 0;


    private void Update()
    {
        if(time > 0)
        {
            mTime += ignoreTimeScale ? Time.unscaledDeltaTime : Time.deltaTime;
            if(mTime > time)
            {
                mTime = 0;
                if(this.gameObject.activeSelf)
                {
                    this.gameObject.SetActive(false);
                }
                if(this.onCompleted != null)
                {
                    this.onCompleted.Invoke();
                }
            }
        }
    }

}

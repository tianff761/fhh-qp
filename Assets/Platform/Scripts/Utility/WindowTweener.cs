using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;

public class WindowTweener : MonoBehaviour
{
    //弹窗动画效果枚举
    public enum animationType
    {
        //无动画
        None = 0,
        //弹窗
        Pop = 1,
        //Alpha渐变
        Alpha = 2,
    }

    [Tooltip("弹窗起始值")]
    public float begin = 0.4f;
    [Tooltip("弹窗结束值")]
    public float end = 1f;
    [Tooltip("Alpha渐变起始值")]
    public float alpha = 0;
    [Tooltip("动画持续时间")]
    public float duration = 0.3f;
    [Tooltip("动画效果类型")]
    public animationType animType = animationType.Pop;
    [Tooltip("DOTween使用的独立更新")]
    public bool isIndependentUpdate = false;

    /// <summary>
    /// Alpha渐变使用的
    /// </summary>
    private CanvasGroup mCanvas = null;
    /// <summary>
    /// 动画播放完成回调，一般用于关闭界面
    /// </summary>
    private Action mCallback = null;

    //弹窗动画
    public void PlayOpenAnim()
    {
        if (animType == animationType.Pop)
        {
            this.transform.localScale = Vector3.one * begin;
            Tweener tweener = this.transform.DOScale(Vector3.one * end, duration);
            tweener.SetUpdate(isIndependentUpdate);
            tweener.SetEase(Ease.OutBack);
        }
        else if (animType == animationType.Alpha)
        {
            if (mCanvas == null)
            {
                mCanvas = GetComponent<CanvasGroup>();
                if (mCanvas == null)
                {
                    mCanvas = this.gameObject.AddComponent<CanvasGroup>();
                }
            }
            if (mCanvas != null)
            {
                mCanvas.alpha = alpha;
                Tweener tweener = mCanvas.DOFade(1, duration);
                tweener.SetUpdate(isIndependentUpdate);
                tweener.SetEase(Ease.Linear);
            }
        }
    }

    public void PlayCloseAnim(Action callback)
    {
        this.mCallback = callback;
        if (animType == animationType.Pop)
        {
            float temp = (this.transform.localScale.x - begin) / (end - begin) * duration;
            Tweener tweener = this.transform.DOScale(Vector3.one * begin, temp);
            tweener.OnComplete(this.OnCompleted);
            tweener.SetUpdate(isIndependentUpdate);
            tweener.SetEase(Ease.InBack);
        }
        else if (animType == animationType.Alpha)
        {
            if (mCanvas == null)
            {
                mCanvas = GetComponent<CanvasGroup>();
                if (mCanvas == null)
                {
                    mCanvas = this.gameObject.AddComponent<CanvasGroup>();
                }
            }
            float temp = (mCanvas.alpha - alpha) / (1 - alpha) * duration;
            Tweener tweener = mCanvas.DOFade(alpha, temp);
            tweener.OnComplete(this.OnCompleted);
            tweener.SetUpdate(isIndependentUpdate);
            tweener.SetEase(Ease.Linear);
        }
        else 
        {
            this.OnCompleted();
        }
    }

    private void OnCompleted()
    {
        if (this.mCallback != null)
        {
            this.mCallback.Invoke();
        }
    }

}

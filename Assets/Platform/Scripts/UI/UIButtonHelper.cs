using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

/// <summary>
/// 按钮按下效果帮助类
/// </summary>
public class UIButtonHelper : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerDownHandler, IPointerUpHandler
{
    /// <summary>
    /// 当前按下的对象
    /// </summary>
    public static UIButtonHelper Current = null;


    /// <summary>
    /// 是否绑定Button，如果按钮被禁用，该组件也被禁用
    /// </summary>
    public bool isBindingButton = false;

    /// <summary>
    /// 是否应用缩放
    /// </summary>
    public bool isApplyScale = true;
    /// <summary>
    /// 缩放的目标对象
    /// </summary>
    public Transform scaleTarget = null;
    /// <summary>
    /// 移上缩放
    /// </summary>
    public Vector3 overScale = new Vector3(1, 1, 1);
    /// <summary>
    /// 按下缩放大小
    /// </summary>
    public Vector3 downScale = new Vector3(0.95f, 0.95f, 1);

    /// <summary>
    /// 是否应用颜色
    /// </summary>
    public bool isApplyColor = false;
    /// <summary>
    /// 颜色的目标对象
    /// </summary>
    public MaskableGraphic colorTarget = null;
    /// <summary>
    /// 移上颜色
    /// </summary>
    public Color overColor = new Color(1, 1, 1, 1);
    /// <summary>
    /// 按下颜色
    /// </summary>
    public Color downColor = new Color(1, 1, 1, 1);
    

    /// <summary>
    /// 默认的缩放
    /// </summary>
    private Vector3 mDefaultScale = Vector3.one;
    /// <summary>
    /// 默认颜色
    /// </summary>
    private Color mDefaultColor = Color.white;
    /// <summary>
    /// 是否按下
    /// </summary>
    private bool mIsDown = false;
    /// <summary>
    /// 是否移上
    /// </summary>
    private bool mIsOver = false;
    /// <summary>
    /// 缓存变量
    /// </summary>
    private bool mLastIsBindingButton = false;
    /// <summary>
    /// 是否激活
    /// </summary>
    private bool mIsActive = true;
    /// <summary>
    /// 绑定的按钮
    /// </summary>
    private Button mBindingButton = null;


    void Awake()
    {
        if(scaleTarget == null)
        {
            scaleTarget = this.transform;
        }
        this.mDefaultScale = scaleTarget.localScale;

        if(colorTarget == null)
        {
            colorTarget = this.transform.GetComponent<MaskableGraphic>();
        }
        if(colorTarget != null)
        {
            this.mDefaultColor = colorTarget.color;
        }
    }

    void OnDisable()
    {
        if(Current == this)
        {
            Current = null;
        }
        this.Clear();
    }

    /// <summary>
    /// 清理
    /// </summary>
    public void Clear()
    {
        this.mIsDown = false;
        this.mIsOver = false;
        this.SetUp();
        this.SetExit();
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        if(eventData.button != PointerEventData.InputButton.Left)
        {
            return;
        }
        this.mIsDown = true;
        this.CheckIsActive();
        if (this.mIsActive)
        {
            this.SetDown();
        }
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        if(eventData.button != PointerEventData.InputButton.Left)
        {
            return;
        }
        this.mIsDown = false;
        this.CheckClearCurrent();
        this.SetUp();
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        this.mIsOver = true;
        Current = this;
        this.CheckIsActive();
        if (this.mIsActive)
        {
            this.SetEnter();
        }
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        this.mIsOver = false;
        this.CheckClearCurrent();
        if (this.mIsActive)
        {
            this.SetExit();
        }
    }

    /// <summary>
    /// 检测清除Current对象
    /// </summary>
    public void CheckClearCurrent()
    {
        if(!this.mIsDown && !this.mIsOver)
        {
            Current = null;
        }
    }

    /// <summary>
    /// 检测是否激活
    /// </summary>
    public void CheckIsActive()
    {
        if (this.mLastIsBindingButton != this.isBindingButton)
        {
            this.mLastIsBindingButton = this.isBindingButton;
            if (this.mLastIsBindingButton)
            {
                this.mBindingButton = this.GetComponent<Button>();
            }
            else
            {
                this.mBindingButton = null;
            }
        }
        if (this.mBindingButton)
        {
            this.mIsActive = this.mBindingButton.interactable;
        }
        else
        {
            this.mIsActive = true;
        }
    }

    public void SetDown()
    {
        if(this.isApplyScale)
        {
            scaleTarget.localScale = downScale;
        }

        if(this.isApplyColor && this.colorTarget != null)
        {
            this.colorTarget.color = this.downColor;
        }
    }

    public void SetUp()
    {
        if(this.isApplyScale)
        {
            if(this.mIsOver)
            {
                scaleTarget.localScale = this.overScale;
            }
            else
            {
                scaleTarget.localScale = this.mDefaultScale;
            }
        }

        if(this.isApplyColor && this.colorTarget != null)
        {
            if(mIsOver)
            {
                this.colorTarget.color = this.overColor;
            }
            else
            {
                this.colorTarget.color = this.mDefaultColor;
            }
        }
    }

    public void SetEnter()
    {
        if(this.isApplyScale)
        {
            if(this.mIsDown)
            {
                scaleTarget.localScale = this.downScale;
            }
            else
            {
                scaleTarget.localScale = this.overScale;
            }
        }

        if(this.isApplyColor && this.colorTarget != null)
        {
            if(this.mIsDown)
            {
                this.colorTarget.color = this.downColor;
            }
            else
            {
                this.colorTarget.color = this.overColor;
            }
        }
    }

    public void SetExit()
    {
        if(this.isApplyScale)
        {
            if(this.mIsDown)
            {
                scaleTarget.localScale = this.downScale;
            }
            else
            {
                scaleTarget.localScale = this.mDefaultScale;
            }
        }

        if(this.isApplyColor && this.colorTarget != null)
        {
            if(this.mIsDown)
            {
                this.colorTarget.color = this.downColor;
            }
            else
            {
                this.colorTarget.color = this.mDefaultColor;
            }
        }
    }
}

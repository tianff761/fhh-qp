using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using DG.Tweening;
using System;

public enum FlipMode
{
    RightToLeft = 0,
    LeftToRight = 1,
    BottomToTop = 2
}

[ExecuteInEditMode]
public class PokerRubCard : MonoBehaviour
{
    public Camera UICamera;

    [SerializeField]
    public RectTransform PokerPanel;
    /// <summary>
    /// 使用的背景(一般为一张一像素的透明图片)
    /// </summary>
    public Sprite background;
    /// <summary>
    /// 牌的背面(翻之前)
    /// </summary>
    public Sprite pokerBack;
    /// <summary>
    /// 牌的正面(翻之后)
    /// </summary>
    public Sprite pokerFront;
    /// <summary>
    /// 牌的点数(翻之后)
    /// </summary>
    public Sprite pokerPoint;
    /// <summary>
    /// 翻牌后右边的点数图片
    /// </summary>
    public Image RightNextRpointImg;
    //public TweenAlpha RightNextRTweenAlpha;
    /// <summary>
    /// 翻牌后左边的点数图片
    /// </summary>
    public Image RightNextLpointImg;
    //public TweenAlpha RightNextLTweenAlpha;
    /// <summary>
    /// 翻牌中右边的点数图片
    /// </summary>
    public Image RightRpointImg;
    /// <summary>
    /// 翻牌中左边的点数图片
    /// </summary>
    public Image RightLpointImg;
    /// <summary>
    /// 是否可以翻牌
    /// </summary>
    public bool interactable = true;
    /// <summary>
    /// 是否自动关闭interactable
    /// </summary>
    public bool isAutoInteractable = true;
    /// <summary>
    /// 翻牌中是否显示Shadow
    /// </summary>
    public bool enableShadowEffect = true;
    /// <summary>
    /// 是否在翻牌中显示点数
    /// </summary>
    public bool showPointOnFilping = false;

    //represent the index of the sprite shown in the right page
    public Image TurnPageClip;
    public Image NextPageClip;
    public Image Shadow;
    //public Image ShadowLTR;
    public Image Left;
    public Image Right;
    public Image RightNext;

    //Spine Bottom
    Vector3 sb;
    //Spine Top
    Vector3 st;
    //corner of the page
    Vector3 c;
    //Edge Bottom Right
    Vector3 ebr;
    //Edge Bottom Left
    Vector3 ebl;
    //follow point 
    Vector3 f;
    //Edge middle Right
    Vector3 mr;
    //middle
    Vector3 mm;
    //Edge middle Left
    Vector3 ml;
    //Edge Top middle
    Vector3 tm;
    //Edge Bottom middle
    Vector3 bm;
    public Vector3 EndBottomLeft
    {
        get { return ebl; }
    }
    public Vector3 EndBottomRight
    {
        get { return ebr; }
    }
    /// <summary>
    /// 获取扑克牌宽高
    /// </summary>
    public float width
    {
        get
        {
            return PokerPanel.rect.width;
        }
    }

    public float height
    {
        get
        {
            return PokerPanel.rect.height;
        }
    }

    /// <summary>
    /// 回调翻完牌回调(指牌翻完成的回调)
    /// </summary>
    public Action EndFlipComplete = null;
    /// <summary>
    /// 是否翻牌中
    /// </summary>
    bool pageDragging = false;
    //current flip mode
    /// <summary>
    /// 当前翻牌模式
    /// </summary>
    FlipMode mode;

    /// <summary>
    /// 开始翻牌 int:当前翻牌模式(左||右||下)  Vector3:当前鼠标的位置(牌翻到哪个位置了)
    /// </summary>
    public Action<int, Vector3> FlipStartCallBack;
    /// <summary>
    /// 翻牌中回调 int:当前翻牌模式(左||右||下)  Vector3:当前鼠标的位置(牌翻到哪个位置了)
    /// </summary>
    public Action<int, Vector3> FlipUpdateCallBack;
    /// <summary>
    /// 翻牌结束 int:当前翻牌模式(左||右||下)  Vector3:当前鼠标的位置(牌翻到哪个位置了)
    /// 这里的翻牌结束不是指牌翻完成，是指鼠标手指松开牌的回调, EndFlipComplete 这个才是牌翻完成的回调
    /// </summary>
    public Action<int, Vector3> FlipEndCallBack;

    /// <summary>
    /// 翻牌中回调的间隔(毫秒)，0为不调用，-1为每帧调用。
    /// </summary>
    public float FlipUpdateInterval = -1;

    /// <summary>
    /// 上一次FlipUpdateCallBack回调时间
    /// </summary>
    private double lastFlipUpdateTime = 0;
    /// <summary>
    /// 当前时间
    /// </summary>
    private double curTime = 0;

    private float bottomLine = 0;
    private float rightLine = 0;
    private float leftLine = 0;
    private Vector3 downPoint = Vector3.zero;

    void Update()
    {
        if (pageDragging && interactable)
        {
            UpdatePoker();
        }
    }

    public void Init(Camera camera = null)
    {
        if (camera != null)
            UICamera = camera;

        float pageWidth = PokerPanel.rect.width / 2;
        float pageHeight = PokerPanel.rect.height;
        Left.gameObject.SetActive(false);
        Right.gameObject.SetActive(false);

        RightNext.sprite = pokerBack;

        if (showPointOnFilping && pokerFront != null)
        {
            RightRpointImg.sprite = pokerPoint;
            RightLpointImg.sprite = pokerPoint;
        }

        //是否在搓牌中显示点数
        RightRpointImg.gameObject.SetActive(showPointOnFilping);
        RightLpointImg.gameObject.SetActive(showPointOnFilping);

        Vector3 globalsb = PokerPanel.transform.position + new Vector3(0, -pageHeight / 2);
        sb = transformPoint(globalsb);
        Vector3 globalebr = PokerPanel.transform.position + new Vector3(pageWidth, -pageHeight / 2);
        ebr = transformPoint(globalebr);
        Vector3 globalebl = PokerPanel.transform.position + new Vector3(-pageWidth, -pageHeight / 2);
        ebl = transformPoint(globalebl);
        Vector3 globalst = PokerPanel.transform.position + new Vector3(0, pageHeight / 2);
        st = transformPoint(globalst);
        Vector3 globalmr = PokerPanel.transform.position + new Vector3(pageWidth, 0);
        mr = transformPoint(globalmr);
        Vector3 globalmm = PokerPanel.transform.position + new Vector3(0, 0);
        mm = transformPoint(globalmm);
        Vector3 globalml = PokerPanel.transform.position + new Vector3(-pageWidth, 0);
        ml = transformPoint(globalml);
        Vector3 globaltm = PokerPanel.transform.position + new Vector3(0, pageHeight / 2);
        tm = transformPoint(globaltm);
        Vector3 globalbm = PokerPanel.transform.position + new Vector3(0, -pageHeight / 2);
        bm = transformPoint(globalbm);
        //
        bottomLine = 260;
        rightLine = 300;//
        leftLine = 300;

        //Debug.LogError(">> bottomLine = " + bottomLine);

        float scaledPageWidth = pageWidth;
        float scaledPageHeight = pageHeight;

        TurnPageClip.rectTransform.sizeDelta = new Vector2(scaledPageWidth * 2, scaledPageHeight);
        Shadow.rectTransform.sizeDelta = new Vector2(scaledPageWidth * 2, scaledPageWidth * 2);
        NextPageClip.rectTransform.sizeDelta = new Vector2(scaledPageWidth * 2, scaledPageHeight);

        Left.rectTransform.pivot = new Vector2(0.5f, 0.5f);
        TurnPageClip.rectTransform.pivot = new Vector2(0.5f, 0.5f);
        NextPageClip.rectTransform.pivot = new Vector2(0.5f, 0.5f);
        RightNext.rectTransform.pivot = new Vector2(0.5f, 0.5f);
        Right.rectTransform.pivot = new Vector2(0.5f, 0.5f);
        Shadow.rectTransform.pivot = new Vector2(0.5f, 0.5f);

        TurnPageClip.transform.position = PokerPanel.transform.position;
        NextPageClip.transform.position = PokerPanel.transform.position;
        RightNext.transform.position = PokerPanel.transform.position;

        Right.transform.position = PokerPanel.transform.position;

        Shadow.transform.position = PokerPanel.transform.position;
    }


    public Vector3 transformPoint(Vector3 global)
    {
        return global;
    }

    public Vector3 GetInputMousePoint()
    {
        return ScreenToPosition(PokerPanel, Input.mousePosition, UICamera);
    }

    public void UpdatePoker()
    {
        //20240509新增鼠标移动过线就直接翻转
        Vector3 temp = GetInputMousePoint();
        //Debug.LogError(">> UpdatePoker > " + temp);
        //只处理下到上
        temp.Set(temp.x, temp.y + (temp.y - downPoint.y) * 2, temp.z);//下到上滑动速度提升2倍

        //Debug.LogError(">> UpdatePoker > " + temp + " , " + downPoint);

        //temp = temp + new Vector3(0, 30, 0);

        f = Vector3.Lerp(f, temp, Time.deltaTime * 10);

        if (mode == FlipMode.RightToLeft)
            UpdateBookRTLToPoint(f);
        else if (mode == FlipMode.LeftToRight)
            UpdateBookLTRToPoint(f);
        else
        {
            UpdateBookBTTToPoint(f);
        }

        if (FlipUpdateCallBack != null && FlipUpdateInterval != 0)
        {
            curTime = GetTime();
            if (FlipUpdateInterval == -1 || curTime - lastFlipUpdateTime > FlipUpdateInterval)
            {
                lastFlipUpdateTime = curTime;
                FlipUpdateCallBack.Invoke((int)mode, GetInputMousePoint());
            }
        }

        if (mode == FlipMode.RightToLeft)
        {
            if (downPoint.x - temp.x < rightLine)
            {
                Flip();
                return;
            }
        }
        else if (mode == FlipMode.LeftToRight)
        {
            if (temp.x - downPoint.x > leftLine)
            {
                Flip();
                return;
            }
        }
        else
        {

            if (temp.y > bottomLine)
            {
                Flip();
                return;
            }
        }

    }

    public void UpdateBookBTTToPoint(Vector3 followLocation)
    {
        mode = FlipMode.BottomToTop;
        f = followLocation;
        Shadow.transform.SetParent(TurnPageClip.transform, true);
        Shadow.transform.localPosition = new Vector3(0, 0, 0);
        Shadow.transform.localEulerAngles = new Vector3(0, 0, -90);
        float moveTopLineY = mm.y + (mr.x - tm.y);
        Shadow.transform.localPosition = new Vector3(0, moveTopLineY, 0);

        Right.transform.SetParent(TurnPageClip.transform, true);

        Right.gameObject.SetActive(true);
        Left.transform.SetParent(PokerPanel.transform, true);
        RightNext.transform.SetParent(PokerPanel.transform, true);
        c = f;
        //判断点是否超出屏幕
        if (c.y < bm.y)
        { //下边屏幕
            c.y = bm.y;
        }
        else
        {
            //上边屏幕
            if (c.y > tm.y * 3.0f)
            {
                c.y = tm.y * 3.0f;
            }
        }

        float ClippingPlaneY = mm.y + Mathf.Abs(bm.y - c.y) / 2.0f;
        TurnPageClip.transform.position = PokerPanel.TransformPoint(new Vector2(mm.x, ClippingPlaneY));

        float RightY = bm.y * 2.0f - (bm.y - c.y);

        Right.transform.position = PokerPanel.TransformPoint(new Vector2(mm.x, RightY));

        float nextPageClipY = bm.y * 2.0f - (bm.y - c.y) / 2.0f;
        NextPageClip.transform.position = PokerPanel.TransformPoint(new Vector2(mm.x, nextPageClipY));

        RightNext.transform.SetParent(NextPageClip.transform, true);
        Left.transform.SetParent(TurnPageClip.transform, true);
        Left.transform.SetAsFirstSibling();
        Shadow.rectTransform.SetParent(Right.rectTransform, true);
    }

    public void UpdateBookLTRToPoint(Vector3 followLocation)
    {
        mode = FlipMode.LeftToRight;
        f = followLocation;
        Shadow.transform.SetParent(TurnPageClip.transform, true);
        Shadow.transform.localPosition = new Vector3(0, 0, 0);
        Shadow.transform.localEulerAngles = new Vector3(0, 0, 180);

        Right.transform.SetParent(TurnPageClip.transform, true);
        Right.gameObject.SetActive(true);
        Left.transform.SetParent(PokerPanel.transform, true);
        RightNext.transform.SetParent(PokerPanel.transform, true);
        c = f;
        //判断点是否超出屏幕
        if (c.x < ml.x)
        { //左边屏幕
            c.x = ml.x;
        }
        else
        {
            //右边屏幕
            if (c.x > mr.x * 3.0f)
            {
                c.x = mr.x * 3.0f;
            }
        }

        float ClippingPlaneX = mm.x + Mathf.Abs(ml.x - c.x) / 2.0f;
        TurnPageClip.transform.position = PokerPanel.TransformPoint(new Vector2(ClippingPlaneX, ml.y));

        float RightX = ml.x * 2.0f - (ml.x - c.x);

        Right.transform.position = PokerPanel.TransformPoint(new Vector2(RightX, ml.y));

        float nextPageClipX = ml.x * 2.0f - (ml.x - c.x) / 2.0f;
        NextPageClip.transform.position = PokerPanel.TransformPoint(new Vector2(nextPageClipX, ml.y));

        RightNext.transform.SetParent(NextPageClip.transform, true);
        Left.transform.SetParent(TurnPageClip.transform, true);
        Left.transform.SetAsFirstSibling();
        Shadow.rectTransform.SetParent(Right.rectTransform, true);
    }

    public void UpdateBookRTLToPoint(Vector3 followLocation)
    {
        mode = FlipMode.RightToLeft;
        f = followLocation;
        Shadow.transform.SetParent(TurnPageClip.transform, true);
        Shadow.transform.localPosition = new Vector3(0, 0, 0);
        Shadow.transform.localEulerAngles = new Vector3(0, 0, 0);
        Right.transform.SetParent(TurnPageClip.transform, true);
        Right.gameObject.SetActive(true);
        Left.transform.SetParent(PokerPanel.transform, true);
        RightNext.transform.SetParent(PokerPanel.transform, true);
        c = f;

        //判断点是否超出屏幕
        if (c.x > 0 && c.x > mr.x)
        { //右边屏幕
            c.x = mr.x;
        }
        else
        {
            //左边界
            if (c.x < 0 && Mathf.Abs(c.x) > (3.0f * mr.x))
                c.x = -(3.0f * mr.x);
        }

        float ClippingPlaneX = mm.x - (mr.x - c.x) / 2.0f;
        TurnPageClip.transform.position = PokerPanel.TransformPoint(new Vector2(ClippingPlaneX, mr.y));

        float RightX = mr.x * 2.0f - (mr.x - c.x);
        Right.transform.position = PokerPanel.TransformPoint(new Vector2(RightX, mr.y));

        float nextPageClipX = mr.x * 2.0f - (mr.x - c.x) / 2.0f;
        NextPageClip.transform.position = PokerPanel.TransformPoint(new Vector2(nextPageClipX, mr.y));

        RightNext.transform.SetParent(NextPageClip.transform, true);
        Left.transform.SetParent(TurnPageClip.transform, true);
        Left.transform.SetAsFirstSibling();
        Shadow.rectTransform.SetParent(Right.rectTransform, true);
    }

    public void DragPageToPoint(Vector3 point)
    {
        pageDragging = true;
        f = point;
        downPoint = point;

        Left.gameObject.SetActive(true);
        Left.transform.position = RightNext.transform.position;

        Left.sprite = pokerBack;
        Left.transform.SetAsFirstSibling();

        Right.transform.position = RightNext.transform.position;
        Right.sprite = pokerFront;
        RightNext.sprite = background;

        if (enableShadowEffect) Shadow.gameObject.SetActive(true);
    }

    /// <summary>
    /// 强行切换当前翻牌模式，以及翻牌进度
    /// </summary>
    /// <param name="flipMode"></param>
    /// <param name="posX"></param>
    /// <param name="posY"></param>
    public void SetMousePosByNetCalled(int flipMode, float posX, float posY)
    {
        if (flipMode < 0)
        {
            ReleasePage();
        }
        else
        {
            switch (flipMode)
            {
                case (int)FlipMode.BottomToTop:
                    mode = FlipMode.BottomToTop;
                    break;
                case (int)FlipMode.LeftToRight:
                    mode = FlipMode.LeftToRight;
                    break;
                case (int)FlipMode.RightToLeft:
                    mode = FlipMode.RightToLeft;
                    break;
            }
            Vector3 pos = new Vector3(posX, posY, 0);
            DragPageToPoint(transformPoint(pos));
        }
    }

    //点击右边的热点
    public void OnMouseDragRightPage()
    {
        if (interactable)
        {
            mode = FlipMode.RightToLeft;
            DragPageToPoint(GetInputMousePoint());

            if (FlipStartCallBack != null)
            {
                FlipStartCallBack.Invoke((int)mode, GetInputMousePoint());
            }
        }
    }
    //点击左边的热点
    public void OnMouseDragLeftPage()
    {
        if (interactable)
        {
            mode = FlipMode.LeftToRight;
            DragPageToPoint(GetInputMousePoint());

            if (FlipStartCallBack != null)
            {
                FlipStartCallBack.Invoke((int)mode, GetInputMousePoint());
            }
        }
    }
    //点击下方的热点
    public void OnMouseDragBottomPage()
    {
        if (interactable)
        {
            mode = FlipMode.BottomToTop;
            DragPageToPoint(GetInputMousePoint());

            if (FlipStartCallBack != null)
            {
                FlipStartCallBack.Invoke((int)mode, GetInputMousePoint());
            }
        }
    }

    /// <summary>
    /// 鼠标释放（鼠标放开了）
    /// </summary>
    public void OnMouseRelease()
    {
        if (interactable)
            ReleasePage();

        if (FlipEndCallBack != null)
        {
            FlipEndCallBack.Invoke((int)mode, GetInputMousePoint());
        }
    }

    public void ReleasePage()
    {
        if (pageDragging)
        {
            pageDragging = false;
            float distanceToLeft = Vector2.Distance(c, ebl);
            float distanceToRight = Vector2.Distance(c, ebr) * 1.5f;
            float distanceToTop = Vector2.Distance(c, tm) * 1.2f;
            float distanceToBottom = Vector2.Distance(c, bm);

            if (distanceToRight <= (distanceToLeft / 2) && mode == FlipMode.RightToLeft)
                TweenBack(ebr);
            else if (distanceToRight / 2 > distanceToLeft  && mode == FlipMode.LeftToRight)
                TweenBack(ebl);
            else if (distanceToTop / 2 > distanceToBottom && mode == FlipMode.BottomToTop)
                TweenBack(bm);
            else
                TweenForward();
        }
    }

    Coroutine currentCoroutine;
    public void TweenForward()
    {
        if (mode == FlipMode.RightToLeft)
        {
            currentCoroutine = StartCoroutine(TweenTo(ebl, 0.15f, Flip));
        }
        else if (mode == FlipMode.LeftToRight)
        {
            currentCoroutine = StartCoroutine(TweenTo(ebr, 0.15f, Flip));
        }
        else
        {
            currentCoroutine = StartCoroutine(TweenTo(tm, 0.15f, Flip));
        }
    }

    void Flip()
    {
        Left.transform.SetParent(PokerPanel.transform, true);
        Left.gameObject.SetActive(false);
        Right.gameObject.SetActive(false);
        Right.transform.SetParent(PokerPanel.transform, true);
        RightNext.transform.SetParent(PokerPanel.transform, true);
        RightNext.sprite = pokerFront;
        Shadow.gameObject.SetActive(false);
        if (pokerPoint != null)
        {
            RightNextRpointImg.sprite = pokerPoint;
            RightNextLpointImg.sprite = pokerPoint;

            if (showPointOnFilping)
            {
                RightNextRpointImg.color = Color.white;
                RightNextLpointImg.color = Color.white;
            }
            else
            {   
                //动画出点数
                //if (RightNextRTweenAlpha != null)
                //{
                //    RightNextRTweenAlpha.ResetToBeginning();
                //    RightNextRTweenAlpha.PlayForward();
                //    //
                //    RightNextLTweenAlpha.ResetToBeginning();
                //    RightNextLTweenAlpha.PlayForward();
                //}
                //else 
                {
                    RightNextRpointImg.DOColor(Color.white, 1f);
                    RightNextLpointImg.DOColor(Color.white, 1f);
                }
            }
        }

        //搓牌完成后回调更新手牌动画
        if (EndFlipComplete != null)
        {
            EndFlipComplete.Invoke();
        }

        if (isAutoInteractable)
        {
            interactable = false;
        }
    }

    /// <summary>
    /// 重置Tween动画，即停止
    /// </summary>
    public void ResetPointTweenAlpha() 
    {
        //if(RightNextRTweenAlpha != null)
        //{
        //    RightNextRTweenAlpha.enabled = false;
        //    RightNextLTweenAlpha.enabled = false;
        //}
    }

    public void TweenBack(Vector3 toLocation)
    {
        if (!gameObject.activeSelf)
        {
            return;
        }
        currentCoroutine = StartCoroutine(TweenTo(toLocation, 0.15f, () =>
        {
            RightNext.sprite = pokerBack;
            RightNextRpointImg.color = new Color(1, 1, 1, 0);
            RightNextLpointImg.color = new Color(1, 1, 1, 0);
            this.ResetPointTweenAlpha();

            RightNext.transform.SetParent(PokerPanel.transform);
            Right.transform.SetParent(PokerPanel.transform);

            Left.gameObject.SetActive(false);
            Right.gameObject.SetActive(false);
            pageDragging = false;
        }
        ));
    }

    public IEnumerator TweenTo(Vector3 to, float duration, Action onFinish)
    {
        int steps = (int)(duration / 0.025f);
        Vector3 displacement = (to - f) / steps;
        for (int i = 0; i < steps - 1; i++)
        {
            if (mode == FlipMode.RightToLeft)
            {
                UpdateBookRTLToPoint(f + displacement);
            }
            else if (mode == FlipMode.LeftToRight)
            {
                UpdateBookLTRToPoint(f + displacement);
            }
            else
            {
                UpdateBookBTTToPoint(f + displacement);
            }
            yield return new WaitForSeconds(0.025f);
        }
        if (onFinish != null)
        {
            onFinish.Invoke();
        }
    }

    public void CleanRubPoker()
    {
        RightNext.sprite = pokerBack;
        RightNextRpointImg.color = new Color(1, 1, 1, 0);
        RightNextLpointImg.color = new Color(1, 1, 1, 0);
        ResetPointTweenAlpha();

        RightNext.transform.SetParent(PokerPanel.transform);
        Right.transform.SetParent(PokerPanel.transform);

        Left.gameObject.SetActive(false);
        Right.gameObject.SetActive(false);
        pageDragging = false;
    }

    public void SetPoker(Sprite pBack, Sprite pFront, Sprite point, Action funs)
    {
        EndFlipComplete = funs;
        interactable = true;

        RightNextRpointImg.color = new Color(1, 1, 1, 0);
        RightNextLpointImg.color = new Color(1, 1, 1, 0);
        ResetPointTweenAlpha();
        pokerBack = pBack;
        pokerFront = pFront;
        if (point != null)
        {
            pokerPoint = point;
        }
        Init();
    }

    private void OnDisable()
    {
        CleanRubPoker();
    }

    private double GetTime()
    {
        TimeSpan ts = new TimeSpan(DateTime.UtcNow.Ticks - new DateTime(1970, 1, 1, 0, 0, 0).Ticks);
        return (long)ts.TotalMilliseconds;
    }

    public Vector2 ScreenToPosition(RectTransform rectTransform, Vector2 screenPoint, Camera camera)
    {
        Vector2 position = Vector2.zero;
        if (rectTransform != null)
        {
            RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTransform, screenPoint, camera, out position);
        }
        return position;
    }
}

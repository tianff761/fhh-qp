using System;
using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class PokerFlipCard : MonoBehaviour
{
    public XEventTriggerListener xListener;
    public RectTransform fg;
    public RectTransform bg;
    public RectTransform mask;
    public Image showImage;
    public float backSpeed = 500f;
    //public RectTransform start;
    //public RectTransform m1;


    private bool hasBeginDrag = false;
    private bool isBackPlaying = false;

    private float w;
    private float h;

    private Vector2 cardPos;
    private float x1, x2, y1, y2;
    private POS curPos;
    private Vector2 orignPos;
    private Vector2 startPos;
    private float showDis = 0f;
    private float showDisScale = 1f;

    private RawImage backImage;
    private RawImage foreImage;
    private Action onComplete;
    private Camera uiCamera;

    void Start()
    {
        xListener.onBeginDragHandler.AddListener(OnBeginDrag);
        xListener.onDragHandler.AddListener(OnDrag);
        xListener.onEndDragHandler.AddListener(OnEndDrag);

        w = bg.sizeDelta.x;
        h = bg.sizeDelta.y;
        cardPos = bg.localPosition;
        //Debug.LogError("牌位置" + cardPos);
        x1 = cardPos.x - w / 3;
        x2 = cardPos.x + w / 3;
        y1 = cardPos.y - h / 3;
        y2 = cardPos.y + h / 3;

        backImage = this.bg.GetComponent<RawImage>();
        foreImage = this.fg.GetComponent<RawImage>();
        //Debug.LogError(x1 + "_"+x2+"_" + y1 +"_"+ y2);
    }
    private void OnDisable()
    {
        this.Reset();
    }

    public void SetPoker(Sprite pBack, Sprite pFront, Action funs)
    {
        if (backImage == null)
            backImage = this.bg.GetComponent<RawImage>();
        if (foreImage == null)
            foreImage = this.fg.GetComponent<RawImage>();
        backImage.texture = pBack.texture;
        foreImage.texture = pFront.texture;
        showImage.sprite = pFront;
        this.onComplete = funs;

        this.mask.gameObject.SetActive(true);
        this.showImage.gameObject.SetActive(false);
    }
    public void SetBackSpeed(float speed)
    {
        speed = Mathf.Min(speed, 1);
        this.backSpeed = speed;
    }
    public void SetShowDisScale(float scale)
    {
        scale = Mathf.Min(0, scale);
        this.showDisScale = scale;
    }
    public void Init(Camera camera)
    {
        this.uiCamera = camera;
    }
    private void OnBeginDrag(PointerEventData evenData)
    {
        if (isBackPlaying == false)
        {
            Vector2 position = Vector2.zero;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(bg, evenData.pressPosition, this.uiCamera, out position);
            curPos = POS.CENTER;
            if (position.x < x1 && position.y < y1)
                curPos = POS.LEFT_BOTTOM;
            else if (position.x < x1 && position.y > y2)
                curPos = POS.LEFT_TOP;
            else if (position.x < x1 && position.y > y1 && position.y < y2)
                curPos = POS.LEFT;
            else if (position.x > x1 && position.x < x2 && position.y > y2)
                curPos = POS.TOP;
            else if (position.x > x1 && position.x < x2 && position.y < y1)
                curPos = POS.BOTTOM;
            else if (position.x > x2 && position.y < y1)
                curPos = POS.RIGHT_BOTTOM;
            else if (position.x > x2 && position.y > y1 && position.y < y2)
                curPos = POS.RIGHT;
            else if (position.x > x2 && position.y > y2)
                curPos = POS.RIGHT_TOP;

            float c = Mathf.Sqrt(Mathf.Pow(w, 2) + Mathf.Pow(h, 2));

            switch (curPos)
            {
                case POS.TOP:
                    orignPos.Set(0, -1);
                    startPos.Set(cardPos.x, cardPos.y + h / 2);
                    showDis = h;
                    break;
                case POS.RIGHT_TOP:
                    orignPos.Set(-1, 0);
                    startPos.Set(cardPos.x + w / 2, cardPos.y + h / 2);
                    showDis = c;
                    break;
                case POS.RIGHT:
                    orignPos.Set(-1, 0);
                    startPos.Set(cardPos.x + w / 2, cardPos.y);
                    showDis = w;
                    break;
                case POS.RIGHT_BOTTOM:
                    orignPos.Set(-1, 0);
                    startPos.Set(cardPos.x + w / 2, cardPos.y - h / 2);
                    showDis = c;
                    break;
                case POS.BOTTOM:
                    orignPos.Set(0, 1);
                    startPos.Set(cardPos.x, cardPos.y - h / 2);
                    showDis = h;
                    break;
                case POS.LEFT_BOTTOM:
                    orignPos.Set(1, 0);
                    startPos.Set(cardPos.x - w / 2, cardPos.y - h / 2);
                    showDis = c;
                    break;
                case POS.LEFT:
                    orignPos.Set(1, 0);
                    startPos.Set(cardPos.x - w / 2, cardPos.y);
                    showDis = w;
                    break;
                case POS.LEFT_TOP:
                    orignPos.Set(1, 0);
                    startPos.Set(cardPos.x - w / 2, cardPos.y + h / 2);
                    showDis = c;
                    break;
            }
            //Debug.LogError("当前点击区域:" + curPos);
            //Debug.LogError("起始计算位置:" + startPos);
            //start.localPosition = startPos;
            //Debug.LogError("显示距离" + showDis);
            if (curPos != POS.CENTER)
            {
                //Debug.LogError("开始拖拽" + startPos);
                hasBeginDrag = true;
            }
            else
                hasBeginDrag = false;
        }
    }
    private void OnDrag(PointerEventData evenData)
    {
        if (hasBeginDrag)
        {
            Vector2 pp;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(bg, evenData.position, this.uiCamera, out pp);
            pp = LimitPosition(pp);
            Calc(pp);
        }
    }
    private void OnEndDrag(PointerEventData evenData)
    {
        if (hasBeginDrag)
        {
            hasBeginDrag = false;
            Vector2 position = Vector2.zero;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(bg, evenData.position, this.uiCamera, out position);
            position = LimitPosition(position);
            float moveDis = Vector2.Distance(startPos, position);
            //Debug.LogError("移动距离" + moveDis);
            if (moveDis > showDis * showDisScale)
            {
                Calc(startPos);
                this.mask.gameObject.SetActive(false);
                this.showImage.gameObject.SetActive(true);
                if (this.onComplete != null)
                {
                    this.onComplete();
                }
            }
            else
            {
                StartCoroutine(BackPlaying(position));
            }
            //Debug.LogError("结束拖拽:" + position);
        }
    }
    private IEnumerator BackPlaying(Vector2 position)
    {
        float moveDis = Vector2.Distance(position, startPos) * 0.5f;
        if (moveDis < float.Epsilon)
        {
            Calc(position);
            yield break;
        }

        isBackPlaying = true;
        float countTime = moveDis / backSpeed;
        float curTime = 0;
        while (true)
        {
            yield return 0;
            curTime += Time.deltaTime;
            if (curTime > countTime) curTime = countTime;
            Vector2 newPos = Vector2.Lerp(startPos, position, 1 - curTime / countTime);
            Calc(newPos);
            if (curTime >= countTime)
            {
                isBackPlaying = false;
                break;
            }
        }
        isBackPlaying = false;
    }
    private void Calc(Vector2 targetPos)
    {
        fg.SetParent(this.transform);
        bg.SetParent(this.transform);
        fg.localEulerAngles = Vector3.zero;
        mask.localEulerAngles = Vector3.zero;
        Vector2 moveDir = (targetPos - startPos).normalized;
        //Debug.LogError("移动方向" + moveDir);
        fg.localPosition = targetPos;
        mask.localPosition = startPos + (targetPos - startPos) / 2;
        //m1.localPosition = mask.localPosition;
        float angle = Vector2.Angle(orignPos, moveDir);
        //Debug.LogError("移动角度" + angle);
        float finalAngle = 0;
        float fixedX = 0;
        float flxedY = 0;
        switch (curPos)
        {
            case POS.TOP:
                fg.pivot = new Vector2(0.5f, 0);
                mask.pivot = new Vector2(0.5f, 1);

                fg.localEulerAngles = Vector3.zero;
                mask.localEulerAngles = Vector3.zero;
                fg.localPosition = new Vector2(0, fg.localPosition.y);
                mask.localPosition = new Vector2(fixedX, mask.localPosition.y);
                //m1.localPosition = mask.localPosition;
                break;
            case POS.RIGHT_TOP:
                fg.pivot = new Vector2(1, 0);
                mask.pivot = new Vector2(1, 0.5f);

                finalAngle = 2 * (90 - angle);
                fg.localEulerAngles = new Vector3(0, 0, -finalAngle);
                mask.localEulerAngles = new Vector3(0, 0, angle);
                break;
            case POS.RIGHT:
                fg.pivot = new Vector2(0, 0.5f);
                mask.pivot = new Vector2(1, 0.5f);

                fg.localPosition = new Vector2(fg.localPosition.x, flxedY);
                mask.localPosition = new Vector2(mask.localPosition.x, flxedY);
                //m1.localPosition = mask.localPosition;
                break;
            case POS.RIGHT_BOTTOM:
                fg.pivot = new Vector2(1, 1);
                mask.pivot = new Vector2(1, 0.5f);

                finalAngle = 2 * (90 - angle);
                fg.localEulerAngles = new Vector3(0, 0, finalAngle);
                mask.localEulerAngles = new Vector3(0, 0, -angle);
                break;
            case POS.BOTTOM:
                fg.pivot = new Vector2(0.5f, 1);
                mask.pivot = new Vector2(0.5f, 0);

                fg.localEulerAngles = Vector3.zero;
                mask.localEulerAngles = Vector3.zero;
                fg.localPosition = new Vector2(0, fg.localPosition.y);

                mask.localPosition = new Vector2(fixedX, mask.localPosition.y);
                //m1.localPosition = mask.localPosition;
                break;
            case POS.LEFT_BOTTOM:
                fg.pivot = new Vector2(0, 1);
                mask.pivot = new Vector2(0, 0.5f);

                finalAngle = 2 * (90 - angle);
                fg.localEulerAngles = new Vector3(0, 0, -finalAngle);
                mask.localEulerAngles = new Vector3(0, 0, angle);
                break;
            case POS.LEFT:
                fg.pivot = new Vector2(1, 0.5f);
                mask.pivot = new Vector2(0, 0.5f);

                fg.localPosition = new Vector2(fg.localPosition.x, flxedY);
                mask.localPosition = new Vector2(mask.localPosition.x, flxedY);
                //m1.localPosition = mask.localPosition;
                break;
            case POS.LEFT_TOP:
                fg.pivot = new Vector2(0, 0);
                mask.pivot = new Vector2(0, 0.5f);

                finalAngle = 2 * (90 - angle);
                fg.localEulerAngles = new Vector3(0, 0, finalAngle);
                mask.localEulerAngles = new Vector3(0, 0, -angle);
                break;
        }

        bg.SetParent(this.mask, true);
        fg.SetParent(this.mask, true);
    }

    private void Reset()
    {
        this.mask.pivot = new Vector2(0.5f, 0.5f);
        this.mask.localPosition = Vector3.zero;
        this.mask.localEulerAngles = Vector3.zero;
        this.bg.localPosition = Vector3.zero;
        this.bg.localEulerAngles = Vector3.zero;
        this.fg.pivot = new Vector2(0.5f, 0.5f);
        this.fg.localPosition = Vector3.zero;
        this.fg.localEulerAngles = Vector3.zero;
        this.fg.SetAsFirstSibling();

        this.mask.gameObject.SetActive(true);
        this.showImage.gameObject.SetActive(false);
        this.isBackPlaying = false;
        this.hasBeginDrag = false;
    }
    /// <summary>
    /// 限制位置
    /// </summary>
    /// <param name="position"></param>
    /// <returns></returns>
    private Vector2 LimitPosition(Vector2 position)
    {
        if (curPos == POS.LEFT_BOTTOM || curPos == POS.RIGHT_BOTTOM)
            position.Set(position.x, Mathf.Max(position.y, startPos.y));
        if (curPos == POS.LEFT_TOP || curPos == POS.RIGHT_TOP)
            position.Set(position.x, Mathf.Min(position.y, startPos.y));
        return position;
    }
}
public enum POS
{
    CENTER,
    TOP,
    RIGHT_TOP,
    RIGHT,
    RIGHT_BOTTOM,
    BOTTOM,
    LEFT_BOTTOM,
    LEFT,
    LEFT_TOP
}
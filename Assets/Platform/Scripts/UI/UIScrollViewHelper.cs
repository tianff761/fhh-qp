using System;
using UnityEngine;
using UnityEngine.UI;
using LuaInterface;

/// <summary>
/// ScrollView辅助类
/// </summary>
public class UIScrollViewHelper : MonoBehaviour
{
    /// <summary>
    /// Content坐标改变，C#回调
    /// </summary>
    public Action<int, int> onContentPositionChanged = null;
    /// <summary>
    /// 行列数
    /// </summary>
    public Vector2 cellSize = new Vector2(1, 1);
    /// <summary>
    /// item的Prefab，用于使用便捷
    /// </summary>
    public GameObject itemPrefab = null;
    /// <summary>
    /// item的大小
    /// </summary>
    public Vector2 itemSize = new Vector2(100, 100);
    /// <summary>
    /// item的间隙
    /// </summary>
    public Vector2 itemGap = new Vector2(10, 10);

    /// <summary>
    /// UIScrollRect组件
    /// </summary>
    private ScrollRect mScrollRect = null;
    /// <summary>
    /// UIScrollRect组件的RectTransform
    /// </summary>
    private RectTransform mScrollTransform = null;
    /// <summary>
    /// Content的RectTransform
    /// </summary>
    private RectTransform mScrollRectContent = null;
    /// <summary>
    /// 用于存储上一次的坐标X
    /// </summary>
    private int mLastPositionX = 0;
    /// <summary>
    /// 用于存储上一次的坐标Y
    /// </summary>
    private int mLastPositionY = 0;
    /// <summary>
    /// 临时使用的变量
    /// </summary>
    private Vector2 mTempAnchoredPosition;
    /// <summary>
    /// LUA回调方法
    /// </summary>
    private LuaFunction mLuaFunction = null;
    /// <summary>
    /// 对象
    /// </summary>
    private LuaTable mLuaTable = null;


    void Start()
    {
        Init();
    }

    void OnEnable()
    {
        Init();
    }

    void Update()
    {
        mTempAnchoredPosition = mScrollRectContent.anchoredPosition;
        int x = (int)mTempAnchoredPosition.x;
        int y = (int)mTempAnchoredPosition.y;
        if(mLastPositionX != x || mLastPositionY != y)
        {
            mLastPositionX = x;
            mLastPositionY = y;
            this.ContentPositionChanged();
        }
    }

    //================================================================

    /// <summary>
    /// 初始化方法
    /// </summary>
    public void Init()
    {
        if(mScrollRectContent != null)
        {
            return;
        }
        mScrollRect = this.GetComponent<ScrollRect>();
        if(mScrollRect == null || mScrollRect.content == null)
        {
            Debug.LogWarning(">> UIScrollViewDisplay > not exist ScrollRect or Content.");
            this.enabled = false;
            return;
        }

        mScrollRectContent = mScrollRect.content;

        if(mScrollRect.horizontal && mScrollRect.vertical)
        {
            Debug.LogWarning(">> UIScrollViewDisplay > not support horizontal and vertical, only support one of them.");
            this.enabled = false;

            return;
        }

        mScrollTransform = this.GetComponent<RectTransform>();
    }

    /// <summary>
    /// 重置，即把Content的坐标设置为0,0
    /// </summary>
    public void Reset()
    {
        if(mScrollRectContent != null)
        {
            mScrollRectContent.anchoredPosition = new Vector2(0, 0);
        }
    }

    /// <summary>
    /// 获取滚动区域的大小
    /// </summary>
    public RectTransform GetScrollTransform()
    {
        return this.mScrollTransform;
    }

    /// <summary>
    /// 获取Content的RectTransform
    /// </summary>
    /// <returns></returns>
    public RectTransform GetContentRectTransform()
    {
        return this.mScrollRectContent;
    }

    /// <summary>
    /// 获取Content的坐标
    /// </summary>
    public Vector2 GetContentPosition()
    {
        if(mScrollRectContent == null)
        {
            return new Vector2(100, 100);
        }
        return mScrollRectContent.anchoredPosition;
    }

    /// <summary>
    /// 设置Content的大小
    /// </summary>
    public void SetContentSize(float width, float height)
    {
        if(mScrollRectContent != null)
        {
            mScrollRectContent.sizeDelta = new Vector2(width, height);
        }
    }

    /// <summary>
    /// 设置Content的宽度
    /// </summary>
    public void SetContentWidth(float width)
    {
        if(mScrollRectContent != null)
        {
            Vector2 v = mScrollRectContent.sizeDelta;
            mScrollRectContent.sizeDelta = new Vector2(width, v.y);
        }
    }

    /// <summary>
    /// 设置Content的高度
    /// </summary>
    public void SetContentHeight(float height)
    {
        if(mScrollRectContent != null)
        {
            Vector2 v = mScrollRectContent.sizeDelta;
            mScrollRectContent.sizeDelta = new Vector2(v.x, height);
        }
    }

    /// <summary>
    /// 设置X值
    /// </summary>
    public void SetContentX(float x)
    {
        if(mScrollRectContent != null)
        {
            Vector2 v = mScrollRectContent.anchoredPosition;
            mScrollRectContent.anchoredPosition = new Vector2(x, v.y);
        }
    }

    /// <summary>
    /// 设置Y值
    /// </summary>
    public void SetContentY(float y)
    {
        if(mScrollRectContent != null)
        {
            Vector2 v = mScrollRectContent.anchoredPosition;
            mScrollRectContent.anchoredPosition = new Vector2(v.x, y);
        }
    }

    /// <summary>
    /// 是否是竖的滚动
    /// </summary>
    public bool IsScrollVertical()
    {
        if(mScrollRect == null)
        {
            return false;
        }
        return mScrollRect.vertical;
    }

    /// <summary>
    /// 设置坐标改变了的LUA回调方法
    /// </summary>
    public void AddContentPositionChangedLuaFunction(LuaFunction luaFunction, LuaTable luaTable)
    {
        //if(this.mLuaFunction != null) { return; }
        this.mLuaFunction = luaFunction;
        this.mLuaTable = luaTable;
    }

    /// <summary>
    /// Content坐标改变回调
    /// </summary>
    private void ContentPositionChanged()
    {
        if(onContentPositionChanged != null)
        {
            onContentPositionChanged.Invoke(mLastPositionX, mLastPositionY);
        }

        if(this.mLuaFunction != null)
        {
            this.mLuaFunction.Call(this.mLuaTable, mLastPositionX, mLastPositionY);
        }
    }

    //================================================================

    /// <summary>
    /// 获取Item的父节点
    /// </summary>
    public Transform GetItemParentNode()
    {
        if(itemPrefab == null)
        {
            return null;
        }
        return itemPrefab.transform.parent;
    }

    /// <summary>
    /// 获取Item的UI坐标
    /// </summary>
    public Vector2 GetItemPosition()
    {
        if(itemPrefab == null)
        {
            return new Vector2(0, 0);
        }
        return itemPrefab.GetComponent<RectTransform>().anchoredPosition;
    }
}

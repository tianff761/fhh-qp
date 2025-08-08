using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public enum ScrollDirection
{
    Top,        //向上滑动
    Bottom,     //向下滑动
    Stoped      //停止
}
public class ScrollRectExtension : MonoBehaviour, IPointerDownHandler, IPointerUpHandler {
    [Header("只支持垂直滑动")]
    [Header("必须在Editor中初始化变量")]
    public ScrollRect scrollRect = null;

    [Header("自动滑动时，每帧小于停止速度时，停止滑动")]
    public float stopSpeedPerFre = 1;

    //默认以Content下第一个宽高为Cell的宽高
    [Header("")]
    [Header("不必初始化，自动获取变量")]
    [Header("从content节点的GridLayoutGroup自动获取")]
    public GridLayoutGroup grid = null;
  
    //默认获取GridLayoutGroup的值，如果没有，row为1，line为Content下childCount
    [Header("列自动计算")]
    public int row = 1;//列

    public ScrollDirection scrollDirection = ScrollDirection.Stoped;

    //更新Item   Transform:待更新的Item    int：更新Item对应的数据索引，从0开始
    public UnityAction<Transform, int> onUpdateItemAction = null;
    //获取下一页数据 int：下一页数据页码，从0开始
    public UnityAction<int> onGetNextPageDataAction = null;
    //获取上一页数据 int：上一页数据页码，从0开始
    public UnityAction<int> onGetLastPageDataAction = null;

    [Header("可视区域")]
    public RectTransform viewRect = null;

    //所有Item个数
    public int totalItemCount = 0;

    public bool isClickedDown = false;

    public int maxDataCount = 50;

    Vector3[] viewRectCorners = new Vector3[4];

    List<RectTransform> allItems = new List<RectTransform>();

    private void Awake()
    {
        if (this.scrollRect == null)
        {
            this.scrollRect = transform.GetComponent<ScrollRect>();
        }
        if (this.scrollRect == null)
        {
            LuaFramework.Util.LogWarning("没有添加ScrollRect组件");
            return;
        }
        if (this.scrollRect.content != null)
        {
            grid = this.scrollRect.content.GetComponent<GridLayoutGroup>();
			grid.constraint = GridLayoutGroup.Constraint.FixedColumnCount;
			this.row = grid.constraintCount;
			this.scrollRect.elasticity = 0.05f;
            this.scrollRect.horizontal = false;
            this.scrollRect.vertical = true;

            this.scrollRect.movementType = ScrollRect.MovementType.Clamped;

            this.viewRect = this.scrollRect.viewport.GetComponent<RectTransform>();

            totalItemCount = this.scrollRect.content.childCount;

            RectTransform rect = null;
            Vector2 pivot = new Vector2(0, 1);
            Vector2 anchorMax = new Vector2(0, 1);
            Vector2 anchorMin = new Vector2(0, 1);
            for (int i = 0; i < totalItemCount; i++)
            {
                rect = this.scrollRect.content.GetChild(i).GetComponent<RectTransform>();
                rect.pivot = pivot;
                rect.anchorMax = anchorMax;
                rect.anchorMin = anchorMin;
                allItems.Add(rect);
               
            }
        }

        this.scrollDirection = ScrollDirection.Stoped;

    }

    void Start()
    {
        grid.enabled = false;
    }

    public void InitItems()
    {
        for (int i = 0; i < this.totalItemCount; i++)
        {
            var item = this.scrollRect.content.GetChild(i).GetComponent<RectTransform>();
            this.UpdateItem(item, i, false);
            var pos = this.scrollRect.content.anchoredPosition;
            pos = new Vector2(pos.x, 0);
            this.scrollRect.content.anchoredPosition = pos;
        }
    }

    int UpdateItem(RectTransform item, int idx = -1, bool isSetSibling = true)
    {
        item.sizeDelta = grid.cellSize;
        if (idx == -1)
        {
            if (this.scrollDirection == ScrollDirection.Top)
            {
                idx = int.Parse(this.scrollRect.content.GetChild(this.totalItemCount - 1).gameObject.name) + 1;
            }
            else if (this.scrollDirection == ScrollDirection.Bottom)
            {
                idx = int.Parse(this.scrollRect.content.GetChild(0).gameObject.name) - 1;
            }
        }
       // Debug.Log("更新Item:" + item.name + "  " + this.scrollDirection + "  " + idx + "   " + this.maxDataCount);
       if(idx >= 0){
            if (isSetSibling)
            {
                if (this.scrollDirection == ScrollDirection.Top)
                {
                    item.SetAsLastSibling();
                }
                else if (this.scrollDirection == ScrollDirection.Bottom)
                {
                    item.SetAsFirstSibling();
                }
            }
            item.gameObject.name = idx.ToString();
            var x = idx % row;
            var y = idx / row * -1;
            item.anchoredPosition = new Vector2((grid.cellSize.x + grid.spacing.x) * x + grid.padding.left, (grid.cellSize.y + grid.spacing.y) * y - grid.padding.top);
            if (idx >= 0 && idx < this.maxDataCount){
                item.gameObject.SetActive(true);  
                if (this.onUpdateItemAction != null){
                    this.onUpdateItemAction(item, idx);
                }
                return idx;
            } else{
                item.gameObject.SetActive(false);  
            }
       }
        return -1;
    }

    //更新所有数据
    public void UpdateAllItems()
    {
        foreach (var item in allItems)
        {
            var idx = 0;
            if(int.TryParse(item.gameObject.name, out idx))
            {
                this.UpdateItem(item, idx, false);
            }
			
        }
    }

    void OnGetNextPageData(int page)
    {
        if (onGetNextPageDataAction != null)
        {
            onGetNextPageDataAction(page);
        }
    }

    void OnGetLastPageData(int page)
    {
        if (onGetLastPageDataAction != null)
        {
            onGetLastPageDataAction(page);
        }
    }

    //由于只支持上下滑动，所有只判断y值即可判断item是否在可视区域
    bool IsItemInViewRect(RectTransform item)
    {
        this.viewRect.GetWorldCorners(this.viewRectCorners);
        Vector3[] itemCorners = new Vector3[4];
        item.GetWorldCorners(itemCorners);
        for (int i = 0; i < 4; i++)
        {
            if (this.IsViewRectContainPoint(itemCorners[i]))
            {
                return true;
            }
        }
        return false;
    }
    //只是上下滚动，所以只判断y值
    bool IsViewRectContainPoint(Vector3 v3)
    {
        bool isContain = false;
        if (v3.y >= this.viewRectCorners[0].y && v3.y <= this.viewRectCorners[2].y)
        {
            isContain = true;
        }
        else
        {
            isContain = false;
        }
        return isContain;
    }

    public void SetMaxDataCount(int count)
    {
        Debug.Log(">> SetMaxDataCount > 设置总数据条数：" + count);
        this.maxDataCount = count;
        var line = Mathf.CeilToInt(count * 1.0f / this.row);
        var size = this.scrollRect.content.sizeDelta;
        this.scrollRect.content.sizeDelta = new Vector2(size.x, line * (this.grid.cellSize.y + this.grid.spacing.y) + this.grid.padding.top);
    }

    float lastY = -99999999;
    float minus = 0;
    RectTransform tempItem = null;
    void Update()
    {
        if (this.scrollRect == null) return;
        var v2 = this.scrollRect.content.anchoredPosition;
        if (lastY < -1000000)
        {
            lastY = v2.y;
            this.scrollDirection = ScrollDirection.Stoped;
            return;
        }

        if (isClickedDown == false && Mathf.Abs(lastY - v2.y) < stopSpeedPerFre)
        {
            this.scrollRect.StopMovement();
            return;
        }
        if (lastY > -1000000)
        {
            if (lastY < v2.y)
            {
                this.scrollDirection = ScrollDirection.Top;
                if (Mathf.Abs(lastY - v2.y) > 0.005)
                {
                    this.OnMoveToTop();
                }
            }
            else
            {
                this.scrollDirection = ScrollDirection.Bottom;
                if (Mathf.Abs(lastY - v2.y) > 0.0001)
                {
                    this.OnMoveToBottom();
                }
            }
            lastY = v2.y;
        }
        else
        {
           
        }
    }
    //待更新的所有Items
    List<RectTransform> updateItems = new List<RectTransform>();
    void OnMoveToTop()
    {
        updateItems.Clear();
        for (int i = 0; i < this.totalItemCount; i++)
        {
            tempItem = this.scrollRect.content.GetChild(i).GetComponent<RectTransform>();
            if (!this.IsItemInViewRect(tempItem))
            {
                updateItems.Add(tempItem);
            }
            else
            {
                break;
            }
        }

        var updateIdx = -1;
        for (int i = 0; i < updateItems.Count; i++)
        {
            tempItem = updateItems[i];
            updateIdx = this.UpdateItem(tempItem);
            if (updateIdx >= 0)
            {
                int idx = 0;
                for (int j = 0; j < 1000; j++)
                {
                    idx = this.totalItemCount * j;
                    if (idx > this.maxDataCount)
                    {
                        break;
                    }
                    if (updateIdx == idx)
                    {
                        //Debug.Log("获取下一页数据：" + updateIdx / this.totalItemCount + "   updateIdx:" + updateIdx + "  maxDataCount:" + this.maxDataCount);
                        this.OnGetNextPageData(updateIdx / this.totalItemCount);
                        break;
                    }
                }
            }
        }
    }

    void OnMoveToBottom()
    {
        updateItems.Clear();
        for (int i = this.totalItemCount - 1; i >= 0; i--)
        {
            tempItem = this.scrollRect.content.GetChild(i).GetComponent<RectTransform>();
            if (!this.IsItemInViewRect(tempItem))
            {
                //先缓存再更新：更新里面有设置tempItem的sibling值，这会导致上面GetChild不准确
                updateItems.Add(tempItem);
            }
            else
            {
                break;
            }
        }

        var updateIdx = -1;
        for (int i = 0; i < updateItems.Count; i++)
        {
            tempItem = updateItems[i];
            updateIdx = this.UpdateItem(tempItem);
            if (updateIdx >= 0)
            {
                int idx = 0;
                for (int j = 0; j < 1000; j++)
                {
                    idx = j * this.totalItemCount;
                    if (idx > this.maxDataCount)
                    {
                        break;
                    }
                    if (updateIdx == idx)
                    {
                        //Debug.Log("获取上一页数据：" + updateIdx / this.totalItemCount + "  updateIdx" + updateIdx);
                        this.OnGetLastPageData(updateIdx / this.totalItemCount);
                        break;
                    }
                }
            }
        }
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        grid.enabled = false;
        lastY = -99999999;
        this.isClickedDown = true;
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        lastY = -99999999;
        this.scrollDirection = ScrollDirection.Stoped;
        this.isClickedDown = false;
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;

public class ToggleList : MonoBehaviour {
    public ToggleItem[] toggleItems;
    public float moveTime = 0.2f;
    public float toggleInterval = 5;
    public RectTransform viewRect = null;
    Dictionary<ToggleItem, Vector2> originToggleItemY = new Dictionary<ToggleItem, Vector2>();
    Vector2 originPos = Vector2.zero;
    RectTransform rectTransform = null;
    float allTogglesHeight = 0;
    private void Awake()
    {
        Vector3[] corners = new Vector3[4];
        Vector2 v2Temp = new Vector2(0, 1);
        rectTransform = this.GetComponent<RectTransform>();
        rectTransform.pivot = v2Temp;
        rectTransform.anchorMin = v2Temp;
        rectTransform.anchorMax = v2Temp;
        originPos = rectTransform.anchoredPosition;
        var toggleGroup = this.GetComponent<ToggleGroup>();
        if (toggleGroup == null)
        {
            toggleGroup = this.gameObject.AddComponent<ToggleGroup>();
        }

        var len = toggleItems.Length;
        if (len > 0)
        {
            RectTransform rect = null;
            float amountHeight = 0;
            for (int i = 0; i < len; i++)
            {
                ToggleItem item = toggleItems[i];
                rect = item.GetComponent<RectTransform>();
                rect.pivot = v2Temp;
                rect.anchorMin = v2Temp;
                rect.anchorMax = v2Temp;
                rect.anchoredPosition = new Vector2(0, -i * toggleInterval - amountHeight);
                originToggleItemY.Add(item, rect.anchoredPosition);
                item.SetToggleList(this);
                allTogglesHeight += rect.sizeDelta.y;
                amountHeight += rect.sizeDelta.y;
            }
            allTogglesHeight += len * toggleInterval;
            for (int i = 0; i < len; i++)
            {
                ToggleItem item = toggleItems[i];
                Toggle toggle = item.GetComponent<Toggle>();
                if (toggle != null)
                {
                    toggle.group = toggleGroup;
                    toggle.onValueChanged.AddListener((bool isOn)=> {
                        this.OnClickToggle(item, isOn, false);
                    });
                    this.OnClickToggle(item, toggle.isOn, true);
                }
                else
                {
                    LuaFramework.Util.LogWarning("toggleItem对象没有Toggle组件");
                }
            }
        }
        else
        {
            LuaFramework.Util.LogWarning("ToggleList对象没有对toggleItems赋值");
        }
    }

    int lastIsOnIdx = -1;
    private void OnClickToggle(ToggleItem isOntoggleItem, bool isOn, bool force)
    {
        //处理当前选中toggle移动
        if (isOn)
        {
            if (isOntoggleItem.isFold)
            {
                return;
            }
            var len = toggleItems.Length;
            var moveY = isOntoggleItem.GetFoldSizeY();
            int isOnIdx = 0;
            if (force)
            {
                for (int i = 0; i < len; i++)
                {
                    if (toggleItems[i] == isOntoggleItem)
                    {
                        isOnIdx = i;
                    }
                }

                //将点击Item下面的下移
                for (int i = 0; i < len; i++)
                {
                    if (i > isOnIdx)
                    {
                        toggleItems[i].GetComponent<RectTransform>().anchoredPosition = originToggleItemY[toggleItems[i]] - new Vector2(0, moveY);
                    }
                    else
                    {
                        toggleItems[i].GetComponent<RectTransform>().anchoredPosition = originToggleItemY[toggleItems[i]];
                    }
                }
            }
            else
            {
                var pos = Vector2.zero;
                for (int i = 0; i < len; i++)
                {
                    if (toggleItems[i] == isOntoggleItem)
                    {
                        isOnIdx = i;
                    }
                }
                float togglesHeight = 0;
                var listPos = this.GetComponent<RectTransform>().anchoredPosition + new Vector2(0, -moveY);
                RectTransform rectItem = null;
                //将点击Item下面的上移
                for (int i = 0; i < len; i++)
                {
                    rectItem = toggleItems[i].GetComponent<RectTransform>();
                    if (i > isOnIdx)
                    {
                        rectItem.DOAnchorPosY(originToggleItemY[toggleItems[i]].y - moveY, moveTime);
                    }
                    else
                    {
                        rectItem.DOAnchorPosY(originToggleItemY[toggleItems[i]].y, moveTime);
                        if (i < isOnIdx)
                        {
                            togglesHeight += (rectItem.sizeDelta.y + toggleInterval);
                        }
                    }
                }

                rectTransform.sizeDelta = new Vector2(rectTransform.sizeDelta.x, allTogglesHeight + moveY);
                if (lastIsOnIdx < isOnIdx)
                {
                    // if (isOntoggleItem.transform.position.y + moveY > viewRect.position.y)
                     if (rectTransform.anchoredPosition.y + moveY > isOntoggleItem.transform.GetComponent<RectTransform>().rect.height)
                    {
                        var y = originPos.y + togglesHeight;
                        if (rectTransform.sizeDelta.y - y < viewRect.rect.height)
                        {
                            y = rectTransform.sizeDelta.y - viewRect.rect.height;
                        }
                        rectTransform.anchoredPosition = new Vector2(originPos.x, y);
                    }
                }
            }
            lastIsOnIdx = isOnIdx;
        }

        //处理toggle下List选项的展开
        if (isOn)
        {
            isOntoggleItem.Fold(force);
        }
        else
        {
            isOntoggleItem.Unfold(true);
        }
    }
}

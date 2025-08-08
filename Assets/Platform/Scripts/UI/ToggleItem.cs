using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
public class ToggleItem : MonoBehaviour {
    public RectTransform[] listItems;
    public bool isFold = false;
    ToggleList list = null;

    private void Start()
    {
        var toggle = this.GetComponent<Toggle>();
        if (toggle != null)
        {
            isFold = toggle.isOn;
        }
    }


    public void SetToggleList(ToggleList toggleList)
    {
        this.list = toggleList;
    }

    //预测最后一个Item的全局Y值
    public float CalcuLastItemY()
    {
        float y = 0;
        for (int i = 0; i < listItems.Length; i++)
        {
            y += listItems[i].sizeDelta.y;
        }
        return transform.position.y - y;      
    }

    //展开
    public void Fold(bool forcePerform)
    {
        if (isFold == false || forcePerform)
        {
            int length = listItems.Length;
            float moveDownY = 0;
            for (int i = 0; i < length; i++)
            {
                UIUtil.SetActive(listItems[i], true);
                UIUtil.SetActive(listItems[i].parent, true);
                if (!forcePerform)
                {
                    moveDownY = 0;
                    for (int j = 0; j < i; j++)
                    {
                        moveDownY += listItems[j].sizeDelta.y;
                    }
                    listItems[i].DOAnchorPosY(-moveDownY, this.list.moveTime);
                    UIUtil.DOFade(listItems[i], 1, this.list.moveTime * i * 0.7f);
                }
                else
                {
                    listItems[i].anchoredPosition = listItems[i].anchoredPosition + new Vector2(0, moveDownY);
                }
               // Debug.Log("Fold移动Toggle" + listItems[i].gameObject.name + " " + moveDownY);
            }
            isFold = true;
        }

    }
    //折叠
    public void Unfold(bool forcePerform)
    {
        if (isFold == true || forcePerform)
        {
            int length = listItems.Length;
            float moveDownY = 0;
            for (int i = 0; i < length; i++)
            {
                if (!forcePerform)
                {
                    var idx = i;
                    moveDownY = listItems[0].anchoredPosition.y;
                    listItems[i].DOMoveY(moveDownY, 0.2f).OnComplete(delegate
                    {
                        UIUtil.SetActive(listItems[idx], false);
                    });
                    UIUtil.DOFade(listItems[i], 0, this.list.moveTime);
                }
                else
                {
                    listItems[i].anchoredPosition = listItems[0].anchoredPosition;
                    UIUtil.SetActive(listItems[i], false);
                }

               // Debug.Log("Unfold移动Toggle" + listItems[i].gameObject.name + " " + moveDownY );
            }
            isFold = false;
        }
    }

    public float GetFoldSizeY()
    {
        float sizeY = 0;
        int length = listItems.Length;
        for (int i = 0; i < length; i++)
        {
            sizeY += listItems[0].sizeDelta.y;
        }
        return sizeY;
    }
}

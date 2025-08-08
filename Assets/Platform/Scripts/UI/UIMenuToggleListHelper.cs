using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;

public class UIMenuToggleListHelper : MonoBehaviour
{
    public class ToggleItem
    {
        public Toggle toggles;
        public GameObject lists;
        public RectTransform items;
    }

    public List<GameObject> Toggles = new List<GameObject>();
    public string listName = "List";
    public float playSpeed = 0.3f;
    /// <summary>
    /// 是否初始化监听事件（用于方便lua调用时这边也执行的问题）
    /// </summary>
    public bool isAutoAddListener = true;

    public List<GameObject> Items = new List<GameObject>();

    public List<ToggleItem> toggleItems = new List<ToggleItem>();

    GameObject tempItem;
    GameObject item
    {
        get {
            if (tempItem == null)
            {
                tempItem = new GameObject("item", typeof(Image));
                tempItem.transform.SetParent(Toggles[0].transform.parent);
                tempItem.gameObject.SetActive(false);
                tempItem.AddComponent<RectTransform>();
                tempItem.GetComponent<RectTransform>().sizeDelta = new Vector2(0, 0);
                tempItem.transform.localScale = new Vector3(1, 0, 1);
                tempItem.GetComponent<Image>().color = new Color(1, 1, 1, 0);
            }
            return tempItem;
        }
    }

    private void Awake()
    {
        Init();
        if (isAutoAddListener)
        {
            AddListener();
        }
    }

    private void Init()
    {
        InitTogglesItem();
        toggleItems = new List<ToggleItem>();
        for (int i = 0; i < Toggles.Count; i++)
        {
            toggleItems.Add(new ToggleItem() { toggles = Toggles[i].GetComponent<Toggle>(), items = (RectTransform)Items[i].transform, lists = InitList(Toggles[i])});
        }
    }

    /// <summary>
    /// 初始化Toggles
    /// </summary>
    public void InitTogglesItem()
    {
        for (int i = 0; i < Toggles.Count; i++)
        {
            if (Items.Count - 1 < i)
            {
                Items.Add(CreateGo(Toggles[i], "temp" + i, Toggles[i].activeSelf));
            }
            Items[i].SetActive(Toggles[i].activeSelf);
        }
    }

    /// <summary>
    /// 刷新Toggles
    /// </summary>
    public void RefreshTogglesItem()
    {
        
        for (int i = 0; i < toggleItems.Count; i++)
        {
            toggleItems[i].items.gameObject.SetActive(toggleItems[i].toggles.gameObject.activeSelf);
        }
    }

    public void CheckIsOnToggle()
    {
        for (int i = 0; i < toggleItems.Count; i++)
        {
            if (toggleItems[i].toggles.isOn == true)
            {
                OnToggleChangeValue(true, toggleItems[i]);
            }
        }
    }

    GameObject InitList(GameObject tog)
    {
        GameObject go = tog.transform.Find(listName).gameObject;
        Vector2 v2 = go.GetComponent<RectTransform>().sizeDelta;
        go.GetComponent<RectTransform>().sizeDelta = new Vector2(v2.x, 0);
        go.transform.localScale = new Vector3(1, 0, 1);
        return go;
    }

    GameObject CreateGo(GameObject mGo, string name, bool isActive)
    {
        GameObject go = Instantiate(item, transform);
        int index = mGo.transform.GetSiblingIndex();
        go.transform.SetSiblingIndex(index + 1);
        go.name = name;
        go.SetActive(isActive);
        return go;
    }

    /// <summary>
    /// 添加事件
    /// </summary>
    public void AddListener()
    {
        for (int i = 0; i < toggleItems.Count; i++)
        {
            int j = i;
            toggleItems[j].toggles.onValueChanged.AddListener((bool isOn) => { OnToggleChangeValue(isOn, toggleItems[j]); });
        }
    }

    /// <summary>
    /// 移除所有事件
    /// </summary>
    public void RemoveListener()
    {
        for (int i = 0; i < toggleItems.Count; i++)
        {
            toggleItems[i].toggles.onValueChanged.RemoveAllListeners();
        }
    }

    public void OnToggleChangeValue(bool isOn, ToggleItem toggleItem)
    {
        toggleItem.items.DOKill();
        toggleItem.lists.transform.DOKill();
        if (isOn)
        {
            toggleItem.items.DOScaleY(1, playSpeed).SetEase(Ease.OutQuad);
            toggleItem.lists.transform.DOScaleY(1, playSpeed).SetEase(Ease.OutQuad);
            toggleItem.items.DOSizeDelta(new Vector2(0, GetHightByChilden(toggleItem.lists.gameObject)), playSpeed, false).SetEase(Ease.OutQuad);
        }
        else
        {
            toggleItem.items.DOScaleY(0, playSpeed).SetEase(Ease.OutQuad);
            toggleItem.lists.transform.DOScaleY(0, playSpeed).SetEase(Ease.OutQuad);
            toggleItem.items.DOSizeDelta(new Vector2(GetHightByChilden(toggleItem.lists.gameObject), 0), playSpeed, false).SetEase(Ease.OutQuad);
        }
    }

    public float GetHightByChilden(GameObject item)
    {
        float allY = 0;
        for (int i = 0; i < item.transform.childCount; i++)
        {
            RectTransform tran = (RectTransform)item.transform.GetChild(i);
            if (tran.gameObject.activeSelf)
            {
                allY += tran.sizeDelta.y;
            }
        }
        return allY;
    }
}

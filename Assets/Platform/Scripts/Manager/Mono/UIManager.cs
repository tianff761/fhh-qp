using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using LuaFramework;

public class UIManager : TMonoBehaviour<UIManager>
{

    /// <summary>
    /// 层级的数量
    /// </summary>
    private static int LayersTotal = 9;

    /// <summary>
    /// Root/Canvas
    /// </summary>
    private Transform rootCanvas = null;
    /// <summary>
    /// 层级
    /// </summary>
    private List<Transform> layers = new List<Transform>();

    /// <summary>
    /// 内部面板
    /// </summary>
    private Dictionary<string, GameObject> mInternalPanels = new Dictionary<string, GameObject>();


    /// <summary>
    /// 获取UI层，初始位置索引使用1作为起始位，设置6为loading，7为Wating，8为Toast，9为Alert
    /// </summary>
    public Transform GetUILayer(int layerIndex)
    {
        if (layers.Count < 1)
        {
            AddUILayerTo(LayersTotal);
        }

        if (layers.Count > 1)
        {
            if (layerIndex < 1)
            {
                layerIndex = 1;
            }
            else if (layerIndex >= layers.Count)
            {
                layerIndex = layers.Count - 1;
            }
            return layers[layerIndex];
        }
        return null;
    }

    /// <summary>
    /// 创建UI层级对象
    /// </summary>
    private Transform CreateUILayer(int index)
    {
        string name = "Layer" + index;
        Transform transform = rootCanvas.Find(name);
        if (transform == null)
        {
            GameObject layerGO = new GameObject(name);
            layerGO.transform.SetParent(rootCanvas);
            layerGO.transform.localPosition = Vector3.zero;
            layerGO.transform.localScale = Vector3.one;
            RectTransform rectTransform = layerGO.GetComponent<RectTransform>();
            if (rectTransform == null)
            {
                rectTransform = layerGO.AddComponent<RectTransform>();
            }
            rectTransform.anchorMin = Vector2.zero;
            rectTransform.anchorMax = Vector2.one;
            rectTransform.sizeDelta = Vector2.zero;
            rectTransform.offsetMin = Vector2.zero;
            rectTransform.offsetMax = Vector2.zero;
            rectTransform.SetAsLastSibling();

            return layerGO.transform;
        }
        else 
        {
            return transform;
        }
    }

    /// <summary>
    /// 新增UI层级数
    /// </summary>
    public void AddUILayerTo(int newLayersTotal)
    {
        if (rootCanvas == null)
        {
            GameObject go = GameObject.Find("UIRoot");
            Transform root = go.transform;
            rootCanvas = root.Find("Canvas");
            CanvasScaler canvasScaler = rootCanvas.GetComponent<CanvasScaler>();
            AppConst.ReferenceResolution = canvasScaler.referenceResolution;
        }

        if (layers.Count < 1)
        {
            layers.Add(null);//占位使用
        }

        if (newLayersTotal < layers.Count - 1)
        {
            return;
        }
        for (int i = layers.Count; i <= newLayersTotal; i++)
        {
            layers.Add(this.CreateUILayer(i));
        }
    }

    /// <summary>
    /// 同步打开内部面板
    /// </summary>
    public GameObject OpenInternalPanel(string name, int layerIndex)
    {
        GameObject go = CreateInternalPanel(name, layerIndex);
        if (go != null)
        {
            go.SetActive(true);
            go.transform.SetAsLastSibling();
        }
        return go;
    }

    /// <summary>
    /// 销毁内部面板
    /// </summary>
    public void DestroyInternalPanel(string name)
    {
        GameObject go = null;
        if (mInternalPanels.TryGetValue(name, out go))
        {
            mInternalPanels.Remove(name);
            if (go != null)
            {
                GameObject.Destroy(go);
            }
        }
    }

    /// <summary>
    /// 同步创建内部面板
    /// </summary>
    private GameObject CreateInternalPanel(string name, int layerIndex)
    {
        if (string.IsNullOrEmpty(name))
        {
            Debug.LogWarning(">> UIManager > CreateInternalPanel > name is NullOrEmpty.");
            return null;
        }
        GameObject go = null;
        if (mInternalPanels.TryGetValue(name, out go))
        {
            if (go == null)
            {
                mInternalPanels.Remove(name);
            }
        }

        if (go == null)
        {
            Object obj = Resources.Load("UI/" + name);
            if (obj != null)
            {
                go = Instantiate(obj) as GameObject;
                go.name = name;
                go.transform.SetParent(GetUILayer(layerIndex));
                go.transform.localPosition = Vector3.zero;
                go.transform.localScale = new Vector3(1, 1, 1);

                mInternalPanels.Add(name, go);

                RectTransform rectTransform = go.GetComponent<RectTransform>();
                if (rectTransform != null)
                {
                    rectTransform.anchorMin = Vector2.zero;
                    rectTransform.anchorMax = Vector2.one;
                    rectTransform.sizeDelta = Vector2.zero;
                    rectTransform.offsetMin = Vector2.zero;
                    rectTransform.offsetMax = Vector2.zero;
                }
            }
            else
            {
                Debug.LogWarning(">> UIManager > CreateInternalPanel > UI is null > " + name);
            }
        }
        return go;
    }
}

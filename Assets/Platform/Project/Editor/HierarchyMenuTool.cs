using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor;

public class HierarchyMenuTool
{
    private static void CreateCustomGameObject(string prefabName, string name)
    {
        GameObject selectedGameObject = Selection.activeObject as GameObject;

        if (selectedGameObject != null && selectedGameObject.activeInHierarchy)
        {
            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>("Assets/Platform/Project/Game/Base/Res/Template/" + prefabName + ".prefab");

            if (prefab != null)
            {
                GameObject go = GameObject.Instantiate(prefab);
                go.name = name;
                SetTransform(go, selectedGameObject.transform);
                Selection.activeObject = go;
            }
            else
            {
                Debug.LogError(">> Not Find > " + prefabName);
            }
        }
        else
        {
            Debug.LogError(">> Selected Null GameObject > " + prefabName);
        }
    }

    private static void SetTransform(GameObject go, Transform parent)
    {
        Vector3 position = Vector3.zero;
        Vector2 sizeDelta = Vector2.zero;
        Vector3 scale = Vector3.one;

        RectTransform rectTransform = go.GetComponent<RectTransform>();

        if (rectTransform != null)
        {
            position = rectTransform.anchoredPosition;
            sizeDelta = rectTransform.sizeDelta;
            scale = rectTransform.localScale;

            go.transform.SetParent(parent);

            rectTransform.anchoredPosition = position;
            rectTransform.sizeDelta = sizeDelta;
            rectTransform.localScale = scale;
        }
        else
        {
            position = go.transform.localPosition;
            scale = go.transform.localScale;

            go.transform.SetParent(parent);

            go.transform.localPosition = position;
            go.transform.localScale = scale;
        }
    }

    [MenuItem("GameObject/UI/Custom/Text - 方正准圆(24)", false, 1)]
    static void CreateUguiTextFZZY()
    {
        CreateCustomGameObject("TextFZZhunYuan", "Text");
    }

    [MenuItem("GameObject/UI/Custom/Text - 方正粗圆(30)", false, 2)]
    static void CreateUguiTextMsFZCY30()
    {
        CreateCustomGameObject("TextFZCuYuan30", "Text");
    }

    [MenuItem("GameObject/UI/Custom/Text - 方正粗圆(24)", false, 3)]
    static void CreateUguiTextMsFZCY24()
    {
        CreateCustomGameObject("TextFZCuYuan24", "Text");
    }

    [MenuItem("GameObject/UI/Custom/Text - 华文圆体", false, 4)]
    static void CreateUguiTextYuantiRegular()
    {
        CreateCustomGameObject("TextYuantiRegular", "Text");
    }

    [MenuItem("GameObject/UI/Custom/Text - 华文粗圆", false, 5)]
    static void CreateUguiTextYuantiBold()
    {
        CreateCustomGameObject("TextYuantiBold", "Text");
    }

    [MenuItem("GameObject/UI/Custom/修改文本字体为方正粗圆", false, 6)]
    static void ModifyCustomTextToFZCuYuan()
    {
        UIFontChecker.ReplaceFontToFZCuYuanAtHierarchy(false);
    }

    [MenuItem("GameObject/UI/Custom/修改文本字体为方正粗圆(包含子对象)", false, 7)]
    static void ModifyCustomTextToFZCuYuanInChildren()
    {
        UIFontChecker.ReplaceFontToFZCuYuanAtHierarchy(true);
    }

    [MenuItem("GameObject/UI/Custom/修改方正粗圆文本为正常样式", false, 8)]
    static void ModifyCustomTextStyleToNormal()
    {
        UIFontChecker.ReplaceFontStyleToNormalAtHierarchy(false);
    }

    [MenuItem("GameObject/UI/Custom/修改方正粗圆文本为正常样式(包含子对象)", false, 9)]
    static void ModifyCustomTextStyleToNormalInChildren()
    {
        UIFontChecker.ReplaceFontStyleToNormalAtHierarchy(true);
    }
}

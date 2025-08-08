using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.IO;

public class UIFontChecker
{
    private static Dictionary<string, Font> mFontDict = new Dictionary<string, Font>();

    /// <summary>
    /// 通过字体名称获取字体
    /// </summary>
    private static Font GetFontByName(string name)
    {
        Font font = null;
        if (!mFontDict.TryGetValue(name, out font))
        {
            font = AssetDatabase.LoadAssetAtPath<Font>("Assets/Platform/Fonts/" + name);
            if (font != null)
            {
                mFontDict.Add(name, font);
            }
        }
        return font;
    }


    private static Font FZCuYuan
    {
        get
        {
            return GetFontByName("FZCuYuan.TTF");
        }
    }


    private static Font FZZhunYuan
    {
        get
        {
            return GetFontByName("FZZhunYuan.TTF");
        }
    }

    private static Font YuantiRegular
    {
        get
        {
            return GetFontByName("YuantiRegular.ttf");
        }
    }

    private static Font YuantiBold
    {
        get
        {
            return GetFontByName("YuantiBold.ttf");
        }
    }

    private static Font ZhongKai
    {
        get
        {
            return GetFontByName("HYZhongKai.ttf");
        }
    }
    private static Font Msyh
    {
        get
        {
            return GetFontByName("Msyh.ttc");
        }
    }

    private static Font FangzhengBlack
    {
        get
        {
            return GetFontByName("FangzhengBlack.TTF");
        }
    }

    private static Font YaSong
    {
        get
        {
            return GetFontByName("YaSong.TTF");
        }
    }

    //========================================================================
    //========================================================================

    /// <summary>
    /// 获取节点路径
    /// </summary>
    public static string GetGameObjectPath(Transform transform)
    {
        string result = transform.name;
        if (transform.parent != null)
        {
            result = GetGameObjectPath(transform.parent) + "/" + result;
        }
        return result;
    }

    /// <summary>
    /// 打印红色日志输出
    /// </summary>
    public static void LogRedColor(string str)
    {
        Debug.Log("<color=#FF0000>" + str + "</color>");
    }
    /// <summary>
    /// 打印红色日志输出
    /// </summary>
    public static void LogRedColor(string str, UnityEngine.Object obj)
    {
        Debug.Log("<color=#FF0000>" + str + "</color>", obj);
    }

    /// <summary>
    /// 打印橙色日志输出
    /// </summary>
    public static void LogOrangeColor(string str)
    {
        Debug.Log("<color=#F07800>" + str + "</color>");
    }

    /// <summary>
    /// 打印橙色日志输出
    /// </summary>
    public static void LogOrangeColor(string str, UnityEngine.Object obj)
    {
        Debug.Log("<color=#F07800>" + str + "</color>", obj);
    }
    /// <summary>
    /// 打印绿色日志输出
    /// </summary>
    public static void LogGreenColor(string str)
    {
        Debug.Log("<color=#00FF00>" + str + "</color>");
    }

    /// <summary>
    /// 打印绿色日志输出
    /// </summary>
    public static void LogGreenColor(string str, UnityEngine.Object obj)
    {
        Debug.Log("<color=#00FF00>" + str + "</color>", obj);
    }

    //========================================================================
    //========================================================================

    /// <summary>
    /// 检测字体
    /// </summary>
    private static void CheckFont(string fontName)
    {
        string tempName = fontName;
        if (string.IsNullOrEmpty(tempName))
        {
            tempName = "Null";
        }
        Object[] gos = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        if (gos == null || gos.Length < 1)
        {
            return;
        }
        LogOrangeColor(string.Format("================检测{0}字体开始================", tempName));

        Text tempText = null;
        for (int i = 0; i < gos.Length; i++)
        {
            GameObject go = gos[i] as GameObject;
            if (go != null)
            {
                Debug.Log(">> ================检查：" + go.name, go);

                Text[] texts = go.GetComponentsInChildren<Text>(true);
                if (texts != null)
                {
                    for (int j = 0; j < texts.Length; j++)
                    {
                        tempText = texts[j];

                        if (fontName == null)
                        {
                            if (tempText.font == null)
                            {
                                Debug.LogWarning(">> Null Font : " + GetGameObjectPath(tempText.transform));
                            }
                        }
                        else
                        {
                            if (tempText.font != null && tempText.font.name == fontName)
                            {
                                Debug.LogWarning(">> " + fontName + " : " + GetGameObjectPath(tempText.transform));
                            }
                        }
                    }
                }
            }
        }
        LogGreenColor(string.Format("================检测{0}字体完成================", tempName));
    }

    //========================================================================

    /// <summary>
    /// 替换字体
    /// </summary>
    private static void ReplaceFont(string fontName, Font font)
    {
        if (font == null)
        {
            Debug.LogError(">> 字体为空！");
            return;
        }

        string tempName = fontName;
        if (string.IsNullOrEmpty(tempName))
        {
            tempName = "Null";
        }

        Object[] gos = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        if (gos == null || gos.Length < 1)
        {
            return;
        }
        LogOrangeColor(string.Format("================检测{0}字体为{1}字体开始================", tempName, font.name));
        bool isSaveAssets = false;

        Text tempText = null;
        bool isReplace = false;
        for (int i = 0; i < gos.Length; i++)
        {
            GameObject go = gos[i] as GameObject;
            if (go != null)
            {
                isReplace = false;
                Text[] texts = go.GetComponentsInChildren<Text>(true);
                if (texts != null && texts.Length > 0)
                {
                    Debug.Log(">> ================替换检测：" + go.name, go);

                    for (int j = 0; j < texts.Length; j++)
                    {
                        tempText = texts[j];
                        if (fontName == null)
                        {
                            if (tempText.font == null)
                            {
                                isReplace = true;
                                tempText.font = font;
                                LogRedColor(">> 1 : " + GetGameObjectPath(tempText.transform));
                            }
                        }
                        else
                        {
                            if (tempText.font != null && tempText.font.name == fontName)
                            {
                                isReplace = true;
                                tempText.font = font;
                                LogRedColor(">> 2 : " + GetGameObjectPath(tempText.transform));
                            }
                        }
                    }
                }
                if (isReplace)
                {
                    isSaveAssets = true;
                    EditorUtility.SetDirty(gos[i]);
                }
            }
        }
        LogGreenColor(string.Format("================检测{0}字体为{1}字体完成================", tempName, font.name));
        if (isSaveAssets)
        {
            AssetDatabase.SaveAssets();
        }
    }

    //========================================================================
    /// <summary>
    /// 设置字体大小
    /// </summary>
    private static void SetFontSize(string fontName, int fontSize)
    {
        if (string.IsNullOrEmpty(fontName))
        {
            return;
        }
        Object[] gos = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        if (gos == null || gos.Length < 1)
        {
            return;
        }
        LogOrangeColor(string.Format("================设置{0}字体大小为{1}开始================", fontName, fontSize));
        bool isSaveAssets = false;
        Text tempText = null;
        bool isReplace = false;
        for (int i = 0; i < gos.Length; i++)
        {
            GameObject go = gos[i] as GameObject;
            if (go != null)
            {
                Debug.Log(">> ================修改字体大小检测：" + go.name, go);

                isReplace = false;
                Text[] texts = go.GetComponentsInChildren<Text>(true);
                if (texts != null)
                {
                    for (int j = 0; j < texts.Length; j++)
                    {
                        tempText = texts[j];
                        if (tempText.font != null && tempText.font.name == fontName)
                        {
                            isReplace = true;
                            tempText.fontSize = fontSize;
                            LogRedColor(">> 修改 : " + GetGameObjectPath(tempText.transform));
                        }
                    }
                }
                if (isReplace)
                {
                    isSaveAssets = true;
                    EditorUtility.SetDirty(gos[i]);
                }
            }
        }
        LogGreenColor(string.Format("================设置{0}字体大小为{1}完成================", fontName, fontSize));
        if (isSaveAssets)
        {
            AssetDatabase.SaveAssets();
        }
    }

    //========================================================================

    /// <summary>
    /// 检测文本
    /// </summary>
    private static void CheckText(string txt)
    {
        if (string.IsNullOrEmpty(txt))
        {
            Debug.LogError(">> ========检测文本为空========");
            return;
        }
        Object[] gos = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        if (gos == null || gos.Length < 1)
        {
            return;
        }
        LogOrangeColor(string.Format("================检测文本“{0}”开始================", txt));
        Text tempText = null;
        for (int i = 0; i < gos.Length; i++)
        {
            GameObject go = gos[i] as GameObject;
            if (go != null)
            {
                Debug.Log(">> ================检测：" + go.name, go);

                Text[] texts = go.GetComponentsInChildren<Text>(true);
                if (texts != null)
                {
                    for (int j = 0; j < texts.Length; j++)
                    {
                        tempText = texts[j];

                        if (!string.IsNullOrEmpty(tempText.text))
                        {
                            if (tempText.text.ToLower().Contains(txt))
                            {
                                Debug.LogWarning(">> 检测到文本路径 : " + GetGameObjectPath(tempText.transform));
                            }
                        }
                    }
                }
            }
        }
        LogGreenColor(string.Format("================检测文本“{0}”完成================", txt));
    }


    /// <summary>
    /// 替换文本
    /// </summary>
    private static void ReplaceText(string txt, string newStr)
    {
        if (string.IsNullOrEmpty(txt))
        {
            Debug.LogError(">> ========检测替换文本为空========");
            return;
        }
        Object[] gos = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        if (gos == null || gos.Length < 1)
        {
            return;
        }
        LogOrangeColor(string.Format("================检测替换文本“{0}”开始================", txt));
        Text tempText = null;
        bool isSaveAssets = false;
        bool isReplace = false;
        for (int i = 0; i < gos.Length; i++)
        {
            GameObject go = gos[i] as GameObject;
            if (go != null)
            {
                Debug.Log(">> ================检测替换：" + go.name, go);
                isReplace = false;
                Text[] texts = go.GetComponentsInChildren<Text>(true);
                if (texts != null)
                {
                    for (int j = 0; j < texts.Length; j++)
                    {
                        tempText = texts[j];

                        if (!string.IsNullOrEmpty(tempText.text))
                        {
                            if (tempText.text.ToLower().Contains(txt))
                            {
                                tempText.text = tempText.text.Replace(txt, newStr);
                                isReplace = true;
                                Debug.LogWarning(">> 检测替换到文本路径 : " + GetGameObjectPath(tempText.transform), go);
                            }
                        }
                    }
                }
                if (isReplace)
                {
                    isSaveAssets = true;
                    EditorUtility.SetDirty(go);
                }
            }
        }
        LogGreenColor(string.Format("================检测替换文本“{0}”完成================", txt));
        if (isSaveAssets)
        {
            AssetDatabase.SaveAssets();
        }
    }


    //========================================================================
    /// <summary>
    /// 替换描边
    /// </summary>
    [MenuItem("GameObject/UIFont/把Outline替换为自定义EX描边")]
    private static void ReplaceOutline()
    {
        bool isSaveAssets = false;
        Object[] gos = new GameObject[] { Selection.activeObject as GameObject };//  .GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        if (gos == null || gos.Length < 1)
        {
            return;
        }
        LogOrangeColor("================替换描边组件开始================");

        Outline temp = null;
        bool isReplace = false;
        GameObject tempGo = null;
        for (int i = 0; i < gos.Length; i++)
        {
            GameObject go = gos[i] as GameObject;
            if (go != null)
            {
                Debug.Log(">> ================检测：" + go.name, go);

                isReplace = false;
                Outline[] temps = go.GetComponentsInChildren<Outline>(true);
                if (temps != null)
                {
                    for (int j = 0; j < temps.Length; j++)
                    {
                        temp = temps[j];
                        tempGo = temp.gameObject;
                        GameObject.DestroyImmediate(temp);
                        if (tempGo.GetComponent<CustomOutlineEx>() == null)
                        {
                            CustomOutlineEx customOutlineEx = tempGo.AddComponent<CustomOutlineEx>();
                        }
                        isReplace = true;
                        LogRedColor(">> 检测到替换路径 : " + GetGameObjectPath(tempGo.transform));
                    }
                }
                if (isReplace)
                {
                    isSaveAssets = true;
                    EditorUtility.SetDirty(go);
                }
            }
        }
        LogGreenColor("================替换描边组件完成================");
        if (isSaveAssets)
        {
            AssetDatabase.SaveAssets();
        }
    }

    //========================================================================
    //========================================================================

    [MenuItem("Assets/UIFont/替换Null为FZCuYuan")]
    private static void ReplaceNullToFZCuYuan()
    {
        ReplaceFont(null, FZCuYuan);
    }

    [MenuItem("Assets/UIFont/替换Arial为FZCuYuan")]
    private static void ReplaceArialToFZCuYuan()
    {
        ReplaceFont("Arial", FZCuYuan);
    }

    [MenuItem("Assets/UIFont/替换FZZhunYuan为FZCuYuan")]
    private static void ReplaceFZZhunYuanToFZCuYuan()
    {
        ReplaceFont("FZZhunYuan", FZCuYuan);
    }

    [MenuItem("Assets/UIFont/替换YuantiBold为FZCuYuan")]
    private static void ReplaceYuantiBoldToFZCuYuan()
    {
        ReplaceFont("YuantiBold", FZCuYuan);
    }

    [MenuItem("Assets/UIFont/替换YuantiRegular为FZCuYuan")]
    private static void ReplaceYuantiRegularToFZCuYuan()
    {
        ReplaceFont("YuantiRegular", FZCuYuan);
    }

    [MenuItem("Assets/UIFont/替换YuantiRegular为FZZhunYuan")]
    private static void ReplaceYuantiRegularToFZZhunYuan()
    {
        ReplaceFont("YuantiRegular", FZZhunYuan);
    }

    [MenuItem("Assets/UIFont/替换FZCuYuan为YuantiBold")]
    private static void ReplaceFZCuYuanToYuantiRegular()
    {
        ReplaceFont("FZCuYuan", YuantiBold);
    }

    [MenuItem("Assets/UIFont/替换FZZhunYuan为YuantiRegular")]
    private static void ReplaceFZZhunYuanToYuantiRegular()
    {
        ReplaceFont("FZZhunYuan", YuantiRegular);
    }

    [MenuItem("Assets/UIFont/替换YuantiRegular为ZhongKai")]
    private static void ReplaceYuantiRegularToZhongKai()
    {
        ReplaceFont("YuantiRegular", ZhongKai);
    }

    [MenuItem("Assets/UIFont/替换ZhongKai为Msyh")]
    private static void ReplaceZhongKaiToMsyh()
    {
        ReplaceFont("HYZhongKai", Msyh);
    }

    [MenuItem("Assets/UIFont/替换YuantiBold为Msyh")]
    private static void ReplaceYuantiBoldToMsyh()
    {
        ReplaceFont("YuantiBold", Msyh);
    }
    [MenuItem("Assets/UIFont/替换Msyh为FangzhengBlack")]
    private static void ReplaceMsyhToFangzhengBlack()
    {
        ReplaceFont("Msyh", FangzhengBlack);
    }

    [MenuItem("Assets/UIFont/替换FangzhengBlack为YaSong")]
    private static void ReplaceFangzhengBlackToYaSong()
    {
        ReplaceFont("FangzhengBlack", YaSong);
    }


    [MenuItem("Assets/UIFont/设置FZCuYuan字体的字号为24号")]
    private static void SetFZCuYuanSize24()
    {
        SetFontSize("FZCuYuan", 24);
    }

    [MenuItem("Assets/UIFont/设置FZCuYuan字体的字号为30号")]
    private static void SetFZCuYuanSize30()
    {
        SetFontSize("FZCuYuan", 30);
    }

    [MenuItem("Assets/UIFont/检测Null")]
    private static void CheckNull()
    {
        CheckFont(null);
    }

    [MenuItem("Assets/UIFont/检测Arial")]
    private static void CheckArial()
    {
        CheckFont("Arial");
    }

    [MenuItem("Assets/UIFont/检测FZZhunYuan")]
    private static void CheckFZZhunYuan()
    {
        CheckFont("FZZhunYuan");
    }

    [MenuItem("Assets/UIFont/检测YuantiBold")]
    private static void CheckYuantiBold()
    {
        CheckFont("YuantiBold");
    }
    
    //========================================================================

    public static void ReplaceFontToFZCuYuanAtHierarchy(bool isInChildren)
    {
        ReplaceFontAtHierarchy(FZCuYuan, isInChildren);
    }

    public static void ReplaceFontToFZZhunYuanAtHierarchy(bool isInChildren)
    {
        ReplaceFontAtHierarchy(FZZhunYuan, isInChildren);
    }

    /// <summary>
    /// 替换字体
    /// </summary>
    private static void ReplaceFontAtHierarchy(Font font, bool isInChildren)
    {
        if (font == null)
        {
            return;
        }
        GameObject selectedGameObject = Selection.activeObject as GameObject;
        if (selectedGameObject != null && selectedGameObject.activeInHierarchy)
        {
            if (isInChildren)
            {
                Text[] texts = selectedGameObject.GetComponentsInChildren<Text>(true);
                for (int i = 0; i < texts.Length; i++)
                {
                    Text temp = texts[i];
                    temp.font = font;
                    LogRedColor(">> 替换字体 : " + GetGameObjectPath(temp.transform));
                }
            }
            else
            {
                Text text = selectedGameObject.GetComponent<Text>();
                text.font = font;
                LogRedColor(">> 替换字体 : " + GetGameObjectPath(text.transform));
            }
        }
        else
        {
            Debug.LogError(">> Selected Null GameObject. ");
        }
    }

    //========================================================================
    public static void ReplaceFontStyleToNormalAtHierarchy(bool isInChildren)
    {
        ReplaceFontStyleToNormalAtHierarchy("FZCuYuan", isInChildren);
    }

    /// <summary>
    /// 替换字体
    /// </summary>
    private static void ReplaceFontStyleToNormalAtHierarchy(string fontName, bool isInChildren)
    {
        GameObject selectedGameObject = Selection.activeObject as GameObject;
        if (selectedGameObject != null && selectedGameObject.activeInHierarchy)
        {
            if (isInChildren)
            {
                Text[] texts = selectedGameObject.GetComponentsInChildren<Text>(true);
                for (int i = 0; i < texts.Length; i++)
                {
                    Text temp = texts[i];
                    if (temp.font != null && temp.font.name == fontName) 
                    {
                        temp.fontStyle = FontStyle.Normal;
                        LogRedColor(">> 修改字体样式 : " + GetGameObjectPath(temp.transform));
                    }
                }
            }
            else
            {
                Text temp = selectedGameObject.GetComponent<Text>();
                if (temp != null && temp.font != null && temp.font.name == fontName)
                {
                    temp.fontStyle = FontStyle.Normal;
                    LogRedColor(">> 修改字体样式 : " + GetGameObjectPath(temp.transform));
                }
            }
        }
        else
        {
            Debug.LogError(">> Selected Null GameObject. ");
        }
    }

    //========================================================================
    [MenuItem("Assets/UIFont/检测文本俱乐部")]
    private static void CheckText1()
    {
        CheckText("俱乐部");
    }
}
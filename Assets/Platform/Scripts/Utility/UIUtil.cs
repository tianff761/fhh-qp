using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using LuaFramework;

/// <summary>
/// UI方面的辅助类
/// </summary>
public class UIUtil
{
    private static void Test() 
    {

    }


    public static bool ScreenPosInRect(RectTransform rect, Vector2 screenPos, Camera camera = null)
    {
        if(rect != null)
        {
            return RectTransformUtility.RectangleContainsScreenPoint(rect, screenPos, camera);
        }
        else
        {
            return false;
        }
    }

    public static Vector2 ScreenToPosition(RectTransform rectTransform, Vector2 screenPoint, Camera camera)
    {
        Vector3 position = Vector3.zero;
        if(rectTransform != null)
        {
            RectTransformUtility.ScreenPointToWorldPointInRectangle(rectTransform, screenPoint, camera, out position);
        }
        return position;
    }

    public static Vector2 ScreenToLocalPosition(RectTransform rectTransform, Vector2 screenPoint, Camera camera)
    {
        Vector2 position = Vector3.zero;
        if(rectTransform != null)
        {
            RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTransform, screenPoint, camera, out position);
        }
        return position;
    }

    public static Tweener DOFade(GameObject target, float endValue, float duration)
    {
        return DOFade(target.transform, endValue, duration);
    }

    public static Tweener DOFade(Transform target, float endValue, float duration)
    {
        CanvasGroup canvas = target.GetComponent<CanvasGroup>();
        if(canvas == null)
        {
            canvas = target.gameObject.AddComponent<CanvasGroup>();
        }
        if(endValue > 0.9f)
        {
            canvas.alpha = 0;
        }
        else if(endValue < 0.1f)
        {
            canvas.alpha = 1;
        }
        return canvas.DOFade(endValue, duration);
    }
    //----------------------------------------------------------------

    /// 复制GameObject，固定设置了localScale，使用prefab的父对象作为父对象
    public static GameObject Duplicate(GameObject prefab)
    {
        return Duplicate(prefab, prefab.transform.parent);
    }

    /// 复制GameObject，固定设置了localScale，父对象
    public static GameObject Duplicate(GameObject prefab, GameObject parent)
    {
        return Duplicate(prefab, parent.transform);
    }

    /// 复制GameObject，固定设置了localScale，父对象
    public static GameObject Duplicate(GameObject prefab, Transform parent)
    {
        GameObject result = GameObject.Instantiate(prefab) as GameObject;
        result.SetActive(true);
        result.transform.SetParent(parent);
        result.transform.localScale = Vector3.one;
        return result;
    }

    /// <summary>
    /// 复制GameObject，带有坐标设置
    /// </summary>
    public static GameObject Duplicate(GameObject prefab, Transform parent, Vector3 position, string name)
    {
        GameObject result = GameObject.Instantiate(prefab) as GameObject;
        result.SetActive(true);
        result.transform.SetParent(parent);
        result.transform.localPosition = position;
        result.transform.localScale = Vector3.one;
        if(!string.IsNullOrEmpty(name))
        {
            result.name = name;
        }
        return result;
    }

    //----------------------------------------------------------------

    /// <summary>
    /// 获取UI的RectTransform组件
    /// </summary>
    public static RectTransform GetRectTransform(GameObject go)
    {
        return go.GetComponent<RectTransform>();
    }

    /// <summary>
    /// 获取UI的RectTransform组件
    /// </summary>
    public static RectTransform GetRectTransform(Transform transform)
    {
        return transform.GetComponent<RectTransform>();
    }

    //----------------------------------------------------------------

    public static float GetWidth(GameObject go)
    {
        return go.GetComponent<RectTransform>().sizeDelta.x;
    }

    public static float GetWidth(Transform transform)
    {
        return transform.GetComponent<RectTransform>().sizeDelta.x;
    }

    //--------------------------------

    public static float GetHeight(GameObject go)
    {
        return go.GetComponent<RectTransform>().sizeDelta.y;
    }

    public static float GetHeight(Transform transform)
    {
        return transform.GetComponent<RectTransform>().sizeDelta.y;
    }

    //--------------------------------

    public static void SetWidth(GameObject go, float width)
    {
        RectTransform rectTransform = go.GetComponent<RectTransform>();
        rectTransform.sizeDelta = new Vector2(width, rectTransform.sizeDelta.y);
    }

    public static void SetWidth(Transform transform, float width)
    {
        RectTransform rectTransform = transform.GetComponent<RectTransform>();
        rectTransform.sizeDelta = new Vector2(width, rectTransform.sizeDelta.y);
    }

    public static void SetWidth(RectTransform rectTransform, float width)
    {
        rectTransform.sizeDelta = new Vector2(width, rectTransform.sizeDelta.y);
    }

    //--------------------------------


    public static void SetHeight(GameObject go, float height)
    {
        RectTransform rectTransform = go.GetComponent<RectTransform>();
        rectTransform.sizeDelta = new Vector2(rectTransform.sizeDelta.x, height);
    }

    public static void SetHeight(Transform transform, float height)
    {
        RectTransform rectTransform = transform.GetComponent<RectTransform>();
        rectTransform.sizeDelta = new Vector2(rectTransform.sizeDelta.x, height);
    }

    public static void SetHeight(RectTransform rectTransform, float height)
    {
        rectTransform.sizeDelta = new Vector2(rectTransform.sizeDelta.x, height);
    }

    //--------------------------------


    public static void SetSize(GameObject go, float width, float height)
    {
        go.GetComponent<RectTransform>().sizeDelta = new Vector2(width, height);
    }

    public static void SetSize(Transform transform, float width, float height)
    {
        transform.GetComponent<RectTransform>().sizeDelta = new Vector2(width, height);
    }

    public static void SetSize(RectTransform rectTransform, float width, float height)
    {
        rectTransform.sizeDelta = new Vector2(width, height);
    }

    //----------------------------------------------------------------

    public static void SetAnchoredPosition(GameObject go, float x, float y)
    {
        go.GetComponent<RectTransform>().anchoredPosition = new Vector2(x, y);
    }

    public static void SetAnchoredPosition(Transform transform, float x, float y)
    {
        transform.GetComponent<RectTransform>().anchoredPosition = new Vector2(x, y);
    }

    public static void SetAnchoredPosition(RectTransform rectTransform, float x, float y)
    {
        rectTransform.anchoredPosition = new Vector2(x, y);
    }

    //--------------------------------


    public static void SetAnchoredPositionX(GameObject go, float x)
    {
        RectTransform rectTransform = go.GetComponent<RectTransform>();
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(x, t.y);
    }

    public static void SetAnchoredPositionX(Transform transform, float x)
    {
        RectTransform rectTransform = transform.GetComponent<RectTransform>();
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(x, t.y);
    }

    public static void SetAnchoredPositionX(RectTransform rectTransform, float x)
    {
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(x, t.y);
    }

    //--------------------------------

    public static void SetAnchoredPositionY(GameObject go, float y)
    {
        RectTransform rectTransform = go.GetComponent<RectTransform>();
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(t.x, y);
    }

    public static void SetAnchoredPositionY(Transform transform, float y)
    {
        RectTransform rectTransform = transform.GetComponent<RectTransform>();
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(t.x, y);
    }

    public static void SetAnchoredPositionY(RectTransform rectTransform, float y)
    {
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(t.x, y);
    }

    //--------------------------------

    public static void SetAnchoredPosition3D(GameObject go, float x, float y, float z)
    {
        go.GetComponent<RectTransform>().anchoredPosition3D = new Vector3(x, y, z);
    }

    public static void SetAnchoredPosition3D(Transform transform, float x, float y, float z)
    {
        transform.GetComponent<RectTransform>().anchoredPosition3D = new Vector3(x, y, z);
    }

    public static void SetAnchoredPosition3D(RectTransform rectTransform, float x, float y, float z)
    {
        rectTransform.anchoredPosition3D = new Vector3(x, y, z);
    }

    //----------------------------------------------------------------

    public static void SetAsFirstSibling(GameObject go)
    {
        go.GetComponent<Transform>().SetAsFirstSibling();
    }

    public static void SetAsFirstSibling(Transform transform)
    {
        transform.SetAsFirstSibling();
    }

    public static void SetAsLastSibling(GameObject go)
    {
        go.GetComponent<Transform>().SetAsLastSibling();
    }

    public static void SetAsLastSibling(Transform transform)
    {
        transform.SetAsLastSibling();
    }

    public static void SetSiblingIndex(GameObject go, int index)
    {
        go.GetComponent<Transform>().SetSiblingIndex(index);
    }

    public static void SetSiblingIndex(Transform transform, int index)
    {
        transform.SetSiblingIndex(index);
    }

    //----------------------------------------------------------------


    public static void AddAnchoredPosition(GameObject gameObject, float deltaX, float deltaY)
    {
        RectTransform rectTransform = gameObject.GetComponent<RectTransform>();
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(t.x + deltaX, t.y + deltaY);
    }

    public static void AddAnchoredPosition(Transform transform, float deltaX, float deltaY)
    {
        RectTransform rectTransform = transform.GetComponent<RectTransform>();
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(t.x + deltaX, t.y + deltaY);
    }

    public static void AddAnchoredPosition(RectTransform rectTransform, float deltaX, float deltaY)
    {
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(t.x + deltaX, t.y + deltaY);
    }

    //--------------------------------

    public static void AddAnchoredPositionX(GameObject gameObject, float deltaX)
    {
        RectTransform rectTransform = gameObject.GetComponent<RectTransform>();
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(t.x + deltaX, t.y);
    }

    public static void AddAnchoredPositionX(Transform transform, float deltaX)
    {
        RectTransform rectTransform = transform.GetComponent<RectTransform>();
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(t.x + deltaX, t.y);
    }

    public static void AddAnchoredPositionX(RectTransform rectTransform, float deltaX)
    {
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(t.x + deltaX, t.y);
    }

    //--------------------------------


    public static void AddAnchoredPositionY(GameObject gameObject, float deltaY)
    {
        RectTransform rectTransform = gameObject.GetComponent<RectTransform>();
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(t.x, t.y + deltaY);
    }

    public static void AddAnchoredPositionY(Transform transform, float deltaY)
    {
        RectTransform rectTransform = transform.GetComponent<RectTransform>();
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(t.x, t.y + deltaY);
    }

    public static void AddAnchoredPositionY(RectTransform rectTransform, float deltaY)
    {
        Vector2 t = rectTransform.anchoredPosition;
        rectTransform.anchoredPosition = new Vector2(t.x, t.y + deltaY);
    }

    //================================================================

    public static Vector3 GetPosition(GameObject go)
    {
        return go.transform.position;
    }

    public static Vector3 GetLocalPosition(GameObject go)
    {
        return go.transform.localPosition;
    }

    public static Vector3 GetEulerAngles(GameObject go)
    {
        return go.transform.eulerAngles;
    }

    public static Vector3 GetLocalScale(GameObject go)
    {
        return go.transform.localScale;
    }

    //--------------------------------

    public static void SetPosition(GameObject go, Vector3 position)
    {
        if(go != null)
        {
            go.transform.position = position;
        }
    }

    public static void SetPosition(GameObject go, float x, float y, float z)
    {
        if(go != null)
        {
            go.transform.position = new Vector3(x, y, z);
        }
    }

    public static void SetLocalPosition(GameObject go, Vector3 position)
    {
        if(go != null)
        {
            go.transform.localPosition = position;
        }
    }

    public static void SetLocalPosition(GameObject go, float x, float y, float z)
    {
        if(go != null)
        {
            go.transform.localPosition = new Vector3(x, y, z);
        }
    }

    public static void SetRotation(GameObject go, float x, float y, float z)
    {
        if(go != null)
        {
            go.transform.rotation = Quaternion.Euler(x, y, z);
        }
    }

    public static void SetLocalScale(GameObject go, float x, float y, float z)
    {
        if(go != null)
        {
            go.transform.localScale = new Vector3(x, y, z);
        }
    }

    //--------------------------------


    public static void SetPosition(Transform transform, float x, float y, float z)
    {
        if(transform != null)
        {
            transform.position = new Vector3(x, y, z);
        }
    }

    public static void SetLocalPosition(Transform transform, float x, float y, float z)
    {
        if(transform != null)
        {
            transform.localPosition = new Vector3(x, y, z);
        }
    }

    public static void SetRotation(Transform transform, float x, float y, float z)
    {
        if(transform != null)
        {
            transform.rotation = Quaternion.Euler(x, y, z);
        }
    }

    public static void SetLocalScale(Transform transform, float x, float y, float z)
    {
        if(transform != null)
        {
            transform.localScale = new Vector3(x, y, z);
        }
    }

    //================================================================


    public static void SetActive(GameObject go, bool value)
    {
        if(go != null && go.activeSelf != value)
        {
            go.SetActive(value);
        }
    }

    public static void SetActive(Transform tran, bool value)
    {
        if(tran != null)
        {
            SetActive(tran.gameObject, value);
        }
    }

    //================================================================

    public static void SetImageColor(Image image, float r, float g, float b)
    {
        if(image != null)
        {
            image.color = new Color(r, g, b);
        }
    }

    public static void SetImageColor(Image image, float r, float g, float b, float a)
    {
        if(image != null)
        {
            image.color = new Color(r, g, b, a);
        }
    }

    public static void SetImageAlpha(Image image, float a)
    {
        if(image != null)
        {
            Color color = image.color;
            color.a = a;
            image.color = color;
        }
    }

    public static void SetTextColor(Text text, float r, float g, float b)
    {
        if(text != null)
        {
            text.color = new Color(r, g, b);
        }
    }

    public static void SetTextColor(Text text, float r, float g, float b, float a)
    {
        if(text != null)
        {
            text.color = new Color(r, g, b, a);
        }
    }

    public static void SetTextAlpha(Text text, float a)
    {
        if(text != null)
        {
            Color color = text.color;
            color.a = a;
            text.color = color;
        }
    }

    //================================================================

    /// <summary>
    /// 设置背景图片适配
    /// </summary>
    public static void SetBackgroundAdaptation(GameObject go)
    {
        if(go == null)
        {
            return;
        }
        Image image = go.GetComponent<Image>();
        if(image == null || image.mainTexture == null)
        {
            return;
        }
        RectTransform rectTransform = image.GetComponent<RectTransform>();
        rectTransform.sizeDelta = UIUtil.CalculateAdaptation(image.mainTexture.width, image.mainTexture.height);
    }

    /// <summary>
    /// 设置背景图片适配
    /// </summary>
    public static void SetBackgroundAdaptation(Image image)
    {
        if(image == null || image.mainTexture == null)
        {
            return;
        }
        RectTransform rectTransform = image.GetComponent<RectTransform>();
        rectTransform.sizeDelta = UIUtil.CalculateAdaptation(image.mainTexture.width, image.mainTexture.height);
    }

    /// <summary>
    /// 横屏设置背景图片适配
    /// </summary>
    public static void SetBackgroundAdaptationByHorizontal(Image image)
    {
        if(image == null || image.mainTexture == null)
        {
            return;
        }
        int screenWidth = Screen.width;
        int screenHeight = Screen.height;
        if(screenWidth < screenHeight)
        {
            screenWidth = Screen.height;
            screenHeight = Screen.width;
        }

        RectTransform rectTransform = image.GetComponent<RectTransform>();
        rectTransform.sizeDelta = UIUtil.CalculateAdaptation(image.mainTexture.width, image.mainTexture.height, screenWidth, screenHeight);
    }

    /// <summary>
    /// 计算适配大小
    /// </summary>
    public static Vector2 CalculateAdaptation(float width, float height)
    {
        return CalculateAdaptation(width, height, Screen.width, Screen.height);
    }

    /// <summary>
    /// 计算适配大小
    /// </summary>
    public static Vector2 CalculateAdaptation(float width, float height, int screenWidth, int screenHeight)
    {
        return CalculateAdaptation(width, height, screenWidth, screenHeight, AppConst.ReferenceResolution.x, AppConst.ReferenceResolution.y);
    }


    /// <summary>
    /// 计算适配大小
    /// </summary>
    public static Vector2 CalculateAdaptation(float width, float height, int screenWidth, int screenHeight, float referenceX, float referenceY)
    {
        float scale = CalculateAdaptationScale(width, height, screenWidth, screenHeight, referenceX, referenceY);

        float tWidth = Mathf.Ceil(width * scale);
        float tHeight = Mathf.Ceil(height * scale);

        return new Vector2(tWidth, tHeight);
    }

    /// <summary>
    /// 计算适配的缩放大小
    /// </summary>
    public static float CalculateAdaptationScale(float width, float height, int screenWidth, int screenHeight, float referenceX, float referenceY)
    {
        float widthScale = screenWidth / referenceX;
        float heightScale = screenHeight / referenceY;

        float tWidth = referenceX;
        float tHeight = referenceY;

        //UI整体缩放比例
        float scale = 1;
        if(widthScale < heightScale)
        {
            scale = widthScale;
        }
        else
        {
            scale = heightScale;
        }

        //计算出Canvas的大小
        tWidth = screenWidth / scale;
        tHeight = screenHeight / scale;

        //计算图片缩放比例
        float tempWidthScale = width / tWidth;
        float tempHeightScale = height / tHeight;
        if(tempWidthScale < tempHeightScale)
        {
            scale = tempWidthScale;
        }
        else
        {
            scale = tempHeightScale;
        }
        return 1f / scale;
    }

    /// <summary>
    /// 根据高宽获取到缩放的大小
    /// </summary>
    public static float GetCalculateAdaptationScale(float width, float height)
    {
        int screenWidth = Screen.width;
        int screenHeight = Screen.height;
        if(screenWidth < screenHeight)
        {
            screenWidth = Screen.height;
            screenHeight = Screen.width;
        }
        return CalculateAdaptationScale(width, height, screenWidth, screenHeight, AppConst.ReferenceResolution.x, AppConst.ReferenceResolution.y);
    }

    /// <summary>
    /// 根据高宽获取到缩放的大小
    /// </summary>
    public static float GetCalculateAdaptationScale(float width, float height, float referenceX, float referenceY)
    {
        int screenWidth = Screen.width;
        int screenHeight = Screen.height;
        if(screenWidth < screenHeight)
        {
            screenWidth = Screen.height;
            screenHeight = Screen.width;
        }
        return CalculateAdaptationScale(width, height, screenWidth, screenHeight, referenceX, referenceY);
    }

    //================================================================
    /// <summary>
    /// 设置背景动画适配
    /// </summary>
    public static void SetBackgroundAnimAdaptation(Transform transform, float width, float height)
    {
        float scale = UIUtil.GetCalculateAdaptationScale(width, height);
        scale *= 100 + 1.5f;
        transform.localScale = new Vector3(scale, scale, 1);
    }

    /// <summary>
    /// 设置和播放背景动画适配
    /// </summary>
    public static void SetPlayBackgroundAnimAdaptation(Transform transform, string animName)
    {
        SetPlayBackgroundAnimAdaptation(transform, animName, 1465, 710);
    }

    /// <summary>
    /// 设置和播放背景动画适配
    /// </summary>
    public static void SetPlayBackgroundAnimAdaptation(Transform transform, string animName, float width, float height)
    {
        DragonBones.UnityArmatureComponent armature = transform.GetComponent<DragonBones.UnityArmatureComponent>();
        if(armature != null)
        {
            armature.animation.Play(animName);
        }

        float scale = UIUtil.GetCalculateAdaptationScale(width, height);
        scale *= 100 + 1.5f;
        transform.localScale = new Vector3(scale, scale, 1);
    }


    //================================================================

    public static void SetText(Transform tran, string text)
    {
        if(tran != null && text != null)
        {
            var textLabel = tran.GetComponent<Text>();
            if(textLabel != null)
            {
                textLabel.text = text;
            }
        }
    }

    public static void SetText(GameObject go, string text)
    {
        if(go != null && text != null)
        {
            SetText(go.transform, text);
        }
    }
    public static string GetText(GameObject go)
    {
        if(go == null || go.GetComponent<Text>() == null)
        {
            Debug.LogError("Text对象为空");
            return "请检测组件";
        }
        return go.GetComponent<Text>().text;
    }
    public static string GetText(Transform tran)
    {
        if(tran == null || tran.GetComponent<Text>() == null)
        {
            Debug.LogError("Text对象为空");
            return "请检测组件";
        }
        return tran.GetComponent<Text>().text;
    }

    public static void SetToggle(GameObject go, bool isOn)
    {
        if(go != null && go.GetComponent<Toggle>() != null)
        {
            go.GetComponent<Toggle>().isOn = isOn;
        }
    }
    public static void SetToggle(Transform tran, bool isOn)
    {
        if(tran != null && tran.GetComponent<Toggle>() != null)
        {
            tran.GetComponent<Toggle>().isOn = isOn;
        }
    }

    public static bool GetToggle(GameObject go)
    {
        if(go == null || go.GetComponent<Toggle>() == null)
        {
            Debug.LogError("=========对象为空");
            return false;
        }
        return go.GetComponent<Toggle>().isOn;
    }
    public static bool GetToggle(Transform tran)
    {
        if(tran == null || tran.GetComponent<Toggle>() == null)
        {
            Debug.LogError("=========对象为空");
            return false;
        }
        return tran.GetComponent<Toggle>().isOn;
    }
    public static void SetInputText(GameObject go, string text)
    {
        if(go != null && go.GetComponent<InputField>() != null)
        {
            go.GetComponent<InputField>().text = text;
        }
    }
    public static void SetInputText(Transform tran, string text)
    {
        if(tran != null && tran.GetComponent<InputField>() != null)
        {
            tran.GetComponent<InputField>().text = text;
        }
    }
    public static string GetInputText(GameObject go)
    {
        if(go == null || go.GetComponent<InputField>() == null)
        {
            Debug.LogError("请查看组件是否为空");
            return "对象为找到";
        }
        return go.GetComponent<InputField>().text;
    }
    public static string GetInputText(Transform tran)
    {
        if(tran == null || tran.GetComponent<InputField>() == null)
        {
            Debug.LogError("请查看组件是否为空");
            return "对象为找到";
        }
        return tran.GetComponent<InputField>().text;
    }
    public static void CheckText(GameObject go, string text)
    {
        if(go != null && !string.IsNullOrEmpty(text))
        {
            if(!string.Equals(GetText(go), text))
            {
                SetText(go, text);
            }

        }
    }
    public static void CheckText(Transform tran, string text)
    {
        if(tran != null && !string.IsNullOrEmpty(text))
        {
            if(!string.Equals(GetText(tran), text))
            {
                SetText(tran, text);
            }
        }
    }

    public static void CheckToggle(GameObject go, bool isOn)
    {
        if(go != null && go.GetComponent<Toggle>() != null)
        {
            if(GetToggle(go) != isOn)
            {
                SetToggle(go, isOn);
            }
        }
    }

    public static void CheckActive(GameObject go, bool isActive)
    {
        if(go != null)
        {
            if(go.activeSelf != isActive)
            {
                SetActive(go, isActive);
            }
        }
    }
    public static void CheckActive(Transform tran, bool isActive)
    {
        if(tran != null)
        {
            if(tran.gameObject.activeSelf != isActive)
            {
                SetActive(tran.gameObject, isActive);
            }
        }
    }

    /// <summary>
    /// 获取遮罩层级，用于射线和摄像机的遮罩处理
    /// </summary>
    public static int GetMaskLayer(int layer)
    {
        return 1 << layer;
    }

    /// <summary>
    /// 获取遮罩层级的取反
    /// </summary>
    public static int GetInverseMaskLayer(int layer)
    {
        return ~(1 << layer);
    }

    /// <summary>
    /// 增加DropdownOptions
    /// </summary>
    public static void AddDropdownOptionsByString(Dropdown dropDown, string[] options)
    {
        List<string> optionDatas = new List<string>(options);
        dropDown.AddOptions(optionDatas);
    }

    /// <summary>
    /// 增加DropdownOptions
    /// </summary>
    public static void AddDropdownOptions(Dropdown dropDown, string[] options)
    {
        List<string> optionDatas = new List<string>(options);
        dropDown.AddOptions(optionDatas);
    }

    /// <summary>
    /// 增加DropdownOptions
    /// </summary>
    public static void AddDropdownOptions(Dropdown dropDown, Sprite[] options)
    {
        List<Sprite> optionDatas = new List<Sprite>(options);
        dropDown.AddOptions(optionDatas);
    }

    /// <summary>
    /// 增加DropdownOptions
    /// </summary>
    public static void AddDropdownOptions(Dropdown dropDown, Dropdown.OptionData[] options)
    {
        List<Dropdown.OptionData> optionDatas = new List<Dropdown.OptionData>(options);
        dropDown.AddOptions(optionDatas);
    }

    /// <summary>
    /// 设置DropdownOptions
    /// </summary>
    public static void SetDropdownOptions(Dropdown dropDown, Dropdown.OptionData[] options)
    {
        List<Dropdown.OptionData> optionDatas = new List<Dropdown.OptionData>(options);
        dropDown.options = optionDatas;
    }
}

using UnityEngine;
/// <summary>
/// 安全区适配器
/// </summary>
public class SafeZoneAdaptor : MonoBehaviour
{
    public UI_KEEP_POS m_dir = UI_KEEP_POS.KEEPLEFT;
    private float orginX;
    /// <summary>
    /// 布局容器
    /// </summary>
    private RectTransform rectTransform;
    private float screenRatio = 0;

    private void Start()
    {
        rectTransform = this.GetComponent<RectTransform>();
        this.orginX = rectTransform.anchoredPosition.x;

        screenRatio = AppConst.ReferenceResolution.y * 1.0f / Screen.height;
        this.OnDeviceChangeOrientation();
    }

    private void OnDestroy()
    {
    }

    private void OnScreenSafeAreaUpdate(object args)
    {
        this.OnDeviceChangeOrientation();
    }

    /// <summary>
    /// 设置切换旋转方向
    /// </summary>
    private void OnDeviceChangeOrientation()
    {
        Rect r = Screen.safeArea;
        float offset = 0;
        Vector2 v = rectTransform.anchoredPosition;
        switch (m_dir)
        {
            case UI_KEEP_POS.KEEPLEFT:
                offset = r.x * screenRatio;
                v.x = this.orginX + offset;
                break;
            case UI_KEEP_POS.KEEPRIGHT:
                offset = (Screen.width - r.x - r.width) * screenRatio;
                v.x = this.orginX - offset;
                break;
        }
        rectTransform.anchoredPosition = v;
    }

}
public enum UI_KEEP_POS
{
    KEEPLEFT,
    KEEPRIGHT
}
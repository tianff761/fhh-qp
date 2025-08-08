using UnityEngine;

/// <summary>
/// 用于辅助UGUI的Toggle组件的使用
/// </summary>
public class UIToggleHelper : MonoBehaviour
{
    /// <summary>
    /// 激活列表
    /// </summary>
    public GameObject[] actives;
    /// <summary>
    /// 不激活列表
    /// </summary>
    public GameObject[] inactives;

    /// <summary>
    /// 设置所有选择对象的Active
    /// </summary>
    public void SetAllActive(bool vaule)
    {
        if(actives != null)
        {
            for(int i = 0; i < actives.Length; i++)
            {
                actives[i].SetActive(vaule);
            }
        }

        if(inactives != null)
        {
            for(int i = 0; i < inactives.Length; i++)
            {
                inactives[i].SetActive(!vaule);
            }
        }
    }
}
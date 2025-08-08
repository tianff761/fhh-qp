using UnityEngine;

/// <summary>
/// TMonoBehaviour类的辅助类
/// </summary>
public class TMonoBehaviourHelper
{

    /// <summary>
    /// 默认的GameObject名称
    /// </summary>
    private const string DEFAULT_NAME = "CustomManager";

    /// <summary>
    /// 提供公共的方法使用
    /// </summary>
    public static T GetManagerInstance<T>(string name = null) where T : MonoBehaviour
    {
        string tempName = name;
        if(string.IsNullOrEmpty(name))
        {
            tempName = DEFAULT_NAME;
        }
        T instance;
        GameObject go = GameObject.Find(tempName);
        if(go == null)
        {
            go = new GameObject(tempName);
            GameObject.DontDestroyOnLoad(go);
        }

        instance = go.GetComponent<T>();
        if(instance == null)
        {
            instance = go.AddComponent<T>();
        }
        return instance;
    }

}

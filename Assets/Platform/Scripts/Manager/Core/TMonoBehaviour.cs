using UnityEngine;

/// <summary>
/// MonoBehaviour单例管理基类
/// </summary>
public class TMonoBehaviour<T> : MonoBehaviour where T : MonoBehaviour
{

    private static T mInstance;

    public static T Instance
    {
        get
        {
            if(mInstance == null)
            {
                mInstance = TMonoBehaviourHelper.GetManagerInstance<T>();
            }
            return mInstance;
        }
    }

    public static T GetInstance()
    {
        return Instance;
    }

}
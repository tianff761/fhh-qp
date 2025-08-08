using System.Reflection;
using System;

/// <summary>
/// 单件安全
/// 非继承MonoBehaviour的单例继承此类，并加入私有构造函数
/// </summary>
public class TSingleton<T> where T : class
{
    private static T mInstance;
    private static readonly object SysLock = new object();
    public static readonly Type[] EmptyTypes = new Type[0];

    public static T Instance
    {
        get
        {
            if(mInstance == null)
            {
                lock(SysLock)
                {
                    if(mInstance == null)
                    {
                        ConstructorInfo ci = typeof(T).GetConstructor(BindingFlags.NonPublic | BindingFlags.Instance, null, EmptyTypes, null);
                        if(ci == null) { throw new InvalidOperationException("Class must contain a private Constructor."); }
                        mInstance = (T)ci.Invoke(null);
                    }
                }
            }
            return mInstance;
        }
    }

}

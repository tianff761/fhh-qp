using System;

public abstract class Listener
{
    protected Action mCallback = null;

    /// <summary>
    /// 回调返回的数据都需要进行null判断
    /// </summary>
    public void AddListener(Action _callback)
    {
        if(_callback != null)
        {
            mCallback += _callback;
        }
    }

    public void RemoveListener(Action _callback)
    {
        if(_callback != null)
        {
            mCallback -= _callback;
        }
    }

    public void Callback()
    {
        if(mCallback != null)
        {
            mCallback.Invoke();
        }
    }

}

public abstract class Listener<T>
{
    protected Action<T> mCallback = null;

    /// <summary>
    /// 回调返回的数据都需要进行null判断
    /// </summary>
    public void AddListener(Action<T> _callback)
    {
        if(_callback != null)
        {
            mCallback += _callback;
        }
    }

    public void RemoveListener(Action<T> _callback)
    {
        if(_callback != null)
        {
            mCallback -= _callback;
        }
    }

    public void Callback(T t)
    {
        if(mCallback != null)
        {
            mCallback.Invoke(t);
        }
    }

}

public abstract class Listener<T, U>
{
    protected Action<T, U> mCallback = null;

    /// <summary>
    /// 回调返回的数据都需要进行null判断
    /// </summary>
    public void AddListener(Action<T, U> _callback)
    {
        if(_callback != null)
        {
            mCallback += _callback;
        }
    }

    public void RemoveListener(Action<T, U> _callback)
    {
        if(_callback != null)
        {
            mCallback -= _callback;
        }
    }

    public void Callback(T t, U u)
    {
        if(mCallback != null)
        {
            mCallback.Invoke(t, u);
        }
    }

}
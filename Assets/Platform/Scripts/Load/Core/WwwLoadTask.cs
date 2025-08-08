using UnityEngine;
using System.Collections;

public class WwwLoadTask : Listener<ResponseData>
{
    /// <summary>
    /// 接口的后续
    /// </summary>
    protected string mUri = null;

    /// <summary>
    /// 完整的Http Url
    /// </summary>
    protected string mUrl = null;

    /// <summary>
    /// 是否是网络HTTP请求标识
    /// </summary>
    protected bool mIsHttp = false;

    /// <summary>
    /// WWW 请求对象，主要用于终止使用
    /// </summary>
    protected WWW mRequest = null;

    /// <summary>
    /// 超时时间
    /// </summary>
    protected float mTimeout = 0;

    /// <summary>
    /// 当前时间
    /// </summary>
    protected float mCurrentTime = 0;


    public WwwLoadTask(string _uri)
    {
        this.mUri = _uri;
        this.mUrl = this.mUri;
    }

    public WwwLoadTask(string _uri, bool _isHttp)
    {
        this.mUri = _uri;
        this.mUrl = this.mUri;
        this.mIsHttp = _isHttp;
    }

    /// <summary>
    /// 设置超时时间，单位秒
    /// </summary>
    /// <param name="time"></param>
    public virtual void SetTimeout(float time)
    {
        this.mTimeout = time;
    }

    /// <summary>
    /// 根据URL返回新建的WWW
    /// </summary>
    /// <returns></returns>
    protected virtual WWW Create()
    {
        return new WWW(this.mUrl);
    }

    /// <summary>
    /// 中途调用Stop，将不进行回调
    /// </summary>
    protected virtual IEnumerator Load()
    {
        this.mRequest = Create();
        this.mCurrentTime = Time.realtimeSinceStartup;
        ResponseData reponseData = new ResponseData(this.mUrl, this.mIsHttp);
        while(true)
        {
            yield return null;

            if(this.mRequest == null)//如果WWW为null，直接退出，也不进行回调
            {
                yield break;
            }

            if(this.mRequest.isDone)//完成
            {
                if(string.IsNullOrEmpty(this.mRequest.error))//如果有其他需求，请自行添加
                {
                    reponseData.code = ResponseCode.SUCCESS;
                    reponseData.text = this.mRequest.text;
                    reponseData.bytes = this.mRequest.bytes;
                    reponseData.texture = this.mRequest.texture;
                }
                else
                {
                    Debug.LogWarning(">> WwwLoadTask > url = " + this.mUrl);
                    Debug.LogWarning(">> WwwLoadTask > error = " + this.mRequest.error);
                    reponseData.code = ResponseCode.FAILED;
                    reponseData.error = this.mRequest.error;
                }
                this.mRequest.Dispose();
                this.mRequest = null;
                Callback(reponseData);
                yield break;
            }

            if(this.mTimeout > 0 && Time.realtimeSinceStartup - this.mCurrentTime > this.mTimeout)//超时处理
            {
                Debug.LogWarning(">> WwwLoadTask > url = " + this.mUrl);
                Debug.LogWarning(">> WwwLoadTask > timeout = " + this.mTimeout);
                reponseData.code = ResponseCode.TIMEOUT;
                this.mRequest.Dispose();
                this.mRequest = null;
                Callback(reponseData);
                yield break;
            }
        }
    }

    /// <summary>
    /// 运行WWW任务
    /// </summary>
    public virtual void Run()
    {
        if(this.mRequest != null)
        {
            Debug.LogWarning(">> WwwLoadTask > Task is running.");
            return;
        }
        CoroutineManager.Instance.StartCoroutine(Load());
    }

    /// <summary>
    /// 停止WWW任务
    /// </summary>
    public virtual void Stop()
    {
        if(this.mRequest != null)
        {
            this.mRequest.Dispose();
            this.mRequest = null;
        }
    }

}
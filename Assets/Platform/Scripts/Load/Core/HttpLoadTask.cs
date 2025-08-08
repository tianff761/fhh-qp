using UnityEngine;
using System.Collections.Generic;

public class HttpLoadTask : WwwLoadTask
{
    enum HttpLoadType
    {
        Get,
        Post,
        PostHeader
    }

    private HttpLoadType mLoadType = HttpLoadType.Get;

    private WWWForm mForm = null;

    private byte[] mPostData = null;
    private Dictionary<string, string> mHeader = null;

    public HttpLoadTask(string _uri) : base(_uri)
    {
        this.mIsHttp = true;
        this.mLoadType = HttpLoadType.Get;
    }

    public HttpLoadTask(string _uri, WWWForm _form) : base(_uri)
    {
        this.mIsHttp = true;
        this.mLoadType = HttpLoadType.Post;
        this.mForm = _form;
    }

    public HttpLoadTask(string _uri, byte[] _postData, Dictionary<string, string> _header) : base(_uri)
    {
        this.mIsHttp = true;
        this.mLoadType = HttpLoadType.PostHeader;
        this.mPostData = _postData;
        this.mHeader = _header;

    }

    protected override WWW Create()
    {
        if(mLoadType == HttpLoadType.Post)
        {
            return new WWW(this.mUrl, mForm);
        }
        else if(mLoadType == HttpLoadType.PostHeader)
        {
            return new WWW(this.mUrl, mPostData, mHeader);
        }
        else
        {
            return new WWW(this.mUrl);
        }
    }

    public override void Stop()
    {
        base.Stop();
        this.mForm = null;
        this.mPostData = null;
        this.mHeader = null;
    }
}
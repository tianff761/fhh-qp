using UnityEngine;

public class ResponseData
{
    /// <summary>
    /// Response代码
    /// </summary>
    public int code = 0;

    /// <summary>
    /// 完整的url路径
    /// </summary>
    public string url = null;

    /// <summary>
    /// 是否是网络请求
    /// </summary>
    public bool isHttp = false;

    /// <summary>
    /// 请求的二进制数据
    /// </summary>
    public byte[] bytes = null;

    /// <summary>
    /// 文本结果
    /// </summary>
    public string text = "";

    /// <summary>
    /// 下载的图片
    /// </summary>
    public Texture texture = null;

    /// <summary>
    /// WWW出错的文本
    /// </summary>
    public string error = "";

    /// <summary>
    /// 构造函数，isHttp表示是否是网络请求
    /// </summary>
    public ResponseData(string url, bool isHttp)
    {
        this.url = url;
        this.isHttp = isHttp;
    }

}

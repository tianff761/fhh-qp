using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AuthLoginData
{
    /// <summary>
    /// 内部Code码
    /// </summary>
    public int code = 0;
    /// <summary>
    /// 授权登录平台
    /// </summary>
    public int platformType = 0;
    /// <summary>
    /// 用于登录的ID，除微信的其他平台需要添加前缀
    /// </summary>
    public string openId = "";
    /// <summary>
    /// 昵称
    /// </summary>
    public string nickName = "";
    /// <summary>
    /// 性别，如果其他平台的性别于微信的不一致，需要转换1男性，2女性
    /// </summary>
    public int sex = 1;
    /// <summary>
    /// 头像链接
    /// </summary>
    public string headImgUrl = "";
    /// <summary>
    /// 如果没有可以为空串
    /// </summary>
    public string unionId = "";

    /// <summary>
    /// 平台返回的错误码，只有错误的时候才有
    /// </summary>
    public int errCode = 0;
    /// <summary>
    /// 平台返回的错误文本信息，如果没有则为空，只有错误的时候才有
    /// </summary>
    public string errMsg = "";
    /// <summary>
    /// 平台返回的完整json串，只有正确的时候才有
    /// </summary>
    public string result = "";
    /// <summary>
    /// WWW错误文本，WWW请求错误的时候才有
    /// </summary>
    public string error = "";


    public AuthLoginData()
    {

    }

    public AuthLoginData(int code)
    {
        this.code = code;
    }

    public AuthLoginData(int platformType, int code)
    {
        this.platformType = platformType;
        this.code = code;
    }
}

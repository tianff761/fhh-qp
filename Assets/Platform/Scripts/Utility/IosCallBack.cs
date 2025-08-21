using UnityEngine;

public class IosCallBack : MonoBehaviour
{
    /// <summary>
    /// 登录回调
    /// </summary>
    /// <param name="callBackInfo"></param>
    public void WechatLoginCallback(string callBackInfo)
    {

        Debug.LogWarning(">> WechatLoginCallback > " + callBackInfo);
        AuthLoginHelper.AuthLogin(callBackInfo);
    }
}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using LitJson;

public class WeChatApiHelper : ApiHelper
{

    public WeChatApiHelper()
    {
        this.mPlatformType = PlatformType.WECHAT;
    }


    private HttpRequest mTokenRequest = null;
    private HttpRequest mUserInfoRequest = null;

    public override void Request(string appId, string appSecret, string code)
    {
        string url = "https://api.weixin.qq.com/sns/oauth2/access_token";
        string param = "appid=" + appId + "&secret=" + appSecret + "&code="
                + code + "&grant_type=authorization_code";
        url = url + "?" + param;

        if (mTokenRequest != null)
        {
            mTokenRequest.RemoveListener(OnRequestTokenCompleted);
            mTokenRequest.Stop();
        }

        mTokenRequest = new HttpRequest(url);
        mTokenRequest.AddListener(OnRequestTokenCompleted);
        mTokenRequest.Connect();
    }

    /// <summary>
    /// 获取Token返回
    /// </summary>
    /// <param name="data"></param>
    private void OnRequestTokenCompleted(ResponseData data)
    {
        mTokenRequest.RemoveListener(OnRequestTokenCompleted);
        mTokenRequest = null;

        if (data.code != ResponseCode.SUCCESS)
        {
            AuthLoginData authLoginData = new AuthLoginData(data.code);
            authLoginData.error = data.error;
            this.SendData(authLoginData);
            return;
        }

        if (string.IsNullOrEmpty(data.text))
        {
            this.SendData(new AuthLoginData(ResponseCode.FAILED));
            return;
        }

        //{"access_token":"12_SwFAc_ua35rqg3Up5pQQs7-nO-7n6zuoI-GsyKNlAekZHsUj4ziuXJDGpPmIR9RbnGg3j-0xgmiV3Xj4Te3jyOjmwyz_OrLAOTAA8fED4oA","expires_in":7200,"refresh_token":"12_jqt4uZlpqJbpw-xfsaf7kaSqiraPQc9obVc-YB3B5j6THtKrXwfR9MVGwY322IsijEGO5yDkuvwWLuaPMatXYieHNQAPUsZouQlRHAYCXUk","openid":"oQgqH0zz3yG6UvZZoNtud761R0BU","scope":"snsapi_userinfo","unionid":"oIhiV1Z4WF3sroNcZ_5pHr_tFwZI"}
        //{"errcode":40029,"errmsg":"invalid code"}

        try
        {
            JsonData jsonData = JsonMapper.ToObject(data.text);

            if (jsonData.Keys.Contains("access_token"))//正确返回
            {
                string accessToken = jsonData["access_token"].ToString();
                string openId = jsonData["openid"].ToString();

                if (string.IsNullOrEmpty(accessToken) || string.IsNullOrEmpty(openId))
                {
                    Debug.LogError(">> WX > OnRequestTokenCompleted > txt = " + data.text);
                    this.SendData(new AuthLoginData(ResponseCode.FAILED));
                    return;
                }
                RequestUserInfo(accessToken, openId);
            }
            else
            {
                int errCode = int.Parse(jsonData["errcode"].ToString());
                AuthLoginData authLoginData = new AuthLoginData(ResponseCode.FAILED);
                authLoginData.errCode = errCode;//由于错误文本返回的是英文字符串，所以不保存
                this.SendData(authLoginData);
            }
        }
        catch (Exception ex)
        {
            this.SendData(new AuthLoginData(ResponseCode.FAILED));
            Debug.LogError(">> WX > OnRequestTokenCompleted > text = " + data.text);
            Debug.LogException(ex);
        }

    }

    /// <summary>
    /// 请求用户信息
    /// </summary>
    /// <param name="accessToken"></param>
    /// <param name="openId"></param>
    private void RequestUserInfo(string accessToken, string openId)
    {
        string url = "https://api.weixin.qq.com/sns/userinfo";
        string param = "access_token=" + accessToken + "&openid=" + openId;
        url = url + "?" + param;

        if (mUserInfoRequest != null)
        {
            mUserInfoRequest.RemoveListener(OnRequestUserInfoCompleted);
            mUserInfoRequest.Stop();
        }

        mUserInfoRequest = new HttpRequest(url);
        mUserInfoRequest.AddListener(OnRequestUserInfoCompleted);
        mUserInfoRequest.Connect();
    }

    /// <summary>
    /// 用户数据返回
    /// </summary>
    /// <param name="data"></param>
    private void OnRequestUserInfoCompleted(ResponseData data)
    {
        mUserInfoRequest.RemoveListener(OnRequestUserInfoCompleted);
        mUserInfoRequest = null;

        if (data.code != ResponseCode.SUCCESS)
        {
            AuthLoginData authLoginData = new AuthLoginData(data.code);
            authLoginData.error = data.error;
            this.SendData(authLoginData);
            return;
        }

        if (string.IsNullOrEmpty(data.text))
        {
            this.SendData(new AuthLoginData(ResponseCode.FAILED));
            return;
        }

        //{"openid":"oQgqH0zz3yG6UvZZoNtud761R0BU","nickname":"永恒的落叶","sex":1,"language":"zh_CN","city":"Chengdu","province":"Sichuan","country":"CN","headimgurl":"http:\/\/thirdwx.qlogo.cn\/mmopen\/vi_32\/Q0j4TwGTfTIj1DK1uFfOgyCnaxYGrWQY8rvRnjO9sZC54VY2p3efoFtrYv6mqWkLHcFfuYxuLB3XqWpLrfoyug\/132","privilege":[],"unionid":"oIhiV1Z4WF3sroNcZ_5pHr_tFwZI"}
        //{"errcode":40030,"errmsg":"invalid refresh_token"}

        try
        {
            JsonData jsonData = JsonMapper.ToObject(data.text);

            if (jsonData.Keys.Contains("openid"))//正确返回
            {
                string openid = jsonData["openid"].ToString();
                string nickname = jsonData["nickname"].ToString();
                int sex = int.Parse(jsonData["sex"].ToString());
                string headimgurl = jsonData["headimgurl"].ToString();
                string unionid = jsonData["unionid"].ToString();

                if (string.IsNullOrEmpty(openid) || string.IsNullOrEmpty(unionid))
                {
                    Debug.LogError(">> WX > OnRequestUserInfoCompleted > txt = " + data.text);
                    this.SendData(new AuthLoginData(ResponseCode.FAILED));
                    return;
                }

                AuthLoginData authLoginData = new AuthLoginData(ResponseCode.SUCCESS);
                authLoginData.openId = openid;
                authLoginData.nickName = nickname;
                authLoginData.sex = sex == 2 ? 2 : 1;//2为女性，1为男性，把0设置为男性;
                authLoginData.headImgUrl = headimgurl;
                authLoginData.unionId = unionid;
                authLoginData.result = jsonData.ToJson();
                this.SendData(authLoginData);
            }
            else
            {
                int errCode = int.Parse(jsonData["errcode"].ToString());
                AuthLoginData authLoginData = new AuthLoginData(ResponseCode.FAILED);
                authLoginData.errCode = errCode;//由于错误文本返回的是英文字符串，所以不保存
                this.SendData(authLoginData);
            }
        }
        catch (Exception ex)
        {
            this.SendData(new AuthLoginData(ResponseCode.FAILED));
            Debug.LogError(">> WX > OnRequestUserInfoCompleted > text = " + data.text);
            Debug.LogException(ex);
        }

    }

}

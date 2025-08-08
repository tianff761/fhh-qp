using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using LitJson;

public class XianLiaoApiHelper : ApiHelper
{

    public XianLiaoApiHelper()
    {
        this.mPlatformType = PlatformType.XIANLIAO;
    }


    private HttpRequest mTokenRequest = null;
    private HttpRequest mUserInfoRequest = null;

    public override void Request(string appId, string appSecret, string code)
    {
        string url = "https://ssgw.updrips.com/oauth2/accessToken";
        WWWForm form = new WWWForm();
        form.AddField("appid", appId);
        form.AddField("appsecret", appSecret);
        form.AddField("grant_type", "authorization_code");
        form.AddField("code", code);

        if (mTokenRequest != null)
        {
            mTokenRequest.RemoveListener(OnRequestTokenCompleted);
            mTokenRequest.Stop();
        }

        mTokenRequest = new HttpRequest(url, form);
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

        //正确返回
        //{
        //    "err_code":0,
        //    "err_msg":"success",
        //    "data":{
        //        "access_token":"64faea85a83f1504509958efdb48a97b",
        //        "refresh_token":"2e85927c3839e9a87424b44f3fe8edd4",
        //        "expires_in":7200
        //    }
        //}
        //错误返回
        //{
        //    "err_code":12,
        //    "err_msg":"无效的授权码"
        //}

        try
        {
            JsonData jsonData = JsonMapper.ToObject(data.text);

            int errCode = int.Parse(jsonData["err_code"].ToString());
            if (errCode == 0)//返回正确
            {
                JsonData dataJsonData = jsonData["data"];
                string accessToken = dataJsonData["access_token"].ToString();
                if (string.IsNullOrEmpty(accessToken))
                {
                    Debug.LogError(">> XL > OnRequestTokenCompleted > txt = " + data.text);
                    this.SendData(new AuthLoginData(ResponseCode.FAILED));
                    return;
                }
                RequestUserInfo(accessToken);
            }
            else
            {
                string errMsg = jsonData["err_msg"].ToString();
                AuthLoginData authLoginData = new AuthLoginData(ResponseCode.FAILED);
                authLoginData.errCode = errCode;
                authLoginData.errMsg = errMsg;
                this.SendData(authLoginData);
                Debug.LogError(">> XL > OnRequestTokenCompleted > errCode = " + errCode + "，errMsg = " + errMsg);
            }
        }
        catch (Exception ex)
        {
            this.SendData(new AuthLoginData(ResponseCode.FAILED));
            Debug.LogError(">> XL > OnRequestTokenCompleted > text = " + data.text);
            Debug.LogException(ex);
        }

    }

    /// <summary>
    /// 请求用户信息
    /// </summary>
    /// <param name="accessToken"></param>
    /// <param name="openId"></param>
    private void RequestUserInfo(string accessToken)
    {
        string url = "https://ssgw.updrips.com/resource/user/getUserInfo";
        WWWForm form = new WWWForm();
        form.AddField("access_token", accessToken);

        if (mUserInfoRequest != null)
        {
            mUserInfoRequest.RemoveListener(OnRequestUserInfoCompleted);
            mUserInfoRequest.Stop();
        }

        mUserInfoRequest = new HttpRequest(url, form);
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

        //正确返回
        //{
        //    "err_code":0,
        //    "err_msg":"success",
        //    "data":{
        //        "gender":0//0未选择，1男性，2女
        //        "openId":"7VVm7/zBlSf055Ql6P118w==",
        //        "nickName":"xianliao",
        //        "originalAvatar":"http://xianliao.updrips.com/123.jpg",
        //        "smallAvatar":"http://xianliao.updrips.com/456.jpg"
        //}
        //错误返回
        //{
        //    "err_code":15,
        //    "err_msg":"无效的 access_token"
        //}

        try
        {
            JsonData jsonData = JsonMapper.ToObject(data.text);

            int errCode = int.Parse(jsonData["err_code"].ToString());
            if (errCode == 0)//返回正确
            {
                JsonData dataJsonData = jsonData["data"];

                AuthLoginData authLoginData = new AuthLoginData(ResponseCode.SUCCESS);
                authLoginData.openId = "XL_" + dataJsonData["openId"].ToString();
                authLoginData.nickName = dataJsonData["nickName"].ToString();
                authLoginData.sex = int.Parse(dataJsonData["gender"].ToString());
                authLoginData.headImgUrl = dataJsonData["smallAvatar"].ToString();

                authLoginData.sex = authLoginData.sex == 2 ? 2 : 1;//2为女性，1为男性，把0设置为男性

                authLoginData.result = dataJsonData.ToJson();
                this.SendData(authLoginData);
            }
            else
            {
                string errMsg = jsonData["err_msg"].ToString();
                AuthLoginData authLoginData = new AuthLoginData(ResponseCode.FAILED);
                authLoginData.errCode = errCode;
                authLoginData.errMsg = errMsg;
                this.SendData(authLoginData);
                Debug.LogError(">> XL > OnRequestTokenCompleted > errCode = " + errCode + "，errMsg = " + errMsg);
            }
        }
        catch (Exception ex)
        {
            this.SendData(new AuthLoginData(ResponseCode.FAILED));
            Debug.LogError(">> XL > OnRequestUserInfoCompleted > text = " + data.text);
            Debug.LogException(ex);
        }


    }

}

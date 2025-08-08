using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using System.Text;
using UnityEngine;
using Qiniu.Util;
using LitJson;


/// <summary>
/// 七牛上传下载处理
/// </summary>
public class QiniuApi
{
    public static string FORM_MIME_URLENCODED = "application/x-www-form-urlencoded";
    public static string FORM_MIME_OCTECT = "application/octet-stream";
    public static string FORM_MIME_JSON = "application/json";
    public static string FORM_BOUNDARY_TAG = "--";
    public static int COPY_BYTES_BUFFER = 40 * 1024 * 1024; //40 KB

    //================================================================
    public static string AccessKey = "";
    public static string SecretKey = "";
    public static string UploadHost = "";
    public static string Bucket = "";
    /// <summary>
    /// 域名
    /// </summary>
    public static string Host = "";

    /// <summary>
    /// 过期时间删除
    /// </summary>
    public static int DeleteAfterDays = 1;

    /// <summary>
    /// 下载的数据存储
    /// </summary>
    private static string DataPath = "";

    //================================================================

    /// <summary>
    /// 初始化，必须调用，否则会导致部分功能无法使用；其他参数通过变量设置
    /// </summary>
    public static void Init(string dataPath = null)
    {
        DataPath = dataPath;

        if(string.IsNullOrEmpty(DataPath))
        {
            return;
        }

        if(!DataPath.EndsWith("/"))
        {
            DataPath += "/";
        }

        DataPath += "Qiniu/";

        if(!Directory.Exists(DataPath))
        {
            Directory.CreateDirectory(DataPath);
        }
    }

    //================================================================

    /// <summary>
    /// 上传的文件
    /// </summary>
    private static string LocalFilePath = null;
    /// <summary>
    /// 上传的文件key
    /// </summary>
    private static string RemoteKey = null;
    /// <summary>
    /// 上传回调
    /// </summary>
    private static Action<int, string> onUploadCompletedCallback = null;

    /// <summary>
    /// 上传重连总次数
    /// </summary>
    public static int UploadRetryTotal = 3;
    /// <summary>
    /// 上传重连次数
    /// </summary>
    private static int UploadRetryCount = 0;

    /// <summary>
    /// upload请求
    /// </summary>
    private static HttpRequest uploadRequest = null;

    /// <summary>
    /// 上传
    /// </summary>
    public static void Upload(string localFilePath, string remoteKey, Action<int, string> onUploadCompleted)
    {
        LocalFilePath = localFilePath;
        RemoteKey = remoteKey;
        onUploadCompletedCallback = onUploadCompleted;

        UploadRetryCount = 0;
        Upload();
    }

    private static void Upload()
    {
        //生成token
        Mac mac = new Mac(AccessKey, SecretKey);
        PutPolicy putPolicy = new PutPolicy();
        putPolicy.Scope = Bucket;//设置Bucket
        putPolicy.SetExpires(3600);
        putPolicy.DeleteAfterDays = DeleteAfterDays;//设置过期时间
        string token = Auth.createUploadToken(putPolicy, mac);

        //formBoundaryStr生成
        string formBoundaryStr = CreateFormDataBoundary();

        //Header生成
        Dictionary<string, string> header = new Dictionary<string, string>();
        string contentType = string.Format("multipart/form-data; boundary={0}", formBoundaryStr);
        header.Add("Content-Type", contentType);


        //--------write post body--------
        byte[] formBoundaryBytes = Encoding.UTF8.GetBytes(string.Format("{0}{1}\r\n", FORM_BOUNDARY_TAG, formBoundaryStr));
        byte[] formBoundaryEndBytes = Encoding.UTF8.GetBytes(string.Format("\r\n{0}{1}{2}\r\n", FORM_BOUNDARY_TAG, formBoundaryStr, FORM_BOUNDARY_TAG));

        Stream postStream = new MemoryStream();

        //写入key
        postStream.Write(formBoundaryBytes, 0, formBoundaryBytes.Length);
        byte[] formPartTitleData = Encoding.UTF8.GetBytes("Content-Disposition: form-data; name=\"key\"\r\n");
        postStream.Write(formPartTitleData, 0, formPartTitleData.Length);
        byte[] formPartBodyData = Encoding.UTF8.GetBytes(string.Format("\r\n{0}\r\n", RemoteKey));
        postStream.Write(formPartBodyData, 0, formPartBodyData.Length);

        //写入token
        postStream.Write(formBoundaryBytes, 0, formBoundaryBytes.Length);
        formPartTitleData = Encoding.UTF8.GetBytes("Content-Disposition: form-data; name=\"token\"\r\n");
        postStream.Write(formPartTitleData, 0, formPartTitleData.Length);
        formPartBodyData = Encoding.UTF8.GetBytes(string.Format("\r\n{0}\r\n", token));
        postStream.Write(formPartBodyData, 0, formPartBodyData.Length);

        //写入file name
        postStream.Write(formBoundaryBytes, 0, formBoundaryBytes.Length);
        string filename = RemoteKey;
        if(string.IsNullOrEmpty(filename))
        {
            filename = CreateRandomFileName();
        }
        byte[] filePartTitleData = Encoding.UTF8.GetBytes(string.Format("Content-Disposition: form-data; name=\"file\"; filename=\"{0}\"\r\n", filename));
        postStream.Write(filePartTitleData, 0, filePartTitleData.Length);

        //write content type
        string mimeType = FORM_MIME_OCTECT;
        byte[] filePartMimeData = Encoding.UTF8.GetBytes(string.Format("Content-Type: {0}\r\n\r\n", mimeType));
        postStream.Write(filePartMimeData, 0, filePartMimeData.Length);

        //write file data
        try
        {
            FileStream fs = File.Open(LocalFilePath, FileMode.Open, FileAccess.Read);
            WriteHttpRequestBody(fs, postStream);
        }
        catch(Exception fex)
        {
            Debug.LogException(fex);
        }

        //写入结束
        postStream.Write(formBoundaryEndBytes, 0, formBoundaryEndBytes.Length);

        //生成byte[]
        byte[] bytes = new byte[postStream.Length];
        postStream.Seek(0, SeekOrigin.Begin);
        postStream.Read(bytes, 0, bytes.Length);

        postStream.Close();
        postStream.Dispose();

        //----------------------------------------------------------------

        if(uploadRequest != null)
        {
            uploadRequest.Stop();
            uploadRequest = null;
        }
        uploadRequest = new HttpRequest(UploadHost, bytes, header);
        uploadRequest.AddListener(OnUploadRequestCompleted);
        uploadRequest.Connect();
    }

    /// <summary>
    /// Http处理完成回调
    /// </summary>
    private static void OnUploadRequestCompleted(ResponseData response)
    {
        uploadRequest.RemoveListener(OnUploadRequestCompleted);
        uploadRequest = null;

        if(!string.IsNullOrEmpty(response.error))
        {
            Debug.Log(">> QiniuUpload > response.error = " + response.error);
        }
        else if(!string.IsNullOrEmpty(response.text))
        {
            Debug.Log(">> QiniuUpload > response.text = " + response.text);
            try
            {
                //{"hash":"FhVRS6TZ6_gMyQBBVdb-pN4HE_g8","key":"local_1431303.amr"}
                JsonData jsonData = JsonMapper.ToObject(response.text);
                if(jsonData["key"] != null)
                {
                    UploadCallback(QiniuCode.Success, jsonData["key"].ToString());
                    return;
                }
            }
            catch(Exception ex)
            {
                Debug.LogException(ex);
            }
        }
        //失败，

        if(UploadRetryCount < UploadRetryTotal)//不进行重试
        {
            Debug.Log(">> QiniuUpload > Retry Count = " + UploadRetryCount);
            Upload();
        }
        else
        {
            UploadCallback(QiniuCode.Failed);
        }
        UploadRetryCount++;
    }

    private static void UploadCallback(int code, string key = "")
    {
        if(onUploadCompletedCallback != null)
        {
            onUploadCompletedCallback.Invoke(code, key);
        }
    }

    private static void WriteHttpRequestBody(Stream fromStream, Stream toStream)
    {
        byte[] buffer = new byte[COPY_BYTES_BUFFER];
        int count = -1;
        using(fromStream)
        {
            while((count = fromStream.Read(buffer, 0, buffer.Length)) != 0)
            {
                toStream.Write(buffer, 0, count);
            }
        }
    }

    private static string CreateFormDataBoundary()
    {
        string now = DateTime.Now.ToLongTimeString();
        return string.Format("-------QiniuCSharpSDKBoundary{0}", Qiniu.Util.StringUtils.md5Hash(now));
    }

    private static string CreateRandomFileName()
    {
        string now = DateTime.Now.ToLongTimeString();
        return string.Format("randomfile{0}", Qiniu.Util.StringUtils.urlSafeBase64Encode(now));
    }

    //================================================================
    /// <summary>
    /// 下载回调
    /// </summary>
    private static Action<int, string> onDownloadCompletedCallback = null;
    /// <summary>
    /// download请求
    /// </summary>
    private static HttpRequest downloadRequest = null;
    /// <summary>
    /// 下载重连总次数
    /// </summary>
    public static int DownloadRetryTotal = 3;
    /// <summary>
    /// 下载重连次数
    /// </summary>
    private static int DownloadRetryCount = 0;
    /// <summary>
    /// 下载的完整URL
    /// </summary>
    private static string DownloadUrl = "";
    /// <summary>
    /// 下载到本地的文件路径
    /// </summary>
    private static string DownloadLoaclPath = "";

    /// <summary>
    /// 下载
    /// </summary>
    public static void Download(string remoteKey, Action<int, string> onDownloadCompleted)
    {
        if(string.IsNullOrEmpty(DataPath))
        {
            Debug.LogWarning(">> QiniuUpload > DataPath is Empty.");
            return;
        }

        DownloadUrl = Host + remoteKey;
        DownloadLoaclPath = DataPath + remoteKey;
        onDownloadCompletedCallback = onDownloadCompleted;

        DownloadRetryCount = 0;
        Download();
    }

    /// <summary>
    /// 根据key获取下载的路径
    /// </summary>
    public static string GetDownloadLoaclPath(string remoteKey)
    {
        return DataPath + remoteKey;
    }

    private static void Download()
    {
        if(downloadRequest != null)
        {
            downloadRequest.Stop();
            downloadRequest = null;
        }
        downloadRequest = new HttpRequest(DownloadUrl);
        downloadRequest.AddListener(OnDownloadRequestCompleted);
        downloadRequest.Connect();
    }

    /// <summary>
    /// Http处理完成回调
    /// </summary>
    private static void OnDownloadRequestCompleted(ResponseData response)
    {
        downloadRequest.RemoveListener(OnDownloadRequestCompleted);
        downloadRequest = null;

        Debug.Log(">> QiniuDown > DownloadLoaclPath = " + DownloadLoaclPath);
        Debug.Log(">> QiniuDown >  response.bytes = " + (response.bytes == null));

        if (!string.IsNullOrEmpty(response.error))
        {
            Debug.Log(">> QiniuDown > response.error = " + response.error);
        }
        else if(response.bytes != null)
        {
            try
            {
                Debug.Log(">> QiniuDown > response.bytes = " + response.bytes.Length);
               
                FileStream fs = new FileStream(DownloadLoaclPath, FileMode.OpenOrCreate, FileAccess.Write);
                //开始写入
                fs.Write(response.bytes, 0, response.bytes.Length);
                //清空缓冲区、关闭流
                fs.Flush();
                fs.Close();
                DownloadCallback(QiniuCode.Success, DownloadLoaclPath);
                return;
            }
            catch(Exception ex)
            {
                Debug.LogException(ex);
            }
        }
        //失败
        if(DownloadRetryCount < DownloadRetryTotal)//不进行重试
        {
            Debug.Log(">> QiniuDown > Retry Count = " + DownloadRetryCount);
            Download();
        }
        else
        {
            DownloadCallback(QiniuCode.Failed);
        }
        DownloadRetryCount++;
    }

    private static void DownloadCallback(int code, string key = "")
    {
        if(onDownloadCompletedCallback != null)
        {
            onDownloadCompletedCallback.Invoke(code, key);
        }
    }

    public static void StopDownload()
    {
        if(downloadRequest != null)
        {
            downloadRequest.Stop();
            downloadRequest = null;
        }
    }

}

using LuaFramework;
using System;
using System.Collections;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using UnityEngine;
using UnityEngine.Events;

class DealGroup
{
    public string bucketDir = "";
    public string bucketFile = "";
    public string uploadFile = "";
    public int status = 0;
    public UnityAction<int, string> resultAction;

    public DealGroup(string bucketDir, string bucketFile, string uploadFile, UnityAction<int, string> resultAction)
    {
        this.bucketDir = bucketDir;
        this.bucketFile = bucketFile;
        this.uploadFile = uploadFile;
        this.resultAction = resultAction;
    }
}

public class TencentBucketApi : MonoBehaviour
{
    static string tecentBucketName = ""; //存储桶，格式：BucketName-APPID
    static string tecentRegion = ""; //设置一个默认的存储桶地域
    static string tecentSecretId = ""; //"云 API 密钥 SecretId";
    static string tecentSecretKey = ""; //"云 API 密钥 SecretKey";
    //static ConcurrentBag<DealGroup> downloadDealGroup = new ConcurrentBag<DealGroup>();
    //static ConcurrentBag<DealGroup> uploadDealGroup = new ConcurrentBag<DealGroup>();

    static string url = "";

    static Coroutine coroutine = null;

    public static void InitTecentBucket(string region, string secretId, string secretKey, string bucket)
    {
        tecentRegion = region;
        tecentSecretId = secretId;
        tecentSecretKey = secretKey;
        tecentBucketName = bucket;
        url = "http://" + tecentBucketName + ".cos." + tecentRegion + ".myqcloud.com";

        coroutine = CoroutineManager.Instance.StartCoroutine(CoDealGroup());
    }

    public static void UninitTecentBucket()
    {
        if (coroutine != null)
        {
            CoroutineManager.Instance.StopCoroutine(coroutine);
        }
        coroutine = null;
        tecentRegion = "";
        tecentSecretId = "";
        tecentSecretKey = "";
        tecentBucketName = "";
        url = "";
    }

    #region 获取签名处理
    static string GetAuthentication(string strModel, string pathname, string qheaderlist = "", string qurlparamlist = "")
    {

        strModel = strModel.ToLower();
        if (pathname.IndexOf("/") != 0)
        {
            pathname = "/" + pathname;
        }
        var singtime = "";

        var now = GetTime() / 1000;

        var exp = GetTime() / 1000 + 15 * 60;

        singtime = (int)now + ";" + (int)exp;

        string s1 = HmacSha1Sign(singtime, tecentSecretKey);

        string s2 = strModel + "\n" + pathname + "\n" + qurlparamlist + "\n" + qheaderlist + "\n";

        string t1 = "";
        t1 = EncryptToSHA1(s2);

        string s3 = "sha1\n" + singtime + "\n" + t1 + "\n";
        string s4 = HmacSha1Sign(s3, s1);
        var authorization = "q-sign-algorithm=sha1&q-ak=" + tecentSecretId + "&q-sign-time=" + singtime + "&q-key-time=" + singtime + "&q-header-list=" + qheaderlist + "&q-url-param-list=" + qurlparamlist + "&q-signature=" + s4;
        return authorization;
    }

    static string EncryptToSHA1(string str)
    {
        var buffer = Encoding.UTF8.GetBytes(str);
        var data = SHA1.Create().ComputeHash(buffer);

        var sb = new StringBuilder();
        foreach (var t in data)
        {
            sb.Append(t.ToString("X2"));
        }

        return sb.ToString().ToLower();
    }

    static double GetTime()
    {
        TimeSpan ts = new TimeSpan(DateTime.UtcNow.Ticks - new DateTime(1970, 1, 1, 0, 0, 0).Ticks);
        return (long)ts.TotalMilliseconds;
    }

    public static string HmacSha1Sign(string EncryptText, string EncryptKey)
    {
        HMACSHA1 myHMACSHA1 = new HMACSHA1(Encoding.Default.GetBytes(EncryptKey));
        byte[] RstRes = myHMACSHA1.ComputeHash(Encoding.Default.GetBytes(EncryptText));
        StringBuilder EnText = new StringBuilder();
        foreach (byte Byte in RstRes)
        {
            EnText.AppendFormat("{0:x2}", Byte);
        }
        return EnText.ToString();
    }
    #endregion

    //bucketDir:示例 /test/
    public static void UploadFile(string bucketDir, string bucketFile, string uploadFile, UnityAction<int, string> resultAction)
    {
        Thread thread = new Thread(delegate ()
        {
            DealGroup dealGroup = new DealGroup(bucketDir, bucketFile, uploadFile, resultAction);
            dealGroup.status = 0;

            bucketFile = bucketDir + bucketFile;
            string sign = GetAuthentication("put", bucketFile, "", "");
            string inUrl = url + bucketFile + "?sign=" + sign;
            string inFilePath = uploadFile;
            try
            {
                // 创建WebClient实例
                WebClient myWebClient = new WebClient();
                myWebClient.Headers.Add("Authorization", sign);
                //访问权限设置　　　　　　
                myWebClient.Credentials = CredentialCache.DefaultCredentials;

                // 要上传的文件
                FileStream fs = new FileStream(inFilePath, FileMode.Open, FileAccess.Read);
                BinaryReader br = new BinaryReader(fs);

                byte[] postArray = br.ReadBytes((int)fs.Length);
                Stream postStream = myWebClient.OpenWrite(inUrl, "PUT");
                if (postStream.CanWrite)
                {
                    postStream.Write(postArray, 0, postArray.Length);
                    //uploadDealGroup.Add(dealGroup);
                }
                else
                {
                    dealGroup.status = -1;
                    //uploadDealGroup.Add(dealGroup);
                }
                postStream.Close();
            }
            catch (WebException errMsg)
            {
                dealGroup.status = (int)errMsg.Status;
                //uploadDealGroup.Add(dealGroup);
            }
            catch (Exception)
            {
                dealGroup.status = -2;
                //uploadDealGroup.Add(dealGroup);
            }
        });
        thread.Start();
    }

    static int tempIdx = 0;
    //同时下载个数最好小于5，越多越卡
    //bucketDir:示例 /test/
    public static void DownloadFile(string bucketDir, string bucketFile, string downloadDir, string downloadFileName, UnityAction<int, string> resultAction)
    {
        Thread thread = new Thread(delegate ()
        {
            tempIdx++;
            if (tempIdx > 10000000)
            {
                tempIdx = 0;
            }
            DealGroup dealGroup = new DealGroup(bucketDir, bucketFile, downloadDir, resultAction);
            dealGroup.status = 0;
            string remoteFile = bucketDir + @"/" + bucketFile;
            string downloadFile = downloadDir + @"/" + downloadFileName;
            // string tempPath = Path.GetDirectoryName(downloadFile) + @"\temp" + tempIdx;
            try
            {
                Util.Log("DownloadFile1:" + downloadDir + "  " + downloadFileName);
                if (!Directory.Exists(downloadDir))
                {
                    Directory.CreateDirectory(downloadDir);  //创建临时文件目录
                }
                Util.Log("DownloadFile2:" + downloadDir + "  " + downloadFileName);
                if (File.Exists(downloadFile))
                {
                    File.Delete(downloadFile);    //存在则删除
                }
                Util.Log("DownloadFile3:" + downloadDir + "  " + downloadFileName);

                FileStream fs = new FileStream(downloadFile, FileMode.Append, FileAccess.Write, FileShare.ReadWrite);
                HttpWebRequest request = WebRequest.Create(url + remoteFile) as HttpWebRequest;
                request.Method = "get";
                var sign = GetAuthentication("get", remoteFile, "", "");
                request.Headers.Add("Authorization", sign);
                //发送请求并获取相应回应数据
                HttpWebResponse response = request.GetResponse() as HttpWebResponse;
                //直到request.GetResponse()程序才开始向目标网页发送Post请求
                Stream responseStream = response.GetResponseStream();
                //创建本地文件写入流
                byte[] bArr = new byte[1024];
                int size = responseStream.Read(bArr, 0, (int)bArr.Length);
                Util.Log("DownloadFile4:" + downloadDir + "  " + downloadFileName);
                while (size > 0)
                {
                    //stream.Write(bArr, 0, size);
                    fs.Write(bArr, 0, size);
                    size = responseStream.Read(bArr, 0, (int)bArr.Length);
                }
                Util.Log("DownloadFile5:" + downloadDir + "  " + downloadFileName);
                fs.Close();
                responseStream.Close();

                //downloadDealGroup.Add(dealGroup);
                Util.Log("DownloadFile6:" + downloadDir + "  " + downloadFileName);
            }
            catch (Exception ex)
            {
                dealGroup.status = -1;
                Debug.LogError(ex.Message);
                //downloadDealGroup.Add(dealGroup);
            }
        });
        thread.Start();
    }

    static IEnumerator CoDealGroup()
    {
        var wait = new WaitForSeconds(0.1f);
        yield return null;
        //while (coroutine != null)
        //{
        //    DealGroup group = null;
        //    while (downloadDealGroup.TryTake(out group))
        //    {
        //        if (group.resultAction != null)
        //        {
        //            group.resultAction(group.status, group.bucketFile);
        //        }
        //    }
        //    while (uploadDealGroup.TryTake(out group))
        //    {
        //        if (group.resultAction != null)
        //        {
        //            group.resultAction(group.status, group.bucketFile);
        //        }
        //    }
        //    yield return wait;
        //}
    }
}

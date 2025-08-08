
public class UpgradeStatus
{
    /// <summary>
    /// 无状态
    /// </summary>
    public const int NONE = 0;
    /// <summary>
    /// 开始
    /// </summary>
    public const int BEGIN = 1;
    /// <summary>
    /// 检测版本号
    /// </summary>
    public const int CHECK = 2;
    /// <summary>
    /// 拷贝StreamingAssets文件
    /// </summary>
    public const int COPY = 3;
    /// <summary>
    /// 下载，网络下载
    /// </summary>
    public const int DOWNLOAD = 4;
    /// <summary>
    /// 更新完成
    /// </summary>
    public const int FINISHED = 5;
    /// <summary>
    /// 更新停止
    /// </summary>
    public const int STOP = 6;


    /// <summary>
    /// 内部静态文本
    /// </summary>
    public const string TIPS_TXT_BEGIN = "初始化";
    /// <summary>
    /// 内部静态文本
    /// </summary>
    public const string TIPS_TXT_CHECK = "初始化";
    /// <summary>
    /// 内部静态文本
    /// </summary>
    public const string TIPS_TXT_COPY = "解压中";
    /// <summary>
    /// 内部静态文本
    /// </summary>
    public const string TIPS_TXT_DOWNLOAD = "更新中";

    /// <summary>
    /// 开始文本，外部设置
    /// </summary>
    public static string BeginTipsTxt = TIPS_TXT_BEGIN;
    /// <summary>
    /// 检测文本，外部设置
    /// </summary>
    public static string CheckTipsTxt = TIPS_TXT_CHECK;
    /// <summary>
    /// 拷贝文本，外部设置
    /// </summary>
    public static string CopyTipsTxt = TIPS_TXT_COPY;
    /// <summary>
    /// 更新文本，外部设置
    /// </summary>
    public static string DownloadTipsTxt = TIPS_TXT_DOWNLOAD;

    /// <summary>
    /// 文本还原
    /// </summary>
    public static void Reset()
    {
        BeginTipsTxt = TIPS_TXT_BEGIN;
        CheckTipsTxt = TIPS_TXT_CHECK;
        CopyTipsTxt = TIPS_TXT_COPY;
        DownloadTipsTxt = TIPS_TXT_DOWNLOAD;
    }

    /// <summary>
    /// 设置提示文本
    /// </summary>
    public static void SetTips(string beginTipsTxt, string checkTipsTxt, string copyTipsTxt, string downloadTipsTxt)
    {
        BeginTipsTxt = CheckStringNull(beginTipsTxt);
        CheckTipsTxt = CheckStringNull(checkTipsTxt);
        CopyTipsTxt = CheckStringNull(copyTipsTxt);
        DownloadTipsTxt = CheckStringNull(downloadTipsTxt);
    }

    private static string CheckStringNull(string str)
    {
        if(str == null)
        {
            return "";
        }
        return str;
    }
}

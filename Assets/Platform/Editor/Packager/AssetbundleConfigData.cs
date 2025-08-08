using System.IO;
using System.Collections.Generic;
using LuaFramework;
using UnityEngine;

/// <summary>
/// 打包资源的配置
/// </summary>
public class AssetbundleConfigData
{
    public string bundleName = null;
    public string folderName = null;
    /// <summary>
    /// 文件的查找后缀字符串
    /// </summary>
    public string ext = null;
    /// <summary>
    /// 文件查找的深度类型
    /// </summary>
    public SearchOption option = SearchOption.TopDirectoryOnly;

    /// <summary>
    /// 单独的文件，路径是相对于Assets文件夹的路径
    /// </summary>
    public List<string> fileList = new List<string>();

    /// <summary>
    /// bundleName：完整的包名，带后缀的；folderName：文件夹名称，不带Assets；ext：文件后缀，如果有多种文件可以配置多个（*.*为全部文件）；option为查找文件深度
    /// </summary>
    public AssetbundleConfigData(string bundleName, string folderName, string ext, SearchOption option)
    {
        this.bundleName = bundleName;
        this.folderName = folderName;
        this.ext = ext;
        this.option = option;
    }

    public AssetbundleConfigData(string bundleName, string singleFile)
    {
        this.bundleName = bundleName;
        this.fileList.Add(singleFile);
    }

    public AssetbundleConfigData(string bundleName, List<string> fileList)
    {
        this.bundleName = bundleName;
        this.fileList.AddRange(fileList);
    }

    /// <summary>
    /// 新建配置，folderName不带Assets
    /// </summary>
    public static AssetbundleConfigData New(string bundleName, string folderName, string ext, SearchOption option = SearchOption.TopDirectoryOnly)
    {
        return new AssetbundleConfigData(bundleName + AppConst.AssetExtName, folderName, ext, option);
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="bundleName"></param>
    /// <param name="singleFile">需要是带Assets文件夹路径的</param>
    /// <returns></returns>
    public static AssetbundleConfigData New(string bundleName, string singleFile)
    {
        return new AssetbundleConfigData(bundleName + AppConst.AssetExtName, singleFile);
    }

    /// <summary>
    /// 获取文件夹下的文件单独打包，folderPath不带Assets
    /// </summary>
    public static List<AssetbundleConfigData> GetConfigsBySingleFile(string abNamePrefix, string folderPath, SearchOption option = SearchOption.TopDirectoryOnly)
    {
        folderPath = FileUtils.CheckDirectoryFormat(folderPath);
        DirectoryInfo directoryInfo = new DirectoryInfo(Packager.GetAssetsPath() + folderPath);
        string newFolderPath = FileUtils.CheckDirectoryFormat(directoryInfo.FullName);
        //最终文件需要带Assets文件夹
        string folderPrefix = newFolderPath.Replace(folderPath, "").Replace("Assets/", "");

        List<AssetbundleConfigData> list = new List<AssetbundleConfigData>();

        FileInfo[] files = directoryInfo.GetFiles("*.*", option);
        FileInfo fileInfo = null;
        string abName = null;
        string tempName = null;
        for (int i = 0; i < files.Length; i++)
        {
            fileInfo = files[i];
            if (!fileInfo.FullName.EndsWith(".meta"))
            {
                abName = abNamePrefix + "/" + Path.GetFileNameWithoutExtension(fileInfo.Name.ToLower());
                tempName = fileInfo.FullName.Replace("\\", "/");
                tempName = tempName.Replace(folderPrefix, "");
                list.Add(New(abName, tempName));
            }
        }
        return list;
    }

    /// <summary>
    /// 获取文件夹下的文件使用文件父文件夹名称打包，folderPath不带Assets
    /// </summary>
    public static List<AssetbundleConfigData> GetConfigsBySingleFolder(string abNamePrefix, string folderPath, SearchOption option = SearchOption.TopDirectoryOnly)
    {
        folderPath = FileUtils.CheckDirectoryFormat(folderPath);
        DirectoryInfo directoryInfo = new DirectoryInfo(Packager.GetAssetsPath() + folderPath);
        string newFolderPath = FileUtils.CheckDirectoryFormat(directoryInfo.FullName);
        string folderPrefix = newFolderPath.Replace(folderPath, "").Replace("Assets/", "");

        List<AssetbundleConfigData> list = new List<AssetbundleConfigData>();

        FileInfo[] files = directoryInfo.GetFiles("*.*", option);
        FileInfo fileInfo = null;
        string abName = null;
        string tempName = null;
        for (int i = 0; i < files.Length; i++)
        {
            fileInfo = files[i];
            if (!fileInfo.FullName.EndsWith(".meta"))
            {
                abName = abNamePrefix + "/" + fileInfo.Directory.Name.ToLower();
                tempName = fileInfo.FullName.Replace("\\", "/");
                list.Add(New(abName, tempName.Replace(folderPrefix, "")));
            }
        }
        return list;
    }

    /// <summary>
    /// 获取文件夹下的所有文件使用当前文件夹名称打包，folderPath不带Assets
    /// </summary>
    public static List<AssetbundleConfigData> GetConfigsByFolder(string abNamePrefix, string folderPath, SearchOption option = SearchOption.TopDirectoryOnly)
    {
        folderPath = FileUtils.CheckDirectoryFormat(folderPath);
        DirectoryInfo directoryInfo = new DirectoryInfo(Packager.GetAssetsPath() + folderPath);
        string newFolderPath = FileUtils.CheckDirectoryFormat(directoryInfo.FullName);
        string folderPrefix = newFolderPath.Replace(folderPath, "").Replace("Assets/", "");

        List<AssetbundleConfigData> list = new List<AssetbundleConfigData>();

        FileInfo[] files = directoryInfo.GetFiles("*.*", option);
        FileInfo fileInfo = null;
        string tempName = null;
        string abName = abNamePrefix + "/" + directoryInfo.Name.ToLower();
        for (int i = 0; i < files.Length; i++)
        {
            fileInfo = files[i];
            if (!fileInfo.FullName.EndsWith(".meta"))
            {
                tempName = fileInfo.FullName.Replace("\\", "/");
                list.Add(New(abName, tempName.Replace(folderPrefix, "")));
            }
        }
        return list;
    }

}
